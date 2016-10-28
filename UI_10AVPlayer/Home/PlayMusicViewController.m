//
//  PlayMusicViewController.m
//  UI_10AVPlayer
//
//  Created by 黄明远 on 16/10/20.
//  Copyright © 2016年 郑小燕. All rights reserved.
//

#import "PlayMusicViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>//后台播放
#import "PlayMusicViewController+methods.h"


@interface PlayMusicViewController ()
@property(nonatomic,strong)AVPlayer *player;
@property (nonatomic,strong)UILabel *titleLabel;/**<歌名>*/
@property(nonatomic,strong) UILabel *singerLabel;/**<歌手>*/
@property(nonatomic,strong) UISlider *progressSlider;/**<进度滑块>*/
@property(nonatomic,strong) UILabel *minLabel;/**<播放的当前时间>*/
@property (nonatomic,strong) UILabel *maxLabel;/**<总时间>*/

@end
static PlayMusicViewController *audioVC;
@implementation PlayMusicViewController{
    UIButton *playButton;/**<播放按钮>*/
    
    UIButton *preButton;/**<上一首>*/
    UIButton *nextButton;/**<下一首>*/
    
    UIButton *recycleButton;/**<单曲循环>*/
    
    UIButton *uploadButton;/**<下载>*/
    
    AVPlayerItem *playerItem;
    id playTimeObserver;/**<播放进度观察者>*/
    NSArray *modelArray;/**<歌曲数组>*/
    NSArray *randomArray;/**<随机数组>*/
    NSInteger _index;/**<播放标记>*/
    BOOL isPlaying;/**<播放状态>*/
    BOOL isRemoveNot;/**<是否移除通知>*/
    AudioPlayerMode playerMode;//播放模式
    MusicModel *playingModel;//正在播放的model
    CGFloat totalTime;/**<总时间>*/
    

}



+ (instancetype)playMusicViewControllerSharedInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioVC = [[PlayMusicViewController alloc]init];
        audioVC.view.backgroundColor = [UIColor whiteColor];
        audioVC.player = [[AVPlayer alloc]init];
        //后台播放
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        
    });
    return audioVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    [self makeContent];
    [self createViews];
    

}
- (void)viewWillLayoutSubviews{
   [self setRotationViewFrame];
}

- (void)initWithArray:(NSArray *)array index:(NSInteger)index{
    _index = index;
    modelArray = array;
    randomArray = nil;
    [self updateAudioPlayer];
}

- (void)updateAudioPlayer{
    if (isRemoveNot) {
        //如果已经存在 移除通知 ,KVO,个控件设初始值
        [self removeObserverAndNotification];
        [self initialControls];
        isRemoveNot = NO;
    }
    
    MusicModel *model;
    //判断是不是随机播放
    if (playerMode  == AudioPlayerModeRandomPlay) {
        //如果是随机播放,判断随机数组是否有值
        if (randomArray.count == 0) {
            model = [modelArray objectAtIndex:_index];
            //如果随机数组没有值,播放当前音乐并给随机数组赋值
            randomArray = [modelArray sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2) {
                return arc4random() % modelArray.count;
                
            }];
        }else{
        //如果随机数组有值,从随机数组取值
            model = [randomArray objectAtIndex:_index];
        }
    }else{
        model = [modelArray objectAtIndex:_index];
    
    }
    playingModel = model;
    
    [self updateUIDataWith:model];
    playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:model.fileName]];
    NSLog(@"URL = %@",[NSURL URLWithString:model.fileName]);
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];//监听status属性
    [self monitoringPlayback:playerItem];// 监听播放状态
    [self addEndTimeNotification];
    isRemoveNot = YES;

    

}
#pragma mark - KVO -status
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    AVPlayerItem *item = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            CMTime duration = item.duration;//获取视频总长度
            [self setMaxDuration:CMTimeGetSeconds(duration)];
            [self play];
        }else if ([playerItem status] == AVPlayerStatusFailed){
            NSLog(@"AVPlayerStatusFailed");
//            NSLog(@"")
            [self stop];
        }
    }

}

- (void)setMaxDuration:(float)duration{
    totalTime = duration;
    self.progressSlider.maximumValue = duration;
    self.maxLabel.text = [NSString convertTime:duration];
}
#pragma mark - 添加播放完后的监听方法
-(void)addEndTimeNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成");
    if (playerMode == AudioPlayerModeSinglePlay) {
        playerItem = [notification object];
        [playerItem seekToTime:kCMTimeZero];
        [self.player play];
    }else{
        [self nextIndexAdd];
        [self updateAudioPlayer];
    }
    

}


#pragma mark - 重新赋值
-(void)updateUIDataWith:(MusicModel *)model{
    self.titleLabel.text = model.name;
    self.singerLabel.text = model.singer;
    [self setImageWith:model];
}
#pragma mark - 移除通知
- (void)removeObserverAndNotification{
    [self.player replaceCurrentItemWithPlayerItem:nil];
    [playerItem removeObserver:self forKeyPath:@"status"];
    [self.player removeTimeObserver:playTimeObserver];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    

}
#pragma mark - 初始化控件
- (void)initialControls{
    [self stop];
    self.minLabel.text = @"00:00";
    self.progressSlider.value = 0.0f;
    [self.rotationView removeAnimation];

}
#pragma mark - 监听播放状态
- (void)monitoringPlayback:(AVPlayerItem *)item {
    WS(ws);
    //这里设置每秒执行30次
    /**
     *CMTime(1,30)1表示当前第几帧,30表示帧率,每秒钟多少帧
     *表示一个每秒钟30帧的视频,播放了1帧,也就是在1/30秒钟的地方
     */
    playTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
       //计算当前在第几秒
        float currentPlayTime = (double)item.currentTime.value / item.currentTime.timescale;
        [ws updateVideoSlider:currentPlayTime];
        
    }];
    

}
-(void)updateVideoSlider:(float)currentTime{
    [self setLockViewWith:playingModel currentTime:currentTime];
    self.progressSlider.value = currentTime;
    
    self.minLabel.text = [NSString convertTime:currentTime];
}
#pragma mark - 锁屏界面
- (void)setLockViewWith:(MusicModel*)model currentTime:(CGFloat)currentTime{
    NSMutableDictionary *musicInfo = [NSMutableDictionary dictionary];
    //设置Singer
    [musicInfo setObject:model.singer forKey:MPMediaItemPropertyArtist];
    //设置歌曲名
    [musicInfo setObject:model.name forKey:MPMediaItemPropertyTitle];
    MPMediaItemArtwork *artwork;
    artwork = [[MPMediaItemArtwork alloc]initWithImage:self.rotationView.imageView.image];
    /**
     *MPNowPlayingInfoPropertyElapsedPlaybackTime 表示已经播放的时间,用这个属性可以让MPNowPlayingInfoCenter显示播放进度;
     *MPNowPlayingInfoPropertyPlaybackRate 表示播放速率.通常情况下播放速率为1.0,即真是时间的1秒对应播放时间中的1秒;
     *NowPlaying Center 中的进度刷新并不是由app不停的更新nowPlayingInfo来做的,而是根据app传入的ElapsedPlaybackTime和PlaybackRate进行自动刷新.例如传入ElapsedPlaybackTime和playbackRate进行自动刷新.例如传入ElapsedPlaybackTime = 120s,PlaybackRate = 1.0,那么NowPlayingInfoCenter会显示2:00并且在接下来的时间中每一秒把进度加1秒并刷新显示.如果需要暂停进度,传入PalybackRate = 0.0即可.
     *所以每次播放暂停和继续都需要更新NowPlayingCenter并正确设置ElapsedPlaybackTime和PlaybackRate否则NowPlayingCenter中的播放进度没法正常显示
     *NowPlayingCenter的刷新时机
     频繁的刷新NowPlayingCenter并不可取，特别是在有Artwork的情况下。所以需要在合适的时候进行刷新。
     
     依照我自己的经验下面几个情况下刷新NowPlayingCenter比较合适：
     
     当前播放歌曲进度被拖动时
     当前播放的歌曲变化时
     播放暂停或者恢复时
     当前播放歌曲的信息发生变化时（例如Artwork，duration等）
     在刷新时可以适当的通过判断app是否active来决定是否必须刷新以减少刷新次数。
     
     *MPMediaItemPropertyArtwork
     
     这是一个非常有用的属性，我们可以利用歌曲的封面图来合成一些图片借此达到美化锁屏界面或者显示锁屏歌词。
     *RemoteControl
     
     RemoteComtrol可以用来在不打开app的情况下控制app中的多媒体播放行为，涉及的内容主要包括：
     
     锁屏界面双击Home键后出现的播放操作区域
     iOS7之后控制中心的播放操作区域
     iOS7之前双击home键后出现的进程中向左滑动出现的播放操作区域
     AppleTV，AirPlay中显示的播放操作区域
     耳机线控
     车载系统的设置
     MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
     [commandCenter.playCommand addTargetUsingBlock:^(MPRemoteCommandEvent *event) {
     // Begin playing the current track.
     [[MyPlayer sharedPlayer] play];
     }

     
     */
    //音乐剩余时长
    
    [musicInfo setObject:[NSNumber numberWithDouble:totalTime] forKey:MPMediaItemPropertyPlaybackDuration];
    [musicInfo setObject:[NSNumber numberWithFloat:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    //音乐当前播放时间
    [musicInfo setObject:[NSNumber numberWithDouble:currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [[MPNowPlayingInfoCenter defaultCenter]setNowPlayingInfo:musicInfo];

}

#pragma mark - 布局
- (void)makeContent{
    
    self.backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"音乐_播放器_默认模糊背景"]];
    [self.view addSubview:self.backgroundImageView];
    self.backgroundImageView.sd_layout.topSpaceToView(self.view,0)
    .leftSpaceToView(self.view,0)
    .rightSpaceToView(self.view,0)
    .heightIs(kScreenHeight);
    self.backgroundImageView.userInteractionEnabled = YES;
    
    
    UIButton *bacdButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backgroundImageView addSubview:bacdButton];
//    [bacdButton setTitle:@"播放" forState:UIControlStateNormal];
    [bacdButton setBackgroundImage:[UIImage imageNamed:@"MusicPlayer_后退"] forState:UIControlStateNormal];
    bacdButton .sd_layout
    .topSpaceToView(self.backgroundImageView,30)
    .leftSpaceToView(self.backgroundImageView,20)
    .widthIs(22)
    .heightIs(22);
    bacdButton.tag = 1001;
    [bacdButton  addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = @"Title";
    [self.backgroundImageView addSubview:self.titleLabel];
    self.titleLabel.sd_layout
    .centerYEqualToView(bacdButton)
    .centerXEqualToView(self.backgroundImageView)
    .heightIs(30)
    .widthIs(300);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:19];
    
    //更多详情
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backgroundImageView addSubview:moreButton];
    [moreButton setTitle:@"---" forState:UIControlStateNormal];
//    [moreButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    moreButton.tag = 1002;
    [self.view addSubview:moreButton];
    moreButton.sd_layout
    .topEqualToView(bacdButton)
    .rightSpaceToView(self.backgroundImageView,20)
    .widthIs(20)
    .heightIs(20);
    
    
    self.singerLabel = [[UILabel alloc]init];
    [self.backgroundImageView addSubview:self.singerLabel];
    self.singerLabel.textColor = [UIColor whiteColor];
    self.singerLabel.textAlignment = NSTextAlignmentCenter;
    self.singerLabel.text = @"--Single--";
    self.singerLabel.sd_layout
    .topSpaceToView(self.titleLabel,10)
    .centerXEqualToView(self.backgroundImageView)
    .heightIs(30)
    .widthIs(kScreenWidth - 32);
    
    
    
    self.progressSlider = [UISlider new];
    self.progressSlider.minimumValue = 0.f;
    [self.backgroundImageView addSubview:self.progressSlider];
    self.progressSlider.sd_layout
    .bottomSpaceToView(self.backgroundImageView,100)
    .centerXEqualToView(self.backgroundImageView)
    .widthIs(250)
    .heightIs(10);
    self.progressSlider.minimumTrackTintColor = [UIColor orangeColor];
    [self.progressSlider addTarget:self action:@selector(ProgressAction) forControlEvents:UIControlEventValueChanged];
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"Slider_控制点"] forState:UIControlStateNormal];
    
    self.minLabel = [UILabel new];
    [self.backgroundImageView addSubview:self.minLabel];
    self.minLabel.sd_layout
    .centerYEqualToView(self.progressSlider)
    .rightSpaceToView(self.progressSlider,10)
    .heightIs(30)
    .widthIs(60);
    self.minLabel.textColor = [UIColor whiteColor];
    self.minLabel.text = @"00:00";
    self.minLabel.textAlignment = NSTextAlignmentRight;
    self.minLabel.font = [UIFont systemFontOfSize:14];

    
    self.maxLabel = [UILabel new];
    [self.backgroundImageView addSubview:self.maxLabel];
    self.maxLabel.sd_layout
    .centerYEqualToView(self.progressSlider)
    .leftSpaceToView(self.progressSlider,10)
    .heightIs(30)
    .widthIs(60);
    self.maxLabel.textColor = [UIColor whiteColor];
    self.maxLabel.text = @"00:00";
    self.maxLabel.textAlignment = NSTextAlignmentLeft;
    self.maxLabel.font = [UIFont systemFontOfSize:14];
    
    
    playButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backgroundImageView addSubview:playButton];
    [playButton setBackgroundImage:[UIImage imageNamed:@"MusicPlayer_暂停"] forState:UIControlStateNormal];
    playButton .sd_layout
    .topSpaceToView(self.progressSlider,15)
    .centerXEqualToView(self.backgroundImageView)
    .widthIs(60)
    .heightIs(60);
    playButton.tag = 1003;
    [playButton  addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    preButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backgroundImageView addSubview:preButton];
    [preButton setBackgroundImage:[UIImage imageNamed:@"MusicPlayer_上一个"] forState:UIControlStateNormal];
//    [preButton setTitle:@"播放" forState:UIControlStateNormal];
        preButton.sd_layout
    .centerYEqualToView(playButton)
    .rightSpaceToView(playButton,20)
    .widthIs(35)
    .heightIs(35);
    preButton.tag = 1004;
    [preButton  addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    
    

    nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backgroundImageView addSubview:nextButton];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"MusicPlayer_下一个"] forState:UIControlStateNormal];
    //    [preButton setTitle:@"播放" forState:UIControlStateNormal];
    nextButton.sd_layout
    .centerYEqualToView(playButton)
    .leftSpaceToView(playButton,20)
    .widthIs(35)
    .heightIs(35);
    nextButton.tag = 1005;
    [nextButton  addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    recycleButton =  [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backgroundImageView addSubview:recycleButton];

    [recycleButton setBackgroundImage:[UIImage imageNamed:@"MusicPlayer_单曲循环"] forState:UIControlStateNormal];
    recycleButton.sd_layout
    .centerYEqualToView(playButton)
    .rightSpaceToView(preButton,20)
    .widthIs(20)
    .heightIs(20);
    recycleButton.tag = 1006;
    [recycleButton  addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    
    uploadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [uploadButton setBackgroundImage:[UIImage imageNamed:@"MusicPlayer_下载"] forState:UIControlStateNormal];
    uploadButton.tag = 1007;
    [self.backgroundImageView addSubview:uploadButton];
    uploadButton.sd_layout
    .centerYEqualToView(nextButton)
    .leftSpaceToView(nextButton,20)
    .widthIs(20)
    .heightIs(20);

    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    

}
#pragma mark - button的点击方法
- (void)playAction:(UIButton *)sender{
    NSInteger tag = sender.tag;
    //返回
    switch (tag) {
        case 1001:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
            //更多
            case 1002:
            NSLog(@"更多");
            break;
            case 1003:
            //播放
            NSLog(@"播放");
            [self playerStatus];
            break;
            case 1004:
            NSLog(@"上一首");
            [self inASong];
            break;
            case 1005:
            NSLog(@"下一首");
            [self theNextSong];
            break;
            case 1006:
            NSLog(@"单曲循环");
            [self playMode];
            break;
            case 1007:
            NSLog(@"下载");
            break;
            
        default:
            break;
    }
}
#pragma mark - 播放暂停
- (void)playerStatus{
    if (isPlaying) {
        [self stop];
    }else{
        [self play];
    }
}
#pragma mark - 播放
- (void)play{
    isPlaying = YES;
    [self.player play];
    [playButton setBackgroundImage:[UIImage imageNamed:@"MusicPlayer_播放"] forState:UIControlStateNormal];
    //开始旋转
    [self.rotationView resumeLayer];
}
#pragma mark - 停止播放
- (void)stop{
    isPlaying = NO;
    [self.player pause];
    [playButton setBackgroundImage:[UIImage imageNamed:@"MusicPlayer_暂停"] forState:UIControlStateNormal];
    //停止旋转
    [self.rotationView pauseLayer];
    
}
#pragma mark - 播放模式
- (void)playMode{
    switch (playerMode) {
        case AudioPlayerModeOrderPlay:{
            playerMode = AudioPlayerModeRandomPlay;
            [recycleButton setBackgroundImage:[UIImage imageNamed:@"MusicPlayer_随机播放"] forState:UIControlStateNormal];
            [self progressHUDWith:@"随机播放"];
            randomArray = [modelArray sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2) {
                return arc4random() % modelArray.count;
            }];
        }break;
        case AudioPlayerModeRandomPlay:
            playerMode = AudioPlayerModeSinglePlay;
            [recycleButton setBackgroundImage:[UIImage imageNamed:@"MusicPlayer_单曲循环"] forState:UIControlStateNormal];
            [self progressHUDWith:@"单曲循环"];
            break;
        case AudioPlayerModeSinglePlay:
            playerMode = AudioPlayerModeOrderPlay;
            [recycleButton setBackgroundImage:[UIImage imageNamed:@"MusicPlayer_顺序播放"] forState:UIControlStateNormal];
            [self progressHUDWith:@"顺序播放"];
            break;
        default:
            break;
    }

}
#pragma mark - 上一首

- (void)inASong{
    if (playerMode != AudioPlayerModeSinglePlay) {
        [self previousIndexSub];
    }
    [self updateAudioPlayer];

}
- (void)previousIndexSub{
    _index--;
    if (_index < 0) {
        _index = modelArray.count - 1;
    }
}
#pragma mark - 下一首
- (void)theNextSong{
    if (playerMode != AudioPlayerModeSinglePlay) {
        [self nextIndexAdd];
    }
    [self updateAudioPlayer];

}
- (void)nextIndexAdd{
    _index++;
    if (_index == modelArray.count) {
        _index = 0;
    }
}

#pragma mark - 滑块的滑动方法
- (void)ProgressAction{
    //转化成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(self.progressSlider.value, 1);

    [playerItem seekToTime:dragedCMTime];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

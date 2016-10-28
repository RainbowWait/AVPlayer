//
//  HomeViewController.m
//  UI7_TabBar
//
//  Created by 黄明远 on 16/10/14.
//  Copyright © 2016年 郑小燕. All rights reserved.
//

#import "HomeViewController.h"
#import "MusicsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>//定制锁屏界面
@interface HomeViewController ()<AVAudioPlayerDelegate>

@end

@implementation HomeViewController {
    AVAudioPlayer *avAudioPlayer;   //播放器player
    UISlider *progressV;      //播放进度
    UISlider *volumeSlider;         //声音控制
    NSTimer *timer;                 //监控音频播放进度
    UILabel *labelMin;
    UILabel *labelMax;
    double currentTime;/**<当前时间>*/ 
    double totalTime;
    NSUInteger currentTrackNumber;/**<当前播放的歌曲>*/
    NSArray *arrayOfTracts;/**<这个数组保存音频的名称>*/
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self makeNavi];
//    arrayOfTracts = @[@"薛之谦 - 你还要我怎样",@"薛之谦 - 丑八怪",@"金玟岐 - 小幸运（Cover 田馥甄）",@"薛之谦 - 演员",@"莫文蔚 - 大王叫我来巡山"];
    
//    [self makeContent];
    //    self.navigationItem.title = @"首页";

    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    MusicsViewController *vc = [[MusicsViewController alloc]init];
    vc.title = @"音区";
    [self.navigationController pushViewController:vc animated:YES];

}
#pragma mark - 导航栏
- (void)makeNavi{
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:117/255.0 green:184/255.0 blue:254/255.0 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @" "; // blank or any other title
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    
}

- (void)makeContent{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:button];
    [button setTitle:@"播放" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor yellowColor];
    button.layer.cornerRadius = 20 ;
    button.clipsToBounds = YES;
    button .sd_layout
    .topSpaceToView(self.view,130)
    .centerXEqualToView(self.view)
    .widthIs(60)
    .heightIs(40);
    button.tag = 1001;
    [button  addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *preButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:preButton];
    [preButton setTitle:@"上一首" forState:UIControlStateNormal];
    preButton.layer.cornerRadius = 20;
    preButton.clipsToBounds = YES;
    preButton .sd_layout
    .topEqualToView(button)
    .rightSpaceToView(button,10)
    .widthIs(60)
    .heightIs(40);
    preButton.tag = 1004;
    [preButton  addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:nextButton];
    [nextButton setTitle:@"下一首" forState:UIControlStateNormal];
    nextButton.layer.cornerRadius = 20;
    nextButton.clipsToBounds = YES;
//    <#button#>.backgroundColor = COLOR_BLUE_TEXTFIELD;
//    <#button#>.titleLabel.font = NewFont(16);
    nextButton .sd_layout
    .topEqualToView(button)
    .leftSpaceToView(button,10)
    .widthIs(60)
    .heightIs(40);
    nextButton.tag = 1005;
    [nextButton  addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *recycleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:recycleButton];
    [recycleButton setTitle:@"单曲循环" forState:UIControlStateNormal];
    recycleButton .sd_layout
    .topEqualToView(nextButton)
    .leftSpaceToView(nextButton,10)
    .widthIs(80)
    .heightIs(40);
    recycleButton.tag = 1006;
    [recycleButton  addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];



    
    
    
    
    
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button1 setTitle:@"pause" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    button1.sd_layout
    .topSpaceToView(button,20)
    .centerXEqualToView(self.view)
    .widthIs(60)
    .heightIs(40);
    button1.tag = 1002;
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:button2];
    //       [button2 setFrame:CGRectMake(100, 200, 60, 40)];
    button2.sd_layout
    .topSpaceToView(button1,20)
    .centerXEqualToView(self.view)
    .heightIs(60)
    .widthIs(40);
    [button2 setTitle:@"stop" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    button2.tag = 1003;
    
    
    
    
    //从budle路径下读取音频文件　　轻音乐 - 萨克斯回家 这个文件名是你的歌曲名字,mp3是你的音频格式
    NSString *string = [[NSBundle mainBundle] pathForResource:arrayOfTracts[currentTrackNumber] ofType:@"mp3"];
    //把音频文件转换成url格式
    NSURL *url = [NSURL fileURLWithPath:string];
    //初始化音频类 并且添加播放文件
    avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    avAudioPlayer.delegate = self;
    
    //1.设置初始音量大小
//    avAudioPlayer.volume = 0.2;
    
    //2.设置音乐播放次数  -1为一直循环
    avAudioPlayer.numberOfLoops = 1;
    //3.播放位置
    avAudioPlayer.currentTime = 0.0;
    //4.声道数
//    NSUInteger channels = avAudioPlayer.numberOfChannels;//只读属性
    //5.持续时间
//    NSTimeInterval duration = avAudioPlayer.duration;//获取采样的持续时间
    //6仪表数
//    avAudioPlayer.meteringEnabled = YES;//开启仪表计数功能
//    [avAudioPlayer updateMeters];
    //读取每个声道的平均电平和峰值电平,代表每个声道的分贝数,范围在-100-0之间
    /*
     for(inti =0; i
     
     floatpower = [player averagePowerForChannel:i];
     
     floatpeak = [player peakPowerForChannel:i];
     
     }
     */
    
    
    //后台播放
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance]setActive:YES error:nil];
    [self setPlayingInfo];
    
    
    //监听播放设备
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    
       //预播放
    [avAudioPlayer prepareToPlay];
    
    
    
    //初始化一个播放进度条
    progressV = [[UISlider alloc] init];
    //WithFrame:CGRectMake(100, 50, 200, 20)
    [self.view addSubview:progressV];
    progressV.sd_layout.topSpaceToView(self.view,100)
    .centerXEqualToView(self.view)
    .heightIs(20)
    .widthIs(200);
    progressV.continuous = YES;
    progressV.minimumValue = 0;
    progressV.maximumValue = 1;
    [progressV addTarget:self action:@selector(progressAction) forControlEvents:UIControlEventValueChanged];
    

    
    
    labelMin = [[UILabel alloc]init];
    labelMin.text = @"00:00";
    [self.view addSubview:labelMin];
    labelMin.textColor = [UIColor blueColor];
    labelMin.textAlignment = NSTextAlignmentRight;
    labelMin.sd_layout
    .centerYEqualToView(progressV)
    .rightSpaceToView(progressV,10)
    .heightIs(30);
    [labelMin setSingleLineAutoResizeWithMaxWidth:self.view.frame.size.width];
    
    
    
    labelMax = [[UILabel alloc]init];
    labelMax.text = @"00:00";
    labelMax.textColor = [UIColor blueColor];
    [self.view addSubview:labelMax];
    labelMax.sd_layout
    .centerYEqualToView(progressV)
    .leftSpaceToView(progressV,10)
    .heightIs(30)
    .widthIs(100);
    labelMax.text = [NSString stringWithFormat:@"%d%d:%02d",(integer_t)(avAudioPlayer.duration / 3600),(int)(avAudioPlayer.duration / 60),((int)avAudioPlayer.duration) % 60];
//   labelMax.text = [NSString stringWithFormat:@"%f",avAudioPlayer.duration];

    
    
    
    //用NSTimer来监控音频播放进度
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playProgress) userInfo:nil repeats:YES];

    //停止定时器
    timer.fireDate = [NSDate distantFuture];
    
    
    //初始化音量控制
    volumeSlider = [[UISlider alloc] init];
    [volumeSlider addTarget:self action:@selector(volumeChange) forControlEvents:UIControlEventValueChanged];
    //设置最小音量
    volumeSlider.minimumValue = 0.0f;
    //设置最大音量
    volumeSlider.maximumValue = 1.0f;
    //初始化音量为多少
    volumeSlider.value = avAudioPlayer.volume;
    [self.view addSubview:volumeSlider];
    volumeSlider.sd_layout
    .bottomSpaceToView(self.view,60)
    .centerXEqualToView(self.view)
    .heightIs(20)
    .widthIs(200);
    
    
    
    //声音开关控件(静音)
    UISwitch *swith = [[UISwitch alloc] init];
    [swith addTarget:self action:@selector(onOrOff:) forControlEvents:UIControlEventValueChanged];
    //默认状态为打开
    swith.on = YES;
    [self.view addSubview:swith];
    swith.sd_layout
    .bottomSpaceToView(volumeSlider,20)
    .centerXEqualToView(self.view)
    .heightIs(40)
    .widthIs(60);
    
    
    
}

- (void)playAction:(UIButton *)sender{
    NSInteger tag = sender.tag;
    if (tag == 1001) {
        //播放
        [avAudioPlayer play];
        //启动定时器
        timer.fireDate = [NSDate distantPast];
//        [timer fire];
    }else if(tag == 1002){
        //暂停
        [avAudioPlayer pause];
        timer.fireDate = [NSDate distantFuture];
        //从运行循环中移除,对运行循环的引用进行一次 release
//        [timer invalidate];
        
    }else if(tag == 1003){
        //停止
        avAudioPlayer.currentTime = 0;  //当前播放时间设置为0
        [avAudioPlayer stop];
        //停止定时器
         timer.fireDate = [NSDate distantFuture];

        
        
    }else if (tag == 1004){
    
        
        
        
    }else if (tag == 1005){
        
        
        
        
    }else if (tag == 1006){
        
        
        
    }
    
    
}

#pragma mark - 定时器方法
- (void)playProgress
{
    //通过音频播放时长的百分比,给progressview进行赋值;
    //         progressV.progress = avAudioPlayer.currentTime/avAudioPlayer.duration;
    
    //当前时间
    
    //当前时间
    currentTime = avAudioPlayer.currentTime;
    //总时间
    totalTime = avAudioPlayer.duration;

//    float progress = ;
    progressV.value = currentTime / totalTime;
        NSLog(@"avAudioPlayer.currentTime = %f totalTime = %f,ProgressValue = %f",avAudioPlayer.currentTime,avAudioPlayer.duration,progressV.value);
    labelMin.text = [NSString stringWithFormat:@"%d%d:%02d",(integer_t)(avAudioPlayer.currentTime / 3600),(int)(avAudioPlayer.currentTime / 60),((int)avAudioPlayer.currentTime) % 60];
    
    
}

//滑块的进度
- (void)progressAction{
    avAudioPlayer.currentTime = progressV.value * avAudioPlayer.duration;
    NSLog(@"当前时间%f",avAudioPlayer.currentTime );

}
//声音开关(是否静音)
- (void)onOrOff:(UISwitch *)sender
{
    avAudioPlayer.volume = sender.on;
}

//播放音量控制
- (void)volumeChange
{
    avAudioPlayer.volume = volumeSlider.value;
}

#pragma mark - 监听播放设备
/**
 *  一旦输入改变则执行此方法
 *@param notification 输入改变通知对象
 */
- (void)routeChange:(NSNotification *)notification{
    NSDictionary *dic = notification.userInfo;
    int changeReason = [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    //等于AVAudioSessionRouteChangeReasonOldDeviceUnavailabel表示输入不可用
    if (changeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *routeDescription = dic[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription = [routeDescription .outputs firstObject];
        //原设备为耳机则暂停
        if ([portDescription.portType isEqualToString:@"Headphones"]) {
            
            [avAudioPlayer pause];
        }
        
        
    }
    
    

}


#pragma mark - delegate(代理方法)
//播放完成时调用的方法  (代理里的方法),需要设置代理才可以调用
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) {
        if (currentTrackNumber < [arrayOfTracts count] - 1) {
            
            currentTrackNumber++;
            if (avAudioPlayer) {
                [avAudioPlayer stop];
                avAudioPlayer = nil;
            }
            
            avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[[NSString alloc] initWithString:[arrayOfTracts objectAtIndex:currentTrackNumber]] ofType:@"mp3"]] error:NULL];
            avAudioPlayer.delegate = self;
            [avAudioPlayer play];
        }
    }
    
//    [timer invalidate]; //NSTimer暂停   invalidate  使...无效;
}

//当有电话打进来时,播放暂停
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{

    [avAudioPlayer pause];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    //解码错误执行的动作
}





- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //接收远程控制
    [self becomeFirstResponder];
    [[UIApplication sharedApplication]beginReceivingRemoteControlEvents];
}

- (void)viewDidDisappear:(BOOL)animated{
       [super viewDidDisappear:animated];
    [[UIApplication sharedApplication]endReceivingRemoteControlEvents];
    
}

#pragma mark - 定制锁屏界面

- (void)setPlayingInfo {
    //    设置后台播放时显示的东西，例如歌曲名字，图片等
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"31e652fe2d.jpg"]];
    
    NSDictionary *dic = @{MPMediaItemPropertyTitle:@"金玟岐 - 小幸运（Cover 田馥甄）",
                          MPMediaItemPropertyArtist:@"田馥甄",
                          MPMediaItemPropertyArtwork:artWork
                          };
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dic];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event{
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                if (![avAudioPlayer isPlaying]) {
                    [avAudioPlayer play];
                }
                break;
            case UIEventSubtypeRemoteControlPause :
                if ([avAudioPlayer isPlaying]) {
                    [avAudioPlayer pause];
                }
                
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                NSLog(@"下一首");
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                NSLog(@"上一首");
                break;
                
            default:
                break;
        }
    }
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

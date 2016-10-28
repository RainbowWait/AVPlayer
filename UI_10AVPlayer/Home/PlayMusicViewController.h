//
//  PlayMusicViewController.h
//  UI_10AVPlayer
//
//  Created by 黄明远 on 16/10/20.
//  Copyright © 2016年 郑小燕. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD.h>
#import "MusicModel.h"
#import "RotationView.h"
#import "UIImage+ImageEffects.h"
static CGFloat topHeight = 64.0 + 20.0;
static CGFloat downHeight = 100.0 + 16.0;

/**
 * AudioPlayerMode 播放模式
 */

typedef NS_ENUM(NSInteger,AudioPlayerMode){
    /**
     * 顺序播放
     */
    
    AudioPlayerModeOrderPlay,
    /**
     * 随机播放
     */
    AudioPlayerModeRandomPlay,
    /**
     * 单曲循环
     */
    AudioPlayerModeSinglePlay,
    
};

@interface PlayMusicViewController : UIViewController
@property (nonatomic, strong) RotationView *rotationView;/**<中间旋转视图>*/
@property (nonatomic, strong) MBProgressHUD *HUD;
@property(nonatomic,strong)UIImageView *backgroundImageView;/**<背景视图>*/


/**
 * 控制器单例
 */
+ (instancetype)playMusicViewControllerSharedInstance;
/**
 *  播放器数据传入
 *
 *  @param array 传入所有数据model数组
 *  @param index 传入当前model在数组的下标
 */
- (void)initWithArray:(NSArray *)array index:(NSInteger)index;

@end

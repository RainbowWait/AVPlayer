//
//  PlayMusicViewController+methods.m
//  UI_10AVPlayer
//
//  Created by 黄明远 on 16/10/21.
//  Copyright © 2016年 郑小燕. All rights reserved.
//

#import "PlayMusicViewController+methods.h"

@implementation PlayMusicViewController (methods)


- (void)createViews{

    self.rotationView = [[RotationView alloc]init];
    self.rotationView.imageView.image = [UIImage imageNamed:@"音乐_播放器_默认唱片头像"];
    [self.view addSubview:self.rotationView];

    self.HUD = [[MBProgressHUD alloc]initWithView:self.view];
    self.HUD.mode = MBProgressHUDModeText;
    self.HUD.userInteractionEnabled = YES;
    [self.view addSubview:self.HUD];
    
}


- (void)progressHUDWith:(NSString *)string{
    self.HUD.label.text = string;
//    self.HUD.label.backgroundColor = [UIColor blackColor];
    [self.HUD showAnimated:YES];
    [self.HUD hideAnimated:YES afterDelay:2.0f];
    
}

- (void)setRotationViewFrame{
    CGFloat height_i4 = kScreenHeight - topHeight - downHeight;
    
    if (kScreenHeight < 500) {
        self.rotationView.frame = CGRectMake(0,  0, height_i4 * 0.8, height_i4 * 0.8);
    }else{
        self.rotationView.frame = CGRectMake(0, 0, kScreenWidth * 0.8, kScreenWidth * 0.8);
        self.rotationView.center = CGPointMake(kScreenWidth / 2, height_i4 / 2 + topHeight);
        [self.rotationView setRotationViewLayoutWithFrame:self.rotationView.frame];
    }

    
}
- (void)setImageWith:(MusicModel *)model{
/**
 *添加旋转动画
 */
    
    [self.rotationView addAnimation];
    self.backgroundImageView.image =[UIImage imageNamed:@"音乐_播放器_默认模糊背景"];
    [self.rotationView.imageView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"音乐_播放器_默认唱片头像"]completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            self.backgroundImageView.image = [image applyDarkEffect];
        }
    }];
}

@end

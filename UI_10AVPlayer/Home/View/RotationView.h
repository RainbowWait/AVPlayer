//
//  RotationView.h
//  UI_10AVPlayer
//
//  Created by 黄明远 on 16/10/21.
//  Copyright © 2016年 郑小燕. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RotationView : UIView

@property (nonatomic, strong) UIImageView *imageView;
- (void)setRotationViewLayoutWithFrame:(CGRect)frame;
- (void)addAnimation;
//暂停layer上的动画
- (void)pauseLayer;
//恢复layer上的动画
- (void)resumeLayer;
//移除动画
- (void)removeAnimation;
@end

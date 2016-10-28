//
//  RotationView.m
//  UI_10AVPlayer
//
//  Created by 黄明远 on 16/10/21.
//  Copyright © 2016年 郑小燕. All rights reserved.
//

#import "RotationView.h"
#define BorderWidth 6.0f//边界半透明宽度

@implementation RotationView
- (instancetype)initWithFrame:(CGRect)frame{

    if ([super initWithFrame:frame]) {
    self = [super initWithFrame:frame];
    self.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.4];
    self.imageView = [UIImageView new];
    [self addSubview:self.imageView];
        
    }
    return self;
}



- (void)setRotationViewLayoutWithFrame:(CGRect)frame{

    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = CGRectGetWidth(frame) / 2.f;
    self.imageView.frame = CGRectMake(BorderWidth, BorderWidth, frame.size.width - BorderWidth * 2, frame.size.width - BorderWidth * 2);
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = CGRectGetWidth(self.imageView.frame) / 2.f;
    
}

///添加动画
- (void)addAnimation{
    //绕z轴旋转
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    animation.fromValue =
    animation.toValue = [NSNumber numberWithFloat:2.0 * M_PI];
    animation.duration = 20.0f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.cumulative = NO;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = FLT_MAX;
    [self.imageView.layer addAnimation:animation forKey:@"AnimatedKey"];
    [self.imageView stopAnimating];
    self.imageView.layer.speed = 0.0;
    

}

//暂停layer上的动画
- (void)pauseLayer{
    CFTimeInterval pausedTime = [self.imageView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.imageView.layer.speed = 0.0;
    self.imageView.layer.timeOffset =pausedTime;

}
//恢复layer上的动画
- (void)resumeLayer{
    CFTimeInterval pausedTime = self.imageView.layer.timeOffset;
    self.imageView.layer.speed = 1.0;
    self.imageView.layer.timeOffset = 0.0;
    self.imageView.layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self.imageView.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    self.imageView.layer.beginTime = timeSincePause;}

//移除动画
- (void)removeAnimation{

    [self.imageView.layer removeAllAnimations];
}
@end

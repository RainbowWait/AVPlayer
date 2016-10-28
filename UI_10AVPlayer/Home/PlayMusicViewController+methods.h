//
//  PlayMusicViewController+methods.h
//  UI_10AVPlayer
//
//  Created by 黄明远 on 16/10/21.
//  Copyright © 2016年 郑小燕. All rights reserved.
//

#import "PlayMusicViewController.h"

@interface PlayMusicViewController (methods)
/**
 * 创建部分空间
*/
- (void)createViews;
/**
 * 设置旋转图的Frame
 */
- (void)setRotationViewFrame;
/**
 * 设置旋转图片,模糊图片
 *@param model 当前的音乐model
 */
- (void)setImageWith:(MusicModel *)model;
/**
 * 提示框
 *
 * @param string 提示字符串
 */
- (void)progressHUDWith:(NSString *)string;
@end

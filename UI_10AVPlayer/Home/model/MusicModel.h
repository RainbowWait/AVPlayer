//
//  MusicModel.h
//  UI_10AVPlayer
//
//  Created by 黄明远 on 16/10/21.
//  Copyright © 2016年 郑小燕. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicModel : NSObject
@property (nonatomic, strong) NSNumber *music_id; // 歌曲id
@property (nonatomic, strong) NSString *name; // 歌曲名
@property (nonatomic, strong) NSString *icon; // 图片
@property (nonatomic, strong) NSString *fileName; // 歌曲地址
@property (nonatomic, strong) NSString *lrcName;
@property (nonatomic, strong) NSString *singer; // 歌手
@property (nonatomic, strong) NSString *singerIcon;
@end

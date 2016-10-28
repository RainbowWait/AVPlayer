//
//  Header.h
//  UI_10AVPlayer
//
//  Created by 黄明远 on 16/10/19.
//  Copyright © 2016年 郑小燕. All rights reserved.
//

#ifndef Header_h
#define Header_h


#define kScreenWidth  [[UIScreen mainScreen]bounds].size.width
#define kScreenHeight   [UIScreen mainScreen].bounds.size.height
/* 数值变量 */
#define TableViewRowHeight 60.0f // tableView RowHight

/* 坐标变量 */
#define Frame_x_0  0.0f // 坐标 -> x
#define Frame_y_0  0.0f //
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#endif /* Header_h */

//
//  IssueViewController.m
//  UI7_TabBar
//
//  Created by 黄明远 on 16/10/14.
//  Copyright © 2016年 郑小燕. All rights reserved.
//

#import "IssueViewController.h"

@interface IssueViewController ()

@end

@implementation IssueViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self makeNavi];
//    self.navigationItem.title = @"";
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

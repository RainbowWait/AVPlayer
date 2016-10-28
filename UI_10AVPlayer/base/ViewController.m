//
//  ViewController.m
//  UI7_TabBar
//
//  Created by 黄明远 on 16/10/14.
//  Copyright © 2016年 郑小燕. All rights reserved.
//

#import "ViewController.h"
#import "HomeViewController.h"
#import "CommunityViewController.h"
#import "IssueViewController.h"
#import "MeViewController.h"
#import "BaseNaviViewController.h"


#define kClassKey @"rootVCClassString"
#define kTitleKey @"title"
#define kImgKey @"imageName"
#define kSelImgKey  @"selectedImageName"
@interface ViewController (){
    UITabBarItem *messageItem;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    NSArray *childItemsArray = @[
                                 @{kClassKey  : @"HomeViewController",
                                   kTitleKey  : @"首页",
                                   kImgKey    : @"bottombar_homepage_unactive",
                                   kSelImgKey : @"bottombar_homepage_active"},
                                 
                                 @{kClassKey  : @"CommunityViewController",
                                   kTitleKey  : @"社区",
                                   kImgKey    : @"bottombar_community_unactive",
                                   kSelImgKey : @"bottombar_community_active"},
                                 
                                 @{kClassKey  : @"IssueViewController",
                                   kTitleKey  : @"",
                                   kImgKey    : @"bottombar_add",
                                   kSelImgKey : @"bottombar_add"},
                                 
                                 @{kClassKey  : @"MessageViewController",
                                   kTitleKey  : @"消息",
                                   kImgKey    : @"bottombar_news_unactive",
                                   kSelImgKey : @"bottombar_news_active"},
                                 
                                 @{kClassKey  : @"MeViewController",
                                   kTitleKey  : @"我的",
                                   kImgKey    : @"bottombar_mine_unactive",
                                   kSelImgKey : @"bottombar_mine_active"}];
    
    [childItemsArray enumerateObjectsUsingBlock:^(NSDictionary  *dic, NSUInteger idx, BOOL * _Nonnull stop) {
        /*
         NSClassFromString的好处是：
         1 弱化连接，因此并不会把没有的Framework也link到程序中。
         2 不需要使用import，因为类是动态加载的，只要存在就可以加载。因此如果你的toolchain中没有某个类的头文件定义，而你确信这个类是可以用的，那么也可以用这种方法。
         */
        UIViewController *vc = [NSClassFromString(dic[kClassKey] )new];
        
        if ([dic[kClassKey] isEqualToString:@"MeViewController"]) {
//            MeViewController *meVC = (MeViewController *)vc;
            
        }
        BaseNaviViewController *nav = [[BaseNaviViewController alloc]initWithRootViewController:vc];
//        self.navigationItem.title = dic[kTitleKey];
        nav.viewClassName = dic[kClassKey];
        /*
         在iOS 7中，苹果引入了一个新的属性，叫做[UIViewController setEdgesForExtendedLayout:]，它的默认值为UIRectEdgeAll。当你的容器是navigation controller时，默认的布局将从navigation bar的顶部开始。这就是为什么所有的UI元素都往上漂移了44pt。
         */
        self.edgesForExtendedLayout = UIRectEdgeNone;
         nav.navigationBar.translucent = NO;
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 49)];
        backView.backgroundColor = [UIColor whiteColor];
        [self.tabBar insertSubview:backView atIndex:0];
        self.tabBar.barTintColor = [UIColor whiteColor];
        self.tabBar.opaque = YES;
        
        if ([dic[kClassKey] isEqualToString:@"IssueViewController"]) {
            UITabBarItem *item = nav.tabBarItem;
            /*
             该枚举中包含下列值：
             
             UIImageRenderingModeAutomatic  // 根据图片的使用环境和所处的绘图上下文自动调整渲染模式。
             UIImageRenderingModeAlwaysOriginal   // 始终绘制图片原始状态，不使用Tint Color。
             UIImageRenderingModeAlwaysTemplate   // 始终根据Tint Color绘制图片，忽略图片的颜色信息。
             */
            item.image = [[UIImage imageNamed:dic[kImgKey]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
            ;
            item.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
            
            [self addChildViewController:nav];
        
        }else{
            UITabBarItem *item = nav.tabBarItem;
            item.title = dic[kTitleKey];
            item.image = [UIImage imageNamed:dic[kImgKey]];
            item.selectedImage = [[UIImage imageNamed:dic[kSelImgKey]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [item setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor colorWithRed:117/255.0 green:184/255.0 blue:255/255.0 alpha:1]} forState:UIControlStateSelected];
            [self addChildViewController:nav];
        }
        
        
    }];
    self.delegate = self;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{

}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
//    BaseNaviViewController *nav = (BaseNaviViewController *)viewController;
//    if ([nav.viewClassName isEqualToString:@"MeViewController"]||[nav.viewClassName isEqualToString:@"IssueViewController"]||[nav.viewClassName isEqualToString:@"MessageViewController"]) {
//        LoginViewController *vc = [LoginViewController new];
//        vc.title = @"登录";
//        vc.hidesBottomBarWhenPushed = YES;
//        [tabBarController.selectedViewController pushViewController:vc animated:YES];
//        return NO;
//    }
    

    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

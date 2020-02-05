//
//  BFTabBarViewController.m
//  BookFriend
//
//  Created by ONON on 2018/5/24.
//  Copyright © 2018年 ONON. All rights reserved.
//

#import "YSTabBarViewController.h"
#import "YSCalendarCurriculumVC.h"
#import "YSMineViewController.h"
//#import "BFShelfViewController.h"
//#import "BFMineViewController.h"
//#import"BFBookCityViewController.h"
//#import "BFClassificationViewController.h"
@interface YSTabBarViewController ()

@end

@implementation YSTabBarViewController


#pragma mark - override

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.backgroundColor = UIColor.clearColor;
    YSCalendarCurriculumVC * shelfVC = [[YSCalendarCurriculumVC alloc] init];
    [self setChildVcWithChildVC:shelfVC title:@"我的" image:@"home" selectedImage:@"home_sel"];
    YSMineViewController * cityVC = [[YSMineViewController alloc] init];
    [self setChildVcWithChildVC:cityVC title:@"日历课程" image:@"live" selectedImage:@"live_sel"];
    
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController {
    [super setSelectedViewController:selectedViewController];
    NSLog(@"%@", selectedViewController);
    
}

#pragma mark - custom method
/**
 *  设置子控制器
 *
 *  @param childVc       子控制器
 *  @param title         标题
 *  @param image         图标
 *  @param selectedImage 选中图标
 */
- (void)setChildVcWithChildVC:(UIViewController *)childVc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
    childVc.tabBarItem.title = title;
    childVc.tabBarItem.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    NSMutableDictionary * childVcDic = [NSMutableDictionary dictionary];
//    childVcDic[NSForegroundColorAttributeName] = UIColor bm_colorWithHex:<#(UInt32)#>
    childVcDic[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    [childVc.tabBarItem setTitleTextAttributes:childVcDic forState:UIControlStateNormal];
    NSMutableDictionary * childVcSelectedDic = [NSMutableDictionary dictionary];
//    childVcSelectedDic[NSForegroundColorAttributeName] = [UIColor colorFromHexString:@"1aa2e6"];
    childVcSelectedDic[NSFontAttributeName] = [UIFont systemFontOfSize:12];
    [childVc.tabBarItem setTitleTextAttributes:childVcSelectedDic forState:UIControlStateSelected];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:childVc];
    nav.tabBarItem.title = title;
    nav.tabBarItem.image = [UIImage imageNamed:image];
    
    [self addChildViewController:nav];

}

@end

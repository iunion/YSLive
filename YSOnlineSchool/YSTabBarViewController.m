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

//正常色
#define ITEM_NOR_COLOR [UIColor bm_colorWithHex:0x979797]
//选中色
#define ITEM_SEL_COLOR [UIColor bm_colorWithHex:UI_NAVIGATION_BGCOLOR_VALU]

@interface YSTabBarViewController ()

@end


@implementation YSTabBarViewController

// 初始化所有Item
- (instancetype)initWithDefaultItems
{
    BMTabItemClass *tab1 = [[BMTabItemClass alloc] init];
    tab1.title = @"日历课程";
    tab1.normalColor = ITEM_NOR_COLOR;
    tab1.selectedColor = ITEM_SEL_COLOR;
    tab1.normalIcon = @"live";
    tab1.selectedIcon = @"live_sel";

    BMTabItemClass *tab2 = [[BMTabItemClass alloc] init];
    tab2.title = @"我的";
    tab2.normalColor = ITEM_NOR_COLOR;
    tab2.selectedColor = ITEM_SEL_COLOR;
    tab2.normalIcon = @"home";
    tab2.selectedIcon = @"home_sel";
    
    return [self initWithArray:@[tab1, tab2]];
}

- (void)addViewControllers
{
    YSCalendarCurriculumVC *calendarVC = [[YSCalendarCurriculumVC alloc] init];
    BMNavigationController *nav1 = [[BMNavigationController alloc] initWithRootViewController:calendarVC];
    nav1.popOnBackButtonHandler = [YSSuperVC getPopOnBackButtonHandler];

    YSMineViewController *personVC = [[YSMineViewController alloc] init];
    BMNavigationController *nav2 = [[BMNavigationController alloc] initWithRootViewController:personVC];//[[FSH5DemoVC alloc] init]
    nav2.popOnBackButtonHandler = [YSSuperVC getPopOnBackButtonHandler];
    
    [self setViewControllers:@[nav1, nav2]];
}

- (void)selectedTabWithIndex:(NSUInteger)index
{
    [super selectedTabWithIndex:index];
    
    switch (index)
    {
        case YSTabIndex_Class:
            break;
        case YSTabIndex_User:
            break;
        default:
            break;
    }
}

@end

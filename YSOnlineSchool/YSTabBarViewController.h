//
//  BFTabBarViewController.h
//  BookFriend
//
//  Created by ONON on 2018/5/24.
//  Copyright © 2018年 ONON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMKit/BMNavigationController.h>
#import <BMKit/BMTabItemButton.h>

typedef NS_ENUM(NSUInteger, YSTabIndex)
{
    YSTabIndex_Class = 0,
    YSTabIndex_User,
    YSTabIndex_Last
};

@interface YSTabBarViewController : UITabBarController

@property (nonatomic, strong) NSArray<__kindof BMTabItemClass *> *tab_ItemArray;

- (instancetype)initWithArray:(NSArray<__kindof BMTabItemClass *> *)itemArray;

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers;

- (void)freshTabItemWithArray:(NSArray<__kindof BMTabItemClass *> *)itemArray;

- (void)hideOriginTabBar;

// 选中某个Tab
- (void)selectedTabWithIndex:(YSTabIndex)index;

- (void)beforeSelectedIndexChangedFrom:(YSTabIndex)findex to:(YSTabIndex)tindex;
- (void)endSelectedIndexChangedFrom:(YSTabIndex)findex to:(YSTabIndex)tindex;

// 某个Tab上可能push了很多层，回到初始页面
- (void)backTopLeverView:(YSTabIndex)index animated:(BOOL)animated;

- (BMNavigationController *)getCurrentNavigationController;
- (BMNavigationController *)getNavigationControllerAtTabIndex:(YSTabIndex)index;

// 返回当前tab的RootVC
- (UIViewController *)getCurrentRootViewController;
// 返回当前tab的首层VC
- (UIViewController *)getCurrentViewController;
// 根据索引找到VC
- (UIViewController *)getRootViewControllerAtTabIndex:(YSTabIndex)index;
- (UIViewController *)getViewControllerAtTabIndex:(YSTabIndex)index;

@end

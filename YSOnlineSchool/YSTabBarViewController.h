//
//  BFTabBarViewController.h
//  BookFriend
//
//  Created by ONON on 2018/5/24.
//  Copyright © 2018年 ONON. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMKit/BMTabItemButton.h>
#import <BMKit/BMTabBarController.h>

typedef NS_ENUM(NSUInteger, YSTabIndex)
{
    YSTabIndex_Class = 0,
    YSTabIndex_User,
    YSTabIndex_Last
};

@interface YSTabBarViewController : BMTabBarController

- (instancetype)initWithDefaultItems;

- (void)addViewControllers;

@end

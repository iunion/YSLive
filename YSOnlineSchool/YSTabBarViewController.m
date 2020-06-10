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
#define ITEM_NOR_COLOR YSSkinOnlineDefineColor(@"placeholderColor")
//选中色
#define ITEM_SEL_COLOR YSSkinOnlineDefineColor(@"defaultSelectedBgColor")

@interface YSTabBarViewController ()

@end


@implementation YSTabBarViewController

#pragma mark 横竖屏

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (BMIOS_VERSION >= 7.0f)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        //self.automaticallyAdjustsScrollViewInsets = NO;
    }

//    self.bm_NavigationItemTintColor = [UIColor whiteColor];
//    self.bm_NavigationTitleTintColor = [UIColor whiteColor];
//    self.bm_NavigationBarTintColor = [UIColor bm_colorWithHex:0x82ABEC];
//    self.bm_NavigationShadowHidden = YES;
//    [self bm_setNeedsUpdateNavigationBar];
}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
//}

#pragma mark 横竖屏

/// 1.决定当前界面是否开启自动转屏，如果返回NO，后面两个方法也不会被调用，只是会支持默认的方向
- (BOOL)shouldAutorotate
{
    return NO;
}

/// 2.返回支持的旋转方向
/// iPad设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
/// iPad设备上，默认返回值是UIInterfaceOrientationMaskAll
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

/// 3.返回进入界面默认显示方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

// 初始化所有Item
- (instancetype)initWithDefaultItems
{
    /// 不支持手滑返回
    self.bm_CanBackInteractive = NO;
    
//    UIButton * tabBtn1 = [[UIButton alloc]init];
//    [tabBtn1 setImage:YSSkinOnlineElementImage(@"tabbar_timeTable", @"iconNor") forState:UIControlStateNormal];
//    [tabBtn1 setImage:YSSkinOnlineElementImage(@"tabbar_timeTable", @"iconSel") forState:UIControlStateSelected];
//    [tabBtn1 setTitle:YSLocalizedSchool(@"Title.OnlineSchool.Calendar") forState:UIControlStateNormal];
//    [tabBtn1 setTitleColor:ITEM_NOR_COLOR forState:UIControlStateNormal];
//    [tabBtn1 setTitleColor:ITEM_SEL_COLOR forState:UIControlStateSelected];
//
//    UIButton * tabBtn2 = [[UIButton alloc]init];
//    [tabBtn2 setImage:YSSkinOnlineElementImage(@"tabbar_personal", @"iconNor") forState:UIControlStateNormal];
//    [tabBtn2 setImage:YSSkinOnlineElementImage(@"tabbar_personal", @"iconSel") forState:UIControlStateSelected];
//    [tabBtn1 setTitle:YSLocalizedSchool(@"Title.OnlineSchool.Mine") forState:UIControlStateNormal];
//    [tabBtn2 setTitleColor:ITEM_NOR_COLOR forState:UIControlStateNormal];
//    [tabBtn2 setTitleColor:ITEM_SEL_COLOR forState:UIControlStateSelected];
    
    
    BMTabItemClass *tab1 = [[BMTabItemClass alloc] init];
    tab1.title = YSLocalizedSchool(@"Title.OnlineSchool.Calendar");
    tab1.normalColor = ITEM_NOR_COLOR;
    tab1.selectedColor = ITEM_SEL_COLOR;
    tab1.normalIcon = @"timeTable_normal_skin";
    tab1.selectedIcon = @"timeTable_highLight_skin";
    //    tab1.normalIcon = YSSkinOnlineElementImage(@"tabbar_timeTable", @"iconNor");
    //    tab1.selectedIcon = YSSkinOnlineElementImage(@"tabbar_timeTable", @"iconNor");

    BMTabItemClass *tab2 = [[BMTabItemClass alloc] init];
    tab2.title = YSLocalizedSchool(@"Title.OnlineSchool.Mine");
    tab2.normalColor = ITEM_NOR_COLOR;
    tab2.selectedColor = ITEM_SEL_COLOR;
//    tab2.normalIcon = @"home";
//    tab2.selectedIcon = @"home_sel";
    tab2.normalIcon = @"personal_normal_skin";
    tab2.selectedIcon = @"personal_high_skin";
    
    return [self initWithArray:@[tab1, tab2]];
}

- (void)addViewControllers
{
    YSCalendarCurriculumVC *calendarVC = [[YSCalendarCurriculumVC alloc] init];
    BMNavigationController *nav1 = [[BMNavigationController alloc] initWithRootViewController:calendarVC];
//    nav1.title = YSLocalizedSchool(@"Title.OnlineSchool.Calendar");
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

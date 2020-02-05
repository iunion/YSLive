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

#define BMTabBar_ItemCount  YSTabIndex_Last

#define ITEM_TAG_START 100000

@interface YSTabBarViewController ()

// 自定义TabBar的背景Image
@property (nonatomic, strong) UIView *tabBarBgView;

@property (nonatomic, strong) NSMutableArray *tabButtonArray;

@end


@implementation YSTabBarViewController

//- (instancetype)init
//{
//    @throw [NSException exceptionWithName:NSGenericException reason:@"init not supported, use initWithArray: instead." userInfo:nil];
//    return nil;
//}

- (instancetype)initWithArray:(NSArray *)itemArray
{
    self = [super init];
    
    if (self)
    {
        NSAssert(itemArray.count >= BMTabBar_ItemCount, @"check define 'BMTabBar_ItemCount'!");

        self.tab_ItemArray = itemArray;
        
        [self addReplaceTabBarView];
    }
    
    return self;
}

// 添加模拟的TabBar
- (void)addReplaceTabBarView
{
    UIImage *originImage = [UIImage imageNamed:@"bmtab_bg"];
    UIImage *resizeImage = [originImage stretchableImageWithLeftCapWidth:originImage.size.width/2 topCapHeight:originImage.size.height/2];
    
    [self.tabBar setBackgroundImage:[UIImage imageNamed:@"bmtab_clear_line"]];
    [self.tabBar setShadowImage:[UIImage imageNamed:@"bmtab_clear_line"]];
    
    // 设置背景图
    self.tabBarBgView = [[UIView alloc] initWithFrame:self.tabBar.bounds];
    self.tabBarBgView.userInteractionEnabled = YES;
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_TAB_BAR_HEIGHT)];
    imageview.image = resizeImage;
    [self.tabBarBgView addSubview:imageview];
    
    // 添加Item
    self.tabButtonArray = [NSMutableArray arrayWithCapacity:0];
    NSUInteger tab_Count = BMTabBar_ItemCount;
    CGFloat width = UI_SCREEN_WIDTH/tab_Count;

    for (NSUInteger i=0; i<tab_Count; i++)
    {
        CGRect rect = CGRectMake(width * i, 0, width, UI_TAB_BAR_HEIGHT-UI_HOME_INDICATOR_HEIGHT);
        
        BMTabItemButton *item = [[BMTabItemButton alloc] initWithFrame:rect];
        
        [item addTarget:self action:@selector(selectedTab:) forControlEvents:UIControlEventTouchUpInside];
        
        BMTabItemClass *itemClass = self.tab_ItemArray[i];
        [item freshWithTabItem:itemClass];
        
        item.tag = ITEM_TAG_START+i;
        item.exclusiveTouch = YES;

        [self.tabBarBgView addSubview:item];
        [self.tabButtonArray addObject:item];
        
        if (i == 0)
        {
            // 默认选中第一个VC
            [item setSelected:YES];
        }
    }
    
    [self.tabBar addSubview:self.tabBarBgView];
}

// 隐藏原来的tabbar
- (void)hideOriginTabBar
{
    [self.tabBar.subviews enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIControl class]])
        {
            UIControl *control = (UIControl *)obj;
            dispatch_async(dispatch_get_main_queue(), ^{
                control.hidden = YES;
            });
        }
    }];
}

- (void)freshTabItemWithArray:(NSArray *)itemArray
{
    if (self.tab_ItemArray.count != itemArray.count)
    {
        return;
    }
    
    for (NSUInteger index = 0; index<self.tab_ItemArray.count; index++)
    {
        BMTabItemButton *item = self.tabButtonArray[index];
        [item freshWithTabItem:itemArray[index]];
    }
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    [super setViewControllers:viewControllers];
    
    [self hideOriginTabBar];
    
    if (self.viewControllers.count > 0)
    {
        return;
    }
    
    [self selectedTabWithIndex:0];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)unselectedTab:(YSTabIndex)index
{
    if (index < self.tab_ItemArray.count)
    {
        BMTabItemButton *item = self.tabButtonArray[index];
        item.selected = NO;
    }
}

- (void)selectedTab:(BMTabItemButton *)item
{
    NSUInteger index = [self.tabButtonArray indexOfObject:item];
    
    [self selectedTabWithIndex:index];
}

- (void)selectedTabWithIndex:(YSTabIndex)index
{
    if (index == NSNotFound )
    {
        return;
    }

    if (index == self.selectedIndex )
    {
        return;
    }

    [self beforeSelectedIndexChangedFrom:self.selectedIndex to:index];
    
    [self unselectedTab:self.selectedIndex];
    
    BMTabItemButton *item = self.tabButtonArray[index];
    item.selected = YES;
    
    NSUInteger oldIndex = self.selectedIndex;
    self.selectedIndex = index;
    
    [self endSelectedIndexChangedFrom:oldIndex to:index];

    [self.tabBarBgView bm_bringToFront];
}

- (void)beforeSelectedIndexChangedFrom:(YSTabIndex)findex to:(YSTabIndex)tindex
{
    switch (tindex)
    {
        case YSTabIndex_Class:
            break;
        case YSTabIndex_User:
            break;
        default:
            break;
    }
}

- (void)endSelectedIndexChangedFrom:(YSTabIndex)findex to:(YSTabIndex)tindex
{
    BMNavigationController *nav = [self.viewControllers objectAtIndex:findex];
    if (nav.viewControllers.count > 1)
    {
        [nav popToRootViewControllerAnimated:NO];
    }
}


- (void)backTopLeverView:(YSTabIndex)index animated:(BOOL)animated
{
    BMNavigationController *navCtl = [self getCurrentNavigationController];
    if (navCtl.viewControllers.count > 1)
    {
        if (self.selectedIndex == index)
        {
            [navCtl popToRootViewControllerAnimated:animated];
        }
        else
        {
            [navCtl popToRootViewControllerAnimated:NO];
        }
    }
    
    [self selectedTabWithIndex:index];
}

- (BMNavigationController *)getCurrentNavigationController
{
    if ([self.selectedViewController isKindOfClass:[BMNavigationController class]])
    {
        return (BMNavigationController *)self.selectedViewController;
    }
    else
    {
        return nil;
    }
}

- (BMNavigationController *)getNavigationControllerAtTabIndex:(YSTabIndex)index
{
    if (index >= self.viewControllers.count)
    {
        return nil;
    }
    
    id navCtl = [self.viewControllers objectAtIndex:index];
    
    if ([navCtl isKindOfClass:[BMNavigationController class]])
    {
        return (BMNavigationController *)navCtl;
    }
    else
    {
        return nil;
    }
}

// 根据索引找到VC
- (UIViewController *)getRootViewControllerAtTabIndex:(YSTabIndex)index
{
    BMNavigationController *navCtl = [self getNavigationControllerAtTabIndex:index];
    
    NSArray *carray = navCtl.viewControllers;
    if (![carray bm_isNotEmpty])
    {
        return nil;
    }
    
    UIViewController *vc = [carray lastObject];
    return vc;
}

- (UIViewController *)getViewControllerAtTabIndex:(YSTabIndex)index
{
    BMNavigationController *navCtl = [self getNavigationControllerAtTabIndex:index];
    
    NSArray *carray = navCtl.viewControllers;
    if (![carray bm_isNotEmpty])
    {
        return nil;
    }
    
    UIViewController *vc = [carray firstObject];
    return vc;
}

// 此函数只是返回当前tab的RootVC
- (UIViewController *)getCurrentRootViewController
{
    BMNavigationController *navCtl = [self getCurrentNavigationController];

    NSArray *carray = navCtl.viewControllers;
    if (![carray bm_isNotEmpty])
    {
        return nil;
    }
    
    // 获取rootVC
    UIViewController *vc = [carray firstObject];
    return vc;
}

- (UIViewController *)getCurrentViewController
{
    BMNavigationController *navCtl = [self getCurrentNavigationController];
    
    NSArray *carray = navCtl.viewControllers;
    if (![carray bm_isNotEmpty])
    {
        return nil;
    }
    
    // 获取topVC
    UIViewController *vc = [carray lastObject];
    return vc;
}


#pragma mark - override

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.view.backgroundColor = UIColor.clearColor;
    YSCalendarCurriculumVC * shelfVC = [[YSCalendarCurriculumVC alloc] init];
    [self setChildVcWithChildVC:shelfVC title:@"我的" image:@"home" selectedImage:@"home_sel"];
    YSMineViewController * cityVC = [[YSMineViewController alloc] init];
    [self setChildVcWithChildVC:cityVC title:@"日历课程" image:@"live" selectedImage:@"live_sel"];
    
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController
{
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

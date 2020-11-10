//
//  UIAlertController+SCAlertAutorotate.m
//  YSLive
//
//  Created by 马迪 on 2019/11/12.
//  Copyright © 2019 YS. All rights reserved.
//

#import "UIAlertController+SCAlertAutorotate.h"
#import <objc/runtime.h>


@implementation UIAlertController (SCAlertAutorotate)

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.sc_Autorotate = NO;
        self.sc_OrientationMask = UIInterfaceOrientationMaskPortrait;
        self.sc_Orientation = UIInterfaceOrientationPortrait;
    }
    
    return self;
}

- (BOOL)sc_Autorotate
{
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setSc_Autorotate:(BOOL)autorotate
{
    objc_setAssociatedObject(self, @selector(sc_Autorotate), @(autorotate), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIInterfaceOrientationMask)sc_OrientationMask
{
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj unsignedIntegerValue] : UIInterfaceOrientationMaskPortrait;
}

- (void)setSc_OrientationMask:(UIInterfaceOrientationMask)orientationMask
{
    objc_setAssociatedObject(self, @selector(sc_OrientationMask), @(orientationMask), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIInterfaceOrientation)sc_Orientation
{
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj integerValue] : UIInterfaceOrientationPortrait;
}

- (void)setSc_Orientation:(UIInterfaceOrientation)orientation
{
    objc_setAssociatedObject(self, @selector(sc_Orientation), @(orientation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark 横竖屏

/// 1.决定当前界面是否开启自动转屏，如果返回NO，后面两个方法也不会被调用，只是会支持默认的方向
- (BOOL)shouldAutorotate
{
#if YSAutorotateNO
    return NO;
#else
    if (!self.sc_Autorotate)
    {
        return NO;
    }
    
    return YES;
#endif
}

/// 2.返回支持的旋转方向
/// iPhone设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
/// iPad设备上，默认返回值是UIInterfaceOrientationMaskAll
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.sc_OrientationMask;
}

/// 3.返回进入界面默认显示方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.sc_Orientation;
}

@end

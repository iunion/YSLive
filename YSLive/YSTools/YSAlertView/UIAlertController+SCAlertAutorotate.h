//
//  UIAlertController+SCAlertAutorotate.h
//  YSLive
//
//  Created by 马迪 on 2019/11/12.
//  Copyright © 2019 YS. All rights reserved.
//

//#import <AppKit/AppKit.h>


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (SCAlertAutorotate)

/// 是否开启自动旋转 默认: NO
@property (nonatomic, assign) BOOL sc_Autorotate;

/// 支持的旋转方向 默认: UIInterfaceOrientationMaskPortrait
@property (nonatomic, assign) UIInterfaceOrientationMask sc_OrientationMask;
/// 默认旋转方向 默认: UIInterfaceOrientationPortrait
@property (nonatomic, assign) UIInterfaceOrientation sc_Orientation;

@end

NS_ASSUME_NONNULL_END

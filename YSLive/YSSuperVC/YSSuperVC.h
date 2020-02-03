//
//  YSSuperVC.h
//  YSLive
//
//  Created by jiang deng on 2019/10/12.
//  Copyright © 2019 FS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSVCProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSSuperVC : UIViewController
<
    YSSuperVCProtocol
>

- (void)backAction:(nullable id)sender;

- (void)backRootAction:(nullable id)sender;

- (void)backToViewController:(UIViewController *)viewController;

// 创建渐变色图层
- (CAGradientLayer *)getGradientLayerWithFrame:(CGRect)frame colors:(NSArray *)colors startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

// RequestStatus
// 校验一些特殊全局状态码,比如:token失效,强制升级
- (BOOL)checkRequestStatus:(NSInteger)statusCode message:(NSString *)message responseDic:(NSDictionary *)responseDic logOutQuit:(BOOL)quit showLogin:(BOOL)show;

@end

NS_ASSUME_NONNULL_END

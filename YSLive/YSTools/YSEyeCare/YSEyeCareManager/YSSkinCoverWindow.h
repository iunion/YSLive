//
//  YSSkinCoverWindow.h
//  YSAll
//
//  Created by jiang deng on 2019/12/25.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSSkinCoverWindow : UIWindow

- (void)changeSkinCoverColor:(UIColor *)color;

- (void)freshWindowWithShowStatusBar:(BOOL)showStatusBar isRientationPortrait:(BOOL)isRientationPortrait;

@end

NS_ASSUME_NONNULL_END

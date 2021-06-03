//
//  CHFullFloatControlView.h
//  YSAll
//
//  Created by 马迪 on 2021/4/7.
//  Copyright © 2021 CH. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 全屏时视频切换按钮
typedef NS_ENUM(NSUInteger, CHFullFloatState)
{
    CHFullFloatState_None = 1,
    CHFullFloatState_Mine,
    CHFullFloatState_All
};

NS_ASSUME_NONNULL_BEGIN

@interface CHFullFloatControlView : UIView

@property (nonatomic, copy) void(^fullFloatControlButtonClick)(CHFullFloatControlView *fullFloatControlView);

@property (nonatomic, assign) CHFullFloatState fullFloatState;

@end

NS_ASSUME_NONNULL_END

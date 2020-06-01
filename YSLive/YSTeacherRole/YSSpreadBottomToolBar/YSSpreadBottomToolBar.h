//
//  YSSpreadBottomToolBar.h
//  YSLive
//
//  Created by jiang deng on 2020/6/1.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YSSpreadBottomToolBarDelegate <NSObject>

/// 展开关闭
- (void)bottomToolBarSpreadOut:(BOOL)spreadOut;
/// 功能点击
- (void)bottomToolBarClickAtIndex:(SCTeacherTopBarType)teacherTopBarType;

@end

@interface YSSpreadBottomToolBar : UIView

@property (nullable, nonatomic, weak) id<YSSpreadBottomToolBarDelegate> delegate;

/// 是否展开
@property (nonatomic, assign, readonly) BOOL spreadOut;

- (instancetype)initWithUserRole:(YSUserRoleType)roleType topLeftpoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END

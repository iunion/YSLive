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
- (void)bottomToolBarClickAtIndex:(SCTeacherTopBarType)teacherTopBarType select:(BOOL)select;

@end

@interface YSSpreadBottomToolBar : UIView

@property (nullable, nonatomic, weak) id<YSSpreadBottomToolBarDelegate> delegate;

/// 是否展开
@property (nonatomic, assign, readonly) BOOL spreadOut;
/// 是否有新的消息
@property (nonatomic, assign) BOOL isNewMessage;

- (instancetype)initWithUserRole:(YSUserRoleType)roleType topLeftpoint:(CGPoint)point;

/// 花名册 课件库按钮的非选中
- (void)hideListView;
/// 隐藏消息界面
- (void)hideMessageView;

@end

NS_ASSUME_NONNULL_END

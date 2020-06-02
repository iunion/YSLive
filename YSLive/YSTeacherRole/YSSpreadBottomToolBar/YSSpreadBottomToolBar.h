//
//  YSSpreadBottomToolBar.h
//  YSLive
//
//  Created by jiang deng on 2020/6/1.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

#define YSSpreadBottomToolBar_BtnWidth          YSToolBar_BtnWidth
#define YSSpreadBottomToolBar_BtnGap            (4.0f)
#define YSSpreadBottomToolBar_SpreadBtnGap      (6.0f)


NS_ASSUME_NONNULL_BEGIN

@protocol YSSpreadBottomToolBarDelegate <NSObject>

@optional

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
/// 是否正在轮播
@property (nonatomic, assign) BOOL isPolling;
/// 是否可以轮播
@property (nonatomic, assign) BOOL isPollingEnable;
// 除退出 收放 按钮以外 其他按钮是否可以点击
@property (nonatomic, assign) BOOL userEnable;
/// 视频布局
@property (nonatomic, assign) BOOL isAroundLayout;
/// 是否上课
@property (nonatomic, assign) BOOL isBeginClass;


- (instancetype)initWithUserRole:(YSUserRoleType)roleType topLeftpoint:(CGPoint)point;

/// 花名册 课件库按钮的非选中
- (void)hideListView;
/// 隐藏消息界面
- (void)hideMessageView;



@end

NS_ASSUME_NONNULL_END

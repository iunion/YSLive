//
//  SCTeacherTopBar.h
//  YSLive
//
//  Created by fzxm on 2019/12/24.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCTopToolBarModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SCTeacherTopBarLayoutType)
{
    /// 上课前
    SCTeacherTopBarLayoutType_BeforeClass = 1,
    /// 上课后
    SCTeacherTopBarLayoutType_ClassBegin,
    /// 全屏
    SCTeacherTopBarLayoutType_FullMedia,

};

@protocol SCTeacherTopBarDelegate <NSObject>


- (void)sc_TeacherTopBarProxyWithBtn:(UIButton *)btn;
/// 轮询
- (void)pollingBtnClickedProxyWithBtn:(UIButton *)btn;
///// 摄像头
//- (void)cameraProxyWithBtn:(UIButton *)btn;
///// 切换布局
//- (void)switchLayoutProxyWithBtn:(UIButton *)btn;
///// 全体控制
//- (void)allControllProxyWithBtn:(UIButton *)btn;
///// 工具箱
//- (void)toolBoxProxyWithBtn:(UIButton *)btn;
///// 课件库
//- (void)coursewareProxyWithBtn:(UIButton *)btn;
///// 花名册
//- (void)personListProxyWithBtn:(UIButton *)btn;
/// 退出
- (void)exitProxyWithBtn:(UIButton *)btn;
/// 上下课
- (void)classBeginEndProxyWithBtn:(UIButton *)btn;

@end

@interface SCTeacherTopBar : UIView


@property (nonatomic, weak) id<SCTeacherTopBarDelegate> delegate;

@property (nonatomic, strong) SCTopToolBarModel *topToolModel;

/// 上下课
@property (nonatomic, strong, readonly) UIButton *classBtn;
/// 切换布局
@property (nonatomic, strong, readonly) UIButton *switchLayoutBtn;
/// 轮询按钮
@property (nonatomic, strong, readonly) UIButton *pollingBtn;

/// 控制全局控制按钮  布局切换按钮 课件表按钮  显示隐藏
@property (nonatomic, assign)SCTeacherTopBarLayoutType layoutType;
/// 除退出按钮以外 其他按钮是否可以点击
@property (nonatomic, assign) BOOL userEnable;
@end

NS_ASSUME_NONNULL_END

//
//  YSBottomToolBar.h
//  YSLive
//
//  Created by fzxm on 2020/5/26.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol YSBottomToolBarDelegate <NSObject>


- (void)sc_bottomToolBarProxyWithBtn:(UIButton *)btn;
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
- (void)sc_bottomToolBarExitProxyWithBtn:(UIButton *)btn;


@end

@interface YSBottomToolBar : UIView

@property (nonatomic, weak) id<YSBottomToolBarDelegate> delegate;


///// 切换布局
@property (nonatomic, strong, readonly) UIButton *switchLayoutBtn;
/// 轮播按钮
@property (nonatomic, strong, readonly) UIButton *pollingBtn;



// 除退出 收放 按钮以外 其他按钮是否可以点击
@property (nonatomic, assign) BOOL userEnable;
@property (nonatomic, assign) BOOL open;

/// 消息按钮的选中与否
- (void)setMessageOpen:(BOOL)open;
@end

NS_ASSUME_NONNULL_END

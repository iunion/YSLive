//
//  YSLiveLevelView.h
//  YSLive
//
//  Created by fzxm on 2020/9/22.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSLiveLevelView : UIView
/// 背景
@property (nonatomic, strong, readonly) UIView *bgView;
/// 主视频容器
@property (nonatomic, strong, readonly) UIView *liveView;
/// 视频蒙版
@property (nonatomic, strong, readonly) UIView *maskView;
/// 弹幕容器
@property (nonatomic, strong, readonly) UIView *barrageView;
/// 工具容器
@property (nonatomic, strong, readonly) UIView *toolsView;
/// 工具容器
@property (nonatomic, strong, readonly) UIView *toolsAutoHideView;

@end

NS_ASSUME_NONNULL_END

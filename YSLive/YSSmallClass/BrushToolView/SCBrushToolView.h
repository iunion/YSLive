//
//  SCBrushToolView.h
//  YSLive
//
//  Created by fzxm on 2019/11/6.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SCBrushToolViewDelegate <NSObject>

/// 总按钮的点击 回调
- (void)toolBtnClickedSeleted:(BOOL)seleted;
/// 工具类型回调
/// @param toolViewBtnType 工具类型
- (void)brushToolViewType:(YSBrushToolType)toolViewBtnType withToolBtn:(nonnull UIButton *)toolBtn;


@optional

- (void)brushToolDoClean;

@end


@interface SCBrushToolView : UIView

@property (nonatomic, weak)id <SCBrushToolViewDelegate>delegate;

@property (nonatomic, strong, readonly) UIButton *toolsBtn;
@property (nonatomic, strong, readonly) UIButton *mouseBtn;

- (instancetype)initWithTeacher:(BOOL)isTeacher;

@end

NS_ASSUME_NONNULL_END

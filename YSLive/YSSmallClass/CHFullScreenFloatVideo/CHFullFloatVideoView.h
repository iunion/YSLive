//
//  CHFullFloatVideoView.h
//  YSAll
//
//  Created by 马迪 on 2021/4/7.
//  Copyright © 2021 CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCVideoView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CHFullFloatVideoViewDelegate <NSObject>

- (void)fullFloatControlViewEvent:(UIButton *)sender;

@end

@interface CHFullFloatVideoView : UIView

///最右侧不能超过【举手】控件的左侧
@property (nonatomic, assign) CGFloat rightViewMaxRight;

@property (nonatomic, weak)id<CHFullFloatVideoViewDelegate> fullFloatVideoViewDelegate;

- (instancetype)initWithFrame:(CGRect)frame wideScreen:(BOOL)isWideScreen;

/// 刷新rightVideoBgView内部view
//- (void)freshViewWithVideoViewArray:(NSMutableArray<SCVideoView *> *)videoSequenceArr;
- (void)freshViewWithVideoViewArray:(NSArray *)videoSequenceArr;
@end

NS_ASSUME_NONNULL_END

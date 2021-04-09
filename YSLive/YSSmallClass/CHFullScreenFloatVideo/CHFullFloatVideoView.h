//
//  CHFullFloatVideoView.h
//  YSAll
//
//  Created by 马迪 on 2021/4/7.
//  Copyright © 2021 CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHVideoView.h"


NS_ASSUME_NONNULL_BEGIN

@protocol CHFullFloatVideoViewDelegate <NSObject>

- (void)fullFloatControlViewEvent:(FullFloatControl)fullFloatControl;

@end

@interface CHFullFloatVideoView : UIView

///最右侧不能超过【举手】控件的左侧
@property (nonatomic, assign) CGFloat rightViewMaxRight;

@property (nonatomic, weak)id<CHFullFloatVideoViewDelegate> fullFloatVideoViewDelegate;

- (instancetype)initWithFrame:(CGRect)frame wideScreen:(BOOL)isWideScreen;

/// 刷新rightVideoBgView内部view布局
- (void)freshFullFloatViewWithVideoArray:(NSMutableArray<CHVideoView *> *)videoSequenceArrFull;
//- (void)freshFullFloatViewWithVideoArray:(NSMutableArray *)videoSequenceArrFull;


@end

NS_ASSUME_NONNULL_END

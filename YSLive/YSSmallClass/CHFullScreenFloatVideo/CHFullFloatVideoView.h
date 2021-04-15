//
//  CHFullFloatVideoView.h
//  YSAll
//
//  Created by 马迪 on 2021/4/7.
//  Copyright © 2021 CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHVideoView.h"
#import "CHFullFloatControlView.h"

NS_ASSUME_NONNULL_BEGIN

@class CHFullFloatVideoView;

@interface CHFullFloatVideoView : UIView

///最右侧不能超过【举手】控件的左侧
@property (nonatomic, assign) CGFloat rightViewMaxRight;

- (instancetype)initWithFrame:(CGRect)frame wideScreen:(BOOL)isWideScreen;

- (void)showFullFloatViewWithMyVideoArray:(NSArray<CHVideoView *> *)myVideoSequenceArray allVideoSequenceArray:(NSArray<CHVideoView *> *)allVideoSequenceArray;
/// 刷新rightVideoBgView内部view布局
- (void)freshFullFloatViewWithMyVideoArray:(NSArray<CHVideoView *> *)myVideoSequenceArray allVideoSequenceArray:(NSArray<CHVideoView *> *)allVideoSequenceArray;

@end

NS_ASSUME_NONNULL_END

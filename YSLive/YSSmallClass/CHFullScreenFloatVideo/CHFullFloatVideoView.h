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

@property (nonatomic, assign, readonly) CHFullFloatState fullFloatState;

- (instancetype)initWithFrame:(CGRect)frame wideScreen:(BOOL)isWideScreen;

- (void)showFullFloatViewWithMyVideoArray:(NSMutableArray<CHVideoView *> *)myVideoSequenceArray allVideoSequenceArray:(NSMutableArray<CHVideoView *> *)allVideoSequenceArray;
/// 刷新rightVideoBgView内部view布局
- (void)freshFullFloatViewWithMyVideoArray:(NSMutableArray<CHVideoView *> *)myVideoSequenceArray allVideoSequenceArray:(NSMutableArray<CHVideoView *> *)allVideoSequenceArray;

- (void)hideFullFloatView;

@end

NS_ASSUME_NONNULL_END

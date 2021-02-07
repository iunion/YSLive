//
//  BMKeystoneCorrectionView.h
//  YSLive
//
//  Created by jiang deng on 2021/2/5.
//  Copyright © 2021 YS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMCorrectionView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BMKeystoneCorrectionViewDelegate;

@interface BMKeystoneCorrectionView : UIView

- (instancetype)initWithFrame:(CGRect)frame liveManager:(YSLiveManager *)liveManager;

@property (nonatomic, weak) id <BMKeystoneCorrectionViewDelegate> delegate;

/// 主视频容器
@property (nonatomic, strong, readonly) UIView *liveView;

/// 手势View
@property (nonatomic, strong, readonly) BMCorrectionView *touchView;

- (void)freshTouchView;

@end

@protocol BMKeystoneCorrectionViewDelegate <NSObject>

- (void)keystoneCorrectionViewClose;

@end

NS_ASSUME_NONNULL_END

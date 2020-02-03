//
//  YSBasicAnimation.h
//  YSAll
//
//  Created by jiang deng on 2019/12/25.
//  Copyright © 2019 YS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^YSAnimationDidStopBlock)(CAAnimation *anim, BOOL flag);

@interface YSBasicAnimation : CABasicAnimation

@property (nonatomic, copy) YSAnimationDidStopBlock animationDidStopBlock;

@end

NS_ASSUME_NONNULL_END

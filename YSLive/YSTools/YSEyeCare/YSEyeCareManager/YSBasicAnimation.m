//
//  YSBasicAnimation.m
//  YSAll
//
//  Created by jiang deng on 2019/12/25.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSBasicAnimation.h"

@interface YSBasicAnimation ()
<
    CAAnimationDelegate
>

@end

@implementation YSBasicAnimation

- (void)setAnimationDidStopBlock:(YSAnimationDidStopBlock)animationDidStopBlock
{
    _animationDidStopBlock = animationDidStopBlock;
    
    self.delegate = self;
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.animationDidStopBlock)
    {
        self.animationDidStopBlock(anim, flag);
    }
}


@end

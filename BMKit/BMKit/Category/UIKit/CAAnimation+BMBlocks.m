//
//  CAAnimation+Blocks.m
//  CAAnimationBlocks
//
//  Created by xissburg on 7/7/11.
//  Copyright 2011 xissburg. All rights reserved.
//

#import "CAAnimation+BMBlocks.h"


@interface BMCAAnimationDelegate : NSObject
<
    CAAnimationDelegate
>

@property (nonatomic, copy) void (^completion)(BOOL);
@property (nonatomic, copy) void (^start)(void);

@end

@implementation BMCAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim
{
    if (self.start != nil) {
        self.start();
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.completion != nil) {
        self.completion(flag);
    }
}

@end


@implementation CAAnimation (BMBlocksAddition)

- (void)setBm_completion:(void (^)(BOOL))completion
{
    if ([self.delegate isKindOfClass:[BMCAAnimationDelegate class]]) {
        ((BMCAAnimationDelegate *)self.delegate).completion = completion;
    }
    else {
        BMCAAnimationDelegate *delegate = [[BMCAAnimationDelegate alloc] init];
        delegate.completion = completion;
        self.delegate = (BMCAAnimationDelegate <CAAnimationDelegate> *) delegate;
    }
}

- (void (^)(BOOL))bm_completion
{
    return [self.delegate isKindOfClass:[BMCAAnimationDelegate class]]? ((BMCAAnimationDelegate *)self.delegate).completion: nil;
}

- (void)setBm_start:(void (^)(void))start
{
    if ([self.delegate isKindOfClass:[BMCAAnimationDelegate class]]) {
        ((BMCAAnimationDelegate *)self.delegate).start = start;
    }
    else {
        BMCAAnimationDelegate *delegate = [[BMCAAnimationDelegate alloc] init];
        delegate.start = start;
        self.delegate = (BMCAAnimationDelegate <CAAnimationDelegate> *) delegate;
    }
}

- (void (^)(void))bm_start
{
    return [self.delegate isKindOfClass:[BMCAAnimationDelegate class]]? ((BMCAAnimationDelegate *)self.delegate).start: nil;
}

@end

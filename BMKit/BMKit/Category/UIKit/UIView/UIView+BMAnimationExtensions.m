//
//  Created by Rafal Sroka
//
//  License CC0.
//  This is free and unencumbered software released into the public domain.
//
//  Anyone is free to copy, modify, publish, use, compile, sell, or
//  distribute this software, either in source code form or as a compiled
//  binary, for any purpose, commercial or non-commercial, and by any means.
//


#import "UIView+BMAnimationExtensions.h"


@implementation UIView (BMAnimationExtensions)


// 心跳动画
- (void)bm_heartbeatDuration:(NSTimeInterval)fDuration
{
    [self bm_heartbeatDuration:fDuration maxSize:1.4f durationPerBeat:0.5f];
}

- (void)bm_heartbeatDuration:(NSTimeInterval)fDuration maxSize:(CGFloat)fMaxSize durationPerBeat:(NSTimeInterval)fDurationPerBeat
{
    [self bm_heartbeatDuration:fDuration maxSize:fMaxSize durationPerBeat:fDurationPerBeat completion:nil];
}

- (void)bm_heartbeatDuration:(NSTimeInterval)fDuration maxSize:(CGFloat)fMaxSize durationPerBeat:(NSTimeInterval)fDurationPerBeat completion:(void (^)(BOOL finished))completion;

{
    if (fDurationPerBeat > 0.1f)
    {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];

        CATransform3D scale1 = CATransform3DMakeScale(0.8, 0.8, 1);
        CATransform3D scale2 = CATransform3DMakeScale(fMaxSize, fMaxSize, 1);
        CATransform3D scale3 = CATransform3DMakeScale(fMaxSize - 0.3f, fMaxSize - 0.3f, 1);
        CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);

        NSArray *frameValues = [NSArray arrayWithObjects:
                                [NSValue valueWithCATransform3D:scale1],
                                [NSValue valueWithCATransform3D:scale2],
                                [NSValue valueWithCATransform3D:scale3],
                                [NSValue valueWithCATransform3D:scale4],
                                nil];

        [animation setValues:frameValues];

        NSArray *frameTimes = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.05],
                               [NSNumber numberWithFloat:0.2],
                               [NSNumber numberWithFloat:0.6],
                               [NSNumber numberWithFloat:1.0],
                               nil];
        [animation setKeyTimes:frameTimes];

        animation.fillMode = kCAFillModeForwards;
        animation.duration = fDurationPerBeat;
        animation.repeatCount = fDuration/fDurationPerBeat;
        
        [animation setBm_completion:completion];

        [self.layer addAnimation:animation forKey:@"heartbeatView"];
    }
}

// 抖动动画
- (void)bm_shakeDuration:(NSTimeInterval)fDuration
{
    if (fDuration >= 0.1f)
    {
        CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //设置抖动幅度
        shake.fromValue = [NSNumber numberWithFloat:-0.3];
        shake.toValue = [NSNumber numberWithFloat:+0.3];
        shake.duration = 0.1f;
        shake.repeatCount = fDuration/4/0.1f;
        shake.autoreverses = YES;
        [self.layer addAnimation:shake forKey:@"shakeView"];
    }
}

- (void)bm_shakeHorizontally
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.5;
    animation.values = @[@(-12), @(12), @(-8), @(8), @(-4), @(4), @(0) ];
    
    [self.layer addAnimation:animation forKey:@"shake"];
}


- (void)bm_shakeVertically
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.5;
    animation.values = @[@(-12), @(12), @(-8), @(8), @(-4), @(4), @(0) ];
    
    [self.layer addAnimation:animation forKey:@"shake"];
}


- (void)bm_applyMotionEffects
{
    // Motion effects are available starting from iOS 7.
    if (([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending))
    {
        
        UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                                        type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        horizontalEffect.minimumRelativeValue = @(-10.0f);
        horizontalEffect.maximumRelativeValue = @( 10.0f);
        UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                                      type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        verticalEffect.minimumRelativeValue = @(-10.0f);
        verticalEffect.maximumRelativeValue = @( 10.0f);
        UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
        motionEffectGroup.motionEffects = @[horizontalEffect, verticalEffect];
        
        [self addMotionEffect:motionEffectGroup];
    }
}


- (void)bm_pulseToSize:(CGFloat)scale
              duration:(NSTimeInterval)duration
                repeat:(BOOL)repeat
{
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    pulseAnimation.duration = duration;
    pulseAnimation.toValue = [NSNumber numberWithFloat:scale];
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = repeat ? HUGE_VALF : 0;
    
    [self.layer addAnimation:pulseAnimation
                      forKey:@"pulse"];
}


- (void)bm_flipWithDuration:(NSTimeInterval)duration
                  direction:(BMUIViewAnimationFlipDirection)direction
                repeatCount:(NSUInteger)repeatCount
                autoreverse:(BOOL)shouldAutoreverse
{
    NSString *subtype = nil;
    
    switch (direction)
    {
        case BMUIViewAnimationFlipDirectionFromTop:
            subtype = @"fromTop";
            break;
        case BMUIViewAnimationFlipDirectionFromLeft:
            subtype = @"fromLeft";
            break;
        case BMUIViewAnimationFlipDirectionFromBottom:
            subtype = @"fromBottom";
            break;
        case BMUIViewAnimationFlipDirectionFromRight:
        default:
            subtype = @"fromRight";
            break;
    }
    
    CATransition *transition = [CATransition animation];
    
    transition.startProgress = 0;
    transition.endProgress = 1.0;
    transition.type = @"flip";
    transition.subtype = subtype;
    transition.duration = duration;
    transition.repeatCount = repeatCount;
    transition.autoreverses = shouldAutoreverse;
    
    [self.layer addAnimation:transition
                      forKey:@"spin"];
}


- (void)bm_rotateToAngle:(CGFloat)angle
                duration:(NSTimeInterval)duration
               direction:(BMUIViewAnimationRotationDirection)direction
             repeatCount:(NSUInteger)repeatCount
             autoreverse:(BOOL)shouldAutoreverse;
{
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    rotationAnimation.toValue = @(direction == BMUIViewAnimationRotationDirectionRight ? angle : -angle);
    rotationAnimation.duration = duration;
    rotationAnimation.autoreverses = shouldAutoreverse;
    rotationAnimation.repeatCount = repeatCount;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.layer addAnimation:rotationAnimation
                      forKey:@"transform.rotation.z"];
}

- (void)bm_rotateFromAngle:(CGFloat)angle
                  duration:(NSTimeInterval)duration
                 direction:(BMUIViewAnimationRotationDirection)direction
               repeatCount:(NSUInteger)repeatCount
               autoreverse:(BOOL)shouldAutoreverse;
{
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    rotationAnimation.fromValue = @(angle);
    rotationAnimation.toValue = @(direction == BMUIViewAnimationRotationDirectionRight ? 2*M_PI+angle : -2*M_PI+angle);
    rotationAnimation.duration = duration;
    rotationAnimation.autoreverses = shouldAutoreverse;
    rotationAnimation.repeatCount = repeatCount;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.layer addAnimation:rotationAnimation
                      forKey:@"transform.rotation.z"];
}


- (void)bm_stopAnimation
{
    [CATransaction begin];
    [self.layer removeAllAnimations];
    [CATransaction commit];
    
    [CATransaction flush];
}


- (BOOL)bm_isBeingAnimated
{
    return [self.layer.animationKeys count];
}


@end

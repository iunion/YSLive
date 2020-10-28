/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDWebImageTransition.h"

#if BMSD_UIKIT || BMSD_MAC

#if BMSD_MAC
#import "BMSDWebImageTransitionInternal.h"
#import "BMSDInternalMacros.h"

CAMediaTimingFunction * BMSDTimingFunctionFromAnimationOptions(BMSDWebImageAnimationOptions options) {
    if (SD_OPTIONS_CONTAINS(BMSDWebImageAnimationOptionCurveLinear, options)) {
        return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    } else if (SD_OPTIONS_CONTAINS(BMSDWebImageAnimationOptionCurveEaseIn, options)) {
        return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    } else if (SD_OPTIONS_CONTAINS(BMSDWebImageAnimationOptionCurveEaseOut, options)) {
        return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    } else if (SD_OPTIONS_CONTAINS(BMSDWebImageAnimationOptionCurveEaseInOut, options)) {
        return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    } else {
        return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    }
}

CATransition * BMSDTransitionFromAnimationOptions(BMSDWebImageAnimationOptions options) {
    if (SD_OPTIONS_CONTAINS(options, BMSDWebImageAnimationOptionTransitionCrossDissolve)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionFade;
        return trans;
    } else if (SD_OPTIONS_CONTAINS(options, BMSDWebImageAnimationOptionTransitionFlipFromLeft)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromLeft;
        return trans;
    } else if (SD_OPTIONS_CONTAINS(options, BMSDWebImageAnimationOptionTransitionFlipFromRight)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromRight;
        return trans;
    } else if (SD_OPTIONS_CONTAINS(options, BMSDWebImageAnimationOptionTransitionFlipFromTop)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromTop;
        return trans;
    } else if (SD_OPTIONS_CONTAINS(options, BMSDWebImageAnimationOptionTransitionFlipFromBottom)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionPush;
        trans.subtype = kCATransitionFromBottom;
        return trans;
    } else if (SD_OPTIONS_CONTAINS(options, BMSDWebImageAnimationOptionTransitionCurlUp)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionReveal;
        trans.subtype = kCATransitionFromTop;
        return trans;
    } else if (SD_OPTIONS_CONTAINS(options, BMSDWebImageAnimationOptionTransitionCurlDown)) {
        CATransition *trans = [CATransition animation];
        trans.type = kCATransitionReveal;
        trans.subtype = kCATransitionFromBottom;
        return trans;
    } else {
        return nil;
    }
}
#endif

@implementation BMSDWebImageTransition

- (instancetype)init {
    self = [super init];
    if (self) {
        self.duration = 0.5;
    }
    return self;
}

@end

@implementation BMSDWebImageTransition (Conveniences)

+ (BMSDWebImageTransition *)fadeTransition {
    return [self fadeTransitionWithDuration:0.5];
}

+ (BMSDWebImageTransition *)fadeTransitionWithDuration:(NSTimeInterval)duration {
    BMSDWebImageTransition *transition = [BMSDWebImageTransition new];
    transition.duration = duration;
#if BMSD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = SDWebImageAnimationOptionTransitionCrossDissolve;
#endif
    return transition;
}

+ (BMSDWebImageTransition *)flipFromLeftTransition {
    return [self flipFromLeftTransitionWithDuration:0.5];
}

+ (BMSDWebImageTransition *)flipFromLeftTransitionWithDuration:(NSTimeInterval)duration {
    BMSDWebImageTransition *transition = [BMSDWebImageTransition new];
    transition.duration = duration;
#if BMSD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = SDWebImageAnimationOptionTransitionFlipFromLeft;
#endif
    return transition;
}

+ (BMSDWebImageTransition *)flipFromRightTransition {
    return [self flipFromRightTransitionWithDuration:0.5];
}

+ (BMSDWebImageTransition *)flipFromRightTransitionWithDuration:(NSTimeInterval)duration {
    BMSDWebImageTransition *transition = [BMSDWebImageTransition new];
    transition.duration = duration;
#if BMSD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = SDWebImageAnimationOptionTransitionFlipFromRight;
#endif
    return transition;
}

+ (BMSDWebImageTransition *)flipFromTopTransition {
    return [self flipFromTopTransitionWithDuration:0.5];
}

+ (BMSDWebImageTransition *)flipFromTopTransitionWithDuration:(NSTimeInterval)duration {
    BMSDWebImageTransition *transition = [BMSDWebImageTransition new];
    transition.duration = duration;
#if BMSD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromTop | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = SDWebImageAnimationOptionTransitionFlipFromTop;
#endif
    return transition;
}

+ (BMSDWebImageTransition *)flipFromBottomTransition {
    return [self flipFromBottomTransitionWithDuration:0.5];
}

+ (BMSDWebImageTransition *)flipFromBottomTransitionWithDuration:(NSTimeInterval)duration {
    BMSDWebImageTransition *transition = [BMSDWebImageTransition new];
    transition.duration = duration;
#if BMSD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionFlipFromBottom | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = BMSDWebImageAnimationOptionTransitionFlipFromBottom;
#endif
    return transition;
}

+ (BMSDWebImageTransition *)curlUpTransition {
    return [self curlUpTransitionWithDuration:0.5];
}

+ (BMSDWebImageTransition *)curlUpTransitionWithDuration:(NSTimeInterval)duration {
    BMSDWebImageTransition *transition = [BMSDWebImageTransition new];
    transition.duration = duration;
#if BMSD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionCurlUp | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = BMSDWebImageAnimationOptionTransitionCurlUp;
#endif
    return transition;
}

+ (BMSDWebImageTransition *)curlDownTransition {
    return [self curlDownTransitionWithDuration:0.5];
}

+ (BMSDWebImageTransition *)curlDownTransitionWithDuration:(NSTimeInterval)duration {
    BMSDWebImageTransition *transition = [BMSDWebImageTransition new];
    transition.duration = duration;
#if BMSD_UIKIT
    transition.animationOptions = UIViewAnimationOptionTransitionCurlDown | UIViewAnimationOptionAllowUserInteraction;
#else
    transition.animationOptions = BMSDWebImageAnimationOptionTransitionCurlDown;
#endif
    transition.duration = duration;
    return transition;
}

@end

#endif

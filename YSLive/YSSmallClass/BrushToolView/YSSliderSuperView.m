//
//  YSSliderSuperView.m
//  YSAll
//
//  Created by fzxm on 2020/1/9.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSSliderSuperView.h"

#define thumbBound_x 10.0f
#define thumbBound_y 20.0f

@interface YSSliderSuperView ()
{
    CGRect lastBounds;
}

@end

@implementation YSSliderSuperView

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    rect.origin.x = rect.origin.x;
    rect.size.width = rect.size.width;
    CGRect result = [super thumbRectForBounds:bounds trackRect:rect value:value];
    lastBounds = result;
    return result;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result = [super hitTest:point withEvent:event];
    if (point.x < 0 || point.x > self.bounds.size.width)
    {
        return result;
    }

    if ((point.y >= -thumbBound_y) && (point.y < lastBounds.size.height + thumbBound_y))
    {
        float value = 0.0f;
        value = point.x - self.bounds.origin.x;
        value = value/self.bounds.size.width;
        value = value < 0 ? 0 : value;
        value = value > 1 ? 1: value;
        value = value * (self.maximumValue - self.minimumValue) + self.minimumValue;
        [self setValue:value animated:YES];
    }
    return result;
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL result = [super pointInside:point withEvent:event];
    
    if (!result && point.y > -10.0f)
    {
        if ((point.x >= lastBounds.origin.x - thumbBound_x) && (point.x <= (lastBounds.origin.x + lastBounds.size.width + thumbBound_x)) && (point.y < (lastBounds.size.height + thumbBound_y)))
        {
            result = YES;
        }
        
    }
    return result;
}

@end

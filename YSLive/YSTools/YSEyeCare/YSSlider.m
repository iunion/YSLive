//
//  YSSlider.m
//  YSAll
//
//  Created by jiang deng on 2019/12/25.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSSlider.h"

@implementation YSSlider

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    UIImage *image = self.currentThumbImage;
    if (image)
    {
        rect.origin.x = rect.origin.x-image.size.width*0.5;
        rect.size.width = rect.size.width+image.size.width;

        return CGRectInset([super thumbRectForBounds:bounds trackRect:rect value:value],image.size.width*0.5,image.size.width*0.5);
    }
    
    return [super thumbRectForBounds:bounds trackRect:rect value:value];
}

@end

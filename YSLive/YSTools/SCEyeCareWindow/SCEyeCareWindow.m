//
//  SCEyeCareWindow.m
//  YSAll
//
//  Created by jiang deng on 2019/12/26.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCEyeCareWindow.h"

static NSInteger const kYSEyeCareWindowLevel = 2100;

@implementation SCEyeCareWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.windowLevel = kYSEyeCareWindowLevel;
        self.backgroundColor = [UIColor bm_colorWithHex:0x999999 alpha:0.5];
    }
    
    return self;
}

@end

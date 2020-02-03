//
//  YSEyeCareMaskView.m
//  YSAll
//
//  Created by jiang deng on 2019/12/25.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSEyeCareMaskView.h"

@implementation YSEyeCareMaskView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI
{
    self.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0.5f;
}

@end

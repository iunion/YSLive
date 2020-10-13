//
//  BMCountDownButton.m
//  BMKit
//
//  Created by njy on 2020/10/13.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#import "BMCountDownButton.h"

@interface BMCountDownButton ()

@end

@implementation BMCountDownButton

- (instancetype)initWithFrame:(CGRect)frame startTitle:(NSString *)startTitle durationTitle:(NSString *)durationTitle endTitle:(NSString *)endTitle seconds:(NSInteger)seconds countDownBlock:(BMCountDownBlock)countDownBlock
{
    if (self = [super initWithFrame:frame])
    {
        _startTitle = startTitle;
        _durationTitle = durationTitle;
        _endTitle = endTitle;
        _seconds = seconds;
        _countDownBlock = countDownBlock;
        [self creatUI];
        
    }
    return self;
}

- (void)creatUI
{
    
}

@end

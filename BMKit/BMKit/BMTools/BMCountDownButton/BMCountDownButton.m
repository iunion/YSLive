//
//  BMCountDownButton.m
//  BMKit
//
//  Created by njy on 2020/10/13.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#import "BMCountDownButton.h"

@interface BMCountDownButton ()

@property (nonatomic, assign) BMCountDownButtonState countState;

@end

@implementation BMCountDownButton

- (instancetype)initWithFrame:(CGRect)frame seconds:(NSInteger)seconds countDownBlock:(BMCountDownBlock)countDownBlock
{
    if (self = [super initWithFrame:frame])
    {
//        _startTitle = startTitle;
//        _durationTitle = durationTitle;
//        _endTitle = endTitle;
        _seconds = seconds;
        _countDownBlock = countDownBlock;
        _countState = BMCountDownButtonStateStart;
 
        
        [self addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)buttonClicked
{
    BMWeakSelf
    
    if (self.countState == BMCountDownButtonStateStart)
    {
        self.countState = BMCountDownButtonStateDuration;
        [self startCountDown];
    }
    else if(self.countState == BMCountDownButtonStateDuration)
    {
        NSInteger seconds = [[BMCountDownManager manager] timeIntervalWithIdentifier:@"CountDownButton"];
        if (self.countDownBlock)
        {
            self.countDownBlock(self, BMCountDownButtonStateDuration, seconds);
        }
    }
    else
    {
        if (self.countDownBlock)
        {
            self.countDownBlock(self, BMCountDownButtonStateEnd, 0);
        }
    }
}

- (void)startCountDown
{
    BMWeakSelf
    [[BMCountDownManager manager] startCountDownWithIdentifier:@"CountDownButton" timeInterval:self.seconds processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL forcedStop) {
        
        BMCountDownButtonState state = BMCountDownButtonStateDuration;
        if (timeInterval == 0)
        {
            state = BMCountDownButtonStateEnd;
        }
        weakSelf.countState = state;
    }];
}

@end

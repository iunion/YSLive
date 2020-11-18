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

- (instancetype)initWithFrame:(CGRect)frame seconds:(NSUInteger)seconds countDownBlock:(BMCountDownBlock)countDownBlock clickedBlock:(nonnull BMCountDownClickedBlock)clickedBlock
{
    if (self = [super initWithFrame:frame])
    {
//        _startTitle = startTitle;
//        _durationTitle = durationTitle;
//        _endTitle = endTitle;
        _seconds = seconds;
        _countDownBlock = countDownBlock;
        _clickedBlock = clickedBlock;
        _countState = BMCountDownButtonStateStart;
        
        [self addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)buttonClicked
{
    if (self.countState == BMCountDownButtonStateStart)
    {
        self.countState = BMCountDownButtonStateDuration;
        if (self.clickedBlock)
        {
            self.clickedBlock(self, BMCountDownButtonStateStart, 0);
        }
    }
    else if(self.countState == BMCountDownButtonStateDuration)
    {
        NSInteger seconds = [[BMCountDownManager manager] timeIntervalWithIdentifier:@"CountDownButton"];
        if (self.clickedBlock)
        {
            self.clickedBlock(self, BMCountDownButtonStateDuration, seconds);
        }
    }
    else
    {
        if (self.clickedBlock)
        {
            self.clickedBlock(self, BMCountDownButtonStateEnd, 0);
        }
    }
}

- (void)startCountDown
{
    BMWeakSelf
    [[BMCountDownManager manager] startCountDownWithIdentifier:@"CountDownButton" timeInterval:self.seconds processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL reStart, BOOL forcedStop) {
        
        BMCountDownButtonState state = BMCountDownButtonStateDuration;
        if (timeInterval == 0)
        {
            state = BMCountDownButtonStateEnd;
        }
        weakSelf.countState = state;
        if (self.countDownBlock)
        {
            self.countDownBlock(self, state, timeInterval);
        }
    }];
}

@end

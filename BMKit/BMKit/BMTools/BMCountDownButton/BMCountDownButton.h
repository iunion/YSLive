//
//  BMCountDownButton.h
//  BMKit
//
//  Created by njy on 2020/10/13.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BMCountDownButton;
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BMCountDownButtonState){
    BMCountDownButtonStateStart = 0,
    BMCountDownButtonStateDuration,
    BMCountDownButtonStateEnd
};

typedef void (^BMCountDownClickedBlock)(BMCountDownButton *button, BMCountDownButtonState state, NSInteger seconds);
typedef void (^BMCountDownBlock)(BMCountDownButton *button, BMCountDownButtonState state, NSInteger seconds);

@interface BMCountDownButton : UIButton
/// 倒计时时间
@property (nonatomic, assign) NSInteger seconds;
/// 倒计时回调
@property (nonatomic, strong) BMCountDownBlock countDownBlock;
/// 点击回调
@property (nonatomic, strong) BMCountDownBlock clickedBlock;


- (instancetype)initWithFrame:(CGRect)frame
                      seconds:(NSInteger)seconds
               countDownBlock:(BMCountDownBlock)countDownBlock
                 clickedBlock:(BMCountDownClickedBlock)clickedBlock;
- (void)startCountDown;

@end

NS_ASSUME_NONNULL_END

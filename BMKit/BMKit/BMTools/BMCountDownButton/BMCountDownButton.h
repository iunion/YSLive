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

typedef void (^BMCountDownBlock)(BMCountDownButton *button, BMCountDownButtonState state, NSString *seconds);

@interface BMCountDownButton : UIButton
/// 倒计时时间
@property (nonatomic, assign) NSInteger seconds;
/// 倒计时点击回调
@property (nonatomic, strong) BMCountDownBlock countDownBlock;
/// 开始标题
@property (nonatomic, strong) NSString *startTitle;
/// 倒计时标题
@property (nonatomic, strong) NSString *durationTitle;
/// 结束标题
@property (nonatomic, strong) NSString *endTitle;

- (instancetype)initWithFrame:(CGRect)frame startTitle:(NSString *)startTitle durationTitle:(NSString *)durationTitle endTitle:(NSString *)endTitle seconds:(NSInteger)seconds countDownBlock:(BMCountDownBlock )countDownBlock;


@end

NS_ASSUME_NONNULL_END

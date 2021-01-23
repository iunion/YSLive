//
//  YSPollingView.m
//  YSLive
//
//  Created by 宁杰英 on 2020/3/24.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSPollingView.h"


#define backViewWidth 333
#define backViewHeight 229

#define maxSecond 99
#define minSecond 10
@interface YSPollingView()
<
    BMStepperInputViewDelegate,
    UIGestureRecognizerDelegate
>
{
    NSInteger _second;
}

/// 底部view
@property (nonatomic, strong) UIView *bacView;
/// 关闭按钮
@property (nonatomic, strong) UIButton *closeBtn;

/// 轮播时间
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *timeView;
/// 时间
@property (nonatomic, strong) UILabel *timeLabel;
/// 增
@property (nonatomic, strong) UIButton *upBtn;
/// 减
@property (nonatomic, strong) UIButton *downBtn;
/// 秒/次
@property (nonatomic, strong) UILabel *secondLabel;
/// 确定
@property (nonatomic, strong) UIButton *sureBtn;


@property(nonatomic, strong) BMStepperInputView *stepperInputView;
@end


@implementation YSPollingView
- (instancetype)init
{
    NSUInteger noticeViewCount = [[BMNoticeViewStack sharedInstance] getNoticeViewCount];
    if (noticeViewCount >= BMNOTICEVIEW_MAXSHOWCOUNT)
    {
        return nil;
    }
    
    self = [super init];
    
    if (self)
    {
        self.showAnimationType = BMNoticeViewShowAnimationNone;
        self.noticeMaskBgEffect = nil;
        self.shouldDismissOnTapOutside = NO;
        self.noticeMaskBgEffectView.alpha = 1;
        self.noticeMaskBgColor = [UIColor bm_colorWithHex:0x000000 alpha:0.6];
    }
    return self;
}

- (void)showTeacherPollingViewInView:(UIView *)inView
backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets
         topDistance:(CGFloat)topDistance
{
    _second = 20;
    self.topDistance = topDistance;
    self.backgroundEdgeInsets = backgroundEdgeInsets;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClicked:)];
    tapGesture.delegate =self;
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGesture];
    
    self.bacView = [[UIView alloc] init];
    self.bacView.backgroundColor = [YSSkinDefineColor(@"Color2") bm_changeAlpha:YSPopViewDefaultAlpha];
    self.bacView.bm_width = backViewWidth;
    self.bacView.bm_height = backViewHeight;
    self.bacView.layer.cornerRadius = 26;
    self.bacView.layer.masksToBounds = YES;
    [self showWithView:self.bacView inView:inView];
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeBtn setImage:YSSkinDefineImage(@"close_btn_icon") forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.closeBtn.hidden = NO;
    [self.bacView addSubview:self.closeBtn];
    self.closeBtn.frame = CGRectMake(0, 0, 25, 25);
    self.closeBtn.bm_right = self.bacView.bm_right - 23;
    self.closeBtn.bm_top = self.bacView.bm_top + 23;
    
    self.titleLabel = [[UILabel alloc] init];
    [self.bacView addSubview:self.titleLabel];
    self.titleLabel.textAlignment= NSTextAlignmentLeft;
    self.titleLabel.textColor = YSSkinDefineColor(@"Color3");
    self.titleLabel.font = UI_FONT_12;
    self.titleLabel.text = YSLocalized(@"Polling.Time");
    self.titleLabel.frame = CGRectMake(30, 80, 70, 25);
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.stepperInputView = [[BMStepperInputView alloc] initWithFrame:CGRectMake(100, 100, 120.0f, 42.0f)];
    [self.bacView addSubview:self.stepperInputView];
    
    self.stepperInputView.bm_centerY = self.titleLabel.bm_centerY;
    self.stepperInputView.bm_left = self.titleLabel.bm_right + 8;
    self.stepperInputView.backgroundColor = YSSkinDefineColor(@"Color2");
    
    
    self.stepperInputView.delegate = self;
    
    self.stepperInputView.minNumberValue = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%@",@(minSecond)]];
    self.stepperInputView.maxNumberValue = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%@",@(maxSecond)]];
    self.stepperInputView.numberValue = [[NSDecimalNumber alloc] initWithString:[NSString stringWithFormat:@"%@",@(_second)]];;
    
    // 递增步长，默认步长为1
    //        self.stepperInputView.stepNumberValue = self.item.stepNumberValue;
    
    // 是否可以使用键盘输入，默认YES
    self.stepperInputView.useKeyBord = YES;
    
    // 数字颜色
    self.stepperInputView.numberColor = YSSkinDefineColor(@"Color3");
    // 数字字体
    self.stepperInputView.numberFont = UI_FONT_18;
    
    // 边框颜色
    self.stepperInputView.borderColor = [UIColor clearColor];
    //            // 边框线宽
    self.stepperInputView.borderWidth = 1;
    [self.stepperInputView bm_addShadow:1 Radius:21 BorderColor:YSSkinDefineColor(@"Color4") ShadowColor:YSSkinDefineColor(@"Color2") Offset:CGSizeMake(0, 1) Opacity:0.5];
    // 加按钮背景图片
    self.stepperInputView.increaseImage = YSSkinElementImage(@"polling_add", @"iconNor");
    // 减按钮背景图片
    self.stepperInputView.decreaseImage = YSSkinElementImage(@"polling_subtract", @"iconNor");
    
    // 长按加减的触发时间间隔,默认0.2s
    //               self.stepperInputView.longPressSpaceTime = 10;
    
    // 第一阶段加速倍数，默认1，加速值为firstMultiple*stepNumberValue
    //           self.stepperInputView.firstMultiple = self.item.firstMultiple;
    // 开始第二阶段加速倍数计数点，默认10
    self.stepperInputView.secondTimeCount = 5;
    // 第二阶段加速倍数，默认10，一般大于firstMultiple
    //           self.stepperInputView.secondMultiple = self.item.secondMultiple;
    
    // 最小值时隐藏减号按钮，默认NO
    //           self.stepperInputView.minHideDecrease = self.item.minHideDecrease;
    // 是否开启抖动动画，默认NO，minHideDecrease为YES时不执行动画
    //           self.stepperInputView.limitShakeAnimation = self.item.limitShakeAnimation;
    
    //           self.enabled = self.item.enabled;
    //               self.stepperable = self.item.stepperable;
    
    
    //
    //    self.timeView = [[UIView alloc] init];
    //    [self.bacView addSubview:self.timeView];
    //    self.timeView.frame = CGRectMake(0, 0, 120, 42);
    //    self.timeView.bm_centerY = self.titleLabel.bm_centerY;
    //    self.timeView.bm_left = self.titleLabel.bm_right + 8;
    //    self.timeView.backgroundColor = [UIColor bm_colorWithHex:0xDEEAFF alpha:0.5];
    //    [self.timeView bm_addShadow:1 Radius:21 BorderColor:[UIColor bm_colorWithHex:0x5A8CDC] ShadowColor:[UIColor whiteColor] Offset:CGSizeMake(0, 1) Opacity:0.5];
    //
    //    self.timeLabel = [[UILabel alloc] init];
    //    [self.timeView addSubview:self.timeLabel];
    //    self.timeLabel.textAlignment= NSTextAlignmentCenter;
    //    self.timeLabel.textColor = [UIColor bm_colorWithHex:0x5A8CDC];
    //    self.timeLabel.font = [UIFont systemFontOfSize:21.0f];
    //    self.timeLabel.text = [NSString stringWithFormat:@"%@",@(_second)];
    //    self.timeLabel.frame = CGRectMake(40, 8, 30, 25);
    //
    //    self.upBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [self.upBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_up_normal"] forState:UIControlStateNormal];
    //    [self.upBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_up_disabled"] forState:UIControlStateDisabled];
    //    [self.upBtn addTarget:self action:@selector(upBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.timeView addSubview:self.upBtn];
    //    self.upBtn.frame = CGRectMake(0, 6, 14, 10);
    //    self.upBtn.bm_left = self.timeLabel.bm_right + 14;
    //
    //    self.downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [self.downBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_down_normal"] forState:UIControlStateNormal];
    //    [self.downBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_down_disabled"] forState:UIControlStateDisabled];
    //    [self.downBtn addTarget:self action:@selector(downBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.timeView addSubview:self.downBtn];
    //    self.downBtn.frame = CGRectMake(0, 0, 14, 10);
    //    self.downBtn.bm_left = self.timeLabel.bm_right + 14;
    //    self.downBtn.bm_top = self.upBtn.bm_bottom + 10;
    //
    self.secondLabel = [[UILabel alloc] init];
    [self.bacView addSubview:self.secondLabel];
    self.secondLabel.textAlignment= NSTextAlignmentLeft;
    self.secondLabel.textColor = YSSkinDefineColor(@"Color3");
    self.secondLabel.font = UI_FONT_12;
    self.secondLabel.text = YSLocalized(@"Polling.second");
    self.secondLabel.frame = CGRectMake(0, 0, 80, 25);
    self.secondLabel.bm_centerY = self.titleLabel.bm_centerY;
    self.secondLabel.bm_left = self.stepperInputView.bm_right + 15;
    self.secondLabel.adjustsFontSizeToFitWidth = YES;
    
    self.sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sureBtn setTitle: YSLocalized(@"Prompt.OK") forState:UIControlStateNormal];
    [self.sureBtn addTarget:self action:@selector(sureBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacView addSubview:self.sureBtn];
    [self.sureBtn setBackgroundColor:YSSkinDefineColor(@"Color4")];
    self.sureBtn.frame = CGRectMake(0, self.bacView.bm_height - 80, 147, 40);
    self.sureBtn.bm_centerX = self.bacView.bm_centerX;
    [self.sureBtn setTitleColor:YSSkinDefineColor(@"Color3") forState:UIControlStateNormal];
    self.sureBtn.titleLabel.font = UI_FONT_16;
    self.sureBtn.layer.cornerRadius = 20;
    self.sureBtn.layer.masksToBounds = YES;
//    [self.sureBtn bm_addShadow:3 Radius:20 BorderColor:[UIColor bm_colorWithHex:0x97B7EB] ShadowColor:[UIColor grayColor] Offset:CGSizeMake(0, 5) Opacity:0.5];
}



#pragma mark - SEL

- (void)closeBtnClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(closePollingView)])
    {
        [self.delegate closePollingView];
    }

    [self dismiss:nil animated:NO dismissBlock:nil];
}

- (void)sureBtnClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(startPollingWithTime:)])
    {
        if (_second < minSecond)
        {
            _second = minSecond;
        }
        if (_second > maxSecond)
        {
            _second = maxSecond;
        }
        [self.delegate startPollingWithTime:_second];
    }
}

//- (void)upBtnClicked:(UIButton *)btn
//{
//    _second++;
//    self.downBtn.enabled = YES;
//    if (_second >= maxSecond)
//    {
//        self.upBtn.enabled = NO;
//        _second = maxSecond;
//    }
//    self.timeLabel.text = [NSString stringWithFormat:@"%02ld", (long)_second];
//}
//
//- (void)downBtnClicked:(UIButton *)btn
//{
//    //减
//    _second--;
//    self.upBtn.enabled = YES;
//    if (_second <= minSecond)
//    {
//        _second = minSecond;
//        self.downBtn.enabled = NO;
//    }
//    self.timeLabel.text = [NSString stringWithFormat:@"%02ld",(long)_second];
//
//}




- (void)stepperInputView:(BMStepperInputView *)stepperInputView changeToNumber:(NSDecimalNumber *)number stepStatus:(BMStepperInputViewStepStatus)stepStatus
{
    _second = [number integerValue];
    if ([number integerValue] < minSecond)
    {
        _second = minSecond;
    }
    if ([number integerValue] > maxSecond)
    {
        _second = maxSecond;
    }
}

- (void)tapGestureClicked:(UITapGestureRecognizer *)tap
{
    [self endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.bacView] )
    {
        [self endEditing:YES];
        return NO;
    }
    else
    {
        return YES;
    }
}
@end

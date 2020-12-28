//
//  YSTeacherTimerView.m
//  YSAll
//
//  Created by 宁杰英 on 2020/2/20.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSTeacherTimerView.h"
#define backViewWidth 320
#define backViewHeight 220

#define backImageWidth 268
#define backImageHeight 180

#define maxMinute 99
#define minMinute 0
#define maxSecond 59
#define minSecond 0
@interface YSTeacherTimerView()
@property (nonatomic, assign) YSTeacherTimerViewType timerType;
/// 底部view
@property (nonatomic, strong) UIView *bacView;

/// 关闭按钮
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UILabel *titleL;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *intervalL;

@property (nonatomic, strong) UIButton *minuteUpBtn;
@property (nonatomic, strong) UILabel *minuteL;
@property (nonatomic, strong) UIButton *minuteDownBtn;

@property (nonatomic, strong) UIButton *secondUpBtn;
@property (nonatomic, strong) UILabel *secondL;
@property (nonatomic, strong) UIButton *secondDownBtn;

/// 开始计时
@property (nonatomic, strong) UIButton *startBtn;

/// 重置
@property (nonatomic, strong) UIButton *resetBtn;
///// 暂停 继续
//@property (nonatomic, strong) UIButton *pauseBtn;

@property (nonatomic, assign) NSInteger minute;
@property (nonatomic, assign) NSInteger second;

@property (nonatomic, strong) UILabel *endTitleL;
@property (nonatomic, strong) UIImageView *endImageV;
@end

@implementation YSTeacherTimerView

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
        self.isPenetration = YES;
        
        self.showAnimationType = BMNoticeViewShowAnimationNone;
        self.noticeMaskBgEffect = nil;
        self.shouldDismissOnTapOutside = NO;
        self.noticeMaskBgEffectView.alpha = 1;
        self.noticeMaskBgColor = [UIColor bm_colorWithHex:0x000000 alpha:0.6];
    }
    return self;
}

- (void)showYSTeacherTimerViewInView:(UIView *)inView
                backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets
                         topDistance:(CGFloat)topDistance
{
    self.topDistance = topDistance;
    self.backgroundEdgeInsets = backgroundEdgeInsets;
    
    self.minute = 5;
    self.second = 0;
    
    self.bacView = [[UIView alloc] init];
    self.bacView.backgroundColor = [YSSkinDefineColor(@"Color2") changeAlpha:YSPopViewDefaultAlpha];
    
    self.bacView.bm_width = backViewWidth;
    self.bacView.bm_height = backViewHeight;
    [self showWithView:self.bacView inView:inView];
    [self.bacView bm_roundedRect:10.0f];
    
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeBtn setImage:YSSkinDefineImage(@"close_btn_icon") forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.closeBtn.hidden = NO;
    [self.bacView addSubview:self.closeBtn];
    self.closeBtn.frame = CGRectMake(0, 0, 25, 25);
    self.closeBtn.bm_right = self.bacView.bm_right - 5;
    self.closeBtn.bm_top = self.bacView.bm_top + 5;
    
    self.titleL = [[UILabel alloc] init];
    [self.bacView addSubview:self.titleL];
    self.titleL.textAlignment= NSTextAlignmentCenter;
    self.titleL.textColor = YSSkinDefineColor(@"Color3");
    self.titleL.font = UI_FONT_16;
    self.titleL.text = YSLocalized(@"tool.jishiqi");
    self.titleL.frame = CGRectMake(30, 10, self.bacView.bm_width - 60, 40);
    
    UIView *lineView = [[UIView alloc] init];
    [self.bacView addSubview:lineView];
    lineView.backgroundColor = YSSkinDefineColor(@"Color7");
    lineView.frame = CGRectMake(0, CGRectGetMaxY(self.titleL.frame), self.bacView.bm_width, 1);
    self.lineView = lineView;
    
    self.intervalL = [[UILabel alloc] init];
    [self.bacView addSubview:self.intervalL];
    self.intervalL.textAlignment= NSTextAlignmentCenter;
    self.intervalL.textColor = YSSkinDefineColor(@"Color3");
    self.intervalL.font = [UIFont systemFontOfSize:30.0f];
    self.intervalL.text = @":";
    self.intervalL.frame = CGRectMake(0, 50, 9, 42);
    self.intervalL.bm_centerX = self.titleL.bm_centerX;
    self.intervalL.bm_top = self.titleL.bm_bottom + 30;
    
    self.minuteL = [[UILabel alloc] init];
    [self.bacView addSubview:self.minuteL];
    self.minuteL.textAlignment= NSTextAlignmentCenter;
    self.minuteL.textColor = YSSkinDefineColor(@"Color3");
    self.minuteL.backgroundColor = YSSkinDefineColor(@"Color7");
        
    self.minuteL.font = [UIFont fontWithName:@"Helvetica" size:42.0f];
    self.minuteL.frame = CGRectMake(0, 0, 70, 42);
    self.minuteL.bm_right = self.intervalL.bm_left - 18;
    self.minuteL.bm_centerY = self.intervalL.bm_centerY;
    self.minuteL.layer.cornerRadius = 3;
    self.minuteL.layer.masksToBounds = YES;
    self.minuteL.text = @"05";
    
    
    self.minuteUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.minuteUpBtn setBackgroundImage:YSSkinElementImage(@"timer_up", @"iconNor") forState:UIControlStateNormal];
    [self.minuteUpBtn setBackgroundImage:YSSkinElementImage(@"timer_up", @"iconHigh") forState:UIControlStateHighlighted];
    UIImage * minuteUpDisImage = [YSSkinElementImage(@"timer_up", @"iconNor") bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [self.minuteUpBtn setBackgroundImage:minuteUpDisImage forState:UIControlStateDisabled];
    [self.minuteUpBtn addTarget:self action:@selector(minuteUpBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacView addSubview:self.minuteUpBtn];
    self.minuteUpBtn.frame = CGRectMake(0, 0, 20, 12);
    self.minuteUpBtn.bm_centerX = self.minuteL.bm_centerX;
    self.minuteUpBtn.bm_bottom = self.minuteL.bm_top - 4;
    
    self.minuteDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.minuteDownBtn setBackgroundImage:YSSkinElementImage(@"timer_down", @"iconNor") forState:UIControlStateNormal];
    [self.minuteDownBtn setBackgroundImage:YSSkinElementImage(@"timer_down", @"iconHigh") forState:UIControlStateHighlighted];
    UIImage * minuteDownDisImage = [YSSkinElementImage(@"timer_down", @"iconNor") bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [self.minuteDownBtn setBackgroundImage:minuteDownDisImage forState:UIControlStateDisabled];
    [self.minuteDownBtn addTarget:self action:@selector(minuteDownBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacView addSubview:self.minuteDownBtn];
    self.minuteDownBtn.frame = CGRectMake(0, 0, 20, 12);
    self.minuteDownBtn.bm_centerX = self.minuteL.bm_centerX;
    self.minuteDownBtn.bm_top = self.minuteL.bm_bottom + 4;
    
    self.secondL = [[UILabel alloc] init];
    [self.bacView addSubview:self.secondL];
    self.secondL.textAlignment= NSTextAlignmentCenter;
    self.secondL.textColor = YSSkinDefineColor(@"Color3");
    self.secondL.backgroundColor = YSSkinDefineColor(@"Color7");
    self.secondL.font = [UIFont fontWithName:@"Helvetica" size:42.0f];
    self.secondL.frame = CGRectMake(0, 0, 70, 42);
    self.secondL.bm_left = self.intervalL.bm_right + 18;
    self.secondL.bm_centerY = self.intervalL.bm_centerY;
    self.secondL.layer.cornerRadius = 3;
    self.secondL.layer.masksToBounds = YES;
    self.secondL.text = @"00";
    
    self.secondUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.secondUpBtn setBackgroundImage:YSSkinElementImage(@"timer_up", @"iconNor") forState:UIControlStateNormal];
    [self.secondUpBtn setBackgroundImage:YSSkinElementImage(@"timer_up", @"iconHigh") forState:UIControlStateHighlighted];
    UIImage * secondUpDisImage = [YSSkinElementImage(@"timer_up", @"iconNor") bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [self.secondUpBtn setBackgroundImage:secondUpDisImage forState:UIControlStateDisabled];
    [self.secondUpBtn addTarget:self action:@selector(secondUpBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacView addSubview:self.secondUpBtn];
    self.secondUpBtn.frame = CGRectMake(0, 0, 20, 12);
    self.secondUpBtn.bm_centerX = self.secondL.bm_centerX;
    self.secondUpBtn.bm_bottom = self.secondL.bm_top - 4;
    
    self.secondDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.secondDownBtn setBackgroundImage:YSSkinElementImage(@"timer_down", @"iconNor") forState:UIControlStateNormal];
    [self.secondDownBtn setBackgroundImage:YSSkinElementImage(@"timer_down", @"iconHigh") forState:UIControlStateHighlighted];
    UIImage * secondDownDisImage = [YSSkinElementImage(@"timer_down", @"iconNor") bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [self.secondDownBtn setBackgroundImage:secondDownDisImage forState:UIControlStateDisabled];
    [self.secondDownBtn addTarget:self action:@selector(secondDownBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacView addSubview:self.secondDownBtn];
    self.secondDownBtn.frame = CGRectMake(0, 0, 20, 12);
    self.secondDownBtn.bm_centerX = self.secondL.bm_centerX;
    self.secondDownBtn.bm_top = self.secondL.bm_bottom + 4;
    self.secondDownBtn.enabled = NO;
    
    self.startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startBtn setTitle: YSLocalized(@"Timer.btn.start") forState:UIControlStateNormal];
    [self.startBtn addTarget:self action:@selector(startBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacView addSubview:self.startBtn];
    self.startBtn.frame = CGRectMake(0, self.bacView.bm_height - 50, 90, 40);
    [self.startBtn setTitleColor:YSSkinDefineColor(@"Color3") forState:UIControlStateNormal];
    [self.startBtn setTitleColor:YSSkinDefineColor(@"Color2") forState:UIControlStateDisabled];
    [self.startBtn setBackgroundColor:YSSkinDefineColor(@"Color4")];
    self.startBtn.titleLabel.font = UI_FONT_12;
    [self.startBtn bm_roundedRect:20];
    self.startBtn.bm_centerX = self.titleL.bm_centerX;
    
    
    self.resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.resetBtn setImage:YSSkinElementImage(@"timer_reset", @"iconNor") forState:UIControlStateNormal];
    [self.resetBtn addTarget:self action:@selector(resetBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacView addSubview:self.resetBtn];
    
        
    self.pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pauseBtn setImage:YSSkinElementImage(@"timer_pause", @"iconNor") forState:UIControlStateNormal];
    [self.pauseBtn setImage:YSSkinElementImage(@"timer_pause", @"iconSel") forState:UIControlStateSelected];
    [self.pauseBtn addTarget:self action:@selector(pauseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacView addSubview:self.pauseBtn];
    
    self.endTitleL = [[UILabel alloc] init];
    [self.bacView addSubview:self.endTitleL];
    self.endTitleL.textAlignment= NSTextAlignmentCenter;
    self.endTitleL.textColor = YSSkinDefineColor(@"Color3");
    self.endTitleL.font = [UIFont systemFontOfSize:20.0f];
    self.endTitleL.text = YSLocalized(@"Timer.lab.end");

    self.endImageV = [[UIImageView alloc] init];
    [self.endImageV setImage:YSSkinElementImage(@"timer_end", @"iconNor")];
    [self.bacView addSubview:self.endImageV];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(contentPanGestureAction:)];
    [self.noticeView addGestureRecognizer:pan];
}

- (void)contentPanGestureAction:(UIPanGestureRecognizer *)panGesture
{
    UIView *panView = panGesture.view;
    
    //1、获得拖动位移
    CGPoint offsetPoint = [panGesture translationInView:panView];
    //2、清空拖动位移
    [panGesture setTranslation:CGPointZero inView:panView];
    //3、重新设置控件位置
    CGFloat newX = panView.bm_centerX+offsetPoint.x;
    CGFloat newY = panView.bm_centerY+offsetPoint.y;
    CGPoint centerPoint = CGPointMake(newX, newY);
    panView.center = centerPoint;
    
    if (panView.bm_top < 0)
    {
        panView.bm_top = 0;
    }
    if (panView.bm_left < 0)
    {
        panView.bm_left = 0;
    }
    
    if (panView.bm_bottom > BMUI_SCREEN_HEIGHT)
    {
        panView.bm_top = BMUI_SCREEN_HEIGHT - panView.bm_height;
    }
    if (panView.bm_right > BMUI_SCREEN_WIDTH)
    {
        panView.bm_left = BMUI_SCREEN_WIDTH - panView.bm_width;
    }
}

- (void)showResponderWithType:(YSTeacherTimerViewType)timerType
{
    self.timerType = timerType;

    if (timerType == YSTeacherTimerViewType_Start)
    {
        //开始
        self.minuteL.text = @"05";
        self.secondL.text = @"00";
        self.minute = 5;
        self.second = 0;
        self.secondDownBtn.enabled = NO;
        self.secondUpBtn.enabled = YES;
        self.minuteDownBtn.enabled = YES;
        self.minuteUpBtn.enabled = YES;
        [self setTimeCountBtnHide:NO];
        self.resetBtn.hidden = YES;
        self.pauseBtn.hidden = YES;
        self.endTitleL.hidden = YES;
        self.endImageV.hidden = YES;
        
        self.minuteL.hidden = NO;
        self.secondL.hidden = NO;
        self.intervalL.hidden = NO;
    }
    else if (timerType == YSTeacherTimerViewType_Ing)
    {
        //计时中
        [self setTimeCountBtnHide:YES];
        self.resetBtn.frame = CGRectMake(0, 0, 30, 30);
        self.resetBtn.bm_right = self.intervalL.bm_left - 16;
        self.resetBtn.bm_top = self.minuteL.bm_bottom + 24;
        self.resetBtn.hidden = NO;
        
        self.pauseBtn.hidden = NO;
        self.pauseBtn.frame = CGRectMake(0, 0, 30, 30);
        self.pauseBtn.bm_left = self.intervalL.bm_right + 16;
        self.pauseBtn.bm_top = self.secondL.bm_bottom + 24;

        self.endTitleL.hidden = YES;
        self.endImageV.hidden = YES;
        
        self.minuteL.hidden = NO;
        self.secondL.hidden = NO;
        self.intervalL.hidden = NO;
    }
    else if (timerType == YSTeacherTimerViewType_End)
    {
        //计时结束
        [self setTimeCountBtnHide:YES];
        self.resetBtn.hidden = NO;
        self.pauseBtn.hidden = YES;
        self.endTitleL.hidden = NO;
        self.endImageV.hidden = NO;
        self.minuteL.hidden = YES;
        self.secondL.hidden = YES;
        self.intervalL.hidden = YES;
        
        self.endImageV.frame = CGRectMake(0, 0, 30, 30);
        self.endImageV.bm_top = self.titleL.bm_bottom + 20;
        self.endImageV.bm_centerX = self.titleL.bm_centerX;
        
        self.endTitleL.frame = CGRectMake(0, 0, 100, 28);
        self.endTitleL.bm_centerX = self.titleL.bm_centerX;
        self.endTitleL.bm_top = self.endImageV.bm_bottom + 5;
        
        self.resetBtn.frame = CGRectMake(0, 0, 30, 30);
        self.resetBtn.bm_centerX = self.endImageV.bm_centerX;
        self.resetBtn.bm_top =  self.endTitleL.bm_bottom + 10;
    }
}

- (void)setTimeCountBtnHide:(BOOL)hide
{
    self.minuteUpBtn.hidden = hide;
    self.minuteDownBtn.hidden = hide;
    self.secondDownBtn.hidden = hide;
    self.secondUpBtn.hidden = hide;
    self.startBtn.hidden = hide;
}

- (void)showTimeInterval:(NSInteger)timeInterval
{
    NSInteger minute = timeInterval / 60;
    NSInteger second = timeInterval % 60;
    self.minute = minute;
    self.second = second;
    self.minuteL.text = [NSString stringWithFormat:@"%02ld",(long)minute];
    self.secondL.text = [NSString stringWithFormat:@"%02ld",(long)second];
}

#pragma mark - SEL

- (void)closeBtnClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(timerClose)])
    {
        [self.delegate timerClose];
    }

    [self dismiss:nil animated:NO dismissBlock:nil];
}

- (void)minuteUpBtnClicked:(UIButton *)btn
{
    //分加
    self.minute++;
    self.minuteDownBtn.enabled = YES;
    if (self.minute >= maxMinute)
    {
        self.minuteUpBtn.enabled = NO;
        self.minute = maxMinute;
    }
    self.minuteL.text = [NSString stringWithFormat:@"%02ld", (long)self.minute];
    NSInteger time = self.minute * 60 + self.second;
    if (time == 0)
    {
        self.startBtn.enabled = NO;
    }
    else
    {
        self.startBtn.enabled = YES;
    }

    
}

- (void)minuteDownBtnClicked:(UIButton *)btn
{
    //分减
    self.minute--;
    self.minuteUpBtn.enabled = YES;
    if (self.minute <= minMinute)
    {
        self.minute = minMinute;
        self.minuteDownBtn.enabled = NO;
    }
    self.minuteL.text = [NSString stringWithFormat:@"%02ld",(long)self.minute];
    NSInteger time = self.minute * 60 + self.second;
    if (time == 0)
    {
        self.startBtn.enabled = NO;
    }
    else
    {
        self.startBtn.enabled = YES;
    }

}

- (void)secondUpBtnClicked:(UIButton *)btn
{
    //秒加
    self.second++;
    self.secondDownBtn.enabled = YES;
    if (self.second >= maxSecond)
    {
        self.secondUpBtn.enabled = NO;
        self.second = maxSecond;
    }
    self.secondL.text = [NSString stringWithFormat:@"%02ld",(long)self.second];
    NSInteger time = self.minute * 60 + self.second;
    if (time == 0)
    {
        self.startBtn.enabled = NO;
    }
    else
    {
        self.startBtn.enabled = YES;
    }

}

- (void)secondDownBtnClicked:(UIButton *)btn
{
    //秒减
    self.second--;
    self.secondUpBtn.enabled = YES;
    if (self.second <= minSecond)
    {
        self.second = minSecond;
        self.secondDownBtn.enabled = NO;
    }
    self.secondL.text = [NSString stringWithFormat:@"%02ld",(long)self.second];
    NSInteger time = self.minute * 60 + self.second;
    if (time == 0)
    {
        self.startBtn.enabled = NO;
    }
    else
    {
        self.startBtn.enabled = YES;
    }

}

- (void)startBtnClicked:(UIButton *)btn
{
    //开始
    NSInteger time = self.minute * 60 + self.second;
    if (time == 0)
    {
        btn.enabled = NO;
        return;
    }
    if ([self.delegate respondsToSelector:@selector(startWithTime:)])
    {
        NSInteger time = self.minute * 60 + self.second;
        [self.delegate startWithTime:time];
    }
    
}

- (void)resetBtnClicked:(UIButton *)btn
{
    //重置
    if (self.timerType == YSTeacherTimerViewType_Ing)
    {
        if ([self.delegate respondsToSelector:@selector(resetWithTIme:pasue:)])
        {
            NSInteger time = self.minute * 60 + self.second;
            [self.delegate resetWithTIme:time pasue:self.pauseBtn.selected];
        }
    }
    else if (self.timerType == YSTeacherTimerViewType_End)
    {
        if ([self.delegate respondsToSelector:@selector(againTimer)])
        {
            [self.delegate againTimer];
        }
    }
}

- (void)pauseBtnClicked:(UIButton *)btn
{
    //暂停继续
    btn.selected = !btn.selected;
//    if (btn.selected)
//    {
//        [self.pauseBtn setImage:[UIImage imageNamed:@"teacherTimer_continue"] forState:UIControlStateNormal];
//    }
//    else
//    {
//        [self.pauseBtn setImage:[UIImage imageNamed:@"teacherTimer_pause"] forState:UIControlStateNormal];
//    }
    if ([self.delegate respondsToSelector:@selector(pasueWithTime:pasue:)])
    {
        NSInteger time = self.minute * 60 + self.second;
        [self.delegate pasueWithTime:time pasue:btn.selected];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint btnP =  [self convertPoint:point toView:self.bacView];
    
    if ( [self.bacView pointInside:btnP withEvent:event])
    {
        return [super hitTest:point withEvent:event];
    }
    else if (self.isPenetration)
    {
        return nil;
    }
    
    return [super hitTest:point withEvent:event];
}

@end

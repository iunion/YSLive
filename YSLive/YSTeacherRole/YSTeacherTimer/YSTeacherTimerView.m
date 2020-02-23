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
/// 底部ImageView
@property (nonatomic, strong) UIImageView *bacImageView;
/// 关闭按钮
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UILabel *titleL;

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
    self.bacView.backgroundColor = [UIColor clearColor];
    self.bacView.bm_width = backViewWidth;
    self.bacView.bm_height = backViewHeight;
    [self showWithView:self.bacView inView:inView];
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeBtn setImage:[UIImage imageNamed:@"btn_close"] forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.closeBtn.hidden = NO;
    [self.bacView addSubview:self.closeBtn];
    self.closeBtn.frame = CGRectMake(0, 0, 25, 25);
    self.closeBtn.bm_right = self.bacView.bm_right - 5;
    self.closeBtn.bm_top = self.bacView.bm_top + 5;
    
    self.bacImageView = [[UIImageView alloc] init];
    [self.bacImageView setImage:[UIImage imageNamed:@"yslive_sign_backimg"]];//teacherTimer_backimg
    self.bacImageView.userInteractionEnabled = YES;
    [self.bacView addSubview:self.bacImageView];
    self.bacImageView.frame = CGRectMake(0, 0, backImageWidth, backImageHeight);
    self.bacImageView.bm_bottom = self.bacView.bm_bottom;
    self.bacImageView.bm_centerX = self.bacView.bm_centerX;
    
    self.titleL = [[UILabel alloc] init];
    [self.bacImageView addSubview:self.titleL];
    self.titleL.textAlignment= NSTextAlignmentCenter;
    self.titleL.textColor = [UIColor bm_colorWithHex:0x6D7278];
    self.titleL.font = [UIFont systemFontOfSize:16.0f];
    self.titleL.text = YSLocalized(@"tool.jishiqi");
    self.titleL.frame = CGRectMake(0, 26, self.bacImageView.bm_width, 22);
    
    self.intervalL = [[UILabel alloc] init];
    [self.bacImageView addSubview:self.intervalL];
    self.intervalL.textAlignment= NSTextAlignmentCenter;
    self.intervalL.textColor = [UIColor bm_colorWithHex:0x6D7278];
    self.intervalL.font = [UIFont systemFontOfSize:30.0f];
    self.intervalL.text = @":";
    self.intervalL.frame = CGRectMake(0, 50, 9, 42);
    self.intervalL.bm_centerX = self.titleL.bm_centerX;
    self.intervalL.bm_top = self.titleL.bm_bottom + 17;
    
    self.minuteL = [[UILabel alloc] init];
    [self.bacImageView addSubview:self.minuteL];
    self.minuteL.textAlignment= NSTextAlignmentCenter;
    self.minuteL.textColor = [UIColor bm_colorWithHex:0x6D7278];
    self.minuteL.backgroundColor = [UIColor bm_colorWithHex:0xDEEAFF];
    self.minuteL.font = [UIFont fontWithName:@"Helvetica" size:42.0f];
    self.minuteL.frame = CGRectMake(0, 0, 70, 42);
    self.minuteL.bm_right = self.intervalL.bm_left - 18;
    self.minuteL.bm_centerY = self.intervalL.bm_centerY;
    self.minuteL.layer.cornerRadius = 3;
    self.minuteL.layer.masksToBounds = YES;
    self.minuteL.text = @"05";
    
    
    self.minuteUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.minuteUpBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_up_normal"] forState:UIControlStateNormal];
    [self.minuteUpBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_up_disabled"] forState:UIControlStateDisabled];
    [self.minuteUpBtn addTarget:self action:@selector(minuteUpBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacImageView addSubview:self.minuteUpBtn];
    self.minuteUpBtn.frame = CGRectMake(0, 0, 20, 12);
    self.minuteUpBtn.bm_centerX = self.minuteL.bm_centerX;
    self.minuteUpBtn.bm_bottom = self.minuteL.bm_top - 4;
    
    self.minuteDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.minuteDownBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_down_normal"] forState:UIControlStateNormal];
    [self.minuteDownBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_down_disabled"] forState:UIControlStateDisabled];
    [self.minuteDownBtn addTarget:self action:@selector(minuteDownBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacImageView addSubview:self.minuteDownBtn];
    self.minuteDownBtn.frame = CGRectMake(0, 0, 20, 12);
    self.minuteDownBtn.bm_centerX = self.minuteL.bm_centerX;
    self.minuteDownBtn.bm_top = self.minuteL.bm_bottom + 4;
    
    self.secondL = [[UILabel alloc] init];
    [self.bacImageView addSubview:self.secondL];
    self.secondL.textAlignment= NSTextAlignmentCenter;
    self.secondL.textColor = [UIColor bm_colorWithHex:0x6D7278];
    self.secondL.backgroundColor = [UIColor bm_colorWithHex:0xDEEAFF];
    self.secondL.font = [UIFont fontWithName:@"Helvetica" size:42.0f];
    self.secondL.frame = CGRectMake(0, 0, 70, 42);
    self.secondL.bm_left = self.intervalL.bm_right + 18;
    self.secondL.bm_centerY = self.intervalL.bm_centerY;
    self.secondL.layer.cornerRadius = 3;
    self.secondL.layer.masksToBounds = YES;
    self.secondL.text = @"00";
    
    self.secondUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.secondUpBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_up_normal"] forState:UIControlStateNormal];
    [self.secondUpBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_up_disabled"] forState:UIControlStateDisabled];
    [self.secondUpBtn addTarget:self action:@selector(secondUpBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacImageView addSubview:self.secondUpBtn];
    self.secondUpBtn.frame = CGRectMake(0, 0, 20, 12);
    self.secondUpBtn.bm_centerX = self.secondL.bm_centerX;
    self.secondUpBtn.bm_bottom = self.secondL.bm_top - 4;
    
    self.secondDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.secondDownBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_down_normal"] forState:UIControlStateNormal];
    [self.secondDownBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_down_disabled"] forState:UIControlStateDisabled];
    [self.secondDownBtn addTarget:self action:@selector(secondDownBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacImageView addSubview:self.secondDownBtn];
    self.secondDownBtn.frame = CGRectMake(0, 0, 20, 12);
    self.secondDownBtn.bm_centerX = self.secondL.bm_centerX;
    self.secondDownBtn.bm_top = self.secondL.bm_bottom + 4;
    self.secondDownBtn.enabled = NO;
    
    self.startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startBtn setTitle: YSLocalized(@"Timer.btn.start") forState:UIControlStateNormal];

    [self.startBtn addTarget:self action:@selector(startBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacImageView addSubview:self.startBtn];
    self.startBtn.frame = CGRectMake(0, self.bacImageView.bm_height - 50, self.bacImageView.bm_width, 40);
    [self.startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.startBtn.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    
    
    self.resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.resetBtn setImage:[UIImage imageNamed:@"teacherTimer_reset"] forState:UIControlStateNormal];
    [self.resetBtn addTarget:self action:@selector(resetBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacImageView addSubview:self.resetBtn];
    
        
    self.pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pauseBtn setImage:[UIImage imageNamed:@"teacherTimer_pause"] forState:UIControlStateNormal];
    [self.pauseBtn setImage:[UIImage imageNamed:@"teacherTimer_continue"] forState:UIControlStateSelected];
    [self.pauseBtn addTarget:self action:@selector(pauseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacImageView addSubview:self.pauseBtn];
    
    self.endTitleL = [[UILabel alloc] init];
    [self.bacImageView addSubview:self.endTitleL];
    self.endTitleL.textAlignment= NSTextAlignmentCenter;
    self.endTitleL.textColor = [UIColor bm_colorWithHex:0x6D7278];
    self.endTitleL.font = [UIFont systemFontOfSize:20.0f];
    self.endTitleL.text = YSLocalized(@"Timer.lab.end");

    self.endImageV = [[UIImageView alloc] init];
    [self.endImageV setImage:[UIImage imageNamed:@"teacherTimer_end"]];
    [self.bacImageView addSubview:self.endImageV];
    
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
    
    if (panView.bm_bottom > UI_SCREEN_HEIGHT)
    {
        panView.bm_top = UI_SCREEN_HEIGHT - panView.bm_height;
    }
    if (panView.bm_right > UI_SCREEN_WIDTH)
    {
        panView.bm_left = UI_SCREEN_WIDTH - panView.bm_width;
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
        [self.bacImageView setImage:[UIImage imageNamed:@"yslive_sign_backimg"]];//teacherTimer_backimg
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
        [self.bacImageView setImage:[UIImage imageNamed:@"teacherTimer_backimg"]];//teacherTimer_backimg
        self.resetBtn.frame = CGRectMake(0, 0, 40, 40);
        self.resetBtn.bm_right = self.intervalL.bm_left - 16;
        self.resetBtn.bm_top = self.minuteL.bm_bottom + 24;
        self.resetBtn.hidden = NO;
        
        self.pauseBtn.hidden = NO;
        self.pauseBtn.frame = CGRectMake(0, 0, 40, 40);
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
        [self.bacImageView setImage:[UIImage imageNamed:@"teacherTimer_backimg"]];//teacherTimer_backimg
        self.resetBtn.hidden = NO;
        self.pauseBtn.hidden = YES;
        self.endTitleL.hidden = NO;
        self.endImageV.hidden = NO;
        self.minuteL.hidden = YES;
        self.secondL.hidden = YES;
        self.intervalL.hidden = YES;
        
        self.endImageV.frame = CGRectMake(0, 0, 24, 29);
        self.endImageV.bm_top = self.titleL.bm_bottom + 15;
        self.endImageV.bm_centerX = self.titleL.bm_centerX;
        
        self.endTitleL.frame = CGRectMake(0, 0, 100, 28);
        self.endTitleL.bm_centerX = self.titleL.bm_centerX;
        self.endTitleL.bm_top = self.endImageV.bm_bottom + 5;
        
        self.resetBtn.frame = CGRectMake(0, 0, 40, 40);
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
}

- (void)startBtnClicked:(UIButton *)btn
{
    //开始
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

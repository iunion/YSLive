//
//  YSStudentTimerView.m
//  YSAll
//
//  Created by 宁杰英 on 2020/2/21.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSStudentTimerView.h"

//#define backViewWidth 320
//#define backViewHeight 220

#define backViewWidth 268
#define backViewHeight 180
#define backImageWidth 268
#define backImageHeight 180
@interface YSStudentTimerView()

/// 底部view
@property (nonatomic, strong) UIView *bacView;
/// 关闭按钮
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UILabel *titleL;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *intervalL;
@property (nonatomic, strong) UILabel *minuteL;
@property (nonatomic, strong) UILabel *secondL;


@property (nonatomic, strong) UILabel *endTitleL;
@property (nonatomic, strong) UIImageView *endImageV;


@end

@implementation YSStudentTimerView
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

- (void)showYSStudentTimerViewInView:(UIView *)inView backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets topDistance:(CGFloat)topDistance
{
    self.topDistance = topDistance;
    self.backgroundEdgeInsets = backgroundEdgeInsets;
    
//    self.minute = 5;
//    self.second = 0;
    
    self.bacView = [[UIView alloc] init];
    self.bacView.backgroundColor = [YSSkinDefineColor(@"Color2") bm_changeAlpha:YSPopViewDefaultAlpha];
    self.bacView.bm_width = backViewWidth;
    self.bacView.bm_height = backViewHeight;
    [self.bacView bm_roundedRect:10.0f];
    [self showWithView:self.bacView inView:inView];
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeBtn setImage:YSSkinDefineImage(@"close_btn_icon") forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacView addSubview:self.closeBtn];
    self.closeBtn.frame = CGRectMake(0, 0, 25, 25);
    self.closeBtn.bm_right = self.bacView.bm_right - 5;
    self.closeBtn.bm_top = self.bacView.bm_top + 5;
    self.closeBtn.hidden = YES;
    
    self.titleL = [[UILabel alloc] init];
    [self.bacView addSubview:self.titleL];
    self.titleL.textAlignment= NSTextAlignmentCenter;
    self.titleL.textColor = YSSkinDefineColor(@"Color3");
    self.titleL.font = UI_FONT_16;
    self.titleL.text = YSLocalized(@"tool.jishiqi");
    self.titleL.frame = CGRectMake(30, 10, self.bacView.bm_width-60, 40);
    
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
    self.intervalL.bm_top = self.titleL.bm_bottom + 20;
    
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

- (void)showTimeInterval:(NSInteger)timeInterval
{
    NSInteger minute = timeInterval / 60;
    NSInteger second = timeInterval % 60;
    self.minuteL.text = [NSString stringWithFormat:@"%02ld",(long)minute];
    self.secondL.text = [NSString stringWithFormat:@"%02ld",(long)second];
}

- (void)closeBtnClicked:(UIButton *)btn
{
    [self dismiss:nil animated:NO dismissBlock:nil];
}

- (void)showResponderWithType:(YSStudentTimerViewType)timerType
{
    if (timerType == YSStudentTimerViewType_Ing)
    {
        //计时中

        self.endTitleL.hidden = YES;
        self.endImageV.hidden = YES;
        
        self.minuteL.hidden = NO;
        self.secondL.hidden = NO;
        self.intervalL.hidden = NO;
    }
    else if (timerType == YSStudentTimerViewType_End)
    {
        //计时结束
        
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

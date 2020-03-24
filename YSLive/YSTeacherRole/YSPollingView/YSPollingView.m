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

#define maxSecond 90
#define minSecond 10
@interface YSPollingView()
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
    
    self.bacView = [[UIView alloc] init];
    self.bacView.backgroundColor = [UIColor whiteColor];
    self.bacView.bm_width = backViewWidth;
    self.bacView.bm_height = backViewHeight;
    self.bacView.layer.cornerRadius = 26;
    self.bacView.layer.masksToBounds = YES;
    [self showWithView:self.bacView inView:inView];
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeBtn setImage:[UIImage imageNamed:@"polling_btn_close"] forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.closeBtn.hidden = NO;
    [self.bacView addSubview:self.closeBtn];
    self.closeBtn.frame = CGRectMake(0, 0, 25, 25);
    self.closeBtn.bm_right = self.bacView.bm_right - 23;
    self.closeBtn.bm_top = self.bacView.bm_top + 23;
    
    self.titleLabel = [[UILabel alloc] init];
    [self.bacView addSubview:self.titleLabel];
    self.titleLabel.textAlignment= NSTextAlignmentLeft;
    self.titleLabel.textColor = [UIColor bm_colorWithHex:0x5A8CDC];
    self.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    self.titleLabel.text = YSLocalized(@"轮播时间");
    self.titleLabel.frame = CGRectMake(30, 80, 70, 25);
    
    self.timeView = [[UIView alloc] init];
    [self.bacView addSubview:self.timeView];
    self.timeView.frame = CGRectMake(0, 0, 120, 42);
    self.timeView.bm_centerY = self.titleLabel.bm_centerY;
    self.timeView.bm_left = self.titleLabel.bm_right + 8;
    self.timeView.backgroundColor = [UIColor bm_colorWithHex:0xDEEAFF alpha:0.5];
    [self.timeView bm_addShadow:1 Radius:21 BorderColor:[UIColor bm_colorWithHex:0x5A8CDC] ShadowColor:[UIColor whiteColor] Offset:CGSizeMake(0, 1) Opacity:0.5];
    
    self.timeLabel = [[UILabel alloc] init];
    [self.timeView addSubview:self.timeLabel];
    self.timeLabel.textAlignment= NSTextAlignmentCenter;
    self.timeLabel.textColor = [UIColor bm_colorWithHex:0x5A8CDC];
    self.timeLabel.font = [UIFont systemFontOfSize:21.0f];
    self.timeLabel.text = @"20";
    self.timeLabel.frame = CGRectMake(40, 8, 30, 25);

    self.upBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.upBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_up_normal"] forState:UIControlStateNormal];
    [self.upBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_up_disabled"] forState:UIControlStateDisabled];
    [self.upBtn addTarget:self action:@selector(upBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.timeView addSubview:self.upBtn];
    self.upBtn.frame = CGRectMake(0, 6, 14, 10);
    self.upBtn.bm_left = self.timeLabel.bm_right + 14;
    
    self.downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.downBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_down_normal"] forState:UIControlStateNormal];
    [self.downBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_down_disabled"] forState:UIControlStateDisabled];
    [self.downBtn addTarget:self action:@selector(downBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.timeView addSubview:self.downBtn];
    self.downBtn.frame = CGRectMake(0, 0, 14, 10);
    self.downBtn.bm_left = self.timeLabel.bm_right + 14;
    self.downBtn.bm_top = self.upBtn.bm_bottom + 10;

    self.secondLabel = [[UILabel alloc] init];
    [self.bacView addSubview:self.secondLabel];
    self.secondLabel.textAlignment= NSTextAlignmentLeft;
    self.secondLabel.textColor = [UIColor bm_colorWithHex:0x5A8CDC];
    self.secondLabel.font = [UIFont systemFontOfSize:16.0f];
    self.secondLabel.text = YSLocalized(@"秒/次");
    self.secondLabel.frame = CGRectMake(0, 0, 42, 25);
    self.secondLabel.bm_centerY = self.titleLabel.bm_centerY;
    self.secondLabel.bm_left = self.timeView.bm_right + 15;
    
//    self.bacImageView = [[UIImageView alloc] init];
//    [self.bacImageView setImage:[UIImage imageNamed:@"yslive_sign_backimg"]];//teacherTimer_backimg
//    self.bacImageView.userInteractionEnabled = YES;
//    [self.bacView addSubview:self.bacImageView];
//    self.bacImageView.frame = CGRectMake(0, 0, backImageWidth, backImageHeight);
//    self.bacImageView.bm_bottom = self.bacView.bm_bottom;
//    self.bacImageView.bm_centerX = self.bacView.bm_centerX;
//
//    self.titleL = [[UILabel alloc] init];
//    [self.bacImageView addSubview:self.titleL];
//    self.titleL.textAlignment= NSTextAlignmentCenter;
//    self.titleL.textColor = [UIColor bm_colorWithHex:0x6D7278];
//    self.titleL.font = [UIFont systemFontOfSize:16.0f];
//    self.titleL.text = YSLocalized(@"tool.jishiqi");
//    self.titleL.frame = CGRectMake(0, 26, self.bacImageView.bm_width, 22);
//
//    self.intervalL = [[UILabel alloc] init];
//    [self.bacImageView addSubview:self.intervalL];
//    self.intervalL.textAlignment= NSTextAlignmentCenter;
//    self.intervalL.textColor = [UIColor bm_colorWithHex:0x6D7278];
//    self.intervalL.font = [UIFont systemFontOfSize:30.0f];
//    self.intervalL.text = @":";
//    self.intervalL.frame = CGRectMake(0, 50, 9, 42);
//    self.intervalL.bm_centerX = self.titleL.bm_centerX;
//    self.intervalL.bm_top = self.titleL.bm_bottom + 17;
//
//    self.minuteL = [[UILabel alloc] init];
//    [self.bacImageView addSubview:self.minuteL];
//    self.minuteL.textAlignment= NSTextAlignmentCenter;
//    self.minuteL.textColor = [UIColor bm_colorWithHex:0x6D7278];
//    self.minuteL.backgroundColor = [UIColor bm_colorWithHex:0xDEEAFF];
//    self.minuteL.font = [UIFont fontWithName:@"Helvetica" size:42.0f];
//    self.minuteL.frame = CGRectMake(0, 0, 70, 42);
//    self.minuteL.bm_right = self.intervalL.bm_left - 18;
//    self.minuteL.bm_centerY = self.intervalL.bm_centerY;
//    self.minuteL.layer.cornerRadius = 3;
//    self.minuteL.layer.masksToBounds = YES;
//    self.minuteL.text = @"05";
//
//
//    self.minuteUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.minuteUpBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_up_normal"] forState:UIControlStateNormal];
//    [self.minuteUpBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_up_disabled"] forState:UIControlStateDisabled];
//    [self.minuteUpBtn addTarget:self action:@selector(minuteUpBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self.bacImageView addSubview:self.minuteUpBtn];
//    self.minuteUpBtn.frame = CGRectMake(0, 0, 20, 12);
//    self.minuteUpBtn.bm_centerX = self.minuteL.bm_centerX;
//    self.minuteUpBtn.bm_bottom = self.minuteL.bm_top - 4;
//
//    self.minuteDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.minuteDownBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_down_normal"] forState:UIControlStateNormal];
//    [self.minuteDownBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_down_disabled"] forState:UIControlStateDisabled];
//    [self.minuteDownBtn addTarget:self action:@selector(minuteDownBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self.bacImageView addSubview:self.minuteDownBtn];
//    self.minuteDownBtn.frame = CGRectMake(0, 0, 20, 12);
//    self.minuteDownBtn.bm_centerX = self.minuteL.bm_centerX;
//    self.minuteDownBtn.bm_top = self.minuteL.bm_bottom + 4;
//
//    self.secondL = [[UILabel alloc] init];
//    [self.bacImageView addSubview:self.secondL];
//    self.secondL.textAlignment= NSTextAlignmentCenter;
//    self.secondL.textColor = [UIColor bm_colorWithHex:0x6D7278];
//    self.secondL.backgroundColor = [UIColor bm_colorWithHex:0xDEEAFF];
//    self.secondL.font = [UIFont fontWithName:@"Helvetica" size:42.0f];
//    self.secondL.frame = CGRectMake(0, 0, 70, 42);
//    self.secondL.bm_left = self.intervalL.bm_right + 18;
//    self.secondL.bm_centerY = self.intervalL.bm_centerY;
//    self.secondL.layer.cornerRadius = 3;
//    self.secondL.layer.masksToBounds = YES;
//    self.secondL.text = @"00";
//
//    self.secondUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.secondUpBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_up_normal"] forState:UIControlStateNormal];
//    [self.secondUpBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_up_disabled"] forState:UIControlStateDisabled];
//    [self.secondUpBtn addTarget:self action:@selector(secondUpBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self.bacImageView addSubview:self.secondUpBtn];
//    self.secondUpBtn.frame = CGRectMake(0, 0, 20, 12);
//    self.secondUpBtn.bm_centerX = self.secondL.bm_centerX;
//    self.secondUpBtn.bm_bottom = self.secondL.bm_top - 4;
//
//    self.secondDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.secondDownBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_down_normal"] forState:UIControlStateNormal];
//    [self.secondDownBtn setBackgroundImage:[UIImage imageNamed:@"teacherTimer_down_disabled"] forState:UIControlStateDisabled];
//    [self.secondDownBtn addTarget:self action:@selector(secondDownBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self.bacImageView addSubview:self.secondDownBtn];
//    self.secondDownBtn.frame = CGRectMake(0, 0, 20, 12);
//    self.secondDownBtn.bm_centerX = self.secondL.bm_centerX;
//    self.secondDownBtn.bm_top = self.secondL.bm_bottom + 4;
//    self.secondDownBtn.enabled = NO;
//
    self.sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sureBtn setTitle: YSLocalized(@"Prompt.OK") forState:UIControlStateNormal];
    [self.sureBtn addTarget:self action:@selector(sureBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacView addSubview:self.sureBtn];
    [self.sureBtn setBackgroundColor:[UIColor bm_colorWithHex:0x5A8CDC]];
    self.sureBtn.frame = CGRectMake(0, self.bacView.bm_height - 80, 147, 40);
    self.sureBtn.bm_centerX = self.bacView.bm_centerX;
    [self.sureBtn setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
    self.sureBtn.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [self.sureBtn bm_addShadow:3 Radius:20 BorderColor:[UIColor bm_colorWithHex:0x97B7EB] ShadowColor:[UIColor grayColor] Offset:CGSizeMake(0, 5) Opacity:0.5];
}



#pragma mark - SEL

- (void)closeBtnClicked:(UIButton *)btn
{
//    if ([self.delegate respondsToSelector:@selector(timerClose)])
//    {
//        [self.delegate timerClose];
//    }

    [self dismiss:nil animated:NO dismissBlock:nil];
}

- (void)sureBtnClicked:(UIButton *)btn
{
    
}

- (void)upBtnClicked:(UIButton *)btn
{
    _second++;
    self.downBtn.enabled = YES;
    if (_second >= maxSecond)
    {
        self.upBtn.enabled = NO;
        _second = maxSecond;
    }
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld", (long)_second];
}

- (void)downBtnClicked:(UIButton *)btn
{
    //减
    _second--;
    self.upBtn.enabled = YES;
    if (_second <= minSecond)
    {
        _second = minSecond;
        self.downBtn.enabled = NO;
    }
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld",(long)_second];
     
}
@end

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
    self.timeLabel.text = [NSString stringWithFormat:@"%@",@(_second)];
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
        [self.delegate startPollingWithTime:_second];
    }
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

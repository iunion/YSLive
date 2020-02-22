//
//  YSStudentTimerView.m
//  YSAll
//
//  Created by 宁杰英 on 2020/2/21.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSStudentTimerView.h"

#define backViewWidth 320
#define backViewHeight 220

#define backImageWidth 268
#define backImageHeight 180
@interface YSStudentTimerView()

/// 底部view
@property (nonatomic, strong) UIView *bacView;
/// 底部ImageView
@property (nonatomic, strong) UIImageView *bacImageView;
/// 关闭按钮
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UILabel *titleL;
@property (nonatomic, strong) UILabel *intervalL;
@property (nonatomic, strong) UILabel *minuteL;
@property (nonatomic, strong) UILabel *secondL;


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
    [self.bacImageView setImage:[UIImage imageNamed:@"teacherTimer_backimg"]];//teacherTimer_backimg
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
@end

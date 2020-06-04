//
//  YSStudentResponder.m
//  YSAll
//
//  Created by 宁杰英 on 2020/2/20.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSStudentResponder.h"
#import "YSCircleProgress.h"

#define backViewWidth 220
#define backViewHeight 220
@interface YSStudentResponder ()

/// 底部view
@property (nonatomic, strong) UIView *bacView;
/// 关闭按钮
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) YSCircleProgress *circleProgress;
@property (nonatomic, strong) UILabel *titleL;
@property (nonatomic, strong) UIView *circleBacView;

@end
@implementation YSStudentResponder
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

- (void)showInView:(UIView *)inView backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets topDistance:(CGFloat)topDistance
{
    self.topDistance = topDistance;
    self.backgroundEdgeInsets = backgroundEdgeInsets;
    
    self.bacView = [[UIView alloc] init];
    self.bacView.backgroundColor = [UIColor clearColor];
    self.bacView.bm_width = backViewWidth;
    self.bacView.bm_height = backViewHeight;
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeBtn setImage:YSSkinDefineImage(@"close_btn_icon") forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacView addSubview:self.closeBtn];
    self.closeBtn.frame = CGRectMake(0, 0, 25, 25);
    self.closeBtn.bm_right = self.bacView.bm_right - 5;
    self.closeBtn.bm_top = self.bacView.bm_top + 5;
    self.closeBtn.hidden = YES;
    //抢答器
    self.circleProgress = [[YSCircleProgress alloc] init];
    self.circleProgress.frame = CGRectMake(0, 0, 180, 180);
    //    self.circleProgress.progress = 0.5;
    self.circleProgress.lineWidth = 7;
    self.circleProgress.isClockwise = YES;
    self.circleProgress.innerColor = YSSkinDefineColor(@"defaultBgColor");
    self.circleProgress.lineBgColor = YSSkinDefineColor(@"defaultTitleColor");
    self.circleProgress.lineProgressColor = YSSkinDefineColor(@"defaultSelectedBgColor");
    [self.bacView addSubview:self.circleProgress];
    [self.circleProgress bm_centerInSuperView];
    
    
    self.circleBacView = [[UIView alloc] init];
    [self.circleProgress addSubview:self.circleBacView];
    self.circleBacView.frame = CGRectMake(0, 0, 160, 160);
    self.circleBacView.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
    [self.circleBacView bm_centerInSuperView];
    [self.circleBacView bm_roundedRect:80];
    
    
    [self showWithView:self.bacView inView:inView];
    
    self.titleL = [[UILabel alloc] init];
    [self.circleProgress addSubview:self.titleL];
    
    self.titleL.textAlignment= NSTextAlignmentCenter;
    self.titleL.textColor = YSSkinDefineColor(@"defaultTitleColor");
    self.titleL.font = [UIFont systemFontOfSize:16.0f];
    self.titleL.numberOfLines = 0;
    self.titleL.frame = CGRectMake(0, 0, 180, 180 );
}

- (void)setTitleName:(NSString *)title
{
    if ([title isEqualToString:YSLocalized(@"Res.lab.get")])
    {
        self.circleBacView.backgroundColor = YSSkinDefineColor(@"defaultSelectedBgColor");
    }
    else
    {
        self.circleBacView.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
    }
    self.titleL.text = title;
}

- (void)setProgress:(CGFloat)progress
{
    self.circleProgress.progress = progress;
}


- (void)closeBtnClicked:(UIButton *)btn
{
    [self dismiss:nil animated:NO dismissBlock:nil];
}


@end

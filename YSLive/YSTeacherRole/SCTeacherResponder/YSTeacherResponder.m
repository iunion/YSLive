//
//  YSTeacherResponder.m
//  YSAll
//
//  Created by 宁杰英 on 2020/2/18.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSTeacherResponder.h"
#import "YSCircleProgress.h"

#define backViewWidth 140
#define backViewHeight 140

@interface YSTeacherResponder ()
@property (nonatomic, assign) YSTeacherResponderType responderType;
/// 底部view
@property (nonatomic, strong) UIView *bacView;
/// 关闭按钮
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) YSCircleProgress *circleProgress;


@property (nonatomic, strong) UILabel *titleL;
@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UIButton *actionBtn;
@property (nonatomic, strong) UIButton *selectBtn;




@end


@implementation YSTeacherResponder
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

- (void)showYSTeacherResponderType:(YSTeacherResponderType)responderType inView:(UIView *)inView backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets topDistance:(CGFloat)topDistance
{
    self.topDistance = topDistance;
    self.backgroundEdgeInsets = backgroundEdgeInsets;
    self.responderType = responderType;
    
    self.bacView = [[UIView alloc] init];
    self.bacView.backgroundColor = [UIColor clearColor];
    self.bacView.bm_width = backViewWidth;
    self.bacView.bm_height = backViewHeight;
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeBtn setImage:[UIImage imageNamed:@"btn_close"] forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.closeBtn.hidden = NO;
    [self.bacView addSubview:self.closeBtn];
    self.closeBtn.frame = CGRectMake(0, 0, 18, 18);
    self.closeBtn.bm_right = self.bacView.bm_right - 5;
    self.closeBtn.bm_top = self.bacView.bm_top + 5;
    
    //抢答器
    self.circleProgress = [[YSCircleProgress alloc] init];
    self.circleProgress.frame = CGRectMake(0, 0, 100, 100);
    self.circleProgress.progress = 0.5;
    self.circleProgress.lineWidth = 5;
    self.circleProgress.isClockwise = YES;
    self.circleProgress.innerColor = [UIColor bm_colorWithHex:0x82ABEC];
    self.circleProgress.lineBgColor = [UIColor bm_colorWithHex:0x5A8CDC];
    self.circleProgress.lineProgressColor = [UIColor bm_colorWithHex:0xFFFFFF];
    self.circleProgress.bm_centerX = self.bacView.bm_centerX;
    self.circleProgress.bm_centerY = self.bacView.bm_centerY;
    [self.bacView addSubview:self.circleProgress];
    [self showWithView:self.bacView inView:inView];
    
    self.titleL = [[UILabel alloc] init];
    [self.circleProgress addSubview:self.titleL];
    self.titleL.frame = CGRectMake(10, 10, self.circleProgress.bm_width - 20, 11);
    self.titleL.text = YSLocalized(@"tool.qiangdaqi");
    self.titleL.textAlignment= NSTextAlignmentCenter;
    self.titleL.textColor = [UIColor bm_colorWithHex:0xFFFFFF];
    self.titleL.font = [UIFont systemFontOfSize:8.0f];
    
    self.iconImgV = [[UIImageView alloc] init];
    [self.iconImgV setImage:[UIImage imageNamed:@"teacher_responder_title"]];
    [self.circleProgress addSubview:self.iconImgV];
    self.iconImgV.frame = CGRectMake(0, 0, 16, 16);
    self.iconImgV.bm_centerX = self.titleL.bm_centerX;
    self.iconImgV.bm_top = self.titleL.bm_bottom + 5;
    
    self.actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.actionBtn setTitle:YSLocalized(@"tool.start") forState:UIControlStateNormal];
    [self.actionBtn addTarget:self action:@selector(actionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.actionBtn.hidden = NO;
    self.actionBtn.backgroundColor = [UIColor bm_colorWithHex:0x5A8CDC];
    [self.actionBtn setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
    self.actionBtn.titleLabel.font = [UIFont systemFontOfSize:9.0f];
    [self.circleProgress addSubview:self.actionBtn];
    self.actionBtn.frame = CGRectMake(0, 0, 65, 18);
    self.actionBtn.bm_centerX = self.titleL.bm_centerX;
    self.actionBtn.bm_top = self.iconImgV.bm_bottom + 5;
    [self.actionBtn bm_addShadow:1 Radius:9 BorderColor:[UIColor bm_colorWithHex:0x97B7EB] ShadowColor:[UIColor grayColor] Offset:CGSizeMake(0, 2) Opacity:0.5];
    
    
    self.selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.selectBtn setTitle:YSLocalized(@"上台*") forState:UIControlStateNormal];
    [self.selectBtn setImage:[UIImage imageNamed:@"teacher_responder_up_normal"] forState:UIControlStateNormal];
    [self.selectBtn setImage:[UIImage imageNamed:@"teacher_responder_up_selected"] forState:UIControlStateSelected];
    [self.selectBtn addTarget:self action:@selector(selectBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.selectBtn.hidden = NO;
    [self.selectBtn setTitleColor:[UIColor bm_colorWithHex:0xFFFFFF] forState:UIControlStateNormal];
    self.selectBtn.titleLabel.font = [UIFont systemFontOfSize:7.0f];
    [self.circleProgress addSubview:self.selectBtn];
    self.selectBtn.frame = CGRectMake(10, 0, self.circleProgress.bm_width - 20, 10);
    self.selectBtn.bm_top = self.actionBtn.bm_bottom + 8;
    [self.selectBtn bm_layoutButtonWithEdgeInsetsStyle:BMButtonEdgeInsetsStyleImageLeft imageTitleGap:4];
    
}


- (void)closeBtnClicked:(UIButton *)btn
{
    [self dismiss:nil animated:NO dismissBlock:nil];
}

- (void)actionBtnClicked:(UIButton *)btn
{
    
}

- (void)selectBtnClicked:(UIButton *)btn
{
    btn.selected = !btn.selected;
}
@end

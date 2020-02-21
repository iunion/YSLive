//
//  YSTeacherResponder.m
//  YSAll
//
//  Created by 宁杰英 on 2020/2/18.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSTeacherResponder.h"
#import "YSCircleProgress.h"

#define backViewWidth 220
#define backViewHeight 220

@interface YSTeacherResponder ()
@property (nonatomic, assign) YSTeacherResponderType responderType;
/// 底部view
@property (nonatomic, strong) UIView *bacView;
/// 关闭按钮
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) YSCircleProgress *circleProgress;


@property (nonatomic, strong) UILabel *titleL;
@property (nonatomic, strong) UILabel *personNumberL;

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
    [self showWithView:self.bacView inView:inView];
    
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeBtn setImage:[UIImage imageNamed:@"btn_close"] forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.closeBtn.hidden = NO;
    [self.bacView addSubview:self.closeBtn];
    self.closeBtn.frame = CGRectMake(0, 0, 25, 25);
    self.closeBtn.bm_right = self.bacView.bm_right - 5;
    self.closeBtn.bm_top = self.bacView.bm_top + 5;
    
    //抢答器
    self.circleProgress = [[YSCircleProgress alloc] init];
    self.circleProgress.frame = CGRectMake(0, 0, 180, 180);
//    self.circleProgress.progress = 0.5;
    self.circleProgress.lineWidth = 7;
    self.circleProgress.isClockwise = YES;
    self.circleProgress.innerColor = [UIColor bm_colorWithHex:0x82ABEC];
    self.circleProgress.lineBgColor = [UIColor bm_colorWithHex:0x5A8CDC];
    self.circleProgress.lineProgressColor = [UIColor bm_colorWithHex:0xFFFFFF];
    self.circleProgress.bm_centerX = self.bacView.bm_centerX;
    self.circleProgress.bm_centerY = self.bacView.bm_centerY;
    [self.bacView addSubview:self.circleProgress];
    
    
    self.titleL = [[UILabel alloc] init];
    [self.circleProgress addSubview:self.titleL];
    
    self.titleL.textAlignment= NSTextAlignmentCenter;
    self.titleL.textColor = [UIColor bm_colorWithHex:0xFFFFFF];
    self.titleL.font = [UIFont systemFontOfSize:16.0f];
    self.titleL.numberOfLines = 0;
    
    self.iconImgV = [[UIImageView alloc] init];
    [self.iconImgV setImage:[UIImage imageNamed:@"teacher_responder_title"]];
    [self.circleProgress addSubview:self.iconImgV];
    
    self.personNumberL = [[UILabel alloc] init];
    [self.circleProgress addSubview:self.personNumberL];
    self.personNumberL.text = YSLocalized(@"tool.qiangdaqi");
    self.personNumberL.textAlignment= NSTextAlignmentCenter;
    self.personNumberL.textColor = [UIColor bm_colorWithHex:0xFFFFFF];
    self.personNumberL.font = [UIFont systemFontOfSize:16.0f];
    self.personNumberL.numberOfLines = 0;
    
    
    self.actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];

    [self.actionBtn addTarget:self action:@selector(actionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.actionBtn.hidden = NO;
    self.actionBtn.backgroundColor = [UIColor bm_colorWithHex:0x5A8CDC];
    [self.actionBtn setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
    self.actionBtn.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [self.circleProgress addSubview:self.actionBtn];
    [self.actionBtn bm_addShadow:3 Radius:17 BorderColor:[UIColor bm_colorWithHex:0x97B7EB] ShadowColor:[UIColor grayColor] Offset:CGSizeMake(0, 2) Opacity:0.5];
    
    
    self.selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.selectBtn setTitle:YSLocalized(@"Button.AnswerSpeak") forState:UIControlStateNormal];
    [self.selectBtn setImage:[UIImage imageNamed:@"teacher_responder_up_normal"] forState:UIControlStateNormal];
    [self.selectBtn setImage:[UIImage imageNamed:@"teacher_responder_up_selected"] forState:UIControlStateSelected];
    [self.selectBtn addTarget:self action:@selector(selectBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.selectBtn.hidden = NO;
    [self.selectBtn setTitleColor:[UIColor bm_colorWithHex:0xFFFFFF] forState:UIControlStateNormal];
    self.selectBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.circleProgress addSubview:self.selectBtn];
    [self.selectBtn bm_layoutButtonWithEdgeInsetsStyle:BMButtonEdgeInsetsStyleImageLeft imageTitleGap:4];

    
    
}

- (void)showResponderWithType:(YSTeacherResponderType)responderType
{
    _responderType = responderType;
    self.personNumberL.hidden = NO;
    if (responderType == YSTeacherResponderType_Start)
    {
        self.personNumberL.hidden = YES;
        self.titleL.frame = CGRectMake(20, 10, self.circleProgress.bm_width - 40, 22);
        self.titleL.text = YSLocalized(@"tool.qiangdaqi");
        self.iconImgV.frame = CGRectMake(0, 0, 30, 30);
        self.iconImgV.bm_centerX = self.titleL.bm_centerX;
        self.iconImgV.bm_top = self.titleL.bm_bottom + 10;
        self.actionBtn.frame = CGRectMake(0, 0, 130, 34);
        self.actionBtn.bm_centerX = self.titleL.bm_centerX;
        self.actionBtn.bm_top = self.iconImgV.bm_bottom + 10;
    [self.actionBtn setTitle:YSLocalized(@"tool.start") forState:UIControlStateNormal];
        self.selectBtn.frame = CGRectMake(10, 0, self.circleProgress.bm_width - 20, 20);
        self.selectBtn.bm_top = self.actionBtn.bm_bottom + 15;
        self.actionBtn.hidden = NO;
        self.selectBtn.hidden = NO;
        self.iconImgV.hidden = NO;
        self.selectBtn.selected = NO;
    }
    else if (responderType == YSTeacherResponderType_ING)
    {
        self.titleL.text = YSLocalized(@"Res.btn.getting");
        self.titleL.frame = CGRectMake(20, 70, self.circleProgress.bm_width - 40, 22);
        self.personNumberL.frame = CGRectMake(20, 0, self.circleProgress.bm_width - 40, 22);
        self.personNumberL.bm_top = self.titleL.bm_bottom;
        self.actionBtn.hidden = YES;
        self.selectBtn.hidden = YES;
        self.iconImgV.hidden = YES;
        
    }
    else if (responderType == YSTeacherResponderType_Result)
    {

        self.personNumberL.frame = CGRectMake(20, 60, self.circleProgress.bm_width - 40, 22);
        self.personNumberL.font = [UIFont systemFontOfSize:14.0f];
        self.iconImgV.frame = CGRectMake(0, 20, 30, 30);
        self.iconImgV.bm_centerX = self.personNumberL.bm_centerX;
        
        self.titleL.frame = CGRectMake(20, 0, self.circleProgress.bm_width - 40, 22);
        self.titleL.bm_top = self.personNumberL.bm_bottom + 2;
        self.titleL.text = @"sdfasdf";
        
        self.actionBtn.frame = CGRectMake(0, 0, 130, 34);
        self.actionBtn.bm_centerX = self.titleL.bm_centerX;
        self.actionBtn.bm_top = self.titleL.bm_bottom + 5;
        [self.actionBtn setTitle:YSLocalized(@"Res.btn.noget") forState:UIControlStateNormal];
        self.actionBtn.hidden = NO;
        self.selectBtn.hidden = YES;
    }

}

- (void)setProgress:(CGFloat)progress
{
    self.circleProgress.progress = progress;
}
- (void)setPersonNumber:(NSString *)person totalNumber:(NSString *)totalNumber
{
    NSString *str = [NSString stringWithFormat:@"%@/%@",person,totalNumber];
    self.personNumberL.text = str;
}

- (void)setPersonName:(NSString *)name
{
    self.titleL.text = name;
}

- (void)closeBtnClicked:(UIButton *)btn
{
//    if (self.responderType != YSTeacherResponderType_Start)
//    {
       
        if ([self.delegate respondsToSelector:@selector(teacherResponderCloseClicked)])
        {
            [self.delegate teacherResponderCloseClicked];
        }
//    }
    [self dismiss:nil animated:NO dismissBlock:nil];
}

- (void)actionBtnClicked:(UIButton *)btn
{
    if (self.responderType == YSTeacherResponderType_Start)
    {
        if ([self.delegate respondsToSelector:@selector(startClickedWithUpPlatform:)])
        {
            [self.delegate startClickedWithUpPlatform:self.selectBtn.selected];
        }
    }
    else if (self.responderType == YSTeacherResponderType_Result)
    {
        if ([self.delegate respondsToSelector:@selector(againClicked)])
        {
            [self.delegate againClicked];
        }
    }

}

- (void)selectBtnClicked:(UIButton *)btn
{
    btn.selected = !btn.selected;
}
@end

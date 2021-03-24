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
@property (nonatomic, strong) UIView *circleBacView;

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
        [self setupUI];
        
    }
    return self;
}

- (void)setupUI
{
    self.bacView = [[UIView alloc] init];
    self.bacView.backgroundColor = [UIColor clearColor];
    self.bacView.bm_width = backViewWidth;
    self.bacView.bm_height = backViewHeight;
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeBtn setImage:YSSkinDefineImage(@"close_btn_icon") forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.closeBtn.hidden = NO;
    [self.bacView addSubview:self.closeBtn];
    self.closeBtn.frame = CGRectMake(0, 0, 25, 25);
    self.closeBtn.bm_right = self.bacView.bm_right - 5;
    self.closeBtn.bm_top = self.bacView.bm_top + 5;
    
    //抢答器
    self.circleProgress = [[YSCircleProgress alloc] init];
    self.circleProgress.frame = CGRectMake(0, 0, 180, 180);
    self.circleProgress.lineWidth = 5;
    self.circleProgress.isClockwise = YES;
    self.circleProgress.innerColor = YSSkinDefineColor(@"Color2");
    self.circleProgress.lineBgColor = YSSkinDefineColor(@"Color4");
    self.circleProgress.lineProgressColor = YSSkinDefineColor(@"Color2");
    [self.bacView addSubview:self.circleProgress];
    [self.circleProgress bm_centerInSuperView];
    
    self.circleBacView = [[UIView alloc] init];
    [self.circleProgress addSubview:self.circleBacView];
    self.circleBacView.frame = CGRectMake(0, 0, 160, 160);
    self.circleBacView.backgroundColor = YSSkinDefineColor(@"Color2");
    [self.circleBacView bm_centerInSuperView];
    [self.circleBacView bm_roundedRect:80];
    
    self.titleL = [[UILabel alloc] init];
    [self.circleProgress addSubview:self.titleL];
    
    self.titleL.textAlignment= NSTextAlignmentCenter;
    self.titleL.textColor = YSSkinDefineColor(@"Color3");
    self.titleL.font = [UIFont systemFontOfSize:16.0f];
    self.titleL.numberOfLines = 0;
    
    self.iconImgV = [[UIImageView alloc] init];
    [self.iconImgV setImage:YSSkinElementImage(@"responder_logo", @"iconNor")];
    [self.circleProgress addSubview:self.iconImgV];
    
    self.personNumberL = [[UILabel alloc] init];
    [self.circleProgress addSubview:self.personNumberL];
    self.personNumberL.text = YSLocalized(@"tool.qiangdaqi");
    self.personNumberL.textAlignment= NSTextAlignmentCenter;
    self.personNumberL.textColor = YSSkinDefineColor(@"Color3");
    self.personNumberL.font = [UIFont systemFontOfSize:16.0f];
    self.personNumberL.numberOfLines = 0;
    
    
    self.actionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.actionBtn addTarget:self action:@selector(actionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.actionBtn.hidden = NO;
    self.actionBtn.backgroundColor = YSSkinDefineColor(@"Color4");
    [self.actionBtn setTitleColor:YSSkinDefineColor(@"Color3") forState:UIControlStateNormal];
    self.actionBtn.titleLabel.font = UI_FONT_16;
    [self.circleProgress addSubview:self.actionBtn];
    [self.actionBtn bm_roundedRect:17];
    
    
    self.selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.selectBtn setTitle:YSLocalized(@"Button.AnswerSpeak") forState:UIControlStateNormal];
    [self.selectBtn setImage:YSSkinElementImage(@"responder_upPlatform", @"iconNor") forState:UIControlStateNormal];
    [self.selectBtn setImage:YSSkinElementImage(@"responder_upPlatform", @"iconSel") forState:UIControlStateSelected];
    [self.selectBtn addTarget:self action:@selector(selectBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.selectBtn.hidden = NO;
    [self.selectBtn setTitleColor:YSSkinDefineColor(@"Color3") forState:UIControlStateNormal];
    self.selectBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.circleProgress addSubview:self.selectBtn];
    [self.selectBtn bm_layoutButtonWithEdgeInsetsStyle:BMButtonEdgeInsetsStyleImageLeft imageTitleGap:4];
}

- (void)showYSTeacherResponderType:(YSTeacherResponderType)responderType inView:(UIView *)inView backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets topDistance:(CGFloat)topDistance
{
    self.topDistance = topDistance;
    self.backgroundEdgeInsets = backgroundEdgeInsets;
//    self.responderType = responderType;
    
    [self showWithView:self.bacView inView:inView];
}

- (void)showResponderWithType:(YSTeacherResponderType)responderType
{
    _responderType = responderType;
    self.personNumberL.hidden = NO;
    if (responderType == YSTeacherResponderType_Start)
    {
        self.personNumberL.hidden = YES;
        self.titleL.frame = CGRectMake(20, 15, self.circleProgress.bm_width - 40, 22);
        self.titleL.text = YSLocalized(@"tool.qiangdaqi");
        self.iconImgV.frame = CGRectMake(0, 0, 30, 30);
        self.iconImgV.bm_centerX = self.titleL.bm_centerX;
        self.iconImgV.bm_top = self.titleL.bm_bottom + 10;
        self.actionBtn.frame = CGRectMake(0, 0, 100, 34);
        self.actionBtn.bm_centerX = self.titleL.bm_centerX;
        self.actionBtn.bm_top = self.iconImgV.bm_bottom + 5;
        [self.actionBtn setTitle:YSLocalized(@"tool.start") forState:UIControlStateNormal];
        self.selectBtn.frame = CGRectMake(10, 0, self.circleProgress.bm_width - 20, 20);
        self.selectBtn.bm_top = self.actionBtn.bm_bottom + 18;
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
        self.titleL.text = @"";
        
        self.actionBtn.frame = CGRectMake(0, 0, 100, 34);
        self.actionBtn.bm_centerX = self.titleL.bm_centerX;
        self.actionBtn.bm_top = self.titleL.bm_bottom + 5;
        [self.actionBtn setTitle:YSLocalized(@"Res.btn.noget") forState:UIControlStateNormal];
        self.actionBtn.enabled = YES;// 只能点一次开始 以后变为不可点状态 直达抢答结果时可以点击
        self.actionBtn.hidden = NO;
        self.selectBtn.hidden = YES;
        self.iconImgV.hidden = NO;
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

- (void)setCloseBtnHide:(BOOL)hide
{
    self.closeBtn.hidden = hide;
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
    
}

- (void)actionBtnClicked:(UIButton *)btn
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(doAction) object:nil];
    [self performSelector:@selector(doAction) withObject:nil afterDelay:0.5f];
}

- (void)doAction
{
    if (self.responderType == YSTeacherResponderType_Start)
    {
        self.actionBtn.enabled = NO;// 只能点一次开始 之后变为不可点状态 直达抢答结果时可以点击
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

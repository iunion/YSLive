//
//  YSToolBoxView.m
//  YSLive
//
//  Created by fzxm on 2020/6/2.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSToolBoxView.h"

static const CGFloat kToolBoxWidth_iPhone = 240.0f;
static const CGFloat kToolBoxWidth_iPad = 308.0f;
#define ToolBoxWidth        ([UIDevice bm_isiPad] ? kToolBoxWidth_iPad : kToolBoxWidth_iPhone)

static const CGFloat kToolBoxHeight_iPhone = 150.0f;
static const CGFloat kToolBoxHeight_iPad = 215.0f;
#define ToolBoxHeight       ([UIDevice bm_isiPad] ? kToolBoxHeight_iPad : kToolBoxHeight_iPhone)

#define ToolBoxBtnWidth     YSToolBar_BtnWidth

#define ToolBoxTitleHeight  (40.0f)

@interface YSToolBoxView()
<
    UIGestureRecognizerDelegate
>
/// 底部view
@property (nonatomic, strong) UIView *bacView;

/// 标题
@property (nonatomic, strong) UILabel *titleL;

/// 答题器
@property (nonatomic, weak) BMImageTitleButtonView *answerBtn;
/// 上传图片
@property (nonatomic, weak) BMImageTitleButtonView *albumBtn;
/// 计时器
@property (nonatomic, weak) BMImageTitleButtonView *timerBtn;
/// 抢答器
@property (nonatomic, weak) BMImageTitleButtonView *responderBtn;

@property (nonatomic, strong) NSMutableArray <BMImageTitleButtonView *> *btnArray;

@property (nonatomic, assign) YSUserRoleType roleType;

@end

@implementation YSToolBoxView

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
        self.noticeMaskBgEffectView.alpha = 1.0f;
        self.noticeMaskBgColor = [UIColor bm_colorWithHex:0x000000 alpha:0.6f];
        self.btnArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)showToolBoxViewInView:(UIView *)inView
         backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets
                  topDistance:(CGFloat)topDistance
                     userRole:(YSUserRoleType)roleType
{
    self.roleType = roleType;
    self.topDistance = topDistance;
    self.backgroundEdgeInsets = backgroundEdgeInsets;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClicked:)];
    tapGesture.delegate = self;
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGesture];
    
    self.bacView = [[UIView alloc] init];
    self.bacView.backgroundColor = [YSSkinDefineColor(@"PopViewBgColor") changeAlpha:YSPopViewDefaultAlpha];
    self.bacView.bm_width = ToolBoxWidth;
    self.bacView.bm_height = ToolBoxHeight;
    self.bacView.layer.cornerRadius = 24.0f;
    self.bacView.layer.masksToBounds = YES;
    
    UILabel *titleL = [[UILabel alloc] init];
    self.titleL = titleL;
    titleL.font = [UIDevice bm_isiPad] ? UI_FONT_16 : UI_FONT_12;
    titleL.textAlignment = NSTextAlignmentCenter;
    titleL.textColor = YSSkinDefineColor(@"defaultTitleColor");
    titleL.text = YSLocalized(@"Title.ToolBox");
    [self.bacView addSubview:titleL];
    titleL.frame = CGRectMake(0, 0, ToolBoxWidth, ToolBoxTitleHeight);
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = YSSkinDefineColor(@"lineColor");
    lineView.frame = CGRectMake(0, CGRectGetMaxY(titleL.frame), ToolBoxWidth, 1.0f);
    [self.bacView addSubview:lineView];
    
    /// 答题器
    BMImageTitleButtonView *answerBtn = [self creatButtonWithNormalTitle:@"tool.datiqiqi" selectedTitle:@"tool.datiqiqi" pathName:@"toolBox_answer"];
    answerBtn.tag = SCToolBoxTypeAnswer;
    
    /// 上传照片
    BMImageTitleButtonView *albumBtn = [self creatButtonWithNormalTitle:@"UploadPhoto.FromGallery" selectedTitle:@"UploadPhoto.FromGallery" pathName:@"toolBox_album"];
    albumBtn.tag = SCToolBoxTypeAlbum;
    
    /// 计时器
    BMImageTitleButtonView *timerBtn = [self creatButtonWithNormalTitle:@"tool.jishiqi" selectedTitle:@"tool.jishiqi" pathName:@"toolBox_timer"];
    timerBtn.tag = SCToolBoxTypeTimer;
    
    /// 抢答器
    BMImageTitleButtonView *responderBtn = [self creatButtonWithNormalTitle:@"tool.qiangdaqi" selectedTitle:@"tool.qiangdaqi" pathName:@"toolBox_responder"];
    responderBtn.tag = SCToolBoxTypeResponder;
    
    if (self.roleType == YSUserType_Teacher)
    {
        self.answerBtn = answerBtn;
        [self.btnArray addObject:self.answerBtn];

        self.albumBtn = albumBtn;
        [self.btnArray addObject:self.albumBtn];
        
        self.timerBtn = timerBtn;
        [self.btnArray addObject:self.timerBtn];

        self.responderBtn = responderBtn;
        [self.btnArray addObject:self.responderBtn];
    }
    else if (self.roleType == YSUserType_Student)
    {
        self.albumBtn = albumBtn;
        [self.btnArray addObject:self.albumBtn];
    }
    
    /// 1-2-2-1
    CGFloat tempWidthGap = (ToolBoxWidth - ToolBoxBtnWidth * 3.0f) / 6.0f;
    /// 1-1-1
    CGFloat tempHeightGap = (ToolBoxHeight - ToolBoxBtnWidth * 2.0f - ToolBoxTitleHeight) / 3.0f;
    for (NSUInteger index=0; index<self.btnArray.count; index++)
    {
        NSUInteger column = index % 3;
        NSUInteger row = index / 3;
        BMImageTitleButtonView *btn = self.btnArray[index];
        [self.bacView addSubview:btn];
        CGRect frame = CGRectMake(tempWidthGap+(ToolBoxBtnWidth+tempWidthGap*2)*column, ToolBoxTitleHeight + tempHeightGap + (ToolBoxBtnWidth+tempHeightGap)*row, ToolBoxBtnWidth, ToolBoxBtnWidth);
        btn.frame = frame;
    }
    
    [self showWithView:self.bacView inView:inView];
}

- (BMImageTitleButtonView *)creatButtonWithNormalTitle:(NSString *)norTitle selectedTitle:(NSString *)selTitle pathName:(NSString *)pathName
{
    UIImage *normalImage = YSSkinElementImage(pathName, @"iconNor");
    UIImage *selectedImage = YSSkinElementImage(pathName, @"iconSel");
    UIImage *disabledImage = [normalImage bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];

    BMImageTitleButtonView *toolBtn = [[BMImageTitleButtonView alloc] init];
    toolBtn.userInteractionEnabled = YES;
    toolBtn.type = BMImageTitleButtonView_ImageTop;
    toolBtn.textFont = UI_FONT_10;
    toolBtn.imageTextGap = 2.0f;
    toolBtn.normalImage = normalImage;
    toolBtn.selectedImage = selectedImage;
    toolBtn.disabledImage = disabledImage;
    if (norTitle)
    {
        toolBtn.normalText = YSLocalized(norTitle);
        toolBtn.disabledText = YSLocalized(norTitle);
    }
    if (selTitle)
    {
        toolBtn.selectedText = YSLocalized(selTitle);
    }
    toolBtn.frame = CGRectMake(0, 0, ToolBoxBtnWidth, ToolBoxBtnWidth);
    [toolBtn addTarget:self action:@selector(toolBoxBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

    return toolBtn;
}

- (void)toolBoxBtnClicked:(BMImageTitleButtonView *)btn
{
    if ([self.delegate respondsToSelector:@selector(toolBoxViewClickAtToolBoxType:)])
    {
        [self.delegate toolBoxViewClickAtToolBoxType:btn.tag];
    }
    
    [self dismiss:nil animated:NO dismissBlock:nil];
}

- (void)tapGestureClicked:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(closeToolBoxView)])
    {
        [self.delegate closeToolBoxView];
    }
    
    [self dismiss:nil animated:NO dismissBlock:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.bacView] )
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

@end

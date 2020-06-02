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

static const CGFloat kToolBoxHeight_iPhone = 146.0f;
static const CGFloat kToolBoxHeight_iPad = 208.0f;
#define ToolBoxHeight       ([UIDevice bm_isiPad] ? kToolBoxHeight_iPad : kToolBoxHeight_iPhone)


static const CGFloat kToolBoxBtnWidth_iPhone = 44.0f;
static const CGFloat kToolBoxBtnWidth_iPad = 52.0f;
#define toolBoxBtnWidth     ([UIDevice bm_isiPad] ? kToolBoxBtnWidth_iPad : kToolBoxBtnWidth_iPhone)


#define toolBoxBtnGap       (6.0f)
@interface YSToolBoxView()
/// 底部view
@property (nonatomic, strong) UIView *bacView;
/// 答题器
@property (nonatomic, strong) BMImageTitleButtonView *answerBtn;
/// 上传图片
@property (nonatomic, strong) BMImageTitleButtonView *albumBtn;
/// 计时器
@property (nonatomic, strong) BMImageTitleButtonView *timerBtn;
/// 抢答器
@property (nonatomic, strong) BMImageTitleButtonView *responderBtn;

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
        self.noticeMaskBgEffectView.alpha = 1;
        self.noticeMaskBgColor = [UIColor bm_colorWithHex:0x000000 alpha:0.6];
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
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClicked:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGesture];
    
    self.bacView = [[UIView alloc] init];
    self.bacView.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
    self.bacView.bm_width = ToolBoxWidth;
    self.bacView.bm_height = ToolBoxHeight;
    self.bacView.layer.cornerRadius = 26;
    self.bacView.layer.masksToBounds = YES;
    [self showWithView:self.bacView inView:inView];
    
    /// 答题器
    BMImageTitleButtonView *answerBtn = [self creatButtonWithNormalTitle:@"Title.AllNoAudio" selectedTitle:@"Title.AllAudio" pathName:@"allNoAudio_bottombar"];
    answerBtn.tag = SCToolBoxTypeAnswer;
    
    /// 上传照片
    BMImageTitleButtonView *albumBtn = [self creatButtonWithNormalTitle:@"Title.ChangeCamera" selectedTitle:@"Title.ChangeCamera" pathName:@"camera_bottombar"];
    albumBtn.tag = SCToolBoxTypeAlbum;
    
    /// 计时器
    BMImageTitleButtonView *timerBtn = [self creatButtonWithNormalTitle:@"Title.Message" selectedTitle:@"Title.Message" pathName:@"message_bottombar"];
    timerBtn.tag = SCToolBoxTypeTimer;
    
    /// 抢答器
    BMImageTitleButtonView *responderBtn = [self creatButtonWithNormalTitle:@"Title.Exit" selectedTitle:@"Title.Exit" pathName:@"exit_bottombar"];
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
    
    CGFloat tempWidthGap = (ToolBoxWidth - toolBoxBtnWidth * 3.0f) / 6.0f;
    CGFloat tempHeightGap = (ToolBoxHeight - toolBoxBtnWidth * 2.0f) / 3.0f;
    for (NSUInteger index=0; index<self.btnArray.count; index++)
    {
        NSInteger column = index % 3;
        NSInteger row = index / 3;
        BMImageTitleButtonView *btn = self.btnArray[index];
        [self addSubview:btn];
        CGRect frame = CGRectMake(tempWidthGap+(toolBoxBtnWidth+tempWidthGap*2)*index, tempHeightGap, toolBoxBtnWidth, toolBoxBtnWidth);
        btn.frame = frame;
    }
    
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
    toolBtn.frame = CGRectMake(0, 0, toolBoxBtnWidth, toolBoxBtnWidth);
    [toolBtn addTarget:self action:@selector(toolBoxBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

    return toolBtn;
}


- (void)toolBoxBtnClicked:(BMImageTitleButtonView *)btn
{
    
}


- (void)tapGestureClicked:(UITapGestureRecognizer *)tap
{
    [self endEditing:YES];
}

@end

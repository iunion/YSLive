//
//  YSSpreadBottomToolBar.m
//  YSLive
//
//  Created by jiang deng on 2020/6/1.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSSpreadBottomToolBar.h"
#import "BMImageTitleButtonView.h"

static const CGFloat kBarBtnWidth_iPhone = 44.0f;
static const CGFloat kBarBtnWidth_iPad = 52.0f;

#define BarBtnWidth     ([UIDevice bm_isiPad] ? kBarBtnWidth_iPad : kBarBtnWidth_iPhone)
#define BarBtnGap       (4.0f)
#define BarSpreadBtnGap (6.0f)


@interface YSSpreadBottomToolBar ()

@property (nonatomic, assign) YSUserRoleType roleType;

@property (nonatomic, assign) CGPoint topLeftpoint;

@property (nonatomic, assign) BOOL spreadOut;

@property (nonatomic, strong) BMImageTitleButtonView *spreadBtn;
@property (nonatomic, strong) NSMutableArray <BMImageTitleButtonView *> *btnArray;

/// 花名册
@property (nonatomic, strong) BMImageTitleButtonView *personListBtn;
/// 课件库
@property (nonatomic, strong) BMImageTitleButtonView *coursewareBtn;
/// 工具箱
@property (nonatomic, strong) BMImageTitleButtonView *toolBoxBtn;
/// 切换布局
@property (nonatomic, strong) BMImageTitleButtonView *switchLayoutBtn;
/// 轮询
@property (nonatomic, strong) BMImageTitleButtonView *pollingBtn;
/// 全体静音
@property (nonatomic, strong) BMImageTitleButtonView *allNoAudioBtn;
/// 切换摄像头
@property (nonatomic, strong) BMImageTitleButtonView *cameraBtn;
/// 聊天按钮
@property (nonatomic, strong) BMImageTitleButtonView *chatBtn;
/// 退出房间
@property (nonatomic, strong) BMImageTitleButtonView *exitBtn;

@end

@implementation YSSpreadBottomToolBar

- (instancetype)initWithUserRole:(YSUserRoleType)roleType topLeftpoint:(CGPoint)point
{
    self = [super init];
    if (self)
    {
        self.roleType = roleType;
        self.topLeftpoint = point;
        
        self.btnArray = [[NSMutableArray alloc] init];
        
        self.spreadOut = YES;
        
        [self setupView];
    }
    
    return self;
}

- (void)setupView
{
    /// 收起展开
    self.spreadBtn = [self creatButtonWithNormalTitle:nil selectedTitle:nil pathName:@"onOff_bottombar"];
    
    [self addSubview:self.spreadBtn];
    self.spreadBtn.tag = SCTeacherTopBarTypeOnOff;

    /// 花名册
    BMImageTitleButtonView *personListBtn = [self creatButtonWithNormalTitle:@"Title.UserList" selectedTitle:@"Title.UserList" pathName:@"personList_bottombar"];
    personListBtn.tag = SCTeacherTopBarTypePersonList;
    
    /// 课件库
    BMImageTitleButtonView *coursewareBtn = [self creatButtonWithNormalTitle:@"Title.DocumentList" selectedTitle:@"Title.DocumentList" pathName:@"courseware_bottombar"];
    coursewareBtn.tag = SCTeacherTopBarTypeCourseware;
    
    /// 工具箱
    BMImageTitleButtonView *toolBoxBtn = [self creatButtonWithNormalTitle:@"Title.ToolBox" selectedTitle:@"Title.ToolBox" pathName:@"toolBox_bottombar"];
    toolBoxBtn.tag = SCTeacherTopBarTypeToolBox;
    
    /// 切换布局
    BMImageTitleButtonView *switchLayoutBtn = [self creatButtonWithNormalTitle:@"Title.AroundLayout" selectedTitle:@"Title.VideoLayout" pathName:@"layout_bottombar"];
    switchLayoutBtn.tag = SCTeacherTopBarTypeSwitchLayout;
    
    /// 轮询
    BMImageTitleButtonView *pollingBtn = [self creatButtonWithNormalTitle:@"Title.Polling" selectedTitle:@"Title.Polling" pathName:@"polling_bottombar"];
    pollingBtn.tag = SCTeacherTopBarTypePolling;
    
    /// 全体禁音
    BMImageTitleButtonView *allNoAudioBtn = [self creatButtonWithNormalTitle:@"Title.AllNoAudio" selectedTitle:@"Title.AllAudio" pathName:@"allNoAudio_bottombar"];
    allNoAudioBtn.tag = SCTeacherTopBarTypeAllNoAudio;
    
    /// 切换摄像头
    BMImageTitleButtonView *cameraBtn = [self creatButtonWithNormalTitle:@"Title.ChangeCamera" selectedTitle:@"Title.ChangeCamera" pathName:@"camera_bottombar"];
    cameraBtn.tag = SCTeacherTopBarTypeCamera;
    
    /// 消息
    BMImageTitleButtonView *chatBtn = [self creatButtonWithNormalTitle:@"Title.Message" selectedTitle:@"Title.Message" pathName:@"message_bottombar"];
    chatBtn.tag = SCTeacherTopBarTypeChat;
    
    /// 退出
    BMImageTitleButtonView *exitBtn = [self creatButtonWithNormalTitle:@"Title.Exit" selectedTitle:@"Title.Exit" pathName:@"exit_bottombar"];
    exitBtn.tag = SCTeacherTopBarTypeExit;
    
    if (self.roleType == YSUserType_Teacher)
    {
        self.personListBtn = personListBtn;
        [self.btnArray addObject:self.personListBtn];

        self.coursewareBtn = coursewareBtn;
        [self.btnArray addObject:self.coursewareBtn];
        
        self.toolBoxBtn = toolBoxBtn;
        [self.btnArray addObject:self.toolBoxBtn];

        self.switchLayoutBtn = switchLayoutBtn;
        [self.btnArray addObject:self.switchLayoutBtn];

        self.pollingBtn = pollingBtn;
        [self.btnArray addObject:self.pollingBtn];

        self.allNoAudioBtn = allNoAudioBtn;
        [self.btnArray addObject:self.allNoAudioBtn];
        
        self.cameraBtn = cameraBtn;
        [self.btnArray addObject:self.cameraBtn];
        
        self.chatBtn = chatBtn;
        [self.btnArray addObject:self.chatBtn];
    }
    else if (self.roleType == YSUserType_Student)
    {
        self.cameraBtn = cameraBtn;
        [self.btnArray addObject:self.cameraBtn];
        
        self.chatBtn = chatBtn;
        [self.btnArray addObject:self.chatBtn];
    }
    else if (self.roleType == YSUserType_Patrol)
    {
        self.personListBtn = personListBtn;
        [self.btnArray addObject:self.personListBtn];

        self.coursewareBtn = personListBtn;
        [self.btnArray addObject:self.coursewareBtn];
        
        self.cameraBtn = cameraBtn;
        [self.btnArray addObject:self.cameraBtn];
        
        self.chatBtn = chatBtn;
        [self.btnArray addObject:self.chatBtn];
    }

    self.exitBtn = exitBtn;
    [self.btnArray addObject:self.exitBtn];
    
    CGFloat top = self.topLeftpoint.y;
    CGFloat left = self.topLeftpoint.x - ((BarBtnWidth+BarBtnGap) * self.btnArray.count + BarSpreadBtnGap-BarBtnGap);
    CGFloat width = (BarBtnWidth+BarBtnGap) * (self.btnArray.count+1) + BarSpreadBtnGap;
    CGFloat height = BarBtnWidth + BarBtnGap*2.0f;

    self.frame = CGRectMake(left, top, width, height);
    CGFloat btnLeft = BarBtnGap;
    for (NSUInteger index=0; index<self.btnArray.count; index++)
    {
        BMImageTitleButtonView *btn = self.btnArray[index];
        [self addSubview:btn];
        CGRect frame = CGRectMake(btnLeft+(BarBtnWidth+BarBtnGap)*index, BarBtnGap, BarBtnWidth, BarBtnWidth);
        btn.frame = frame;
    }
    
    self.spreadBtn.bm_left = self.bm_width-(BarBtnWidth+BarBtnGap);
    self.spreadBtn.bm_top = BarBtnGap;

    [self bm_addShadow:0.0f Radius:self.bm_height*0.5f BorderColor:nil ShadowColor:[UIColor grayColor]];
    self.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
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
    
    toolBtn.frame = CGRectMake(0, 0, BarBtnWidth, BarBtnWidth);
    [toolBtn addTarget:self action:@selector(bottomToolBarClicked:) forControlEvents:UIControlEventTouchUpInside];
    return toolBtn;
}


- (void)bottomToolBarClicked:(BMImageTitleButtonView *)btn
{
    if (btn != self.pollingBtn)
    {
        btn.selected = !btn.selected;
    }
    
    if (btn == self.spreadBtn)
    {
        self.spreadOut = !self.spreadOut;
        
        if (self.spreadOut)
        {
            CGFloat top = self.topLeftpoint.y;
            CGFloat left = self.topLeftpoint.x - ((BarBtnWidth+BarBtnGap) * self.btnArray.count + BarSpreadBtnGap-BarBtnGap);
            CGFloat width = (BarBtnWidth+BarBtnGap) * (self.btnArray.count+1) + BarSpreadBtnGap;
            CGFloat height = BarBtnWidth + BarBtnGap*2.0f;

            self.frame = CGRectMake(left, top, width, height);
            self.spreadBtn.bm_top = BarBtnGap;
            self.spreadBtn.bm_left = self.bm_width-(BarBtnWidth+BarBtnGap);
            
            for (UIButton *btn in self.btnArray)
            {
                btn.hidden = NO;
            }
        }
        else
        {
            CGFloat top = self.topLeftpoint.y;
            CGFloat left = self.topLeftpoint.x;
            CGFloat width = BarBtnWidth + BarBtnGap*2.0f;
            CGFloat height = BarBtnWidth + BarBtnGap*2.0f;

            self.frame = CGRectMake(left, top, width, height);
            self.spreadBtn.bm_top = BarBtnGap;
            self.spreadBtn.bm_left = BarBtnGap;
            
            for (UIButton *btn in self.btnArray)
            {
                btn.hidden = YES;
            }
        }
        
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(bottomToolBarSpreadOut:)])
        {
            [self.delegate bottomToolBarSpreadOut:self.spreadOut];
        }
        
        return;
    }
    
    if (btn == self.chatBtn)
    {
        if (btn.selected)
        {
            self.isNewMessage = NO;
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomToolBarClickAtIndex:select:)])
    {
        [self.delegate bottomToolBarClickAtIndex:btn.tag select:btn.selected];
    }
}

- (void)hideListView
{
    self.personListBtn.selected = NO;
    self.coursewareBtn.selected = NO;
}
/// 隐藏消息界面
- (void)hideMessageView
{
    self.chatBtn.selected = NO;
}

- (void)setIsNewMessage:(BOOL)isNewMessage
{
    if (isNewMessage)
    {
        if (!self.chatBtn.selected)
        {
            self.chatBtn.badgeRadius = 2.0f;
            self.chatBtn.badgeCenterOffset = CGPointMake(-12, 5);
            self.chatBtn.badgeBorderColor = [UIColor redColor];
            [self.chatBtn showRedDotBadge];
        }
    }
    else
    {
        [self.chatBtn clearBadge];
    }
}

- (void)setIsPolling:(BOOL)isPolling
{
    _isPolling = isPolling;
    if (self.isPollingEnable)
    {
        self.pollingBtn.selected = isPolling;
    }
    else
    {
//        self.pollingBtn.selected = NO;
    }
}

- (void)setIsPollingEnable:(BOOL)isPollingEnable
{
    _isPollingEnable = isPollingEnable;
    if (self.isBeginClass)
    {
        self.pollingBtn.enabled = isPollingEnable;
    }
    else
    {
        self.pollingBtn.enabled = NO;
    }
    
}

- (void)setUserEnable:(BOOL)userEnable
{
    _userEnable = userEnable;
    ///花名册
    self.personListBtn.enabled = userEnable;
    ///课件库
    self.coursewareBtn.enabled = userEnable;
    ///工具箱
    self.toolBoxBtn.enabled = userEnable;
    ///切换布局
    self.switchLayoutBtn.enabled = userEnable;
    /// 轮询
    self.pollingBtn.enabled = userEnable;
    /// 全体禁音
    self.allNoAudioBtn.enabled = userEnable;
    ///切换摄像头
    self.cameraBtn.enabled = userEnable;
    /// 消息
    self.chatBtn.enabled = userEnable;
    
}

- (void)setIsAroundLayout:(BOOL)isAroundLayout
{
    _isAroundLayout = isAroundLayout;
    self.switchLayoutBtn.selected = !isAroundLayout;
}

- (void)setIsBeginClass:(BOOL)isBeginClass
{
    _isBeginClass = isBeginClass;
    self.allNoAudioBtn.enabled = isBeginClass;
    self.switchLayoutBtn.enabled = isBeginClass;
    self.toolBoxBtn.enabled = isBeginClass;

}
@end

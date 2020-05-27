//
//  YSBottomToolBar.m
//  YSLive
//
//  Created by fzxm on 2020/5/26.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSBottomToolBar.h"

#define barBtn_iPadWidth  40
#define barBtn_iPhoneWidth  36
#define barBtn_gap_horizontal  20.0f


static const CGFloat kBarBtnOnOff_Width_iPhone = 36.0f;
static const CGFloat kBarBtnOnOff_Width_iPad = 40.0f;
#define BarBtnOnOff_Width           ([UIDevice bm_isiPad] ? kBarBtnOnOff_Width_iPad : kBarBtnOnOff_Width_iPhone)

static const CGFloat kBarBtn_gap_iPhone = 4.0f;
static const CGFloat kBarBtn_gap_iPad = 5.0f;
#define BarBtnGap           ([UIDevice bm_isiPad] ? kBarBtn_gap_iPad : kBarBtn_gap_iPhone)

@interface YSBottomToolBar ()

/// 花名册
@property (nonatomic, strong) UIButton *personListBtn;
/// 课件库
@property (nonatomic, strong) UIButton *coursewareBtn;
/// 工具箱
@property (nonatomic, strong) UIButton *toolBoxBtn;
/// 切换布局
@property (nonatomic, strong) UIButton *switchLayoutBtn;
/// 轮询
@property (nonatomic, strong) UIButton *pollingBtn;
/// 全体静音
@property (nonatomic, strong) UIButton *allNoAudioBtn;
/// 切换摄像头
@property (nonatomic, strong) UIButton *cameraBtn;
/// 聊天按钮
@property (nonatomic, strong) UIButton *chatBtn;
/// 退出房间
@property (nonatomic, strong) UIButton *exitBtn;

/// 收起展开
@property (nonatomic, strong) UIButton *onOffBtn;

@end


@implementation YSBottomToolBar
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    
    return self;
}


- (void)setup
{
    self.userEnable = YES;
    
    ///花名册
    UIButton *personListBtn = [self creatButtonWithNorTitle:@"Title.UserList" selTitle:@"Title.UserList" pathName:@"personList_bottombar"];
    self.personListBtn = personListBtn;
    [self addSubview:self.personListBtn];
    personListBtn.tag = SCTeacherTopBarTypePersonList;
    
    ///课件库
    UIButton *coursewareBtn = [self creatButtonWithNorTitle:@"Title.DocumentList" selTitle:@"Title.DocumentList" pathName:@"courseware_bottombar"];
    self.coursewareBtn = coursewareBtn;
    [self addSubview:self.coursewareBtn];
    coursewareBtn.tag = SCTeacherTopBarTypeCourseware;
    
    ///工具箱
    UIButton *toolBoxBtn = [self creatButtonWithNorTitle:@"Title.ToolBox" selTitle:@"Title.ToolBox" pathName:@"toolBox_bottombar"];
    self.toolBoxBtn = toolBoxBtn;
    [self addSubview:self.toolBoxBtn];
    toolBoxBtn.tag = SCTeacherTopBarTypeToolBox;
    
    ///切换布局
    UIButton *switchLayoutBtn = [self creatButtonWithNorTitle:@"Title.AroundLayout" selTitle:@"Title.VideoLayout" pathName:@"layout_bottombar"];
    self.switchLayoutBtn = switchLayoutBtn;
    [self addSubview:self.switchLayoutBtn];
    switchLayoutBtn.tag = SCTeacherTopBarTypeSwitchLayout;
    
    /// 轮询
    UIButton *pollingBtn = [self creatButtonWithNorTitle:@"Title.Polling" selTitle:@"Title.Polling" pathName:@"polling_bottombar"];
    self.pollingBtn = pollingBtn;
    [self addSubview:self.pollingBtn];
    pollingBtn.tag = SCTeacherTopBarTypePolling;
    
    /// 全体禁音
    UIButton *allNoAudioBtn = [self creatButtonWithNorTitle:@"Title.AllNoAudio" selTitle:@"Title.AllAudio" pathName:@"allNoAudio_bottombar"];
    self.allNoAudioBtn = allNoAudioBtn;
    [self addSubview:self.allNoAudioBtn];
    allNoAudioBtn.tag = SCTeacherTopBarTypeAllNoAudio;
    
    /// 切换摄像头
    UIButton *cameraBtn = [self creatButtonWithNorTitle:@"Title.ChangeCamera" selTitle:@"Title.ChangeCamera" pathName:@"camera_bottombar"];
    self.cameraBtn = cameraBtn;
    [self addSubview:self.cameraBtn];
    cameraBtn.tag = SCTeacherTopBarTypeCamera;
    
    /// 消息
    UIButton *chatBtn = [self creatButtonWithNorTitle:@"Title.Message" selTitle:@"Title.Message" pathName:@"message_bottombar"];
    self.chatBtn = chatBtn;
    [self addSubview:self.chatBtn];
    chatBtn.tag = SCTeacherTopBarTypeChat;
    
    /// 退出
    UIButton *exitBtn = [self creatButtonWithNorTitle:@"Title.Exit" selTitle:@"Title.Exit" pathName:@"exit_bottombar"];
    self.exitBtn = exitBtn;
    [self addSubview:self.exitBtn];
    exitBtn.tag = SCTeacherTopBarTypeExit;
    
    /// 收起展开
    UIButton *onOffBtn = [self creatButtonWithNorTitle:@"" selTitle:@"" pathName:@"onOff_bottombar"];
    self.onOffBtn = onOffBtn;
    [self addSubview:self.onOffBtn];
    onOffBtn.tag = SCTeacherTopBarTypeOnOff;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat selfWidth = self.bounds.size.width;
    CGFloat selfHeight = self.bounds.size.height;
    CGFloat topGap = BarBtnGap;
    CGFloat onOffBtnWidth = BarBtnOnOff_Width;

    CGFloat btnWidth = (selfWidth - topGap*2.0f - onOffBtnWidth - barBtn_gap_horizontal * 10.0f) / 9.0f;
    CGFloat btnHeight = selfHeight - topGap * 2.0f;
    
    self.onOffBtn.frame = CGRectMake(selfWidth - topGap*2 - onOffBtnWidth , topGap, onOffBtnWidth, onOffBtnWidth);
    
    ///花名册
    self.personListBtn.frame = CGRectMake(barBtn_gap_horizontal , topGap, btnWidth, btnHeight);
    ///课件库
    self.coursewareBtn.frame = CGRectMake(0 , topGap, btnWidth, btnHeight);
    self.coursewareBtn.bm_left = self.personListBtn.bm_right + barBtn_gap_horizontal;
    ///工具箱
    self.toolBoxBtn.frame = CGRectMake(0 , topGap, btnWidth, btnHeight);
    self.toolBoxBtn.bm_left = self.coursewareBtn.bm_right + barBtn_gap_horizontal;
    ///切换布局
    self.switchLayoutBtn.frame = CGRectMake(0 , topGap, btnWidth, btnHeight);
    self.switchLayoutBtn.bm_left = self.toolBoxBtn.bm_right + barBtn_gap_horizontal;
    /// 轮询
    self.pollingBtn.frame = CGRectMake(0 , topGap, btnWidth, btnHeight);
    self.pollingBtn.bm_left = self.switchLayoutBtn.bm_right + barBtn_gap_horizontal;
    /// 全体禁音
    self.allNoAudioBtn.frame = CGRectMake(0 , topGap, btnWidth, btnHeight);
    self.allNoAudioBtn.bm_left = self.pollingBtn.bm_right + barBtn_gap_horizontal;
    ///切换摄像头
    self.cameraBtn.frame = CGRectMake(0 , topGap, btnWidth, btnHeight);
    self.cameraBtn.bm_left = self.allNoAudioBtn.bm_right + barBtn_gap_horizontal;
    /// 消息
    self.chatBtn.frame = CGRectMake(0 , topGap, btnWidth, btnHeight);
    self.chatBtn.bm_left = self.cameraBtn.bm_right + barBtn_gap_horizontal;
    /// 退出
    self.exitBtn.frame = CGRectMake(0 , topGap, btnWidth, btnHeight);
    self.exitBtn.bm_left = self.chatBtn.bm_right + barBtn_gap_horizontal;
      
}



- (UIButton *)creatButtonWithNorTitle:(NSString *)norTitle selTitle:(NSString *)selTitle pathName:(NSString *)pathName
{
    UIButton *toolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [toolBtn setImage:YSSkinElementImage(pathName, @"iconNor") forState:UIControlStateNormal];
    [toolBtn setImage:YSSkinElementImage(pathName, @"iconSel") forState:UIControlStateSelected];
    [toolBtn setImage:YSSkinElementImage(pathName, @"iconDis") forState:UIControlStateDisabled];
    
    if ([norTitle bm_isNotEmpty])
    {
        [toolBtn setTitle:YSLocalized(norTitle) forState:UIControlStateNormal];
        toolBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 8, toolBtn.titleLabel.bounds.size.height - 5, 0);
        toolBtn.titleEdgeInsets = UIEdgeInsetsMake(toolBtn.currentImage.size.width, -(toolBtn.currentImage.size.width), 0, 0);
        toolBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    }
    if ([selTitle bm_isNotEmpty])
    {
        [toolBtn setTitle:YSLocalized(selTitle) forState:UIControlStateSelected];
    }
    
    [toolBtn setTitleColor:YSSkinDefineColor(@"defaultTitleColor") forState:UIControlStateNormal];
    [toolBtn setTitleColor:YSSkinDefineColor(@"disableColor") forState:UIControlStateDisabled];
    
    toolBtn.titleLabel.font = UI_FONT_10;
    toolBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [toolBtn addTarget:self action:@selector(bottomToolBarClicked:) forControlEvents:UIControlEventTouchUpInside];
    toolBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    return toolBtn;
    
}

- (void)bottomToolBarClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(sc_bottomToolBarProxyWithBtn:)])
    {
        [self.delegate sc_bottomToolBarProxyWithBtn:btn];
    }
}


#pragma mark - 设置导航按钮

//- (void)setBtnView
//{
//
//    /// 轮询
//    UIButton *pollingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.pollingBtn = pollingBtn;
//    [self.btnStackView addArrangedSubview:self.pollingBtn];
//    [pollingBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_personPollingBtn_Normal"] forState:UIControlStateNormal];
//    [pollingBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_personPollingBtn_Selected"] forState:UIControlStateSelected];
//    [pollingBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_personPollingBtn_Disabled"] forState:UIControlStateDisabled];
//    [pollingBtn addTarget:self action:@selector(pollingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    pollingBtn.tag = SCTeacherTopBarTypePolling;
//    
//    
//
//    
//    ///课件库
//    UIButton *coursewareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.coursewareBtn = coursewareBtn;
//    [self.btnStackView addArrangedSubview:self.coursewareBtn];
//    [coursewareBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_coursewareBtn_Normal"] forState:UIControlStateNormal];
//    [coursewareBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_coursewareBtn_Selected"] forState:UIControlStateSelected];
//    [coursewareBtn addTarget:self action:@selector(coursewareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    coursewareBtn.tag = SCTeacherTopBarTypeCourseware;
//    
//    ///工具箱
//    UIButton *toolBoxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.toolBoxBtn = toolBoxBtn;
//    [self.btnStackView addArrangedSubview:self.toolBoxBtn];
//    [toolBoxBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_toolBoxBtn_Normal"] forState:UIControlStateNormal];
//    [toolBoxBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_toolBoxBtn_Selected"] forState:UIControlStateSelected];
//    [toolBoxBtn addTarget:self action:@selector(toolBoxBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    toolBoxBtn.tag = SCTeacherTopBarTypeToolBox;
//   
//    ///全局控制
//    UIButton *allControllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.allControllBtn = allControllBtn;
//    [self.btnStackView addArrangedSubview:self.allControllBtn];
//    [allControllBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_allControllBtn_Normal"] forState:UIControlStateNormal];
//    [allControllBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_allControllBtn_Selected"] forState:UIControlStateSelected];
//    [allControllBtn addTarget:self action:@selector(allControllBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    allControllBtn.tag = SCTeacherTopBarTypeAllControll;
//    
//    /// 切换布局
//    UIButton *switchLayoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.switchLayoutBtn = switchLayoutBtn;
//    [self.btnStackView addArrangedSubview:self.switchLayoutBtn];
//    [switchLayoutBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_switchLayout_Selected"] forState:UIControlStateNormal];
//    [switchLayoutBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_switchLayout_Normal"] forState:UIControlStateSelected];
//    [switchLayoutBtn addTarget:self action:@selector(switchLayoutBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    switchLayoutBtn.tag = SCTeacherTopBarTypeSwitchLayout;
//    
//    /// 切换摄像头
//    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.cameraBtn = cameraBtn;
//    [self.btnStackView addArrangedSubview:self.cameraBtn];
//    [cameraBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_camera_Normal"] forState:UIControlStateNormal];
//    [cameraBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_camera_Selected"] forState:UIControlStateSelected];
//    [cameraBtn addTarget:self action:@selector(cameraBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    cameraBtn.tag = SCTeacherTopBarTypeCamera;
//}


#pragma mark -- Setter

//- (void)setLayoutType:(SCTeacherTopBarLayoutType)layoutType
//{
//    _layoutType = layoutType;
//    switch (layoutType)
//    {
//        case SCTeacherTopBarLayoutType_BeforeClass:
//            [self.classBtn setTitle:YSLocalized(@"Button.ClassBegin") forState:UIControlStateNormal];
//            self.allControllBtn.hidden = YES;
//            self.switchLayoutBtn.hidden = YES;
//            self.toolBoxBtn.hidden = YES;
//            self.classBtn.selected = NO;
//            self.pollingBtn.hidden = YES;
//            [self.btnStackView removeArrangedSubview:self.toolBoxBtn];
//            [self.btnStackView removeArrangedSubview:self.allControllBtn];
//            [self.btnStackView removeArrangedSubview:self.switchLayoutBtn];
//            break;
//        case SCTeacherTopBarLayoutType_ClassBegin:
//            self.allControllBtn.hidden = NO;
//            self.switchLayoutBtn.hidden = NO;
//            self.toolBoxBtn.hidden = NO;
//            self.classBtn.selected = YES;
//            self.coursewareBtn.hidden = NO;
//            self.pollingBtn.hidden = NO;
//            [self.classBtn setTitle:YSLocalized(@"Button.ClassIsOver") forState:UIControlStateNormal];
//            [self.btnStackView insertArrangedSubview:self.personListBtn atIndex:1];
//            [self.btnStackView insertArrangedSubview:self.coursewareBtn atIndex:2];
//            [self.btnStackView insertArrangedSubview:self.toolBoxBtn atIndex:3];
//            [self.btnStackView insertArrangedSubview:self.allControllBtn atIndex:4];
//            [self.btnStackView insertArrangedSubview:self.switchLayoutBtn atIndex:4];
//            break;
//        case SCTeacherTopBarLayoutType_FullMedia:
//            self.coursewareBtn.hidden = YES;
////            self.pollingBtn.hidden = YES;
////            [self.btnStackView removeArrangedSubview:self.pollingBtn];
//            [self.btnStackView removeArrangedSubview:self.coursewareBtn];
//
//        default:
//            break;
//    }
//    [self setNeedsLayout];
//}

- (void)setUserEnable:(BOOL)userEnable
{
    
}

- (void)setOpen:(BOOL)open
{
    _open = open;
    ///花名册
    self.personListBtn.hidden = !open;
    ///课件库
    self.coursewareBtn.hidden = !open;
    ///工具箱
    self.toolBoxBtn.hidden = !open;
    ///切换布局
    self.switchLayoutBtn.hidden = !open;
    /// 轮询
    self.pollingBtn.hidden = !open;
    /// 全体禁音
    self.allNoAudioBtn.hidden = !open;
    ///切换摄像头
    self.cameraBtn.hidden = !open;
    /// 消息
    self.chatBtn.hidden = !open;
    /// 退出
    self.exitBtn.hidden = !open;

    CGFloat topGap = BarBtnGap;
    CGFloat onOffBtnWidth = BarBtnOnOff_Width;
    CGFloat selfWidth = self.bounds.size.width;
    if (open)
    {
        self.onOffBtn.frame = CGRectMake(selfWidth - topGap*2 - onOffBtnWidth , topGap, onOffBtnWidth, onOffBtnWidth);
    }
    else
    {
        self.onOffBtn.frame = CGRectMake(topGap , topGap, onOffBtnWidth, onOffBtnWidth);
    }

}
- (void)setMessageOpen:(BOOL)open
{
    self.chatBtn.selected = open;
}
@end

//
//  YSSpreadBottomToolBar.m
//  YSLive
//
//  Created by jiang deng on 2020/6/1.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSSpreadBottomToolBar.h"


@interface YSSpreadBottomToolBar ()

@property (nonatomic, assign) YSUserRoleType roleType;

@property (nonatomic, assign) CGPoint topLeftpoint;

@property (nonatomic, assign) BOOL spreadOut;

@property (nonatomic, strong) BMImageTitleButtonView *spreadBtn;
@property (nonatomic, strong) NSMutableArray <BMImageTitleButtonView *> *btnArray;

/// 花名册
@property (nonatomic, weak) BMImageTitleButtonView *personListBtn;
/// 课件库
@property (nonatomic, weak) BMImageTitleButtonView *coursewareBtn;
/// 工具箱
@property (nonatomic, weak) BMImageTitleButtonView *toolBoxBtn;
/// 切换布局
@property (nonatomic, weak) BMImageTitleButtonView *switchLayoutBtn;
/// 轮询
@property (nonatomic, weak) BMImageTitleButtonView *pollingBtn;
/// 全体静音
@property (nonatomic, weak) BMImageTitleButtonView *allNoAudioBtn;
/// 切换摄像头
@property (nonatomic, weak) BMImageTitleButtonView *cameraBtn;
/// 聊天按钮
@property (nonatomic, weak) BMImageTitleButtonView *chatBtn;
/// 退出房间
@property (nonatomic, weak) BMImageTitleButtonView *exitBtn;
/// 房间类型 0:表示一对一教室  非0:表示一多教室
@property (nonatomic, assign) YSRoomUserType roomtype;
@end

@implementation YSSpreadBottomToolBar

- (instancetype)initWithUserRole:(YSUserRoleType)roleType topLeftpoint:(CGPoint)point roomType:(YSRoomUserType)roomType
{
    self = [super init];
    if (self)
    {
        self.roleType = roleType;
        self.topLeftpoint = point;
        self.roomtype = roomType;
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
    self.spreadBtn.tag = SCBottomToolBarTypeOnOff;

    /// 花名册
    BMImageTitleButtonView *personListBtn = [self creatButtonWithNormalTitle:@"Title.UserList" selectedTitle:@"Title.UserList" pathName:@"personList_bottombar"];
    personListBtn.tag = SCBottomToolBarTypePersonList;
    
    /// 课件库
    BMImageTitleButtonView *coursewareBtn = [self creatButtonWithNormalTitle:@"Title.DocumentList" selectedTitle:@"Title.DocumentList" pathName:@"courseware_bottombar"];
    coursewareBtn.tag = SCBottomToolBarTypeCourseware;
    
    /// 工具箱
    BMImageTitleButtonView *toolBoxBtn = [self creatButtonWithNormalTitle:@"Title.ToolBox" selectedTitle:@"Title.ToolBox" pathName:@"toolBox_bottombar"];
    toolBoxBtn.tag = SCBottomToolBarTypeToolBox;
    
    /// 切换布局
    BMImageTitleButtonView *switchLayoutBtn = [self creatButtonWithNormalTitle:@"Title.AroundLayout" selectedTitle:@"Title.VideoLayout" pathName:@"layout_bottombar"];
    switchLayoutBtn.tag = SCBottomToolBarTypeSwitchLayout;
    
    /// 轮询
    BMImageTitleButtonView *pollingBtn = [self creatButtonWithNormalTitle:@"Title.Polling" selectedTitle:@"Title.Polling" pathName:@"polling_bottombar"];
    pollingBtn.tag = SCBottomToolBarTypePolling;
    
    /// 全体禁音
    BMImageTitleButtonView *allNoAudioBtn = [self creatButtonWithNormalTitle:@"Title.AllNoAudio" selectedTitle:@"Title.AllAudio" pathName:@"allNoAudio_bottombar"];
    allNoAudioBtn.tag = SCBottomToolBarTypeAllNoAudio;
    
    /// 切换摄像头
    BMImageTitleButtonView *cameraBtn = [self creatButtonWithNormalTitle:@"Title.ChangeCamera" selectedTitle:@"Title.ChangeCamera" pathName:@"camera_bottombar"];
    cameraBtn.tag = SCBottomToolBarTypeCamera;
    
    /// 消息
    BMImageTitleButtonView *chatBtn = [self creatButtonWithNormalTitle:@"Title.Message" selectedTitle:@"Title.Message" pathName:@"message_bottombar"];
    chatBtn.tag = SCBottomToolBarTypeChat;
    
    /// 退出
    BMImageTitleButtonView *exitBtn = [self creatButtonWithNormalTitle:@"Title.Exit" selectedTitle:@"Title.Exit" pathName:@"exit_bottombar"];
    exitBtn.tag = SCBottomToolBarTypeExit;
    
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
        if (self.roomtype == YSRoomUserType_More)
        {
            self.allNoAudioBtn = allNoAudioBtn;
            [self.btnArray addObject:self.allNoAudioBtn];
        }

        self.cameraBtn = cameraBtn;
        [self.btnArray addObject:self.cameraBtn];
        
        self.chatBtn = chatBtn;
        [self.btnArray addObject:self.chatBtn];
    }
    else if (self.roleType == YSUserType_Student)
    {
        self.toolBoxBtn = toolBoxBtn;
        [self.btnArray addObject:self.toolBoxBtn];
        
        self.cameraBtn = cameraBtn;
        [self.btnArray addObject:self.cameraBtn];
        
        self.chatBtn = chatBtn;
        [self.btnArray addObject:self.chatBtn];
    }
    else if (self.roleType == YSUserType_Patrol)
    {
        self.personListBtn = personListBtn;
        [self.btnArray addObject:self.personListBtn];

        self.coursewareBtn = coursewareBtn;
        [self.btnArray addObject:self.coursewareBtn];

        self.chatBtn = chatBtn;
        [self.btnArray addObject:self.chatBtn];
    }

    self.exitBtn = exitBtn;
    [self.btnArray addObject:self.exitBtn];
    
    CGFloat top = self.topLeftpoint.y;
    NSUInteger count = self.btnArray.count;
    CGFloat height = YSSpreadBottomToolBar_BtnWidth + YSSpreadBottomToolBar_BtnGap*2.0f;
    CGFloat width = height*0.5 + (YSSpreadBottomToolBar_BtnWidth+YSSpreadBottomToolBar_BtnGap) * count + YSSpreadBottomToolBar_SpreadBtnGap + YSSpreadBottomToolBar_BtnWidth;
    CGFloat left = self.topLeftpoint.x - (YSSpreadBottomToolBar_BtnWidth+YSSpreadBottomToolBar_BtnGap) * count - height*0.5 - YSSpreadBottomToolBar_SpreadBtnGap + YSSpreadBottomToolBar_BtnGap;

    self.frame = CGRectMake(left, top, width, height);
    
    CGFloat btnLeft = height*0.5;
    for (NSUInteger index=0; index<self.btnArray.count; index++)
    {
        BMImageTitleButtonView *btn = self.btnArray[index];
        [self addSubview:btn];
        CGRect frame = CGRectMake(btnLeft+(YSSpreadBottomToolBar_BtnWidth+YSSpreadBottomToolBar_BtnGap)*index, YSSpreadBottomToolBar_BtnGap, YSSpreadBottomToolBar_BtnWidth, YSSpreadBottomToolBar_BtnWidth);
        btn.frame = frame;
    }
    
    self.spreadBtn.bm_left = width-(YSSpreadBottomToolBar_BtnWidth+YSSpreadBottomToolBar_BtnGap);
    self.spreadBtn.bm_top = YSSpreadBottomToolBar_BtnGap;

    //[self bm_addShadow:0.0f Radius:self.bm_height*0.5f BorderColor:nil ShadowColor:[UIColor grayColor]];
    [self bm_roundedRect:height*0.5f];
    
    self.backgroundColor = [YSSkinDefineColor(@"PopViewBgColor") changeAlpha:YSPopViewDefaultAlpha];
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
    
    toolBtn.frame = CGRectMake(0, 0, YSSpreadBottomToolBar_BtnWidth, YSSpreadBottomToolBar_BtnWidth);
    //toolBtn.backgroundColor = [UIColor redColor];
    
    [toolBtn addTarget:self action:@selector(bottomToolBarClicked:) forControlEvents:UIControlEventTouchUpInside];

    return toolBtn;
}

- (void)bottomToolBarClicked:(BMImageTitleButtonView *)btn
{
    if (btn != self.pollingBtn && btn != self.exitBtn)
    {
        btn.selected = !btn.selected;
    }
    
    if (btn == self.spreadBtn)
    {
        self.spreadOut = !self.spreadOut;
        
        if (self.spreadOut)
        {
            CGFloat top = self.topLeftpoint.y;
            NSUInteger count = self.btnArray.count;
            CGFloat height = YSSpreadBottomToolBar_BtnWidth + YSSpreadBottomToolBar_BtnGap*2.0f;
            CGFloat width = height*0.5 + (YSSpreadBottomToolBar_BtnWidth+YSSpreadBottomToolBar_BtnGap) * count + YSSpreadBottomToolBar_SpreadBtnGap + YSSpreadBottomToolBar_BtnWidth;
            CGFloat left = self.topLeftpoint.x - (YSSpreadBottomToolBar_BtnWidth+YSSpreadBottomToolBar_BtnGap) * count - height*0.5 - YSSpreadBottomToolBar_SpreadBtnGap + YSSpreadBottomToolBar_BtnGap;

            self.spreadBtn.alpha = 0.0f;

            [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.frame = CGRectMake(left, top, width, height);

                self.spreadBtn.bm_top = YSSpreadBottomToolBar_BtnGap;
                self.spreadBtn.bm_left = width-(YSSpreadBottomToolBar_BtnWidth+YSSpreadBottomToolBar_BtnGap);
                for (UIButton *btn in self.btnArray)
                {
                    btn.alpha = 1.0f;
                }
            } completion:^(BOOL finished) {
                self.spreadBtn.alpha = 1.0f;
            }];

//            [UIView animateWithDuration:0.1f animations:^{
//
//                self.frame = CGRectMake(left, top, width, height);
//
//                self.spreadBtn.bm_top = BarBtnGap;
//                self.spreadBtn.bm_left = self.bm_width-(BarBtnWidth+BarBtnGap);
//            } completion:^(BOOL finished) {
//                CGFloat index = 1.0f;
//                NSTimeInterval ts = 0.3f;
//                if ([self.btnArray bm_isNotEmpty])
//                {
//                    ts = 0.5f / self.btnArray.count;
//                    for (UIButton *btn in self.btnArray)
//                    {
//                        [UIView animateWithDuration:(index * ts) delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//                            btn.alpha = 1.0f;
//                        } completion:^(BOOL finished) {
//                        }];
////                        [UIView animateWithDuration:(index * ts) animations:^{
////                            btn.alpha = 1.0f;
////                        } completion:^(BOOL finished) {
////
////                        }];
//                        index = index + 1.0f;
//                    }
//                }
//            }];
        }
        else
        {
            CGFloat top = self.topLeftpoint.y;
            CGFloat left = self.topLeftpoint.x-YSSpreadBottomToolBar_BtnGap;
            CGFloat height = YSSpreadBottomToolBar_BtnWidth + YSSpreadBottomToolBar_BtnGap*2.0f;
            CGFloat width = height;
            self.spreadBtn.alpha = 0.0f;

            [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.frame = CGRectMake(left, top, width, height);
                self.spreadBtn.bm_top = YSSpreadBottomToolBar_BtnGap;
                self.spreadBtn.bm_left = YSSpreadBottomToolBar_BtnGap;
                
                for (UIButton *btn in self.btnArray)
                {
                    btn.alpha = 0.0f;
                }
            } completion:^(BOOL finished) {
                self.spreadBtn.alpha = 1.0f;
            }];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(bottomToolBarSpreadOut:)])
        {
            [self.delegate bottomToolBarSpreadOut:self.spreadOut];
        }
        
        return;
    }
    else
    {
        [btn bm_shakeDuration:0.3f];
    }
    
    if (btn == self.chatBtn)
    {
        if (btn.selected)
        {
            self.isNewMessage = NO;
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomToolBarClickAtIndex:isSelected:)])
    {
        [self.delegate bottomToolBarClickAtIndex:btn.tag isSelected:btn.selected];
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
            self.chatBtn.badgeRadius = 3.0f;
            if ([UIDevice bm_isiPad])
            {
                self.chatBtn.badgeCenterOffset = CGPointMake(-16, 10);
            }
            else
            {
                self.chatBtn.badgeCenterOffset = CGPointMake(-14, 8);
            }
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
    self.toolBoxBtn.enabled = userEnable ? self.isToolBoxEnable : NO;
    ///切换布局
    self.switchLayoutBtn.enabled = userEnable;
    /// 轮询
    self.pollingBtn.enabled = userEnable;
    /// 全体禁音
    self.allNoAudioBtn.enabled = userEnable;
    ///切换摄像头
    self.cameraBtn.enabled = userEnable ? self.isCameraEnable : NO;
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
//    self.toolBoxBtn.enabled = isBeginClass;
}

- (void)setIsToolBoxEnable:(BOOL)isToolBoxEnable
{
    _isToolBoxEnable = isToolBoxEnable;
    if (self.isBeginClass)
    {
        self.toolBoxBtn.enabled = isToolBoxEnable;
    }
    else
    {
        self.toolBoxBtn.enabled = NO;
    }
}

- (void)setIsCameraEnable:(BOOL)isCameraEnable
{
    _isCameraEnable = isCameraEnable;
    self.cameraBtn.enabled = isCameraEnable;
}

- (BOOL)nameListIsShow
{
    BOOL nameLiseShow = self.personListBtn.selected;
    return nameLiseShow;
}

- (BOOL)coursewareListIsShow
{
    BOOL coursewareLiseShow = self.coursewareBtn.selected;
    return coursewareLiseShow;
}

/// 隐藏工具箱
- (void)hideToolBoxView
{
    self.toolBoxBtn.selected = NO;
}

///  收起工具栏
- (void)closeToolBar
{
    self.spreadOut = NO;
    self.spreadBtn.selected = YES;
    
    CGFloat top = self.topLeftpoint.y;
    CGFloat left = self.topLeftpoint.x-YSSpreadBottomToolBar_BtnGap;
    CGFloat height = YSSpreadBottomToolBar_BtnWidth + YSSpreadBottomToolBar_BtnGap*2.0f;
    CGFloat width = height;
    self.spreadBtn.alpha = 0.0f;
    
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.frame = CGRectMake(left, top, width, height);
        self.spreadBtn.bm_top = YSSpreadBottomToolBar_BtnGap;
        self.spreadBtn.bm_left = YSSpreadBottomToolBar_BtnGap;
        
        for (UIButton *btn in self.btnArray)
        {
            btn.alpha = 0.0f;
        }
    } completion:^(BOOL finished) {
        self.spreadBtn.alpha = 1.0f;
    }];
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(bottomToolBarSpreadOut:)])
    {
        [self.delegate bottomToolBarSpreadOut:self.spreadOut];
    }
}

@end

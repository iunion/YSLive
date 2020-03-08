//
//  SCTeacherTopBar.m
//  YSLive
//
//  Created by fzxm on 2019/12/24.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCTeacherTopBar.h"

#define BeforeClassWidth 164
#define ClassBeginWidth  338
#define FullMediaWidth   280
#define Top_iPadHeight  48
#define Top_iPhoneHeight  38
@interface SCTeacherTopBar ()

/// 退出房间
@property (nonatomic, strong) UIButton *exitBtn;
/// 房间号
@property (nonatomic, strong) UILabel *roomIDL;
/// 信号
@property (nonatomic, strong) UILabel *signalStateL;
/// 时间
@property (nonatomic, strong) UILabel *timeL;

/// 按钮容器
@property (nonatomic, strong) UIStackView *btnStackView;
/// 切换摄像头
@property (nonatomic, strong) UIButton *cameraBtn;

/// 全体控制
@property (nonatomic, strong) UIButton *allControllBtn;
/// 工具箱
@property (nonatomic, strong) UIButton *toolBoxBtn;
/// 课件库
@property (nonatomic, strong) UIButton *coursewareBtn;
/// 花名册
@property (nonatomic, strong) UIButton *personListBtn;

/// 上下课
@property (nonatomic, strong) UIButton *classBtn;
/// 切换布局
@property (nonatomic, strong) UIButton *switchLayoutBtn;

@end

@implementation SCTeacherTopBar
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
    /// 退出
    UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.exitBtn = exitBtn;
    [self addSubview:self.exitBtn];
    [exitBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_exitBtn_Normal"] forState:UIControlStateNormal];
    [exitBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_exitBtn_Highlighted"] forState:UIControlStateHighlighted];
    [exitBtn addTarget:self action:@selector(exitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    /// 设置房间号信号时间
    [self setupRoomMsg];
    
    /// 设置导航按钮
    [self setBtnView];
    
    self.layoutType = SCTeacherTopBarLayoutType_BeforeClass;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat classBtnWidth = 150;
    CGFloat exitBtnWidth = 40;
    if (![UIDevice bm_isiPad])
    {
        classBtnWidth = 100;
        exitBtnWidth = 30;
    }
    self.exitBtn.frame = CGRectMake(10, 0, exitBtnWidth, exitBtnWidth);
    self.exitBtn.bm_centerY = self.bm_centerY;
    
    self.classBtn.frame = CGRectMake(0, 0, classBtnWidth, 40);
    self.classBtn.bm_centerY = self.bm_centerY;
    self.classBtn.bm_right = self.bm_right - 10;
    [self.classBtn bm_addShadow:3 Radius:20 BorderColor:[UIColor bm_colorWithHex:0x97B7EB] ShadowColor:[UIColor grayColor] Offset:CGSizeMake(0, 5) Opacity:0.5];

    CGFloat stackViewWidth = Top_iPadHeight * 3;
    
    switch (self.layoutType)
    {
        case SCTeacherTopBarLayoutType_BeforeClass:
            stackViewWidth = Top_iPadHeight * 3;
            break;
        case SCTeacherTopBarLayoutType_ClassBegin:
            stackViewWidth = Top_iPadHeight * 6;
            if (![UIDevice bm_isiPad])
            {
                stackViewWidth = Top_iPhoneHeight * 6;
            }
            break;
        case SCTeacherTopBarLayoutType_FullMedia:
            stackViewWidth = Top_iPadHeight * 5;
            if (![UIDevice bm_isiPad])
            {
                stackViewWidth = Top_iPhoneHeight * 5;
            }
        default:
            break;
    }
    
    CGFloat h = Top_iPadHeight;
    if (![UIDevice bm_isiPad])
    {
        h = Top_iPhoneHeight;
    }
    
    
    self.btnStackView.frame = CGRectMake(0, 0, stackViewWidth, h);
    self.btnStackView.bm_centerY = self.bm_centerY;
    self.btnStackView.bm_right = self.classBtn.bm_left - 10;
    
//    self.cameraBtn.frame = CGRectMake(0, 0, w, h);
//    self.switchLayoutBtn.frame = CGRectMake(0, 0, w, h);
//    self.allControllBtn.frame = CGRectMake(0, 0, w, h);
//    self.toolBoxBtn.frame = CGRectMake(0, 0, w, h);
//    self.coursewareBtn.frame = CGRectMake(0, 0, w, h);
//    self.personListBtn.frame = CGRectMake(0, 0, w, h);
    
    if ([UIDevice bm_isiPad])
    {

        self.roomIDL.frame = CGRectMake(0, 0, 160, 26);
        self.roomIDL.bm_centerY = self.bm_centerY;
        self.roomIDL.bm_left = self.exitBtn.bm_right + 10;
        
        self.signalStateL.frame = CGRectMake(0, 0, 170, 26);
        self.signalStateL.bm_centerY = self.bm_centerY;
        self.signalStateL.bm_left = self.roomIDL.bm_right + 10;
        
        self.timeL.frame = CGRectMake(0, 0, 90, 26);
        self.timeL.bm_centerY = self.bm_centerY;
        self.timeL.bm_left = self.signalStateL.bm_right + 10;
    }
    else
    {

        self.roomIDL.frame = CGRectMake(0, 0, 130, 26);
        self.roomIDL.bm_centerY = self.bm_centerY;
        self.roomIDL.bm_left = self.exitBtn.bm_right + 5;

        self.timeL.frame = CGRectMake(0, 0, 60, 26);
        self.timeL.bm_centerY = self.bm_centerY;
        self.timeL.bm_right = self.btnStackView.bm_left - 5;
        
        self.signalStateL.frame = CGRectMake(0, 0, 0, 26);
        self.signalStateL.bm_centerY = self.bm_centerY;
        self.signalStateL.bm_left = self.roomIDL.bm_right + 5;
        [self.signalStateL bm_setLeft:self.roomIDL.bm_right + 5 right:self.timeL.bm_left - 5];
    }

//    bm_setLeft:(CGFloat)left right:(CGFloat)right;
    
}

#pragma mark - 设置房间信息

- (void)setupRoomMsg
{
    CGFloat fontSize = 14;
    if (![UIDevice bm_isiPad])
    {
        fontSize = 12;
    }

    /// 房间号
    UILabel *roomIDL = [[UILabel alloc] init];
    roomIDL.textColor = [UIColor bm_colorWithHex:0xFFFFFF];
    roomIDL.textAlignment = NSTextAlignmentLeft;
    roomIDL.font = [UIFont systemFontOfSize:fontSize];
    self.roomIDL = roomIDL;
    [self addSubview:roomIDL];
    roomIDL.adjustsFontSizeToFitWidth = YES;
    
    /// 信号
    UILabel *signalStateL = [[UILabel alloc] init];
    signalStateL.textColor = [UIColor bm_colorWithHex:0xFFFFFF];
    signalStateL.textAlignment = NSTextAlignmentLeft;
    signalStateL.font = [UIFont systemFontOfSize:fontSize];
    self.signalStateL = signalStateL;
    [self addSubview:signalStateL];
    signalStateL.adjustsFontSizeToFitWidth = YES;
    
    /// time
    UILabel *timeL = [[UILabel alloc] init];
    timeL.textColor = [UIColor bm_colorWithHex:0xFFFFFF];
    timeL.textAlignment = NSTextAlignmentCenter;
    timeL.font = [UIFont fontWithName:@"Helvetica" size:fontSize];
    self.timeL = timeL;
    [self addSubview:timeL];
    timeL.adjustsFontSizeToFitWidth = YES;
    
    
}

#pragma mark - 设置导航按钮

- (void)setBtnView
{
    UIButton *classBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.classBtn = classBtn;
    [self addSubview:classBtn];
    [classBtn setBackgroundColor:[UIColor bm_colorWithHex:0xCA5B75]];
    [classBtn setTitle:YSLocalized(@"Button.ClassBegin") forState:UIControlStateNormal];
    [classBtn setTitle:YSLocalized(@"Button.ClassIsOver") forState:UIControlStateSelected];
    [classBtn setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
    [classBtn addTarget:self action:@selector(classBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    if (![UIDevice bm_isiPad])
    {
        classBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    
    
    UIStackView *btnStackView = [[UIStackView alloc] init];
    [self addSubview:btnStackView];
    self.btnStackView = btnStackView;
    btnStackView.axis = UILayoutConstraintAxisHorizontal;
    btnStackView.alignment = UIStackViewAlignmentCenter;
    btnStackView.distribution = UIStackViewDistributionFillEqually;
    btnStackView.spacing = 0;
    
    ///花名册
    UIButton *personListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.personListBtn = personListBtn;
    [self.btnStackView addArrangedSubview:self.personListBtn];
    [personListBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_personListBtn_Normal"] forState:UIControlStateNormal];
    [personListBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_personListBtn_Selected"] forState:UIControlStateSelected];
    [personListBtn addTarget:self action:@selector(personListBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    personListBtn.tag = SCTeacherTopBarTypePersonList;
    
    ///课件库
    UIButton *coursewareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.coursewareBtn = coursewareBtn;
    [self.btnStackView addArrangedSubview:self.coursewareBtn];
    [coursewareBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_coursewareBtn_Normal"] forState:UIControlStateNormal];
    [coursewareBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_coursewareBtn_Selected"] forState:UIControlStateSelected];
    [coursewareBtn addTarget:self action:@selector(coursewareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    coursewareBtn.tag = SCTeacherTopBarTypeCourseware;
    
    ///工具箱
    UIButton *toolBoxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.toolBoxBtn = toolBoxBtn;
    [self.btnStackView addArrangedSubview:self.toolBoxBtn];
    [toolBoxBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_toolBoxBtn_Normal"] forState:UIControlStateNormal];
    [toolBoxBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_toolBoxBtn_Selected"] forState:UIControlStateSelected];
    [toolBoxBtn addTarget:self action:@selector(toolBoxBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    toolBoxBtn.tag = SCTeacherTopBarTypeToolBox;
   
    ///全局控制
    UIButton *allControllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.allControllBtn = allControllBtn;
    [self.btnStackView addArrangedSubview:self.allControllBtn];
    [allControllBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_allControllBtn_Normal"] forState:UIControlStateNormal];
    [allControllBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_allControllBtn_Selected"] forState:UIControlStateSelected];
    [allControllBtn addTarget:self action:@selector(allControllBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    allControllBtn.tag = SCTeacherTopBarTypeAllControll;
    
    /// 切换布局
    UIButton *switchLayoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.switchLayoutBtn = switchLayoutBtn;
    [self.btnStackView addArrangedSubview:self.switchLayoutBtn];
    [switchLayoutBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_switchLayout_Selected"] forState:UIControlStateNormal];
    [switchLayoutBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_switchLayout_Normal"] forState:UIControlStateSelected];
    [switchLayoutBtn addTarget:self action:@selector(switchLayoutBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    switchLayoutBtn.tag = SCTeacherTopBarTypeSwitchLayout;
    
    /// 切换摄像头
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cameraBtn = cameraBtn;
    [self.btnStackView addArrangedSubview:self.cameraBtn];
    [cameraBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_camera_Normal"] forState:UIControlStateNormal];
    [cameraBtn setBackgroundImage:[UIImage imageNamed:@"scteacher_topbar_camera_Selected"] forState:UIControlStateSelected];
    [cameraBtn addTarget:self action:@selector(cameraBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    cameraBtn.tag = SCTeacherTopBarTypeCamera;
}


#pragma mark -- Setter

- (void)setLayoutType:(SCTeacherTopBarLayoutType)layoutType
{
    _layoutType = layoutType;
    switch (layoutType)
    {
        case SCTeacherTopBarLayoutType_BeforeClass:
            [self.classBtn setTitle:YSLocalized(@"Button.ClassBegin") forState:UIControlStateNormal];
            self.allControllBtn.hidden = YES;
            self.switchLayoutBtn.hidden = YES;
            self.toolBoxBtn.hidden = YES;
            self.classBtn.selected = NO;
            [self.btnStackView removeArrangedSubview:self.toolBoxBtn];
            [self.btnStackView removeArrangedSubview:self.allControllBtn];
            [self.btnStackView removeArrangedSubview:self.switchLayoutBtn];
            break;
        case SCTeacherTopBarLayoutType_ClassBegin:
            self.allControllBtn.hidden = NO;
            self.switchLayoutBtn.hidden = NO;
            self.toolBoxBtn.hidden = NO;
            self.classBtn.selected = YES;
            self.coursewareBtn.hidden = NO;
            [self.classBtn setTitle:YSLocalized(@"Button.ClassIsOver") forState:UIControlStateNormal];
            [self.btnStackView insertArrangedSubview:self.coursewareBtn atIndex:1];
            [self.btnStackView insertArrangedSubview:self.toolBoxBtn atIndex:2];
            [self.btnStackView insertArrangedSubview:self.allControllBtn atIndex:3];
            [self.btnStackView insertArrangedSubview:self.switchLayoutBtn atIndex:4];
            break;
        case SCTeacherTopBarLayoutType_FullMedia:
            self.coursewareBtn.hidden = YES;
            [self.btnStackView removeArrangedSubview:self.coursewareBtn];

        default:
            break;
    }
    [self setNeedsLayout];
}

- (void)setTopToolModel:(SCTopToolBarModel *)topToolModel
{
    _topToolModel = topToolModel;
    self.roomIDL.text = [NSString stringWithFormat:@"  %@：%@",YSLocalized(@"Label.roomid"),topToolModel.roomID];
    NSString *netText = @"";
    switch (topToolModel.netQuality)
    {
        case YSNetQuality_Excellent:
        case YSNetQuality_Good:
        {
            netText = YSLocalized(@"netstate.excellent");
            break;
        }
        case YSNetQuality_Accepted:
        case YSNetQuality_Bad:
        {
            netText = YSLocalized(@"netstate.medium");
            break;
        }
        case YSNetQuality_VeryBad:
        case YSNetQuality_Down:
        {
            netText = YSLocalized(@"netstate.bad");
            break;
        }
    }

//    self.signalStateL.text = [NSString stringWithFormat:@"%@: %@",YSLocalized(@"State.NetworkState"), netText];

    self.timeL.text = topToolModel.lessonTime;
}


#pragma mark --SEL
/// 退出
- (void)exitBtnClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(exitProxyWithBtn:)])
    {
        [self.delegate exitProxyWithBtn:btn];
    }
}

/// 花名册
- (void)personListBtnClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(sc_TeacherTopBarProxyWithBtn:)])
    {
        [self.delegate sc_TeacherTopBarProxyWithBtn:btn];
    }
}

/// 课件表
- (void)coursewareBtnClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(sc_TeacherTopBarProxyWithBtn:)])
    {
        [self.delegate sc_TeacherTopBarProxyWithBtn:btn];
    }
    
}

/// 工具箱
- (void)toolBoxBtnClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(sc_TeacherTopBarProxyWithBtn:)])
    {
        [self.delegate sc_TeacherTopBarProxyWithBtn:btn];
    }

}

/// 全局控制
- (void)allControllBtnClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(sc_TeacherTopBarProxyWithBtn:)])
    {
        [self.delegate sc_TeacherTopBarProxyWithBtn:btn];
    }
}

/// 布局切换
- (void)switchLayoutBtnClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(sc_TeacherTopBarProxyWithBtn:)])
    {
        [self.delegate sc_TeacherTopBarProxyWithBtn:btn];
    }
}

/// 摄像头
- (void)cameraBtnClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(sc_TeacherTopBarProxyWithBtn:)])
    {
        [self.delegate sc_TeacherTopBarProxyWithBtn:btn];
    }
}

/// 上下课
- (void)classBtnClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(classBeginEndProxyWithBtn:)])
    {
        [self.delegate classBeginEndProxyWithBtn:btn];
    }
}

@end

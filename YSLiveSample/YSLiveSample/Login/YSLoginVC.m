//
//  YSLoginViewController.m
//  YSEdu
//
//  Created by fzxm on 2019/10/9.
//  Copyright © 2019 ysxl. All rights reserved.
//

#import "YSLoginVC.h"
#import "AppDelegate.h"

#import "YSInputView.h"
#import "Masonry.h"
#import "YSLoginMacros.h"

#import <YSSDK/YSSDKManager.h>
#import <MBProgressHUD/MBProgressHUD.h>

#define USE_COOKIES     0

/// 登录时 输入框记录的房间号
static NSString *const YSLOGIN_USERDEFAULT_ROOMID = @"ysLOGIN_USERDEFAULT_ROOMID";
/// 登录时 输入框记录的昵称
static NSString *const YSLOGIN_USERDEFAULT_NICKNAME = @"ysLOGIN_USERDEFAULT_NICKNAME";


@interface YSLoginVC ()
<
    UITextFieldDelegate,
    YSInputViewDelegate,
    YSSDKDelegate
>
{
    YSSDKUserRoleType userRole;
}

@property (nonatomic, weak) YSSDKManager *ysSDKManager;

/// 背景滚动
@property (nonatomic, strong) UIScrollView *backScrollView;
/// 背景
@property (nonatomic, strong) UIImageView *backImageView;
/// 顶部LOGO
@property (nonatomic, strong) UIImageView *logoImageView;
/// 房间号输入框
@property (nonatomic, strong) YSInputView *roomTextField;
/// 昵称输入框
@property (nonatomic, strong) YSInputView *nickNameTextField;
/// 底部版本文字
@property (nonatomic, strong) UILabel *bottomVersionL;
/// 进入教室按钮
@property (nonatomic, strong) UIButton *joinRoomBtn;

@property (assign, nonatomic) NSInteger role;
/// 默认服务
@property (strong, nonatomic) NSString *defaultServer;

// 网络等待
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end


@implementation YSLoginVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    GetAppDelegate.allowRotation = NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)even
{
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
//    {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.extendedLayoutIncludesOpaqueBars = NO;
//        self.modalPresentationCapturesStatusBarAppearance = NO;
//    }
//
//    // 隐藏系统的返回按钮
//    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
//    temporaryBarButtonItem.title = @"";
//    //    temporaryBarButtonItem.tintColor = [UIColor whiteColor];
//    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;

    [self setupUI];

    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHUD.animationType = MBProgressHUDAnimationFade;
    [self.view addSubview:self.progressHUD];

    NSString *roomID = [YSLoginVC getLoginRoomID];
    if (roomID)
    {
        self.roomTextField.inputTextField.text = roomID;
    }
    NSString *nickName = [YSLoginVC getLoginNickName];
    if (nickName)
    {
        self.nickNameTextField.inputTextField.text = nickName;
    }
    if (roomID && nickName)
    {
        self.joinRoomBtn.enabled = YES;
    }
    else
    {
        self.joinRoomBtn.enabled = NO;
    }

    NSLog(@"SDK version: %@", [YSSDKManager SDKDetailVersion]);
    self.ysSDKManager = [YSSDKManager sharedInstance];
    [self.ysSDKManager registerManagerDelegate:self];
    
#if USE_COOKIES
    // 如果使用cookie请关闭HttpDNS
    [self.ysSDKManager registerUseHttpDNSForWhiteBoard:NO];
    
    NSDictionary *cookieDic = @{NSHTTPCookieDomain:@".kidsloop.4mvlbg6o.badanamu.com.cn", NSHTTPCookiePath:@"/", NSHTTPCookieName:@"username", NSHTTPCookieValue:@"world", NSHTTPCookieExpires:[NSDate dateWithTimeIntervalSinceNow:24*60*60]};
    // 设置cookie，只在初始化使用，后期设置无效
    [self.ysSDKManager setConnectH5CoursewareUrlCookies:@[cookieDic]];
#endif
    
    // 设置H5课件扩展参数
    [self.ysSDKManager changeConnectH5CoursewareUrlParameters:@{@"app_token" : @"eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJiYWRhbmFtdSBhcHAiLCJleHAiOjE1OTE0MjcyOTMsImlhdCI6MTU4ODgzNTI2MywiaXNzIjoiS2lkc0xvb3BDaGluYVVzZXIiLCJzdWIiOiJhdXRob3JpemF0aW9uIiwiVG9rZW5UeXBlIjowLCJEYXRhIjoiSE9HdE1Ub3dsVVhyeGRQdlFmYXNKRHIvK3k0OWhQU2Q1ajVrblFEMEViV3g0d202L3dsYkdWS0NicjZoeU90WUpPQlRjVmJvK2NUbXNySVhSV0s1amQ4bVRkOXNnN253RlAzZGFQajZjV3FjTzdrMEMxNDNYQlV6YmJ1bEFHVHVJWFpKYy9Fa2p2am43c0Z4OGNGLyJ9.HCRjxXuE9wU_ingpplY88Zl9O-TyvxgZ1H5yoOxEtNFPfZ1-tllQ-RZfMH5mX5zEWx1WI6TbKr_jPVN4j73aJYUC90hPmXG4VZLVQgt9ffVEnheKc8_ZATSF0LD0P8pERUjnqXp4cMPcEk37VSAZcOzdySdgR8_ac1FPfZV9eL8"}];
    
    if (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad)
    {
        [self.ysSDKManager setWhiteBoardBackGroundColor:nil maskImage:[UIImage imageNamed:@"whiteboardmask_ipad"]];
    }
    else
    {
        [self.ysSDKManager setWhiteBoardBackGroundColor:nil maskImage:[UIImage imageNamed:@"whiteboardmask_iphone"]];
    }
}


#pragma mark 横竖屏

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    // 只支持竖屏
    return UIInterfaceOrientationPortrait;
}

#pragma mark - UI

- (void)setupUI
{
    login_WeakSelf
    [self.view addSubview:self.backScrollView];
    self.backScrollView.frame = CGRectMake(0, 0,login_UI_SCREEN_WIDTH, login_UI_SCREEN_HEIGHT);
    self.backScrollView.contentSize = CGSizeMake(login_UI_SCREEN_WIDTH, login_UI_SCREEN_HEIGHT);
    
    if (@available(iOS 11.0, *))
    {
        self.backScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.backImageView.frame = CGRectMake(0, 0,login_UI_SCREEN_WIDTH, login_UI_SCREEN_HEIGHT);
    self.backImageView.backgroundColor = [UIColor redColor];
    [self.backScrollView addSubview:self.backImageView];

    UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAction:)];
    [self.backImageView addGestureRecognizer:click];

    [self.backImageView addSubview:self.logoImageView];
    self.logoImageView.frame = CGRectMake(0, 130, 153, 197);
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(login_kScale_H(130));
        make.height.mas_equalTo(login_kScale_W(153));
        make.width.mas_equalTo(login_kScale_W(197));
    }];

    [self.backImageView addSubview:self.roomTextField];
    [self.roomTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(login_kScale_W(28));
        make.right.mas_equalTo(-login_kScale_W(28));
        make.top.mas_equalTo(weakSelf.logoImageView.mas_bottom).mas_offset(login_kScale_H(60));
        make.height.mas_equalTo(40);
    }];
    self.roomTextField.layer.cornerRadius = 20;
    self.roomTextField.layer.borderWidth = 1;
    self.roomTextField.layer.borderColor =  login_UIColorFromRGB(0x82ABEC).CGColor;// [UIColor bm_colorWithHex:].CGColor;
    
    
    [self.backImageView addSubview:self.nickNameTextField];
    [self.nickNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(login_kScale_W(28));
        make.right.mas_equalTo(-login_kScale_W(28));
        make.top.mas_equalTo(weakSelf.roomTextField.mas_bottom).mas_offset(login_kScale_H(30));
        make.height.mas_equalTo(40);
    }];
    self.nickNameTextField.layer.cornerRadius = 20;
    self.nickNameTextField.layer.borderWidth = 1;
    self.nickNameTextField.layer.borderColor = login_UIColorFromRGB(0x82ABEC).CGColor;//[UIColor bm_colorWithHex:0x82ABEC].CGColor;
    
    [self.backImageView addSubview:self.bottomVersionL];
    [self.bottomVersionL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(0);
        make.height.mas_equalTo(login_kScale_H(17));
        make.bottom.mas_equalTo(-login_kScale_H(17));
    }];
    NSString *bundleVersionCode = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
#ifdef DEBUG
    NSString *string = [NSString stringWithFormat:@"%@: %@", @"buildNO", bundleVersionCode];
#else
    //do sth.
    NSString *string = [NSString stringWithFormat:@"%@: %@", @"releaseNO" , bundleVersionCode];
#endif
    
    self.bottomVersionL.text = string;
    
    [self.backImageView addSubview:self.joinRoomBtn];
    [self.joinRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.nickNameTextField.mas_bottom).mas_offset(login_kScale_H(43));
        make.height.mas_equalTo(login_kScale_H(48));
        make.width.mas_equalTo(login_kScale_W(238));
        make.centerX.mas_equalTo(0);
    }];
    
    self.joinRoomBtn.layer.cornerRadius = 25;
    self.joinRoomBtn.layer.masksToBounds = YES;
    [self.joinRoomBtn addTarget:self action:@selector(joinRoomBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark --键盘弹出收起管理

- (void)keyboardWillShow:(NSNotification *)note
{
    CGRect frame = self.nickNameTextField.frame;
    //获取键盘高度
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat offSet = frame.origin.y + 60 - (self.view.frame.size.height - kbSize.height);

    if (offSet > 0.01)
    {
        login_WeakSelf
        [UIView animateWithDuration:0.1 animations:^{
            weakSelf.backScrollView.contentOffset = CGPointMake(0, offSet);
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)note
{
    [UIView animateWithDuration:0.1 animations:^{
        self.backScrollView.contentOffset = CGPointMake(0, 0);
    }];
}


#pragma mark -
#pragma mark NSUserDefaults

+ (void)setLoginRoomID:(NSString *)roomID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:roomID forKey:YSLOGIN_USERDEFAULT_ROOMID];
    [defaults synchronize];
}

+ (NSString *)getLoginRoomID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *loginRoomID = [defaults objectForKey:YSLOGIN_USERDEFAULT_ROOMID];
    return loginRoomID;
}

+ (void)setLoginNickName:(NSString *)nickName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nickName forKey:YSLOGIN_USERDEFAULT_NICKNAME];
    [defaults synchronize];
}

+ (NSString *)getLoginNickName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *nickName = [defaults objectForKey:YSLOGIN_USERDEFAULT_NICKNAME];
    return nickName;
}


#pragma mark -
#pragma mark Lazy

- (UIScrollView *)backScrollView
{
    if (!_backScrollView)
    {
        _backScrollView = [[UIScrollView alloc] init];
        _backScrollView.bounces = NO;
        _backScrollView.alwaysBounceVertical = YES;
        _backScrollView.showsVerticalScrollIndicator = NO;
        _backScrollView.showsHorizontalScrollIndicator = NO;
        
    }
    return _backScrollView;
}

- (UIImageView *)backImageView
{
    if (!_backImageView)
    {
        _backImageView = [[UIImageView alloc] init];
        _backImageView.backgroundColor = [UIColor whiteColor];
        [_backImageView setImage:[UIImage imageNamed:@"ysall_login_background"]];
        _backImageView.userInteractionEnabled = YES;
    }
    return _backImageView;
}

- (YSInputView *)roomTextField
{
    if (!_roomTextField)
    {
        _roomTextField = [[YSInputView alloc] initWithFrame:CGRectZero withPlaceholder:@"请输入房间号" withImageName:@"login_room"];
        _roomTextField.inputTextField.delegate = self;
        _roomTextField.inputTextField.tag = 101;
        _roomTextField.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
        _roomTextField.delegate = self;
    }
    return _roomTextField;
}

- (YSInputView *)nickNameTextField
{
    if (!_nickNameTextField)
    {
        _nickNameTextField = [[YSInputView alloc] initWithFrame:CGRectZero withPlaceholder:@"请输入您的昵称" withImageName:@"login_name"];
        _nickNameTextField.inputTextField.delegate = self;
        _nickNameTextField.inputTextField.tag = 102;
        _nickNameTextField.delegate = self;
    }
    return _nickNameTextField;
}

- (UIImageView *)logoImageView
{
    if (!_logoImageView)
    {
        _logoImageView = [[UIImageView alloc] init];
        [_logoImageView setImage:[UIImage imageNamed:@"login_icon"]];
    }
    return _logoImageView;
}

- (UILabel *)bottomVersionL
{
    if (!_bottomVersionL)
    {
        _bottomVersionL = [[UILabel alloc] init];
        _bottomVersionL.font =  [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];//UI_FSFONT_MAKE(FontNamePingFangSCRegular, 12);
        _bottomVersionL.textColor = login_UIColorFromRGB(0x6D7278);//[UIColor bm_colorWithHex:0x6D7278];
        _bottomVersionL.textAlignment = NSTextAlignmentCenter;
        
    }
    return _bottomVersionL;
}

- (UIButton *)joinRoomBtn
{
    if (!_joinRoomBtn)
    {
        _joinRoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        _joinRoomBtn.backgroundColor = YSColor_DefaultBlue;
        [_joinRoomBtn setTitle:[NSString stringWithFormat:@"%@",YSSLocalized(@"Login.EnterRoom")] forState:UIControlStateNormal];
        
        UIColor *color = login_UIColorFromRGB(0xFFE895);
        [_joinRoomBtn setTitleColor:color forState:UIControlStateNormal];
        _joinRoomBtn.titleLabel.textAlignment =  NSTextAlignmentCenter;
        _joinRoomBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        
        [_joinRoomBtn setBackgroundImage:[UIImage imageNamed:@"login_join_normal"] forState:UIControlStateNormal];
        [_joinRoomBtn setBackgroundImage:[UIImage imageNamed:@"login_join_highlight"] forState:UIControlStateHighlighted];
        [_joinRoomBtn setBackgroundImage:[UIImage imageNamed:@"login_join_disabled"] forState:UIControlStateDisabled];
        _joinRoomBtn.enabled = NO;
    }
    return _joinRoomBtn;
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location == 0 && [string isEqualToString:@" "])
    {
        textField.text = @"";
        return NO;
    }
    if (range.location>=10)
    {
        return YES;
    }
    else
    {
        return YES;
    }
    return YES;

}

- (void)inpuTextFieldDidChanged:(UITextField *)textField
{
    if (self.roomTextField.inputTextField.text.length > 0 && self.nickNameTextField.inputTextField.text.length > 0)
    {
        self.joinRoomBtn.enabled = YES;
    }
    else
    {
        self.joinRoomBtn.enabled = NO;
    }
    
    if (textField.tag ==102)
    {
        NSInteger existTextNum = textField.text.length;
        if (existTextNum == 1 && [textField.text isEqualToString:@" "])
        {
            existTextNum = 0;
            textField.text = @"";
        }
        else if (existTextNum > 10)
        {
            //截取到最大位置的字符
            NSString *s = [textField.text substringToIndex:10];
            [textField setText:s];
            
        }
    }
}


#pragma mark -
#pragma mark SEL

- (void)clickAction:(UITapGestureRecognizer *)tap
{
     [self.view endEditing:YES];
}

#if 1
// 进入房间方法一
- (void)joinRoomBtnClicked:(UIButton *)btn
{
    NSString *roomId = self.roomTextField.inputTextField.text;
    NSString *nickName = self.nickNameTextField.inputTextField.text;

    /**信息检查*/
    if (!roomId.length)
    {
        //教室号不能为空
        NSString *content =  @"房间号不能为空";
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:content message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *confimAc = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertVc addAction:confimAc];
        return;
    }

    if (!nickName.length)
    {
        // 昵称不能为空
        NSString *content =  @"昵称不能为空";
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:content message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *confimAc = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertVc addAction:confimAc];
        return;
    }

    // 根据实际用户变更用户身份
    userRole = YSSDKUserType_Teacher;
    __weak __typeof(self) weakSelf = self;
    // 预先获得房间类型和是否需要登入密码
    [self.ysSDKManager checkRoomTypeBeforeJoinRoomWithRoomId:roomId success:^(YSSDKUseTheType roomType, BOOL needpassword) {
        // roomType: 房间类型 3：小班课  4：直播   6：会议
        // needpassword: 参会人员(学生)是否需要密码
        if (self->userRole == YSSDKSUserType_Student)
        {
            // 学生登入
            // 注意： 直播只支持学生身份登入房间
            [weakSelf.ysSDKManager joinRoomWithRoomId:roomId nickName:nickName roomPassword:nil userId:nil userParams:nil];
        }
        else
        {
            // 老师(会议主持)登入
            // 注意： 小班课和会议支持老师和学生身份登入房间
            [weakSelf.ysSDKManager joinRoomWithRoomId:roomId nickName:nickName roomPassword:nil userRole:self->userRole userId:nil userParams:nil];
        }
        
    } failure:^(NSInteger code, NSString * _Nonnull errorStr) {
        NSLog(@"code:%@, message: %@", @(code), errorStr);
        [self.progressHUD hideAnimated:YES];
    }];
    
    [self.progressHUD showAnimated:YES];
}

#else

// 进入房间方法二
- (void)joinRoomBtnClicked:(UIButton *)btn
{
    NSString *roomId = self.roomTextField.inputTextField.text;
    NSString *nickName = self.nickNameTextField.inputTextField.text;

    /**信息检查*/
    if (!roomId.length)
    {
        //教室号不能为空
        NSString *content =  @"房间号不能为空";
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:content message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *confimAc = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertVc addAction:confimAc];
        return;
    }

    if (!nickName.length)
    {
        // 昵称不能为空
        NSString *content =  @"昵称不能为空";
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:content message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *confimAc = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertVc addAction:confimAc];
        return;
    }

    // 根据实际用户变更用户身份
    // 如果需要密码请添加password
    userRole = YSSDKUserType_Teacher;
    if (userRole == YSSDKSUserType_Student)
    {
        // 学生登入
        // 注意： 直播只支持学生身份登入房间
        [self.ysSDKManager joinRoomWithRoomId:roomId nickName:nickName roomPassword:nil userId:nil userParams:nil];
    }
    else
    {
        // 老师(会议主持)登入
        // 注意： 小班课和会议支持老师和学生身份登入房间
        [self.ysSDKManager joinRoomWithRoomId:roomId nickName:nickName roomPassword:nil userRole:userRole userId:nil userParams:nil];
    }
    
    [self.progressHUD showAnimated:YES];
}


#endif

#pragma mark -
#pragma mark YSLiveSDKDelegate

/**
    成功进入房间
    @param ts 服务器当前时间戳，以秒为单位，如1572001230
 */
- (void)onRoomJoined:(NSTimeInterval)ts roomType:(YSSDKUseTheType)roomType userType:(YSSDKUserRoleType)userType
{
    NSLog(@"onRoomJoined");
    
    [self.progressHUD hideAnimated:YES];
    
    [YSLoginVC setLoginRoomID:self.roomTextField.inputTextField.text];
    [YSLoginVC setLoginNickName:self.nickNameTextField.inputTextField.text];
    
    if (roomType == YSSDKUseTheType_LiveRoom)
    {
        GetAppDelegate.allowRotation = NO;
    }
    else
    {
        GetAppDelegate.allowRotation = YES;
    }
}

/**
    失去连接
 */
- (void)onRoomConnectionLost
{
    NSLog(@"onRoomConnectionLost");

}

/**
    已经离开房间
 */
- (void)onRoomLeft
{
    NSLog(@"onRoomLeft");
    
    //GetAppDelegate.allowRotation = NO;
}

/**
    自己被踢出房间
    @param reason 被踢原因
 */
- (void)onRoomKickedOut:(NSDictionary *)reason
{
    NSLog(@"onRoomKickedOut");

}

/**
    发生密码错误 回调
    需要重新输入密码

    @param errorCode errorCode
 */
- (void)onRoomNeedEnterPassWord:(YSSDKErrorCode)errorCode
{
    NSLog(@"onRoomNeedEnterPassWord");
    
    [self.progressHUD hideAnimated:YES];

    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:YSSLocalized(@"Error.PwdError") message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    __block UITextField *passwordTextField;
    [alertVc addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        passwordTextField = textField;
        if (self->userRole == YSSDKUserType_Teacher)
        {
            textField.placeholder = YSSLocalized(@"Error.NeedPwd.teacher");
        }
        else
        {
            textField.placeholder = YSSLocalized(@"Error.NeedPwd.student");
        }
    }];

    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        NSString *roomId = self.roomTextField.inputTextField.text;
        NSString *nickName = self.nickNameTextField.inputTextField.text;
        NSString *password = passwordTextField.text;
        if (self->userRole == YSSDKSUserType_Student)
        {
            // 学生登入
            // 注意： 直播只支持学生身份登入房间
            [self.ysSDKManager joinRoomWithRoomId:roomId nickName:nickName roomPassword:password userId:nil userParams:nil needCheckPermissions:NO];
        }
        else
        {
            // 老师(会议主持)登入
            // 注意： 小班课和会议支持老师和学生身份登入房间
            [self.ysSDKManager joinRoomWithRoomId:roomId nickName:nickName roomPassword:password userRole:self->userRole userId:nil userParams:nil needCheckPermissions:NO];
        }
    }];
    [alertVc addAction:confimAc];
    
    [self presentViewController:alertVc animated:YES completion:nil];
}

/**
    发生其他错误 回调
    需要重新登陆
 
    @param errorCode errorCode
*/
- (void)onRoomReportFail:(YSSDKErrorCode)errorCode descript:(NSString *)descript
{
    NSLog(@"onRoomNeedEnterPassWord");

    [self.progressHUD hideAnimated:YES];

    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:descript message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSSLocalized(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:confimAc];
    
    [self presentViewController:alertVc animated:YES completion:nil];
}

/**
   已经进入直播房间
*/
- (void)onEnterLiveRoom
{
    NSLog(@"onEnterLiveRoom");

}

/**
   已经进入小班课(会议)房间
*/
- (void)onEnterClassRoom
{
    NSLog(@"onEnterClassRoom");

}

@end

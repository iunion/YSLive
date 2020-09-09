//
//  YSLoginViewController.m
//  YSEdu
//

//

#import "CHLoginVC.h"
#import "AppDelegate.h"

#import "CHInputView.h"
#import "Masonry.h"
#import "CHLoginMacros.h"

#import <MBProgressHUD/MBProgressHUD.h>

#import "CHMainViewController.h"

/// server
//NSString *const CHJoinRoomParamsServerKey       = @"server";
///// 客户端类型
/////// port
//NSString *const CHJoinRoomParamsPortKey         = @"port";
/////// secure
//NSString *const CHJoinRoomParamsSecureKey       = @"secure";
#define CloudHubManager_DefaultApiHost     @"api.roadofcloud.net"
#define CloudHubManager_DefaultApiPort     (443)

#define USE_COOKIES     0

/// 登录时 输入框记录的房间号
static NSString *const YSLOGIN_USERDEFAULT_ROOMID = @"chLOGIN_USERDEFAULT_ROOMID";
/// 登录时 输入框记录的昵称
static NSString *const YSLOGIN_USERDEFAULT_NICKNAME = @"chLOGIN_USERDEFAULT_NICKNAME";

@interface CHLoginVC ()
<
    UITextFieldDelegate,
    CHInputViewDelegate,
    CHWhiteBoardManagerDelegate
>
//{
//    YSUserRoleType userRole;
//}

@property (nonatomic, weak) CloudHubWhiteBoardKit *cloudHubManager;

/// 背景滚动
@property (nonatomic, strong) UIScrollView *backScrollView;
/// 背景
@property (nonatomic, strong) UIImageView *backImageView;
/// 顶部LOGO
@property (nonatomic, strong) UIImageView *logoImageView;
/// 房间号输入框
@property (nonatomic, strong) CHInputView *roomTextField;
/// 昵称输入框
@property (nonatomic, strong) CHInputView *nickNameTextField;
/// 底部版本文字
@property (nonatomic, strong) UILabel *bottomVersionL;
/// 进入教室按钮
@property (nonatomic, strong) UIButton *joinRoomBtn;

/// 当前用户数据
@property (nonatomic, strong) CHRoomUser *localUser;

@property (assign, nonatomic) NSInteger role;
/// 默认服务
@property (strong, nonatomic) NSString *defaultServer;
/// 音视频SDK干管理
@property (nonatomic, weak) CloudHubRtcEngineKit *cloudHubRtcEngineKit;
// 网络等待
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@end


@implementation CHLoginVC

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
 
    [self setupUI];

    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHUD.animationType = MBProgressHUDAnimationFade;
    [self.view addSubview:self.progressHUD];

    NSString *roomID = [CHLoginVC getLoginRoomID];
    if (roomID)
    {
        self.roomTextField.inputTextField.text = roomID;
    }
    NSString *nickName = [CHLoginVC getLoginNickName];
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
    CHWeakSelf
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
        make.top.mas_equalTo(weakSelf.logoImageView.mas_bottom).mas_offset(-login_kScale_H(60));
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
        CHWeakSelf
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

- (CHInputView *)roomTextField
{
    if (!_roomTextField)
    {
        _roomTextField = [[CHInputView alloc] initWithFrame:CGRectZero withPlaceholder:@"请输入房间号" withImageName:@"login_room"];
        _roomTextField.inputTextField.delegate = self;
        _roomTextField.inputTextField.tag = 101;
        _roomTextField.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
        _roomTextField.delegate = self;
    }
    return _roomTextField;
}

- (CHInputView *)nickNameTextField
{
    if (!_nickNameTextField)
    {
        _nickNameTextField = [[CHInputView alloc] initWithFrame:CGRectZero withPlaceholder:@"请输入您的昵称" withImageName:@"login_name"];
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
//        [_joinRoomBtn setTitle:[NSString stringWithFormat:@"%@",YSSLocalized(@"Login.EnterRoom")] forState:UIControlStateNormal];
        
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
//    userRole = YSUserType_Teacher;
    
    self.cloudHubManager = [CloudHubWhiteBoardKit sharedInstance];
//    self.cloudHubManager.delegate = self;

    [self joinRoomWithNickName:nickName roomId:roomId roomPassword:nickName];
}

- (BOOL)joinRoomWithNickName:(NSString *)nickName roomId:(NSString *)roomId roomPassword:(NSString *)roomPassword
{
    // 用户ID
    NSString * userId = [[NSUUID UUID] UUIDString];
    self.localUser = [[CHRoomUser alloc] initWithPeerId:userId];

    // 用户属性
    self.localUser.nickName = nickName;

    // 初始化 cloudHubRtcEngineKit
    // rtcEngineKit 使用http，所以端口是80
//    NSDictionary *rtcEngineKitConfig = @{ CHJoinRoomParamsServerKey:host, CHJoinRoomParamsPortKey:@(80), CHJoinRoomParamsSecureKey:@(NO) };
//    self.cloudHubRtcEngineKit = [CloudHubRtcEngineKit sharedEngineWithAppId:@"" config:[rtcEngineKitConfig bm_toJSON]];
    self.cloudHubRtcEngineKit = [CloudHubRtcEngineKit sharedEngineWithAppId:@"" config:nil];
    self.cloudHubRtcEngineKit.wb = self.cloudHubManager;
    self.cloudHubRtcEngineKit.delegate = self;
    
#ifdef DEBUG
    [self.cloudHubRtcEngineKit setLogFilter:1];
#endif
    
    [self.cloudHubManager registeWhiteBoardWithHost:CloudHubManager_DefaultApiHost port:CloudHubManager_DefaultApiPort withLocalUser:self.localUser roomId:roomId];
    
    if ([self.cloudHubRtcEngineKit joinChannelByToken:@"" channelId:roomId properties:nil uid:self.localUser.peerID joinSuccess:nil] != 0)
    {
        NSLog(@"Join Channel failed!!");
        return NO;
    }

    return YES;
}

#pragma mark -
#pragma mark CloudHubRtcEngineDelegate

/// 进入房间
- (void)rtcEngine:(CloudHubRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(NSString *)uid elapsed:(NSInteger)elapsed
{
    NSLog(@"onRoomJoined");
    
    [self.progressHUD hideAnimated:YES];
    
    [CHLoginVC setLoginRoomID:self.roomTextField.inputTextField.text];
    [CHLoginVC setLoginNickName:self.nickNameTextField.inputTextField.text];

    GetAppDelegate.allowRotation = YES;
    
    CHMainViewController *mainVC = [[CHMainViewController alloc] initWithwhiteBordView:self.cloudHubManager.mainWhiteBoardView userId:nil];
    
    self.cloudHubManager.delegate = mainVC;
    
    mainVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:mainVC animated:YES completion:nil];
    
}

#pragma mark - 重连

- (void)rtcEngine:(CloudHubRtcEngineKit *)engine didReJoinChannel:(NSString *)channel withUid:(NSString *)uid elapsed:(NSInteger) elapsed
{
    
}

/// 成功重连房间
- (void)onRoomReJoined
{
    
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
    @param reasonCode 被踢原因
 */
- (void)onRoomKickedOut:(NSInteger)reasonCode
{
    NSLog(@"onRoomKickedOut");

}

- (void)onRoomDidOccuredError:(CloudHubErrorCode)errorCode withMessage:(NSString *)message
{
    [CloudHubWhiteBoardKit destroy];
    
    [self.progressHUD hideAnimated:YES];

    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    NSString * jjj = CHSLocalized(@"Prompt.OK");
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:confimAc];
    
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (void)onUpdateTimeWithTimeInterval:(NSTimeInterval)timeInterval
{
    
}



#pragma mark - CHWhiteBoardManagerDelegate

/// 白板准备完毕
- (void)onWhiteBroadCheckRoomFinish:(BOOL)finished
{
    
}

/**
 文件列表回调
 @param fileList 文件NSDictionary列表
 */
- (void)onWhiteBroadFileList:(NSArray *)fileList
{
    
}

/// H5脚本文件加载初始化完成
- (void)onWhiteBoardPageFinshed:(NSString *)fileId
{
    
}

/// 切换Web课件加载状态
- (void)onWhiteBoardLoadedState:(NSString *)fileId withState:(NSDictionary *)dic
{
    
}

/// Web课件翻页结果
- (void)onWhiteBoardStateUpdate:(NSString *)fileId withState:(NSDictionary *)dic
{
    
}
/// 翻页超时
- (void)onWhiteBoardSlideLoadTimeout:(NSString *)fileId withState:(NSDictionary *)dic
{
    
}
/// 课件缩放
- (void)onWhiteBoardZoomScaleChanged:(NSString *)fileId zoomScale:(CGFloat)zoomScale
{
    
}


#pragma mark - 课件事件

/// 课件全屏
- (void)onWhiteBoardFullScreen:(BOOL)isAllScreen
{
    
}

/// 切换课件
- (void)onWhiteBoardChangedFileWithFileList:(NSArray *)fileList
{
    
}


/// 课件窗口最大化事件
- (void)onWhiteBoardMaximizeView
{
    
}

@end

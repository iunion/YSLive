
//
//  YSLoginViewController.m
//  YSEdu
//
//  Created by fzxm on 2019/10/9.
//  Copyright © 2019 ysxl. All rights reserved.
//

#import "YSLoginVC.h"
#import "YSInputView.h"
#import "YSCoreStatus.h"
#import "AppDelegate.h"

#import <Bugly/Bugly.h>

#import "YSSetViewController.h"
#import "YSEyeCareVC.h"
#import "YSEyeCareManager.h"
#import "YSPermissionsVC.h"
#import <AVFoundation/AVFoundation.h>
#ifdef YSLIVE
#import "YSMainVC.h"
#endif
#if YSCLASS
#import "SCMainVC.h"
#endif

#import "YSTeacherRoleMainVC.h"

#import "YSTabBarViewController.h"

#if USE_TEST_HELP
#import "YSTestHelp.h"
#endif

#import "YSPassWordAlert.h"

#import "YSLiveApiRequest.h"

#import "BMAlertView+YSDefaultAlert.h"

#import "YSLiveUtil.h"
#import "YSWebViewController.h"
#import "YSTextView.h"

#import "SSZipArchive.h"

#import "CHBeautyControlView.h"

#if USE_TEST_HELP
#define USE_YSLIVE_ROOMID 0
#define CLEARCHECK 0
#endif


#define YSONLINESCHOOL 1
#define YS_CHANGE_WHITEBOARD_BACKGROUND 0

/// 每次打包的递增版本号 +1
#define YSAPP_CommitVersion [[NSBundle mainBundle] infoDictionary][@"YSAppCommitVersion"]

#define ThemeKP(args) [@"Alert." stringByAppendingString:args]

typedef void (^YSRoomLeftDoBlock)(void);

@interface YSLoginVC ()
<
    CHSessionDelegate,
    UITextFieldDelegate,
    YSInputViewDelegate,
    UITextViewDelegate
>
{
    UIAlertController *updatAalertVc;
    UIAlertController *eyeCareAlertVc;
}
@property (nonatomic, assign) CHRoomUseType room_UseTheType;

@property (nonatomic, strong) NSURL *loginUrl;

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
/// 密码输入框
@property (nonatomic, strong) YSInputView *passwordTextField;
/// 密码输入框上蒙版
@property (nonatomic, strong) UIView * passwordMask;

/// 域名输入框
@property (nonatomic, strong) YSInputView *domainTextField;
/// 账号输入框
@property (nonatomic, strong) YSInputView *admin_accountTextField;
/// 网校密码输入框
@property (nonatomic, strong) YSInputView *passOnlineTextField;
/// grouproom 房间分组类型 0 普通房间，1 分组主（父）房间，2 分组子房间
@property (nonatomic, assign) CHRoomGroupType grouproom;
///获取房间类型时，探测接口的调用次数
@property (nonatomic, assign) NSInteger  callNum;

///学生是否需要密码
@property (nonatomic, assign) BOOL needpwd;

/// 底部版本文字
@property (nonatomic, strong) UILabel *bottomVersionL;
/// 进入教室按钮
@property (nonatomic, strong) UIButton *joinRoomBtn;

//@property (nonatomic, assign) NSInteger role;
/// 默认服务
@property (nonatomic, strong) NSString *defaultServer;

/// 选择角色的弹框view
@property (nonatomic, strong) UIView *roleSelectView;
/// 底部的角色type
@property (nonatomic, assign) CHUserRoleType selectRoleType;

/// 学生角色button
@property (nonatomic, strong) UIButton *studentRoleBtn;
/// 老师角色button
@property (nonatomic, strong) UIButton *teacherRoleBtn;
/// 巡课角色button
@property (nonatomic, strong) UIButton *patrolRoleBtn;

/// 选中的角色button
@property (nonatomic, strong) UIButton *selectedRoleBtn;
/// 进入网校
@property (nonatomic, strong) UIButton *onlineSchoolBtn;

/// 网校密码明文按钮
@property (nonatomic, strong) UIButton *passwordEyeBtn;

// 网络等待
@property (nonatomic, strong) BMProgressHUD *progressHUD;
@property (nonatomic, assign) BOOL isOnlineSchool;

@property (nonatomic, strong) NSString *randomKey;

@property (nonatomic, assign) BOOL needCheckPermissions;

@property (nonatomic, strong)CHBeautyControlView *beautyView;

#if 0
@property (nonatomic, strong) NSString *leftHUDmessage;
#endif

@end


@implementation YSLoginVC

- (instancetype)initWithLoginURL:(NSURL *)loginurl
{
    self = [super init];
    if (self)
    {
        self.loginUrl = loginurl;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [BMProgressHUD bm_hideAllHUDsForView:YSKeyWindow animated:YES];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[YSEyeCareManager shareInstance] stopRemindtime];
    [[YSEyeCareManager shareInstance] freshWindowWithShowStatusBar:YES isRientationPortrait:YES];
    
    GetAppDelegate.allowRotation = NO;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)even
{
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getAppStoreNewVersion];
    
    self.selectRoleType = CHUserType_Student;
    self.isOnlineSchool = NO;
    
    // 主题问题
    [self setupUI];
    
#if CLEARCHECK
    UIButton *clearCheckBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:clearCheckBtn];
    [clearCheckBtn setBackgroundColor:[UIColor redColor]];
    clearCheckBtn.frame = CGRectMake(50, 100, 100, 50);
    [clearCheckBtn setTitle:@"重置权限" forState:UIControlStateNormal];
    [clearCheckBtn addTarget:self action:@selector(clearCheckBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
#endif
        
    self.progressHUD = [[BMProgressHUD alloc] initWithView:self.view];
    self.progressHUD.animationType = BMProgressHUDAnimationFade;
    [self.view addSubview:self.progressHUD];
    
    NSString * roomID = [YSUserDefault getLoginRoomID];
    if ([roomID bm_isNotEmpty])
    {
        self.roomTextField.inputTextField.text = roomID;
    }
    
    NSString * nickName = [YSUserDefault getLoginNickName];
    
    if ([nickName bm_isNotEmpty])
    {
        self.nickNameTextField.inputTextField.text = nickName;
    }
    
#if USE_YSLIVE_ROOMID
#else
    if ([roomID bm_isNotEmpty] && [nickName bm_isNotEmpty])
    {
        self.joinRoomBtn.enabled = YES;
        self.joinRoomBtn.alpha = 1.0;
    }
    else
    {
        self.joinRoomBtn.enabled = NO;
        self.joinRoomBtn.alpha = 0.3;
    }
#endif

    [self showEyeCareRemind];
    
    [self getServerTime];
    
    if (self.loginUrl)
    {
        NSDictionary *dic = [YSLiveManager resolveJoinRoomParamsWithUrl:self.loginUrl];
        self.loginUrl = nil;
        if (![dic bm_isNotEmptyDictionary])
        {
            return;
        }
        
        if ([dic bm_containsObjectForKey:@"roomid"])
        {
            NSString *roomId = [dic bm_stringTrimForKey:@"roomid"];
            if ([roomId bm_isNotEmpty])
            {
                [self joinRoomWithRoomId:roomId];
            }
        }
        else
        {
            [self joinRoomWithRoomParams:dic userParams:nil];
        }
    }
    
}

#if CLEARCHECK
- (void)clearCheckBtnClicked:(UIButton *)btn
{
#if 0
//    NSString *urlstr = @"joinroom://rddoccdndemows.roadofcloud.com/static/h5_live_2.1.1.16/index.html/?host=release.roadofcloud.com&domain=xzj&param=oQWJiPESSSloUJYW_eebY4yhaXjcSeaZpBOt-tb2Cin88FjhbovGoYEX4dwrhvbuqYDqikDGwcB2bh3nMEiDhD7Vf-GmIxIs_tB_CdQZIiQrcC3ZIkUOS6NH9ks6LYfKu33bWttb7llfvnUU8_0C3A&timestamp=1581314212&roomtype=3&logintype=2&video=320*180&companyidentify=1";
        //NSString *urlstr = @"joinroom://?host=api.roadofcloud.net&domain=wjy&param=JxMe2Nu5uY9Bb5C_hStqSGuavpYFRNVVeHLFDFPH-R_q7cduxOZzR4i7XX3TqgytZtMeGuLhBSaXK4Gw6IXs7YZZQLFGu5SyULxpCxSfIJ6vuff28NGkwAq19EcpO7lBOAbgZ6Iv5XgJs26-2lNy4pZxaiTiGVbXAre7LrqaoVk&timestamp=1581327248&roomtype=3&logintype=2&video=200*150&companyidentify=1";
    //NSString *urlstr = @"joinroom://?host=api.roadofcloud.net&domain=wjy&param=JxMe2Nu5uY-l_bzNjinmoaeL6LbNaatpEnJM0sSUj6In0bo9pmxZMFqVdhpay2ki8fgtSO-azH9m0x4a4uEFJpcrgbDoheztZn7cF4vFUetQvGkLFJ8gnq-59_bw0aTACrX0Ryk7uUE4BuBnoi_leAmzbr7aU3LilnFqJOIZVtcEZHxpqdz3aQ&timestamp=1581500012&roomtype=3&logintype=2&video=200*150&companyidentify=1";
    
    // 巡课
    NSString *urlstr =  @"joinroom://?host=demo.roadofcloud.com&domain=xzj&param=yqf-h_RjzTMLh8pbnyIHAoyhaXjcSeaZ2LXK2b7Cadzg2o4NYECOmOxfrjFxVN42yjWfictg5s5pqIxRpJy1Gg26dxosssvbR6A-OLn12TYaWhuBL_kx7o5ZSnPRPCRIAT8qff7E-1Q&timestamp=1583057949&roomtype=3&logintype=4&video=320*240&companyidentify=1&entryUserId=67af2ebd-2321-d387-dfaa-3e08d2ca9151";
    
    NSURL *url = [NSURL URLWithString:urlstr];
    NSDictionary *dic = [YSLiveManager resolveJoinRoomParamsWithUrl:url];

    if (![dic bm_isNotEmptyDictionary])
    {
        return;
    }

    if ([dic bm_containsObjectForKey:@"roomid"])
    {
        NSString *roomId = [dic bm_stringTrimForKey:@"roomid"];
        if ([roomId bm_isNotEmpty])
        {
            [self joinRoomWithRoomId:roomId];
        }
    }
    else
    {
        [self joinRoomWithRoomParams:dic userParams:nil];
    }

#else
    
    [YSUserDefault setReproducerPermission:NO];
    
#endif
}

#endif

#pragma mark 横竖屏

/// 1.决定当前界面是否开启自动转屏，如果返回NO，后面两个方法也不会被调用，只是会支持默认的方向
- (BOOL)shouldAutorotate
{
    if (GetAppDelegate.useAllowRotation)
    {
        return NO;
    }
    
    return YES;
}

/// 2.返回支持的旋转方向
/// iPhone设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
/// iPad设备上，默认返回值是UIInterfaceOrientationMaskAll
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

/// 3.返回进入界面默认显示方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)showEyeCareRemind
{
    if ([[YSEyeCareManager shareInstance] getEyeCareModeStatus])
    {
        [[YSEyeCareManager shareInstance] switchEyeCareWithWindowMode:YES];
    }
    
    if ([[YSEyeCareManager shareInstance] getEyeCareNeverRemind])
    {
        return;
    }
    
    NSDate *date = [NSDate date];
    NSUInteger currentHour = date.bm_hour;
    if ((currentHour >= 0 && currentHour < 6) || (currentHour >= 22 && currentHour <= 23))
    {
        BMWeakSelf
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:YSLoginLocalized(@"EyeProtection.AlertTitle") message:YSLoginLocalized(@"EyeProtection.AlertMsg") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLoginLocalized(@"EyeProtection.Btnsetup") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            YSEyeCareVC *eyeCareVC = [[YSEyeCareVC alloc] init];
            [weakSelf.navigationController pushViewController:eyeCareVC animated:YES];
        }];
        UIAlertAction *cancleAc = [UIAlertAction actionWithTitle:YSLoginLocalized(@"EyeProtection.BtnKnow") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertVc addAction:cancleAc];
        [alertVc addAction:confimAc];
        if (!updatAalertVc)
        {
            [self presentViewController:alertVc animated:YES completion:nil];
            eyeCareAlertVc = alertVc;
        }
    }
}

/// 获取服务器时间
- (void)getServerTime
{
    // 使用的默认host，所以获取的服务器时间是默认标准服务器时间
    BMAFHTTPSessionManager *manager = [BMAFHTTPSessionManager manager];
    NSMutableURLRequest *request = [YSLiveApiRequest getServerTime];
    if (request)
    {
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
            @"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript",
            @"text/xml", @"image/jpeg", @"image/*"
        ]];
        
        NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
            }
            else
            {
#ifdef DEBUG
                NSString *responseStr = [[NSString stringWithFormat:@"%@", responseObject] bm_convertUnicode];
                BMLog(@"%@ %@", response, responseStr);
#endif

                NSDictionary *responseDic = [BMCloudHubUtil convertWithData:responseObject];
                if ([responseDic bm_containsObjectForKey:@"time"])
                {
                    NSTimeInterval timeInterval = [responseDic bm_doubleForKey:@"time"];
#if (0)
                    YSLiveManager *liveManager = [YSLiveManager sharedInstance];
                    if (liveManager.tServiceTime == 0)
                    {
                        liveManager.tServiceTime = timeInterval;
                    }
#endif
                    BMLog(@"服务器当前时间： %@", [NSDate bm_stringFromTs:timeInterval]);
                }
            }
        }];
        [task resume];
    }
}


#pragma mark -- 获取商店的版本

- (void)getAppStoreNewVersion
{
    NSString *urlStr = [NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@&ts=%@", YS_APPID, @([NSDate date].timeIntervalSince1970)];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // 请求的数据转字典，必须判断数据有值才走里面，不然空的data会出现crash
        if (data.length > 0)
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSString *newVersion = [result[@"results"] firstObject][@"version"];
            if ([newVersion bm_isNotEmpty])
            {
                NSString *oldVersion = BMAPP_VERSIONNO;
                if ([newVersion compare: oldVersion] == NSOrderedDescending)
                {
                    [self checkUpdate];
                }
            }
        }
    }];
    [task resume];
}

///检查版本升级
- (void)checkUpdate
{
    BMAFHTTPSessionManager *manager = [BMAFHTTPSessionManager manager];
    NSString *commitVersion = YSAPP_CommitVersion;
    
    [manager.requestSerializer setTimeoutInterval:30];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
        @"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript",
        @"text/xml"
    ]];

    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/ClientAPI/checkupdateinfo", YSLive_Http, [YSLiveManager sharedInstance].apiHost];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    // 默认是自己的标准app，传值是其他公司定制
    //[parameters bm_setString:@"" forKey:@"companydomain"];
#ifdef YSCUSTOMIZED_WSKJ
    // 网宿科技
    [parameters bm_setString:@"wskj" forKey:@"companydomain"];
#endif
    [parameters bm_setString:commitVersion forKey:@"version"];
    [parameters bm_setInteger:3 forKey:@"type"];
    
    NSURLSessionDataTask *task = [manager POST:urlStr parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
#ifdef DEBUG
        BMLog(@"%@", responseObject);
#endif
        
        if ([[responseObject bm_stringForKey:@"result"] isEqualToString:@"-1"])
        {
            return ;
        }
        NSDictionary *responseDic = [BMCloudHubUtil convertWithData:responseObject];
        NSString *downString;
        NSString *httpLink = [responseDic bm_stringTrimForKey:@"setupaddr"];
        //NSString *appId = [responseDic bm_stringTrimForKey:@"appId"];
        NSInteger updateflag = [responseDic bm_intForKey:@"updateflag"];
        
        if ([httpLink bm_isNotEmpty])
        {
            downString = httpLink;
        }
//        else if ([appId bm_isNotEmpty])
//        {
//            downString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/%@", appId];
//        }
        else
        {
            downString = YS_APPSTORE_DOWNLOADAPP_ADDRESS;
        }
        
        BOOL needUpdata = NO;
        if (updateflag == 1)
        {
            needUpdata = YES;
        }
        else if (updateflag == 2)
        {
            needUpdata = NO;
        }
        [self showUpdateAlertWithTitle:YSLoginLocalized(@"Alert.UpdateTitle") downLink:downString needUpdata:needUpdata];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error)
        {
            BMLog(@"Error: %@", error);
        }
    }];
    [task resume];
}

- (void)showUpdateAlertWithTitle:(NSString *)title downLink:(NSString *)downLink needUpdata:(BOOL)needUpdata
{
    NSString *message = @"";
    UIAlertActionStyle style;
    
    if (needUpdata)
    {
        message = YSLoginLocalized(@"Alert.UpdateForceMessage");
        style = UIAlertActionStyleDestructive;
    }
    else
    {
        message = YSLoginLocalized(@"Alert.UpdateMessage");
        style = UIAlertActionStyleDefault;
    }
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLoginLocalized(@"Alert.UpdateNow") style:style handler:^(UIAlertAction * _Nonnull action) {
        if (@available(iOS 10.0, *))
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downLink] options:@{} completionHandler:nil];
        }
        else
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downLink]];
        }
        if (needUpdata)
        {
            [self showUpdateAlertWithTitle:title downLink:downLink needUpdata:needUpdata];
        }
    }];
    [alertVc addAction:confimAc];
    
    if (!needUpdata)
    {
        UIAlertAction *ccc = [UIAlertAction actionWithTitle:YSLoginLocalized(@"Alert.UpdateAfter") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertVc addAction:ccc];
    }
    
    if (eyeCareAlertVc)
    {
        [eyeCareAlertVc dismissViewControllerAnimated:NO completion:^{
            [self presentViewController:alertVc animated:NO completion:nil];
            self->updatAalertVc = alertVc;
        }];
        eyeCareAlertVc = nil;
    }
    else
    {
        [self presentViewController:alertVc animated:YES completion:nil];
        updatAalertVc = alertVc;
    }
}

#pragma mark - UI

- (void)setupUI
{
    BMWeakSelf
    [self.view addSubview:self.backScrollView];
    self.backScrollView.frame = CGRectMake(0, 0, BMUI_SCREEN_WIDTH, BMUI_SCREEN_HEIGHT);
    self.backScrollView.contentSize = CGSizeMake(BMUI_SCREEN_WIDTH, BMUI_SCREEN_HEIGHT);
    
    if (@available(iOS 11.0, *))
    //if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0)
    {
        self.backScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.backImageView.frame = CGRectMake(0, 0, BMUI_SCREEN_WIDTH, BMUI_SCREEN_HEIGHT);

    [self.backScrollView addSubview:self.backImageView];

    UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAction:)];
    [self.backImageView addGestureRecognizer:click];
    
    [self.backImageView addSubview:self.logoImageView];
    [self.logoImageView bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
//        make.centerX.bmmas_equalTo(0);
        make.top.bmmas_equalTo(kBMScale_H(90));
        make.left.bmmas_equalTo(kBMScale_W(40));
        make.right.bmmas_equalTo(-kBMScale_W(40));
//        make.height.bmmas_equalTo(kBMScale_H(250));
    }];
    
    [self.backImageView addSubview:self.roomTextField];
    [self.roomTextField bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.top.bmmas_equalTo(weakSelf.logoImageView.bmmas_bottom);//.bmmas_offset(kBMScale_H(15));
        make.height.bmmas_equalTo(40);
        make.width.bmmas_equalTo(kBMScale_W(210));
        make.centerX.bmmas_equalTo(0);
    }];

    [self.backImageView addSubview:self.domainTextField];
    [self.domainTextField bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.top.bmmas_equalTo(weakSelf.logoImageView.bmmas_bottom).bmmas_offset(kBMScale_H(10));
        make.height.bmmas_equalTo(40);
        make.width.bmmas_equalTo(kBMScale_W(210));
        make.centerX.bmmas_equalTo(0);
    }];
    self.domainTextField.hidden = YES;

    [self.backImageView addSubview:self.nickNameTextField];
    [self.nickNameTextField bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.top.bmmas_equalTo(weakSelf.roomTextField.bmmas_bottom).bmmas_offset(kBMScale_H(20));
        make.height.bmmas_equalTo(40);
        make.width.bmmas_equalTo(kBMScale_W(210));
        make.centerX.bmmas_equalTo(0);
    }];
    
    [self.backImageView addSubview:self.admin_accountTextField];
    [self.admin_accountTextField bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.top.bmmas_equalTo(weakSelf.domainTextField.bmmas_bottom).bmmas_offset(kBMScale_H(20));
        make.height.bmmas_equalTo(40);
        make.width.bmmas_equalTo(kBMScale_W(210));
        make.centerX.bmmas_equalTo(0);
    }];
    self.admin_accountTextField.hidden = YES;

    [self.backImageView addSubview:self.passOnlineTextField];
    [self.passOnlineTextField bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.top.bmmas_equalTo(weakSelf.admin_accountTextField.bmmas_bottom).bmmas_offset(kBMScale_H(20));
        make.height.bmmas_equalTo(40);
        make.width.bmmas_equalTo(kBMScale_W(210));
        make.centerX.bmmas_equalTo(0);
    }];
    self.passOnlineTextField.hidden = YES;
    
    [self.passwordEyeBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.right.bmmas_equalTo(-10);
        make.top.bmmas_equalTo(self.passOnlineTextField);
        make.width.height.bmmas_equalTo(40);
    }];
    
    [self.backImageView addSubview:self.bottomVersionL];
    [self.bottomVersionL bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(25);
        make.height.bmmas_equalTo(30);
        make.width.bmmas_equalTo(kBMScale_W(180));
        make.top.bmmas_equalTo(kBMScale_H(18) + BMUI_STATUS_BAR_HEIGHT);
    }];
    
#ifdef DEBUG
    NSString *string = [NSString stringWithFormat:@"%@: %@", @"buildNO", BMAPP_BUILDNO];
    //NSString *string = [NSString stringWithFormat:@"V%@", APP_VERSIONNO];
#else
    //do sth.
    NSString *string = [NSString stringWithFormat:@"V%@", BMAPP_VERSIONNO];
#endif
    
    self.bottomVersionL.text = string;
    
    [self.backImageView addSubview:self.joinRoomBtn];
    [self.joinRoomBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.top.bmmas_equalTo(weakSelf.nickNameTextField.bmmas_bottom).bmmas_offset(kBMScale_H(30));
        make.height.bmmas_equalTo(50);
        make.width.bmmas_equalTo(kBMScale_W(238));
        make.centerX.bmmas_equalTo(0);
    }];
    
    UIButton *eyeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    eyeBtn.frame = CGRectMake(0, 0, 100, 40);
//    [eyeBtn setTitle:YSLoginLocalized(@"Login.Seting") forState:UIControlStateNormal];
    [eyeBtn setImage:YSSkinElementImage(@"login_setting", @"iconNor") forState:UIControlStateNormal];
    eyeBtn.titleLabel.font = UI_FONT_12;
    [eyeBtn setTitleColor:[UIColor bm_colorWithHex:0x878E95] forState:UIControlStateNormal];
    [eyeBtn addTarget:self action:@selector(onClickEye:) forControlEvents:UIControlEventTouchUpInside];
    [self.backImageView addSubview:eyeBtn];
    [eyeBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.right.bmmas_equalTo(-20);
        make.top.bmmas_equalTo(kBMScale_H(18) + BMUI_STATUS_BAR_HEIGHT);
    }];

    self.joinRoomBtn.layer.cornerRadius = 25;
    self.joinRoomBtn.layer.masksToBounds = YES;
    [self.joinRoomBtn addTarget:self action:@selector(joinRoomBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
#if YSONLINESCHOOL
    UIButton *onlineSchoolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.onlineSchoolBtn = onlineSchoolBtn;
    [self.backImageView addSubview:onlineSchoolBtn];
    [onlineSchoolBtn setTitle:YSLocalizedSchool(@"Button.onlineschool") forState:UIControlStateNormal];
    [onlineSchoolBtn setTitleColor:YSSkinDefineColor(@"Color4") forState:UIControlStateNormal];
    onlineSchoolBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    onlineSchoolBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [onlineSchoolBtn addTarget:self action:@selector(onlineSchoolBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    onlineSchoolBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.onlineSchoolBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.top.bmmas_equalTo(weakSelf.joinRoomBtn.bmmas_bottom).bmmas_offset(27);
        make.height.bmmas_equalTo(30);
        make.width.bmmas_equalTo(150);
        make.centerX.bmmas_equalTo(weakSelf.joinRoomBtn.bmmas_centerX);
    }];
#endif
    
    NSString *str = YSLocalized(@"Agreement.Agree");//@"已阅读并同意《隐私政策》和《用户协议》";
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSString *linkStr1 = YSLocalized(@"Agreement.Privacy");//隐私政策
    NSString *linkStr2 = YSLocalized(@"Agreement.User");// 用户协议
    // iOS 获取设备当前语言和地区的代码
    NSString *currentLanguageRegion = [[NSLocale preferredLanguages] firstObject];
    
    if ([currentLanguageRegion bm_containString:@"zh-Hant"] || [currentLanguageRegion bm_containString:@"zh-Hans"])
    {
        linkStr1 = [NSString stringWithFormat:@"《%@》",YSLocalized(@"Agreement.Privacy")];//隐私政策
        linkStr2 = [NSString stringWithFormat:@"《%@》",YSLocalized(@"Agreement.User")];//用户协议
    }

    
    
    [attribute addAttribute:NSLinkAttributeName value:YSPrivacyClause range:[str rangeOfString:linkStr1]];
    [attribute addAttribute:NSLinkAttributeName value:YSUserAgreement range:[str rangeOfString:linkStr2]];
    
    YSTextView *textView = [[YSTextView alloc] init];
    textView.delegate = self;
    textView.textColor = YSSkinDefineColor(@"PlaceholderColor");
    textView.backgroundColor = [UIColor clearColor];
    textView.font = UI_FONT_10;
    
    textView.linkTextAttributes = @{NSForegroundColorAttributeName:YSSkinDefineColor(@"Color4"),NSFontAttributeName:[UIFont systemFontOfSize:10]};
    textView.editable = NO;
    textView.scrollEnabled = NO;
    [self.backImageView addSubview:textView];
        
    CGSize textViewSize = [attribute bm_sizeToFit:CGSizeMake(250.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    textView.attributedText = attribute;
    textView.textAlignment = NSTextAlignmentCenter;
    [textView bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.bottom.bmmas_equalTo(-20.f);
        make.height.bmmas_equalTo(textViewSize.height);
        make.left.bmmas_equalTo(5.0f);
        make.right.bmmas_equalTo(-5.0f);
    }];
    
    
    
//    // 用户协议
//    UIButton *userAgreement = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.backImageView addSubview:userAgreement];
//    [userAgreement setImage:YSSkinElementImage(@"login_userAgreement", @"iconNor") forState:UIControlStateNormal];
//    [userAgreement setImage:YSSkinElementImage(@"login_userAgreement", @"iconSel") forState:UIControlStateSelected];
//    [userAgreement addTarget:self action:@selector(userAgreementClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [userAgreement bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
//        make.right.bmmas_equalTo(textView.bmmas_left).bmmas_offset(-2);
//        make.height.bmmas_equalTo(25);
//        make.width.bmmas_equalTo(25);
//        make.centerY.bmmas_equalTo(textView.bmmas_centerY);
//    }];
//
//    if ([YSUserDefault getUserAgreement])
//    {
//        userAgreement.selected = YES;
//    }
    
    [self addBeautyView];
    
}




- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(nonnull NSURL *)URL inRange:(NSRange)characterRange
{
    
    YSWebViewController *webVC = [[YSWebViewController alloc] init];
    webVC.roteUrl = [URL absoluteString];
    
    [self.navigationController pushViewController:webVC animated:YES];
    return NO;
}



///// 同意用户协议
//- (void)userAgreementClicked:(UIButton *)btn
//{
//    btn.selected = !btn.selected;
//    [YSUserDefault setUserAgreement:btn.selected];
//
//}

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
        [UIView animateWithDuration:0.25 animations:^{
            self.backScrollView.contentOffset = CGPointMake(0, offSet);
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)note
{
    [UIView animateWithDuration:0.25 animations:^{
        self.backScrollView.contentOffset = CGPointMake(0, 0);
    }];
}


#pragma mark -
#pragma mark SEL
#pragma mark 教室，网校切换
- (void)onlineSchoolBtnClicked:(UIButton *)btn
{
    self.isOnlineSchool = !_isOnlineSchool;
    BMWeakSelf
    if (self.isOnlineSchool)
    {//进入网校
        
        [self.logoImageView setImage:YSSkinElementImage(@"login_topImage", @"iconOnlineSchool")];
//        [self.logoImageView bmmas_remakeConstraints:^(BMMASConstraintMaker *make) {
//            make.centerX.bmmas_equalTo(0);
//            //        make.top.bmmas_equalTo(kScale_H(130));
//            make.top.bmmas_equalTo(kBMScale_H(50));
//            make.height.bmmas_equalTo(kBMScale_W(153));
//            make.width.bmmas_equalTo(kBMScale_W(197));
//        }];
        
        self.passOnlineTextField.hidden = NO;
        self.domainTextField.hidden = NO;
        self.admin_accountTextField.hidden = NO;
        self.roomTextField.hidden = YES;
        self.nickNameTextField.hidden = YES;
        [self.joinRoomBtn setTitle:YSLocalizedSchool(@"Login.Enter") forState:UIControlStateNormal];
        [self.onlineSchoolBtn setTitle:YSLocalizedSchool(@"Login.EnterRoom") forState:UIControlStateNormal];
        
        [self.joinRoomBtn bmmas_remakeConstraints:^(BMMASConstraintMaker *make) {
            make.top.bmmas_equalTo(weakSelf.passOnlineTextField.bmmas_bottom).bmmas_offset(kBMScale_H(30));
            make.height.bmmas_equalTo(50);
            make.width.bmmas_equalTo(kBMScale_W(238));
            make.centerX.bmmas_equalTo(0);
        }];
        
        YSSchoolUser *schoolUser = [YSSchoolUser shareInstance];
        if (![schoolUser.domain bm_isNotEmpty])
        {
            [schoolUser getSchoolUserLoginData];
        }
        self.domainTextField.inputTextField.text = schoolUser.domain;
        self.admin_accountTextField.inputTextField.text = schoolUser.userAccount;
        self.passOnlineTextField.inputTextField.text = @"";
        
        self.joinRoomBtn.enabled = YES;
        self.joinRoomBtn.alpha = 1.0;
    }
    else
    {//进入教室
        NSString * roomID = [YSUserDefault getLoginRoomID];
        if ([roomID bm_isNotEmpty])
        {
            self.roomTextField.inputTextField.text = roomID;
        }
        NSString * nickName = [YSUserDefault getLoginNickName];
        if ([nickName bm_isNotEmpty])
        {
            self.nickNameTextField.inputTextField.text = nickName;
        }
        
        [self.logoImageView setImage:YSSkinElementImage(@"login_topImage", @"iconNor")];
//        [self.logoImageView bmmas_remakeConstraints:^(BMMASConstraintMaker *make) {
//            make.centerX.bmmas_equalTo(0);
//            make.top.bmmas_equalTo(kBMScale_H(100));
//            make.height.bmmas_equalTo(kBMScale_W(153));
//            make.width.bmmas_equalTo(kBMScale_W(197));
//        }];

        self.passOnlineTextField.hidden = YES;
        self.domainTextField.hidden = YES;
        self.admin_accountTextField.hidden = YES;
        self.roomTextField.hidden = NO;
        self.nickNameTextField.hidden = NO;
        [self.joinRoomBtn setTitle:YSLoginLocalized(@"Login.EnterRoom") forState:UIControlStateNormal];
        [self.onlineSchoolBtn setTitle:YSLocalizedSchool(@"Button.onlineschool") forState:UIControlStateNormal];
        [self.joinRoomBtn bmmas_remakeConstraints:^(BMMASConstraintMaker *make) {
            make.top.bmmas_equalTo(weakSelf.nickNameTextField.bmmas_bottom).bmmas_offset(kBMScale_H(30));
            make.height.bmmas_equalTo(50);
            make.width.bmmas_equalTo(kBMScale_W(238));
            make.centerX.bmmas_equalTo(0);
        }];

        roomID = self.roomTextField.inputTextField.text;
        nickName = self.nickNameTextField.inputTextField.text;
        if ([roomID bm_isNotEmpty] && [nickName bm_isNotEmpty])
        {
            self.joinRoomBtn.enabled = YES;
            self.joinRoomBtn.alpha = 1.0;
        }
        else
        {
            self.joinRoomBtn.enabled = NO;
            self.joinRoomBtn.alpha = 0.3;
        }
    }
}

- (void)clickAction:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

- (void)getSchoolPublicKey
{
    NSString *domain = [self.domainTextField.inputTextField.text bm_trimAllSpace];
    if ([domain bm_containString:@"."])
    {
        if (![domain bm_isValidDomain])
        {
            [self.progressHUD bm_hideAnimated:NO];
            
            NSString *content = YSLocalizedSchool(@"Error.DomainError");
            [BMAlertView ys_showAlertWithTitle:content message:nil cancelTitle:YSLocalizedSchool(@"Prompt.OK") completion:nil];
            return;
        }
        
        YSLiveManager *liveManager = [YSLiveManager sharedInstance];
        liveManager.schoolApiHost = domain;
    }
    else
    {
        YSLiveManager *liveManager = [YSLiveManager sharedInstance];
        liveManager.schoolApiHost = YSSchool_Server;
    }
    
    NSString *account = self.admin_accountTextField.inputTextField.text;
    [Bugly setUserValue:@"" forKey:@"rommId"];
    [Bugly setUserValue:@"" forKey:@"userId"];
    [Bugly setUserValue:@"" forKey:@"nickName"];
    [Bugly setUserValue:account forKey:@"userAccount"];

    BMAFHTTPSessionManager *manager = [YSApiRequest makeYSHTTPSessionManager];
    NSMutableURLRequest *request = [YSLiveApiRequest getSchoolPublicKey];
    if (request)
    {
        BMWeakSelf
        NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
                NSString *errorMessage;
                if ([YSCoreStatus currentNetWorkStatus] == YSCoreNetWorkStatusNone)
                {
                    errorMessage = YSLoginLocalized(@"Error.WaitingForNetwork");//@"网络错误，请稍后再试";
                }
                else
                {
                    errorMessage = YSLoginLocalized(@"Error.CanNotConnectNetworkError");//@"服务器繁忙，请稍后再试";
                }

#if YSShowErrorCode
                [weakSelf.progressHUD bm_showAnimated:NO withDetailText:[NSString stringWithFormat:@"%@: %@", @(error.code), error.localizedDescription] delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
#else
                [weakSelf.progressHUD bm_showAnimated:NO withDetailText:errorMessage delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
#endif
            }
            else
            {
                NSDictionary *dataDic = [BMCloudHubUtil convertWithData:responseObject];
                if ([dataDic bm_isNotEmptyDictionary])
                {
                    NSInteger statusCode = [dataDic bm_intForKey:YSSuperVC_StatusCode_Key];
                    if (statusCode == YSSuperVC_StatusCode_Succeed)
                    {
                        NSString *key = [dataDic bm_stringForKey:@"key"];
                        if ([key bm_isNotEmpty])
                        {
                            NSString *randomKey = [NSString bm_randomStringWithLength:10];
                            weakSelf.randomKey = randomKey;
                            [weakSelf loginSchoolWithPubKey:key randomKey:randomKey];

                            return;
                        }
                    }
#if YSShowErrorCode
                    else
                    {
                        NSString *message = [dataDic bm_stringTrimForKey:YSSuperVC_ErrorMessage_key withDefault:YSLocalizedSchool(@"Error.ServerError")];
                        message = [NSString stringWithFormat:@"%@: %@", @(statusCode), message];
                        [weakSelf.progressHUD bm_showAnimated:NO withDetailText:message delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
                        return;
                    }
#endif
                }
                
                [weakSelf.progressHUD bm_showAnimated:NO withDetailText:YSLoginLocalized(@"Error.ServerError") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
            }
        }];
        [task resume];
    }
    else
    {
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLoginLocalized(@"Error.ServerError") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
}

- (void)loginSchoolWithPubKey:(NSString *)key randomKey:(NSString *)randomKey
{
    BMAFHTTPSessionManager *manager = [YSApiRequest makeYSHTTPSessionManager];
    NSMutableURLRequest *request =
        [YSLiveApiRequest postLoginWithPubKey:key
                                       domain:[self.domainTextField.inputTextField.text bm_trimAllSpace]
                                admin_account:self.admin_accountTextField.inputTextField.text
                                    admin_pwd:self.passOnlineTextField.inputTextField.text
                                    randomKey:randomKey];
    if (request)
    {
        BMWeakSelf
        NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
                                
                NSString *errorMessage;
                if ([YSCoreStatus currentNetWorkStatus] == YSCoreNetWorkStatusNone)
                {
                    errorMessage = YSLoginLocalized(@"Error.WaitingForNetwork");//@"网络错误，请稍后再试";
                }
                else
                {
                    errorMessage = YSLoginLocalized(@"Error.CanNotConnectNetworkError");//@"服务器繁忙，请稍后再试";
                }

#if YSShowErrorCode
                [weakSelf.progressHUD bm_showAnimated:NO withDetailText:[NSString stringWithFormat:@"%@: %@", @(error.code), error.localizedDescription] delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
#else
                [weakSelf.progressHUD bm_showAnimated:NO withDetailText:errorMessage delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
#endif
            }
            else
            {
                [weakSelf.progressHUD bm_hideAnimated:NO];
                
                NSDictionary *responseDic = [BMCloudHubUtil convertWithData:responseObject];
                
#ifdef DEBUG
                NSString *str = [[NSString stringWithFormat:@"%@", responseDic] bm_convertUnicode];
                NSLog(@"%@", str);
#endif
                if ([responseDic bm_isNotEmptyDictionary])
                {
                    NSInteger statusCode = [responseDic bm_intForKey:YSSuperVC_StatusCode_Key];
                    if (statusCode == YSSuperVC_StatusCode_Succeed)
                    {
                        YSSchoolUser *schoolUser = [YSSchoolUser shareInstance];
                        schoolUser.domain = [weakSelf.domainTextField.inputTextField.text bm_trimAllSpace];
                        schoolUser.userAccount = weakSelf.admin_accountTextField.inputTextField.text;
                        //schoolUser.userPassWord = weakSelf.passOnlineTextField.inputTextField.text;
                        schoolUser.randomKey = self.randomKey;
                        
                        NSDictionary *dataDic = [responseDic bm_dictionaryForKey:@"data"];
                        [schoolUser updateWithServerDic:dataDic];
                        
                        if ([schoolUser.userId bm_isNotEmpty] && [schoolUser.token bm_isNotEmpty])
                        {
                            [schoolUser saveSchoolUserLoginData];

                            YSTabBarViewController *tabBar = [[YSTabBarViewController alloc] initWithDefaultItems];
                            [tabBar addViewControllers];
                            tabBar.modalPresentationStyle = UIModalPresentationFullScreen;
                            [self presentViewController:tabBar animated:YES completion:^{
                            }];

                            return;
                        }
                    }
#if YSShowErrorCode
                    else
                    {
                        NSString *message = [responseDic bm_stringTrimForKey:YSSuperVC_ErrorMessage_key withDefault:YSLocalizedSchool(@"Error.ServerError")];
                        message = [NSString stringWithFormat:@"%@: %@", @(statusCode), message];
                        [weakSelf.progressHUD bm_showAnimated:NO withDetailText:message delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
                        return;
                    }
#endif

                    NSString *info = [responseDic bm_stringForKey:@"info"];
                    [weakSelf.progressHUD bm_showAnimated:NO withDetailText:info delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
                }
                else
                {
                    [weakSelf.progressHUD bm_showAnimated:NO withDetailText:YSLoginLocalized(@"Error.ServerError") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
                }
            }
        }];
        [task resume];
    }
    else
    {
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLoginLocalized(@"Error.ServerError") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
}

- (void)joinRoomBtnClicked:(UIButton *)btn
{
//    if (![YSUserDefault getUserAgreement])
//    {
//        [BMAlertView ys_showAlertWithTitle:YSLocalized(@"Agreement.Alert") message:nil cancelTitle:YSLocalizedSchool(@"Prompt.OK") completion:nil];
//        return;
//    }
//
    if (![YSCoreStatus isNetworkEnable])
    {
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLoginLocalized(@"Error.WaitingForNetwork") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
        return;
    }

    if (self.isOnlineSchool)
    {
        if (![[self.domainTextField.inputTextField.text bm_trimAllSpace] bm_isNotEmpty])
        {
            //没有输入机构域名
            NSString *content =  YSLocalizedSchool(@"Prompt.NoDomain");
            [BMAlertView ys_showAlertWithTitle:content message:nil cancelTitle:YSLocalizedSchool(@"Prompt.OK") completion:nil];
            return;
        }
        if (![self.admin_accountTextField.inputTextField.text bm_isNotEmpty])
        {
            //没有输入账号
            NSString *content =  YSLocalizedSchool(@"Prompt.NoAccountl");
            [BMAlertView ys_showAlertWithTitle:content message:nil cancelTitle:YSLocalizedSchool(@"Prompt.OK") completion:nil];
            return;
        }
        
        if (![self.passOnlineTextField.inputTextField.text bm_isNotEmpty])
        {
            //没有输入密码
            NSString *content =  YSLocalizedSchool(@"Prompt.NoPassword");
            [BMAlertView ys_showAlertWithTitle:content message:nil cancelTitle:YSLocalizedSchool(@"Prompt.OK") completion:nil];
            return;
        }

        ///查看摄像头权限
        BOOL isCamera = [self cameraPermissionsService];
        ///查看麦克风权限
        BOOL isOpenMicrophone = [self microphonePermissionsService];
        /// 扬声器权限
        BOOL isReproducer = [YSUserDefault getReproducerPermission];
        
        //    isOpenMicrophone = NO;
        if (!isOpenMicrophone || !isCamera || !isReproducer)
        {            
            YSPermissionsVC *vc = [[YSPermissionsVC alloc] init];
            
            BMWeakSelf
            vc.toJoinRoom = ^{
                [weakSelf.progressHUD bm_showAnimated:NO showBackground:YES];
                [weakSelf getSchoolPublicKey];
            };
            [self.navigationController pushViewController:vc animated:NO];
            return;
        }
        
        [self.progressHUD bm_showAnimated:NO showBackground:YES];

        [self getSchoolPublicKey];
        
        return;
    }
    
    NSString *roomId = [self.roomTextField.inputTextField.text bm_trimAllSpace];
    NSString *nickName = self.nickNameTextField.inputTextField.text;
    
#if USE_YSLIVE_ROOMID
    if (![roomId bm_isNotEmpty])
    {
        NSUInteger roomIndex = ((NSNumber *)YSLIVE_ROOMIDINDEX).integerValue;
        NSDictionary *roomIdDic = [YSTestHelp roomIdArray][roomIndex];
        roomId = roomIdDic[@"roomid"];
        self.roomTextField.inputTextField.text = roomId;
    }
    if (![nickName bm_isNotEmpty])
    {
        nickName = @"iOS";
        self.nickNameTextField.inputTextField.text = nickName;
    }
#else
    
    /**信息检查*/
    if (![roomId bm_isNotEmpty])
    {
        //教室号不能为空
        NSString *content =  YSLoginLocalized(@"Prompt.RoomIDNotNull");
        [BMAlertView ys_showAlertWithTitle:content message:nil cancelTitle:YSLoginLocalized(@"Prompt.OK") completion:nil];
        return;
    }
    
    if (![nickName bm_isNotEmpty])
    {
        // 昵称不能为空
        NSString *content = YSLoginLocalized(@"Prompt.nicknameNotNull");
        [BMAlertView ys_showAlertWithTitle:content message:nil cancelTitle:YSLoginLocalized(@"Prompt.OK") completion:nil];
        return;
    }
    
#endif
    
    self.needCheckPermissions = YES;

    //检查房间类型
//    if ([UIDevice bm_isiPad])
//    {
        [self checkRoomType];
//    }
//    else
//    {
//        [self joinRoom];
//    }
}

- (BOOL)checkKickTimeWithRoomId:(NSString *)roomId
{
    if (self.selectRoleType == CHUserType_Student)
    {
        // 学生被T 3分钟内不能登录
        NSString *roomIdKey = [NSString stringWithFormat:@"%@_%@", YSKickTime, roomId];
        
        id idTime = [[NSUserDefaults standardUserDefaults] objectForKey:roomIdKey];
        if (idTime && [idTime isKindOfClass:NSDate.class])
        {
            NSDate *time = (NSDate *)idTime;
            NSDate *curTime = [NSDate date];
            // 计算出相差多少秒
            NSTimeInterval delta = [curTime timeIntervalSinceDate:time];
            
            if (delta < 60 * 3)
            {
                NSString *content =  YSLoginLocalized(@"Prompt.kick");
                [BMAlertView ys_showAlertWithTitle:content message:nil cancelTitle:nil completion:nil];
                return NO;
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:roomIdKey];
            }
        }
    }
    
    return YES;
}


#pragma mark - 检查房间类型
- (void)checkRoomType
{
    [self.progressHUD bm_showAnimated:NO showBackground:YES];
    
    BMWeakSelf
    BMAFHTTPSessionManager *manager = [BMAFHTTPSessionManager manager];
    NSMutableURLRequest *request = [YSLiveApiRequest checkRoomTypeWithRoomId:self.roomTextField.inputTextField.text];
    request.timeoutInterval = 30.0f;
    if (request)
    {
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
            @"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript",
            @"text/xml"
        ]];
    
        NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            [weakSelf.progressHUD bm_hideAnimated:NO];
            if (error)
            {
                NSString *errorMessage;
                if ([YSCoreStatus currentNetWorkStatus] == YSCoreNetWorkStatusNone)
                {
                    errorMessage = YSLoginLocalized(@"Error.WaitingForNetwork");//@"网络错误，请稍后再试";
                }
                else
                {
                    errorMessage = YSLoginLocalized(@"Error.CanNotConnectNetworkError");//@"服务器繁忙，请稍后再试";
                }

#if YSShowErrorCode
                [weakSelf.progressHUD bm_showAnimated:NO withDetailText:[NSString stringWithFormat:@"%@: %@", @(error.code), error.localizedDescription] delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
#else
                [weakSelf.progressHUD bm_showAnimated:NO withDetailText:errorMessage delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
#endif
            }
            else
            {
                [self.progressHUD bm_hideAnimated:NO];
                
                NSDictionary *responseDic = [BMCloudHubUtil convertWithData:responseObject];

                if (![responseDic bm_isNotEmptyDictionary])
                {
                    [weakSelf.progressHUD bm_showAnimated:NO withDetailText:YSLoginLocalized(@"Error.ServerError") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
                    return;
                }

                NSInteger result = [responseDic bm_intForKey:@"result"];
                if (result == CHErrorCode_CheckRoom_RoomFreeze || result == CHErrorCode_CheckRoom_RoomDeleteOrOrverdue ||  result == CHErrorCode_CheckRoom_RoomNonExistent)
                {
                    NSString *descript = [YSLiveUtil getOccuredErrorCode:result];
#if YSShowErrorCode
                    NSString *errorMessage = [NSString stringWithFormat:@"%@: %@", @(result), descript];
#else
                    NSString *errorMessage = descript;
#endif

                    [weakSelf.progressHUD bm_showAnimated:NO withDetailText:errorMessage delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
                    return;
                }
                else if (result != 0)
                {
                    weakSelf.callNum ++;
                    if (weakSelf.callNum<3)
                    {
                        [weakSelf checkRoomType];
                    }
                    else
                    {
                        NSString *message = [responseDic bm_stringTrimForKey:YSSuperVC_ErrorMessage_key withDefault:YSLocalizedSchool(@"Error.ServerError")];
#if YSShowErrorCode
                        message = [NSString stringWithFormat:@"%@: %@", @(result), message];
#endif
                        [weakSelf.progressHUD bm_showAnimated:NO withDetailText:message delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];

                        weakSelf.callNum = 0;
                    }
                    return;
                }
                
                NSDictionary * dataDict = [responseDic bm_dictionaryForKey:@"data"];
                // 'roomtype'=>房间类型3小班课，4直播，6会议
                weakSelf.room_UseTheType = [dataDict bm_intForKey:@"roomtype"];
                
                weakSelf.needpwd = [dataDict bm_boolForKey:@"needpwd"];
                
                // grouproom 房间分组类型 0 普通房间，1 分组主（父）房间，2 分组子房间
                weakSelf.grouproom = [dataDict bm_intForKey:@"grouproom"];
                
                if (weakSelf.needpwd)
                {
                    self.passwordTextField.placeholder = YSLoginLocalized(@"Prompt.inputPwd");
                    self.passwordMask.hidden = YES;
                }
                else
                {
                    self.passwordTextField.placeholder = YSLoginLocalized(@"Prompt.noneedPwd");
                    self.passwordMask.hidden = NO;
                }
                                
                switch (weakSelf.room_UseTheType)
                {
                    // 小班课
                    case 3:
                        weakSelf.room_UseTheType = CHRoomUseTypeSmallClass;

                        [weakSelf showRoleSelectView];

                        [weakSelf.view endEditing:YES];
                        weakSelf.passwordTextField.inputTextField.text = nil;
                        
                        return;
                    // 直播
                    case 4:
                        weakSelf.room_UseTheType = CHRoomUseTypeLiveRoom;
                        [weakSelf joinRoom];
                        return;
                    // 会议室
                    case 6:
                        weakSelf.room_UseTheType = CHRoomUseTypeMeeting;
                        [weakSelf showRoleSelectView];
                        [weakSelf.view endEditing:YES];
                        weakSelf.passwordTextField.inputTextField.text = nil;
                        return;
                        
                    default:
                        break;
                }
            }
        }];
        [task resume];
    }
    else
    {
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLoginLocalized(@"Error.ServerError") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
}

- (void)joinRoom
{
    //进入教室
    [self.view endEditing:YES];
    
    NSString *roomId = [self.roomTextField.inputTextField.text bm_trimAllSpace];
    NSString *nickName = self.nickNameTextField.inputTextField.text;
    NSString *passWordStr = self.passwordTextField.inputTextField.text;
    
    if (![self checkKickTimeWithRoomId:roomId])
    {
        return;
    }

    if (self.grouproom > CHRoomGroupType_Normal && (self.grouproom == CHRoomGroupType_GroupSub && self.selectRoleType == CHUserType_Teacher))
    {
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLocalized(@"Error.JoinGroupRoom") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
        return;
    }
    
    YSLiveManager *liveManager = [YSLiveManager sharedInstance];
    [liveManager registerRoomDelegate:self];
    liveManager.apiHost = YSLIVE_HOST;
#if YS_CHANGE_WHITEBOARD_BACKGROUND
    if (BMIS_IPHONE)
    {
       [liveManager setWhiteBoardBackGroundColor:nil maskImage:[UIImage imageNamed:@"whiteboardmask_iphone"]];
    }
    else
    {
        [liveManager setWhiteBoardBackGroundColor:nil maskImage:[UIImage imageNamed:@"whiteboardmask_ipad"]];
    }
#endif

    if ([passWordStr bm_isNotEmpty])
    {
        [liveManager initializeWhiteBoardWithWithHost:liveManager.apiHost port:YSLive_Port nickName:nickName roomId:roomId roomPassword:passWordStr userRole:self.selectRoleType userId:nil userParams:nil];
    }
    else
    {
        [liveManager initializeWhiteBoardWithWithHost:liveManager.apiHost port:YSLive_Port nickName:nickName roomId:roomId roomPassword:nil userRole:self.selectRoleType userId:nil userParams:nil];
    }
    
    self.needCheckPermissions = YES;
    
    self.selectedRoleBtn.selected = NO;
    self.passwordMask.hidden = NO;
    self.passwordTextField.inputTextField.text = nil;
    self.selectedRoleBtn = self.studentRoleBtn;
    self.selectedRoleBtn.selected = YES;
    self.selectRoleType = CHUserType_Student;
    
    [self.progressHUD bm_showAnimated:NO showBackground:YES];
}

// URL打开登录
- (void)joinRoomWithRoomId:(NSString *)roomId
{
    self.roomTextField.inputTextField.text = roomId;
}

// URL直接进入房间
- (BOOL)joinRoomWithRoomParams:(NSDictionary *)roomParams userParams:(NSDictionary *)userParams
{
    [self.view endEditing:YES];
    
    YSLiveManager *liveManager = [YSLiveManager sharedInstance];
    [liveManager registerRoomDelegate:self];
#if YS_CHANGE_WHITEBOARD_BACKGROUND
    if (BMIS_IPHONE)
    {
        [liveManager setWhiteBoardBackGroundColor:nil maskImage:[UIImage imageNamed:@"whiteboardmask_iphone"]];
    }
    else
    {
        [liveManager setWhiteBoardBackGroundColor:nil maskImage:[UIImage imageNamed:@"whiteboardmask_ipad"]];
    }
#endif

    [liveManager initializeWhiteBoardWithWithHost:liveManager.apiHost port:YSLive_Port nickName:@"" roomParams:roomParams userParams:userParams];
    
    [self.progressHUD bm_showAnimated:NO showBackground:YES];
    
    return YES;
}

- (void)onClickEye:(UIButton*)sender
{
//    YSEyeCareVC *eyeCareVC = [[YSEyeCareVC alloc] init];
//    [self.navigationController pushViewController:eyeCareVC animated:YES];
    YSSetViewController * setViewController = [[YSSetViewController alloc]init];
    [self.navigationController pushViewController:setViewController animated:YES];
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
        _backImageView.backgroundColor = YSSkinDefineColor(@"Color3");
//        [_backImageView setImage:YSSkinElementImage(@"login_background", @"iconNor")];
        _backImageView.userInteractionEnabled = YES;
    }
    return _backImageView;
}

// 房间号输入框
- (YSInputView *)roomTextField
{
    if (!_roomTextField)
    {
        _roomTextField = [[YSInputView alloc] initWithFrame:CGRectZero withPlaceholder:YSLoginLocalized(@"Label.roomPlaceholder") withImage:YSSkinElementImage(@"login_roomNum", @"iconNor")];
        _roomTextField.inputTextField.delegate = self;
        _roomTextField.inputTextField.tag = 101;
        _roomTextField.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
        _roomTextField.delegate = self;
    }
    return _roomTextField;
}

// 昵称输入框
- (YSInputView *)nickNameTextField
{
    if (!_nickNameTextField)
    {
        _nickNameTextField = [[YSInputView alloc] initWithFrame:CGRectZero withPlaceholder:YSLoginLocalized(@"Label.nicknamePlaceholder") withImage:YSSkinElementImage(@"login_userName", @"iconNor")];
        _nickNameTextField.inputTextField.delegate = self;
        _nickNameTextField.inputTextField.tag = 102;
        _nickNameTextField.delegate = self;
    }
    return _nickNameTextField;
}

/// 密码输入框
- (YSInputView *)passwordTextField
{
    if (!_passwordTextField)
    {
        _passwordTextField = [[YSInputView alloc] initWithFrame:CGRectMake(76, 171, 348, 40) withPlaceholder:YSLoginLocalized(@"Prompt.inputPwd") withImage:YSSkinElementImage(@"login_password", @"iconNor")];
        _passwordTextField.inputTextField.keyboardType = UIKeyboardTypeDefault;
        _passwordTextField.inputTextField.secureTextEntry = YES;
        _passwordTextField.inputTextField.clearButtonMode = UITextFieldViewModeNever;
        _passwordTextField.layer.cornerRadius = 20;
        _passwordTextField.layer.borderWidth = 1;
        _passwordTextField.layer.borderColor = [UIColor bm_colorWithHex:0x82ABEC].CGColor;
        _passwordTextField.delegate = self;
        _passwordTextField.lineView.hidden = YES;
        if (![UIDevice bm_isiPad]) {
            self.passwordTextField.frame = CGRectMake((350-300)/2, 171, 300, 40);
        }
        
        UIImageView *passImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
        passImg.contentMode = UIViewContentModeCenter;
        [passImg setImage:YSSkinElementImage(@"login_passImg", @"iconNor")];
        _passwordTextField.inputTextField.leftView = passImg;
        _passwordTextField.inputTextField.leftViewMode = UITextFieldViewModeAlways;
        
        UIButton * eyeBtn = [[UIButton alloc]initWithFrame:CGRectMake(_passwordTextField.bm_width-40, 0, 40, 40)];
        [eyeBtn setImage:YSSkinElementImage(@"login_passEye", @"iconNor") forState:UIControlStateNormal];
        [eyeBtn setImage:YSSkinElementImage(@"login_passEye", @"iconSel") forState:UIControlStateSelected];
        [eyeBtn addTarget:self action:@selector(changeSecureTextEntry:) forControlEvents:UIControlEventTouchUpInside];
        [_passwordTextField addSubview:eyeBtn];
        
        UIView * passwordMask = [[UIView alloc]initWithFrame:_passwordTextField.bounds];
        passwordMask.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        self.passwordMask = passwordMask;
        [_passwordTextField addSubview:passwordMask];
    }
    return _passwordTextField;
}

// 房间号输入框
- (YSInputView *)domainTextField
{
    if (!_domainTextField)
    {
        _domainTextField = [[YSInputView alloc] initWithFrame:CGRectZero withPlaceholder:YSLocalizedSchool(@"Label.onlineSchoolPlaceholder") withImage:YSSkinElementImage(@"login_roomNum", @"iconNor")];
        _domainTextField.inputTextField.delegate = self;
        _domainTextField.inputTextField.tag = 1001;
        _domainTextField.inputTextField.keyboardType = UIKeyboardTypeDefault;
        _domainTextField.delegate = self;
    }
    return _domainTextField;
}


// 昵称输入框
- (YSInputView *)admin_accountTextField
{
    if (!_admin_accountTextField)
    {
        _admin_accountTextField = [[YSInputView alloc] initWithFrame:CGRectZero withPlaceholder:YSLocalizedSchool(@"Label.accountNumberPlaceholder") withImage:YSSkinElementImage(@"login_userName", @"iconNor")];
        _admin_accountTextField.inputTextField.delegate = self;
        _admin_accountTextField.inputTextField.tag = 1002;
        _admin_accountTextField.delegate = self;
    }
    return _admin_accountTextField;
}


- (YSInputView *)passOnlineTextField
{
    if (!_passOnlineTextField)
    {
        _passOnlineTextField = [[YSInputView alloc] initWithFrame:CGRectMake(76, 171, 348, 40) withPlaceholder:YSLoginLocalized(@"Prompt.inputPwd") withImage:YSSkinElementImage(@"login_password", @"iconNor")];
        _passOnlineTextField.inputTextField.keyboardType = UIKeyboardTypeDefault;
        _passOnlineTextField.inputTextField.secureTextEntry = YES;
        _passOnlineTextField.inputTextField.clearButtonMode = UITextFieldViewModeNever;

        if (![UIDevice bm_isiPad]) {
            self.passOnlineTextField.frame = CGRectMake((350-300)/2, 171, 300, 40);
        }
        
        self.passwordEyeBtn = [[UIButton alloc]initWithFrame:CGRectMake(_passOnlineTextField.bm_width-40, 0, 40, 40)];
                
        [self.passwordEyeBtn setImage:YSSkinElementImage(@"login_rowPassword", @"iconNor") forState:UIControlStateNormal];
        [self.passwordEyeBtn setImage:YSSkinElementImage(@"login_rowPassword", @"iconSel") forState:UIControlStateSelected];
        [self.passwordEyeBtn addTarget:self action:@selector(changeSecureTextEntry:) forControlEvents:UIControlEventTouchUpInside];
        
        [_passOnlineTextField addSubview:self.passwordEyeBtn];

    }
    return _passOnlineTextField;
}

- (void)changeSecureTextEntry:(UIButton *)button
{
    button.selected = !button.selected;
    
    if (self.isOnlineSchool)
    {
        self.passOnlineTextField.inputTextField.secureTextEntry = !button.selected;
    }
    else
    {
        self.passwordTextField.inputTextField.secureTextEntry = !button.selected;
    }
}

/// 选择角色的view
- (UIView *)roleSelectView
{
    if (!_roleSelectView)
    {
        _roleSelectView = [[UIView alloc]initWithFrame:self.view.bounds];
        _roleSelectView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        [self.backImageView addSubview:_roleSelectView];
        
        //弹框
//        UIImageView * alertView = [[UIImageView alloc]initWithFrame:CGRectMake((BMUI_SCREEN_WIDTH-500)/2, (BMUI_SCREEN_HEIGHT-330)/2, 500, 330)];
//      alertView.image = [UIImage imageNamed:@"roleAlertBackImage"];
//        alertView.layer.cornerRadius = 26;
//        alertView.layer.masksToBounds = YES;
//        alertView.userInteractionEnabled = YES;
//        [self.roleSelectView addSubview:alertView];
        
        UIView * alertView = [[UIView alloc]initWithFrame:CGRectMake((BMUI_SCREEN_WIDTH-500)/2, (BMUI_SCREEN_HEIGHT-330)/2, 500, 330)];
        alertView.backgroundColor = UIColor.whiteColor;
        alertView.layer.cornerRadius = 26;
        alertView.layer.masksToBounds = YES;
        alertView.userInteractionEnabled = YES;
        [self.roleSelectView addSubview:alertView];
        
        
        
        if (![UIDevice bm_isiPad])
        {
            alertView.frame = CGRectMake((BMUI_SCREEN_WIDTH-350)/2, 100, 350, 330);
        }
        
        //删除按钮
        UIButton * cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(alertView.bm_width-50, 0, 50, 50)];
        cancelBtn.tag = 0;
        [cancelBtn setImage:YSSkinDefineImage(@"cancel_btn_icon_select") forState:UIControlStateNormal];
        [cancelBtn setBackgroundColor:UIColor.clearColor];
        [cancelBtn addTarget:self action:@selector(roleViewBtnsClick:) forControlEvents:UIControlEventTouchUpInside];
        [alertView addSubview:cancelBtn];
        
        UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
        titleLab.text = YSLoginLocalized(@"Label.choiceIdentity");
        titleLab.font = UI_FONT_18;
        titleLab.textColor = YSSkinDefineColor(@"PlaceholderColor");
        titleLab.textAlignment = NSTextAlignmentCenter;
        [alertView addSubview:titleLab];
        titleLab.bm_centerX = alertView.bm_width/2;
        
        UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, titleLab.bm_bottom, alertView.bm_width, 0.8)];
        lineView.backgroundColor = YSSkinDefineColor(@"Color7");
        lineView.alpha = 0.14;
        [alertView addSubview:lineView];
        
        //密码输入框
        [alertView addSubview:self.passwordTextField];
        
        //身份按钮个数
        NSInteger buttonNum = 3;
        NSInteger leftMargin = 50;
        
        CGFloat margin = (500-2*leftMargin-buttonNum*100)/(buttonNum+1);
               
        if (![UIDevice bm_isiPad]) {
            
            margin = (350-buttonNum*100)/(buttonNum+1);
        }
        
        for (int i = 0; i<buttonNum; i++)
        {
            UIButton * button = nil;
            
            if (![UIDevice bm_isiPad]) {
                
                button = [[UIButton alloc]initWithFrame:CGRectMake(margin + i*(margin+100), 93, 100, 40)];
            }
            else
            {
                button = [[UIButton alloc]initWithFrame:CGRectMake(leftMargin + margin + i*(margin+100), 93, 100, 40)];
            }
            
            [alertView addSubview:button];
            
            if (self.room_UseTheType == CHRoomUseTypeMeeting)
            {
                if (i == 0)
                {
                    [button setTitle:YSLoginLocalized(@"Role.Host") forState:UIControlStateNormal];
                    self.teacherRoleBtn = button;
                    
                }
                else if (i == 1)
                {
                    [button setTitle:YSLoginLocalized(@"Role.Attendee") forState:UIControlStateNormal];
                    button.selected = YES;
                    self.selectedRoleBtn = button;
                    self.studentRoleBtn = button;
                    
                }
                else if (i == 2)
                {
                    [button setTitle:YSLoginLocalized(@"Role.PatrolMeeting") forState:UIControlStateNormal];
                    self.patrolRoleBtn = button;
                }
            }
            else
            {
                if (i == 0)
                {
                    [button setTitle:YSLoginLocalized(@"Role.Teacher") forState:UIControlStateNormal];
                    self.teacherRoleBtn = button;
                }
                else if (i == 1)
                {
                    [button setTitle:YSLoginLocalized(@"Role.Student") forState:UIControlStateNormal];
                    button.selected = YES;
                    self.selectedRoleBtn = button;
                    self.studentRoleBtn = button;
                }
                else if (i == 2)
                {
                    [button setTitle:YSLoginLocalized(@"Role.Patrol") forState:UIControlStateNormal];
                    self.patrolRoleBtn = button;
                }
                else if (i == 3)
                {
                    
                }
            }
            
            button.titleLabel.font = UI_FONT_14;
            [button setTitleColor:YSSkinDefineColor(@"Color4") forState:UIControlStateNormal];
            [button setTitleColor:YSSkinDefineColor(@"Color3") forState:UIControlStateSelected];
            [button setBackgroundImage:YSSkinElementImage(@"login_roleBtn", @"iconNor") forState:UIControlStateNormal];
            [button setBackgroundImage:YSSkinElementImage(@"login_roleBtn", @"iconSel") forState:UIControlStateSelected];
            button.titleLabel.font = UI_FONT_18;
            button.layer.cornerRadius = 20;
            button.tag = i+1;
            [button addTarget:self action:@selector(roleViewBtnsClick:) forControlEvents:UIControlEventTouchUpInside];
        }
            
        //确定按钮
        UIButton * okBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, alertView.bm_height-77, 147, 40)];
        okBtn.bm_centerX = alertView.bm_width/2;
        
        [okBtn setTitle:YSLoginLocalized(@"Prompt.OK") forState:UIControlStateNormal];
        okBtn.titleLabel.font = UI_FONT_18;
        [okBtn setTitleColor:YSSkinDefineColor(@"Color3") forState:UIControlStateNormal];
        [okBtn addTarget:self action:@selector(okBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [alertView addSubview:okBtn];
        
        [okBtn setBackgroundColor:YSSkinDefineColor(@"Color4")];
        okBtn.layer.cornerRadius = 20;
        okBtn.layer.masksToBounds = YES;
    }
    return _roleSelectView;
}

- (void)showRoleSelectView
{
    self.passwordMask.hidden = self.needpwd;
    
    self.roleSelectView.hidden = NO;
    if (self.room_UseTheType == CHRoomUseTypeMeeting)
    {
            [self.studentRoleBtn setTitle:YSLoginLocalized(@"Role.Attendee") forState:UIControlStateNormal];
            [self.teacherRoleBtn setTitle:YSLoginLocalized(@"Role.Host") forState:UIControlStateNormal];
            [self.patrolRoleBtn setTitle:YSLoginLocalized(@"Role.PatrolMeeting") forState:UIControlStateNormal];
    }
    else
    {
        [self.studentRoleBtn setTitle:YSLoginLocalized(@"Role.Student") forState:UIControlStateNormal];
        [self.teacherRoleBtn setTitle:YSLoginLocalized(@"Role.Teacher") forState:UIControlStateNormal];
        [self.patrolRoleBtn setTitle:YSLoginLocalized(@"Role.Patrol") forState:UIControlStateNormal];
    }
}

- (void)okBtnClick
{
    self.roleSelectView.hidden = YES;

    [self joinRoom];
}

/// 选择角色的点击事件
- (void)roleViewBtnsClick:(UIButton *)sender
{
    if (sender.tag == 0)
    {
        self.selectedRoleBtn.selected = NO;
        self.passwordMask.hidden = NO;
//        self.passwordTextField.inputTextField.text = nil;
        self.selectedRoleBtn = self.studentRoleBtn;
        self.selectedRoleBtn.selected = YES;
        self.roleSelectView.hidden = YES;
        self.selectRoleType = CHUserType_Student;
    }
    else
    {
        self.selectedRoleBtn.selected = NO;
        sender.selected = YES;
        self.selectedRoleBtn = sender;
    }
    
    [self.view endEditing:YES];
    
    self.passwordTextField.inputTextField.text = nil;
    self.passwordTextField.placeholder = YSLoginLocalized(@"Prompt.inputPwd");
    
    switch (sender.tag)
    {

        case 1:
            self.selectRoleType = CHUserType_Teacher;
            self.passwordMask.hidden = YES;
            break;
        case 2:

            self.selectRoleType = CHUserType_Student;
            if (self.needpwd)
            {
                self.passwordMask.hidden = YES;
            }
            else
            {
                self.passwordTextField.placeholder = YSLoginLocalized(@"Prompt.noneedPwd");
                self.passwordMask.hidden = NO;
            }
            break;
        case 3:
            self.selectRoleType = CHUserType_Patrol;
            self.passwordMask.hidden = YES;

            break;
        default:
            break;
    }
}

- (UIImageView *)logoImageView
{
    if (!_logoImageView)
    {
        _logoImageView = [[UIImageView alloc] init];
        [_logoImageView setImage:YSSkinElementImage(@"login_topImage", @"iconNor")];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _logoImageView;
}

- (UILabel *)bottomVersionL
{
    if (!_bottomVersionL)
    {
        _bottomVersionL = [[UILabel alloc] init];
        _bottomVersionL.font = UI_FSFONT_MAKE(FontNamePingFangSCRegular, 12);
        _bottomVersionL.textColor = [UIColor bm_colorWithHex:0x6D7278];
        //_bottomVersionL.textAlignment = NSTextAlignmentCenter;
        
    }
    return _bottomVersionL;
}

- (UIButton *)joinRoomBtn
{
    if (!_joinRoomBtn)
    {
        _joinRoomBtn = [UIButton bm_buttonWithFrame:CGRectMake(0, 0, 100, 50) color:YSSkinDefineColor(@"Color4") highlightedColor:[UIColor bm_colorWithHex:0x336CC7] disableColor:[UIColor bm_colorWithHex:0x97B7EB]];
        [_joinRoomBtn setTitle:[NSString stringWithFormat:@"%@",YSLoginLocalized(@"Login.EnterRoom")] forState:UIControlStateNormal];
        
        [_joinRoomBtn setTitleColor:YSSkinDefineColor(@"Color3") forState:UIControlStateNormal];
        _joinRoomBtn.titleLabel.textAlignment =  NSTextAlignmentCenter;
        _joinRoomBtn.titleLabel.font = UI_FSFONT_MAKE(FontNamePingFangSCMedium, 16);
//        [_joinRoomBtn bm_addShadow:4.0f Radius:25.0f BorderColor:[UIColor bm_colorWithHex:0x9DB7E7] ShadowColor:[UIColor lightGrayColor]];
        

#if USE_YSLIVE_ROOMID
        _joinRoomBtn.enabled = YES;
        _joinRoomBtn.alpha = 1.0;
        
#else
        _joinRoomBtn.enabled = NO;
        _joinRoomBtn.alpha = 0.3;
#endif
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
    if (!self.isOnlineSchool)
    {
        if (self.roomTextField.inputTextField.text.length > 0 && self.nickNameTextField.inputTextField.text.length > 0)
        {
            self.joinRoomBtn.enabled = YES;
            self.joinRoomBtn.alpha = 1.0;
        }
        else
        {
#if USE_YSLIVE_ROOMID
            self.joinRoomBtn.enabled = YES;
            self.joinRoomBtn.alpha = 1.0;
#else
            self.joinRoomBtn.enabled = NO;
            self.joinRoomBtn.alpha = 0.3;
#endif
        }
    }
    if (textField.tag ==102 )
    {
        NSInteger existTextNum = textField.text.length;
        if (existTextNum == 1 && [textField.text isEqualToString:@" "])
        {
            //existTextNum = 0;
            textField.text = @"";
        }
        else if (existTextNum > 10)
        {
            //截取到最大位置的字符
            NSString *s = [textField.text substringToIndex:10];
            [textField setText:s];
            
            [self.progressHUD bm_showAnimated:NO withDetailText:YSLoginLocalized(@"Alert.NumberOfWords.10") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
        }
    }
}


#pragma mark -
#pragma mark YSRoomInterfaceDelegate

- (void)waitRoomLeft:(YSRoomLeftDoBlock)doSometing
{
    [self.progressHUD bm_showAnimated:NO showBackground:YES];
    [[YSLiveManager sharedInstance] leaveRoom:nil];
    if (doSometing)
    {
        doSometing();
    }
}


#pragma mark -  成功进入房间

- (void)onRoomDidCheckRoom
{
    BMLog(@"YSLoginVC onRoomDidCheckRoom");
    
    [YSUserDefault setLoginRoomID:[self.roomTextField.inputTextField.text bm_trimAllSpace]];
    [YSUserDefault setLoginNickName:[self.nickNameTextField.inputTextField.text bm_trimAllSpace]];

    YSLiveManager *liveManager = [YSLiveManager sharedInstance];
    
    NSString *roomId = liveManager.room_Id ? liveManager.room_Id : @"";
    NSString *userId = liveManager.localUser.peerID ? liveManager.localUser.peerID : @"";
    NSString *nickName = liveManager.localUser.nickName ? liveManager.localUser.nickName : @"";

    [Bugly setUserValue:roomId forKey:@"rommId"];
    [Bugly setUserValue:userId forKey:@"userId"];
    [Bugly setUserValue:nickName forKey:@"nickName"];
    [Bugly setUserValue:@"NO" forKey:@"userAccount"];
    
    
    CHRoomUseType appUseTheType = liveManager.room_UseType;
    // 未通过check进入房间时
    if (self.room_UseTheType == 0)
    {
        self.room_UseTheType = appUseTheType;
    }
           
    // 3: 小班课  4: 直播  6： 会议
    BOOL isSmallClass = (self.room_UseTheType == CHRoomUseTypeSmallClass || self.room_UseTheType == CHRoomUseTypeMeeting);
    
    if (isSmallClass)
    {
        [YSLiveSkinManager shareInstance].skinBundle = [CHSessionManager sharedInstance].skinBundle;
        
        [YSLiveSkinManager shareInstance].isSmallVC = YES;
        
        [self smallClassJoinRoomSuccess];
    }
    else
    {
        [self.progressHUD bm_hideAnimated:NO];
        
        GetAppDelegate.allowRotation = NO;
        BOOL isWideScreen = liveManager.room_IsWideScreen;
        YSMainVC *mainVC = [[YSMainVC alloc] initWithWideScreen:isWideScreen whiteBordView:liveManager.whiteBordView userId:nil];
        mainVC.appUseTheType = self.room_UseTheType;
        BMNavigationController *nav = [[BMNavigationController alloc] initWithRootViewController:mainVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        nav.popOnBackButtonHandler = [YSSuperVC getPopOnBackButtonHandler];
        [self presentViewController:nav animated:YES completion:^{
            [[YSEyeCareManager shareInstance] freshWindowWithShowStatusBar:NO isRientationPortrait:YES];
        }];
        
        [YSEyeCareManager shareInstance].showRemindBlock = ^{
            [mainVC showEyeCareRemind];
        };
        
        [[YSEyeCareManager shareInstance] stopRemindtime];
        if ([YSLiveManager sharedInstance].roomConfig.isRemindEyeCare)
        {
            [[YSEyeCareManager shareInstance] startRemindtime];
        }
    }
}

///小班课跳转教室界面
- (void)smallClassJoinRoomSuccess
{
    [self.progressHUD bm_hideAnimated:NO];
    YSLiveManager *liveManager = [YSLiveManager sharedInstance];
            
    GetAppDelegate.allowRotation = YES;
    NSUInteger maxvideo = [liveManager.roomDic bm_uintForKey:@"maxvideo"];
    CHRoomUserType roomusertype = liveManager.roomModel.roomUserType;
    
    BOOL isWideScreen = liveManager.room_IsWideScreen;
    
    if (liveManager.localUser.role == CHUserType_Teacher)
    {
        YSTeacherRoleMainVC *mainVC = [[YSTeacherRoleMainVC alloc] initWithRoomType:roomusertype isWideScreen:isWideScreen maxVideoCount:maxvideo whiteBordView:liveManager.whiteBordView userId:nil];
        mainVC.appUseTheType = self.room_UseTheType;
        BMNavigationController *nav = [[BMNavigationController alloc] initWithRootViewController:mainVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        nav.popOnBackButtonHandler = [YSSuperVC getPopOnBackButtonHandler];
        [self presentViewController:nav animated:NO completion:^{
            [[YSEyeCareManager shareInstance] freshWindowWithShowStatusBar:NO isRientationPortrait:NO];
        }];
        [YSEyeCareManager shareInstance].showRemindBlock = ^{
            [mainVC showEyeCareRemind];
        };
    }
    else
    {
       SCMainVC *mainVC = [[SCMainVC alloc] initWithRoomType:roomusertype isWideScreen:isWideScreen maxVideoCount:maxvideo whiteBordView:liveManager.whiteBordView userId:nil];
        mainVC.appUseTheType = self.room_UseTheType;
        BMNavigationController *nav = [[BMNavigationController alloc] initWithRootViewController:mainVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        nav.popOnBackButtonHandler = [YSSuperVC getPopOnBackButtonHandler];
        [self presentViewController:nav animated:NO completion:^{
            [[YSEyeCareManager shareInstance] freshWindowWithShowStatusBar:NO isRientationPortrait:NO];
        }];
        
        [YSEyeCareManager shareInstance].showRemindBlock = ^{
            [mainVC showEyeCareRemind];
        };
    }
    
    self.selectedRoleBtn.selected = NO;
    self.passwordMask.hidden = NO;
    self.passwordTextField.inputTextField.text = nil;
    self.selectedRoleBtn = self.studentRoleBtn;
    self.selectedRoleBtn.selected = YES;
    self.roleSelectView.hidden = YES;
    self.selectRoleType = CHUserType_Student;
    
    [[YSEyeCareManager shareInstance] stopRemindtime];
    if ([YSLiveManager sharedInstance].roomConfig.isRemindEyeCare)
    {
        [[YSEyeCareManager shareInstance] startRemindtime];
    }
    
}


/// 进入房间失败
- (void)roomManagerNeedEnterPassWord:(CHRoomErrorCode)errorCode
{
    [self.progressHUD bm_hideAnimated:NO];

    [YSLiveManager destroy];

    self.needCheckPermissions = NO;
    
    BMWeakSelf
    if (errorCode == CHErrorCode_CheckRoom_PasswordError ||
        errorCode == CHErrorCode_CheckRoom_WrongPasswordForRole)
    {
        [BMAlertView ys_showAlertWithTitle:YSLoginLocalized(@"Error.PwdError") message:nil cancelTitle:YSLoginLocalized(@"Prompt.OK") completion:^(BOOL cancelled, NSInteger buttonIndex) {
             [weakSelf theRoomNeedPassword];
        }];
    }
    else
    {
        [self theRoomNeedPassword];
    }
}

- (void)theRoomNeedPassword
{
    // 需要密码
     if ( self.room_UseTheType == CHRoomUseTypeMeeting || self.room_UseTheType == CHRoomUseTypeSmallClass)
    {
//        self.roleSelectView.hidden = NO;
        [self showRoleSelectView];
    }
    else
    {
        BMWeakSelf
        [YSPassWordAlert showPassWordInputAlerWithTopDistance:(BMUI_SCREEN_HEIGHT - 210)/2 inView:self.view backgroundEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0) sureBlock:^(NSString * _Nonnull passWord) {
            BMLog(@"%@",passWord);
            //[YSLiveManager destroy];
            
            YSLiveManager *liveManager = [YSLiveManager sharedInstance];
            [liveManager registerRoomDelegate:self];
#if YS_CHANGE_WHITEBOARD_BACKGROUND
            if (BMIS_IPHONE)
            {
                [liveManager setWhiteBoardBackGroundColor:nil maskImage:[UIImage imageNamed:@"whiteboardmask_iphone"]];
            }
            else
            {
                [liveManager setWhiteBoardBackGroundColor:nil maskImage:[UIImage imageNamed:@"whiteboardmask_ipad"]];
            }
#endif

            [liveManager initializeWhiteBoardWithWithHost:liveManager.apiHost port:YSLive_Port nickName:weakSelf.nickNameTextField.inputTextField.text roomId:weakSelf.roomTextField.inputTextField.text roomPassword:passWord userRole:CHUserType_Student userId:nil userParams:nil];
            
            [weakSelf.progressHUD bm_showAnimated:NO showBackground:YES];
        } dismissBlock:^(id  _Nullable sender, NSUInteger index) {
            //if (index == 0)
            //{
            //    [YSLiveManager destroy];
            //}
        }];
    }
}

/// 进入房间失败
- (void)onRoomJoinFailed:(NSDictionary *)errorDic
{
    NSError *error = [errorDic objectForKey:@"error"];
    CHRoomErrorCode errorCode = error.code;
    NSString *descript = [YSLiveUtil getOccuredErrorCode:errorCode];
//
    NSLog(@"================================== onRoomJoinFailed: %@, %@", @(errorCode), descript);
    
    if (errorCode == CHErrorCode_CheckRoom_NeedPassword ||
        errorCode == CHErrorCode_CheckRoom_PasswordError ||
        errorCode == CHErrorCode_CheckRoom_WrongPasswordForRole)
    {
        [self roomManagerNeedEnterPassWord:errorCode];
        return;
    }
    
#if YSShowErrorCode
    NSString *errorMessage = [NSString stringWithFormat:@"%@: %@", @(errorCode), descript];
#else
    NSString *errorMessage = descript;
#endif
    
    [self.progressHUD bm_showAnimated:NO withDetailText:errorMessage delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
    
    [YSLiveManager destroy];

#if 0
#if YSShowErrorCode
    self.leftHUDmessage = [NSString stringWithFormat:@"%@: %@", @(errorCode), descript];
#else
    self.leftHUDmessage = descript;
#endif
    
    [self waitRoomLeft:nil];
#endif
}

- (void)onRoomConnectionLost
{
    NSLog(@"================================== onRoomConnectionLost");

    [self waitRoomLeft:nil];

//    [self.progressHUD bm_showAnimated:NO withDetailText:YSLoginLocalized(@"Error.ServerError") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
//
//    [YSLiveManager destroy];
}

/// 发生错误 回调
- (void)onRoomDidOccuredError:(CloudHubErrorCode)errorCode withMessage:(NSString *)message
{
    NSLog(@"================================== onRoomDidOccuredError: %@", message);
    
#if YSShowErrorCode
    NSString *errorMessage = [NSString stringWithFormat:@"%@: %@", @(errorCode), message];
#else
    NSString *errorMessage = message;
#endif
    
    [self.progressHUD bm_showAnimated:NO withDetailText:errorMessage delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
}

// 已经离开房间
- (void)onRoomLeft
{
    NSLog(@"================================== onRoomLeft");
    
    NSString *errorMessage;
#if 0
    if (self.leftHUDmessage)
    {
        errorMessage = self.leftHUDmessage;
    }
    else
#endif
    {
        if ([YSCoreStatus currentNetWorkStatus] == YSCoreNetWorkStatusNone)
        {
            errorMessage = YSLoginLocalized(@"Error.WaitingForNetwork");//@"网络错误，请稍后再试";
        }
        else
        {
            errorMessage = YSLoginLocalized(@"Error.CanNotConnectNetworkError");//@"服务器繁忙，请稍后再试";
        }
    }

    [self.progressHUD bm_showAnimated:NO withDetailText:errorMessage delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];

#if 0
    self.leftHUDmessage = nil;
#endif
    
    [YSLiveManager destroy];
}


- (void)logoutOnlineSchool
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    
    self.passOnlineTextField.inputTextField.text = @"";
}


///查看麦克风权限
- (BOOL)microphonePermissionsService
{
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    return permissionStatus == AVAudioSessionRecordPermissionGranted;
}
///查看摄像头权限
- (BOOL)cameraPermissionsService
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return authStatus == AVAuthorizationStatusAuthorized;
}

- (void)addBeautyView
{
    UIButton *beautyButton = [[UIButton alloc]initWithFrame:CGRectMake(50, 150, 100, 50)];
    [beautyButton setBackgroundColor:UIColor.yellowColor];
    [beautyButton setTitle:@"美颜按钮" forState:UIControlStateNormal];
    [beautyButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [self.view addSubview:beautyButton];
    [beautyButton addTarget:self action:@selector(beautyButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)beautyButtonClick
{
    if (!self.beautyView)
    {
        self.beautyView = [[CHBeautyControlView alloc]initWithFrame:CGRectMake(0, self.view.bm_height, self.view.bm_width, 0)];
        [self.view addSubview:self.beautyView];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        if (self.beautyView.bm_originY == self.view.bm_height)
        {
            self.beautyView.bm_originY = self.view.bm_height - self.beautyView.bm_height - 60;
        }
        else
        {
            self.beautyView.bm_originY = self.view.bm_height;
        }
    }];
}

@end

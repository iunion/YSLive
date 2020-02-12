
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

#import "YSEyeCareVC.h"
#import "YSEyeCareManager.h"

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

#if USE_TEST_HELP
#define USE_YSLIVE_ROOMID 1
#define CLEARCHECK 1
#endif

#define ONLINESCHOOL 1

/// 每次打包的递增版本号 +1
#define YSAPP_CommitVersion [[NSBundle mainBundle] infoDictionary][@"YSAppCommitVersion"]

#define ThemeKP(args) [@"Alert." stringByAppendingString:args]

@interface YSLoginVC ()
<
    YSLiveRoomManagerDelegate,
    UITextFieldDelegate,
    YSInputViewDelegate
>

@property (nonatomic, assign) YSAppUseTheType room_UseTheType;

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
/// 网校密码输入框
@property (nonatomic, strong) YSInputView *passOnlineTextField;
/// 网校系统
@property (nonatomic, strong) UILabel *onlineSchoolTitle;

///获取房间类型时，探测接口的调用次数
@property (nonatomic, assign) NSInteger  callNum;

///学生是否需要密码
@property (nonatomic, assign) BOOL needpwd;

/// 底部版本文字
@property (nonatomic, strong) UILabel *bottomVersionL;
/// 进入教室按钮
@property (nonatomic, strong) UIButton *joinRoomBtn;

@property (nonatomic, assign) NSInteger role;
/// 默认服务
@property (nonatomic, strong) NSString *defaultServer;

/// 选择角色的弹框view
@property (nonatomic, strong) UIView *roleSelectView;
/// 底部的角色type
@property (nonatomic, assign) YSUserRoleType selectRoleType;

/// 学生角色button
@property (nonatomic, strong) UIButton *studentRoleBtn;
/// 老师角色button
@property (nonatomic, strong) UIButton *teacherRoleBtn;
/// 助教角色button
@property (nonatomic, strong) UIButton *assistantRoleBtn;

/// 选中的角色button
@property (nonatomic, strong) UIButton *selectedRoleBtn;
/// 进入网校
@property (nonatomic, strong) UIButton *onlineSchoolBtn;
// 网络等待
@property (nonatomic, strong) BMProgressHUD *m_ProgressHUD;
@property (nonatomic, assign) BOOL isOnlineSchool;

@property (nonatomic, strong) NSString *randomKey;

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
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[YSEyeCareManager shareInstance] stopRemindtime];
    [[YSEyeCareManager shareInstance] freshWindowWithShowStatusBar:YES isRientationPortrait:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)even
{
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getAppStoreNewVersion];
    
    self.selectRoleType = YSUserType_Student;
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
        
    self.m_ProgressHUD = [[BMProgressHUD alloc] initWithView:self.view];
    self.m_ProgressHUD.animationType = BMProgressHUDAnimationFade;
    [self.view addSubview:self.m_ProgressHUD];
    
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
    }
    else
    {
        self.joinRoomBtn.enabled = NO;
    }
#endif

    [self showEyeCareRemind];
    
    [self getServerTime];
    
    if (self.loginUrl)
    {
        NSDictionary *dic = [[YSLiveManager shareInstance] resolveJoinRoomParamsWithUrl:self.loginUrl];
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
//    NSString *urlstr = @"joinroom://rddoccdndemows.roadofcloud.com/static/h5_live_2.1.1.16/index.html/?host=release.roadofcloud.com&domain=xzj&param=oQWJiPESSSloUJYW_eebY4yhaXjcSeaZpBOt-tb2Cin88FjhbovGoYEX4dwrhvbuqYDqikDGwcB2bh3nMEiDhD7Vf-GmIxIs_tB_CdQZIiQrcC3ZIkUOS6NH9ks6LYfKu33bWttb7llfvnUU8_0C3A&timestamp=1581314212&roomtype=3&logintype=2&video=320*180&companyidentify=1";
        //NSString *urlstr = @"joinroom://?host=api.roadofcloud.net&domain=wjy&param=JxMe2Nu5uY9Bb5C_hStqSGuavpYFRNVVeHLFDFPH-R_q7cduxOZzR4i7XX3TqgytZtMeGuLhBSaXK4Gw6IXs7YZZQLFGu5SyULxpCxSfIJ6vuff28NGkwAq19EcpO7lBOAbgZ6Iv5XgJs26-2lNy4pZxaiTiGVbXAre7LrqaoVk&timestamp=1581327248&roomtype=3&logintype=2&video=200*150&companyidentify=1";
    NSString *urlstr = @"joinroom://?host=api.roadofcloud.net&domain=wjy&param=JxMe2Nu5uY-l_bzNjinmoaeL6LbNaatpEnJM0sSUj6In0bo9pmxZMFqVdhpay2ki8fgtSO-azH9m0x4a4uEFJpcrgbDoheztZn7cF4vFUetQvGkLFJ8gnq-59_bw0aTACrX0Ryk7uUE4BuBnoi_leAmzbr7aU3LilnFqJOIZVtcEZHxpqdz3aQ&timestamp=1581500012&roomtype=3&logintype=2&video=200*150&companyidentify=1";
    
    NSURL *url = [NSURL URLWithString:urlstr];
    NSDictionary *dic = [[YSLiveManager shareInstance] resolveJoinRoomParamsWithUrl:url];

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

    
//    [YSUserDefault setReproducerPermission:NO];
}
#endif

#pragma mark 横竖屏

/// 1.决定当前界面是否开启自动转屏，如果返回NO，后面两个方法也不会被调用，只是会支持默认的方向
- (BOOL)shouldAutorotate
{
    return NO;
}

/// 2.返回支持的旋转方向
/// iPad设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
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
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:YSLocalized(@"EyeProtection.AlertTitle") message:YSLocalized(@"EyeProtection.AlertMsg") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"EyeProtection.Btnsetup") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            YSEyeCareVC *eyeCareVC = [[YSEyeCareVC alloc] init];
            [weakSelf.navigationController pushViewController:eyeCareVC animated:YES];
        }];
        UIAlertAction *cancleAc = [UIAlertAction actionWithTitle:YSLocalized(@"EyeProtection.BtnKnow") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertVc addAction:cancleAc];
        [alertVc addAction:confimAc];
        [self presentViewController:alertVc animated:YES completion:nil];
    }
}

/// 获取服务器时间
- (void)getServerTime
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
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
                
                NSDictionary *responseDic = [YSLiveUtil convertWithData:responseObject];
                if ([responseDic bm_containsObjectForKey:@"time"])
                {
                    NSTimeInterval timeInterval = [responseDic bm_doubleForKey:@"time"];
                    BMLog(@"服务器当前时间： %@", [NSDate bm_stringFromTs:timeInterval]);
                }
#endif
            }
        }];
        [task resume];
    }
}


#pragma mark -- 获取商店的版本

- (void)getAppStoreNewVersion
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@",YS_APPID]]];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // 请求的数据转字典，必须判断数据有值才走里面，不然空的data会出现crash
        if (data.length > 0) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSString *newVersion = [result[@"results"] firstObject][@"version"];
            NSString *oldVersion = APP_VERSIONNO;
            if ([newVersion compare: oldVersion] == NSOrderedDescending)
            {
                [self checkUpdate];
            }
        }
    }];
    [task resume];
}

- (void)checkUpdate
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *commitVersion = YSAPP_CommitVersion;
    
    [manager.requestSerializer setTimeoutInterval:30];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
        @"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript",
        @"text/xml"
    ]];
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/ClientAPI/getupdateinfo", YSLive_Http, [YSLiveManager shareInstance].liveHost];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
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
        NSDictionary *responseDic = [YSLiveUtil convertWithData:responseObject];
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
        [self showUpdateAlertWithTitle:YSLocalized(@"Alert.UpdateTitle") downLink:downString needUpdata:needUpdata];
        
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
        message = YSLocalized(@"Alert.UpdateForceMessage");
        style = UIAlertActionStyleDestructive;
    }
    else
    {
        message = YSLocalized(@"Alert.UpdateMessage");
        style = UIAlertActionStyleDefault;
    }
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalized(@"Alert.UpdateNow") style:style handler:^(UIAlertAction * _Nonnull action) {
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
        UIAlertAction *ccc = [UIAlertAction actionWithTitle:YSLocalized(@"Alert.UpdateAfter") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVc addAction:ccc];
    }
    [self presentViewController:alertVc animated:YES completion:nil];
}


#pragma mark - UI

- (void)setupUI
{
    BMWeakSelf
    [self.view addSubview:self.backScrollView];
    self.backScrollView.frame = CGRectMake(0, 0,UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
    self.backScrollView.contentSize = CGSizeMake(UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
    
    if (@available(iOS 11.0, *))
    //if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0)
    {
        self.backScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.backImageView.frame = CGRectMake(0, 0,UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
    self.backImageView.backgroundColor = [UIColor redColor];
    [self.backScrollView addSubview:self.backImageView];
    //    [self.backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.edges.mas_equalTo(0);
    //    }];
    //
    UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAction:)];
    [self.backImageView addGestureRecognizer:click];
    
    [self.backImageView addSubview:self.logoImageView];
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        //        make.top.mas_equalTo(kScale_H(130));
        make.top.mas_equalTo(kScale_H(100));
        make.height.mas_equalTo(kScale_W(153));
        make.width.mas_equalTo(kScale_W(197));
    }];
    
    
    UILabel *onlineSchoolTitle = [[UILabel alloc] init];
    onlineSchoolTitle.font = [UIFont systemFontOfSize:16];
    onlineSchoolTitle.textColor = [UIColor bm_colorWithHex:0x6D7278];
    onlineSchoolTitle.textAlignment = NSTextAlignmentCenter;
    onlineSchoolTitle.hidden = YES;
    onlineSchoolTitle.text = YSLocalized(@"Label.onlineSchoolSystem");
    self.onlineSchoolTitle = onlineSchoolTitle;
    [self.backImageView addSubview:onlineSchoolTitle];
    [self.onlineSchoolTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kScale_W(28));
        make.right.mas_equalTo(-kScale_W(28));
        make.top.mas_equalTo(weakSelf.logoImageView.mas_bottom).mas_offset(kScale_H(5));
        make.height.mas_equalTo(30);
    }];
    
    [self.backImageView addSubview:self.roomTextField];
    [self.roomTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kScale_W(28));
        make.right.mas_equalTo(-kScale_W(28));
        make.top.mas_equalTo(weakSelf.logoImageView.mas_bottom).mas_offset(kScale_H(60));
        make.height.mas_equalTo(40);
    }];
    self.roomTextField.layer.cornerRadius = 20;
    self.roomTextField.layer.borderWidth = 1;
    self.roomTextField.layer.borderColor = [UIColor bm_colorWithHex:0x82ABEC].CGColor;
    
    
    [self.backImageView addSubview:self.nickNameTextField];
    [self.nickNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kScale_W(28));
        make.right.mas_equalTo(-kScale_W(28));
        make.top.mas_equalTo(weakSelf.roomTextField.mas_bottom).mas_offset(kScale_H(30));
        make.height.mas_equalTo(40);
    }];
    self.nickNameTextField.layer.cornerRadius = 20;
    self.nickNameTextField.layer.borderWidth = 1;
    self.nickNameTextField.layer.borderColor = [UIColor bm_colorWithHex:0x82ABEC].CGColor;
    
    [self.backImageView addSubview:self.passOnlineTextField];
    [self.passOnlineTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kScale_W(28));
        make.right.mas_equalTo(-kScale_W(28));
        make.top.mas_equalTo(weakSelf.nickNameTextField.mas_bottom).mas_offset(kScale_H(30));
        make.height.mas_equalTo(40);
    }];
    self.passOnlineTextField.layer.cornerRadius = 20;
    self.passOnlineTextField.layer.borderWidth = 1;
    self.passOnlineTextField.layer.borderColor = [UIColor bm_colorWithHex:0x82ABEC].CGColor;
    self.passOnlineTextField.hidden = YES;
    
    [self.backImageView addSubview:self.bottomVersionL];
    [self.bottomVersionL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(0);
        make.height.mas_equalTo(kScale_H(17));
        make.bottom.mas_equalTo(-kScale_H(17));
    }];
    
#ifdef DEBUG
    NSString *string = [NSString stringWithFormat:@"%@: %@", @"buildNO", APP_BUILDNO];
#else
    //do sth.
    NSString *string = [NSString stringWithFormat:@"%@: %@", @"releaseNO" , APP_VERSIONNO];
#endif
    
    self.bottomVersionL.text = string;
    
    [self.backImageView addSubview:self.joinRoomBtn];
    [self.joinRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.nickNameTextField.mas_bottom).mas_offset(kScale_H(43));
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(kScale_W(238));
        make.centerX.mas_equalTo(0);
    }];
    
    UIButton *eyeBtn = [UIButton bm_buttonWithFrame:CGRectMake(0, 0, 100, 40) image:[UIImage imageNamed:@"eyecaresetup"]];
    [eyeBtn setTitle:YSLocalized(@"EyeProtection.Btnsetup") forState:UIControlStateNormal];
    eyeBtn.titleLabel.font = UI_FONT_12;
    [eyeBtn setTitleColor:[UIColor bm_colorWithHex:0x878E95] forState:UIControlStateNormal];
    [eyeBtn addTarget:self action:@selector(onClickEye:) forControlEvents:UIControlEventTouchUpInside];
    [self.backImageView addSubview:eyeBtn];
    [eyeBtn bm_layoutButtonWithEdgeInsetsStyle:BMButtonEdgeInsetsStyleImageLeft imageTitleGap:2.0f];
    [eyeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(-kScale_H(17));
    }];

    self.joinRoomBtn.layer.cornerRadius = 25;
    self.joinRoomBtn.layer.masksToBounds = YES;
    [self.joinRoomBtn addTarget:self action:@selector(joinRoomBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //    NSString *bundleVersionCode = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    //    NSString *string = [NSString stringWithFormat:@"buildNO: %@", bundleVersionCode];
    //    UILabel *label = [UILabel bm_labelWithFrame:CGRectMake(20, 40, 200, 30) text:string fontSize:14.0 color:[UIColor bm_colorWithHex:0x999999] alignment:NSTextAlignmentLeft lines:1];
    //    [self.backImageView addSubview:label];
        
#if ONLINESCHOOL
    UIButton *onlineSchoolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.onlineSchoolBtn = onlineSchoolBtn;
    [self.backImageView addSubview:onlineSchoolBtn];
    [onlineSchoolBtn setTitle:YSLocalized(@"Button.onlineschool") forState:UIControlStateNormal];
    [onlineSchoolBtn setTitleColor:[UIColor bm_colorWithHex:0x6D7278] forState:UIControlStateNormal];
    onlineSchoolBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [onlineSchoolBtn addTarget:self action:@selector(onlineSchoolBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.onlineSchoolBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.joinRoomBtn.mas_bottom).mas_offset(kScale_H(5));
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(70);
        make.right.mas_equalTo(weakSelf.joinRoomBtn.mas_right);
    }];
#endif
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
        BMWeakSelf
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.backScrollView.contentOffset = CGPointMake(0, offSet);
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

- (void)onlineSchoolBtnClicked:(UIButton *)btn
{
    self.isOnlineSchool = !_isOnlineSchool;
    BMWeakSelf
    if (self.isOnlineSchool)
    {
        BMLog(@"进入网校");
        self.onlineSchoolTitle.hidden = NO;
        self.passOnlineTextField.hidden = NO;
        [self.logoImageView setImage:[UIImage imageNamed:@"onlineSchool_login_icon"]];
        [self.logoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            //        make.top.mas_equalTo(kScale_H(130));
            make.top.mas_equalTo(kScale_H(50));
            make.height.mas_equalTo(kScale_W(153));
            make.width.mas_equalTo(kScale_W(197));
        }];
        self.roomTextField.placeholder = YSLocalized(@"Label.onlineSchoolPlaceholder");
        self.roomTextField.inputTextField.keyboardType = UIKeyboardTypeDefault;
        self.nickNameTextField.placeholder = YSLocalized(@"Label.accountNumberPlaceholder");
        [self.joinRoomBtn setTitle:YSLocalized(@"Login.Enter") forState:UIControlStateNormal];
        [self.onlineSchoolBtn setTitle:YSLocalized(@"Login.EnterRoom") forState:UIControlStateNormal];
        
        [self.joinRoomBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.passOnlineTextField.mas_bottom).mas_offset(kScale_H(43));
            make.height.mas_equalTo(50);
            make.width.mas_equalTo(kScale_W(238));
            make.centerX.mas_equalTo(0);
        }];
        
        YSSchoolUser *schoolUser = [YSSchoolUser shareInstance];
        if (![schoolUser.domain bm_isNotEmpty])
        {
            [schoolUser getSchoolUserLoginData];
        }
        self.roomTextField.inputTextField.text = schoolUser.domain;
        self.nickNameTextField.inputTextField.text = schoolUser.userAccount;
        self.passOnlineTextField.inputTextField.text = @"";
    }
    else
    {
        BMLog(@"进入教室");
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

        self.onlineSchoolTitle.hidden = YES;
        self.passOnlineTextField.hidden = YES;
        [self.logoImageView setImage:[UIImage imageNamed:@"login_icon"]];
        [self.logoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(kScale_H(100));
            make.height.mas_equalTo(kScale_W(153));
            make.width.mas_equalTo(kScale_W(197));
        }];
        self.roomTextField.placeholder = YSLocalized(@"Label.roomPlaceholder");
        self.roomTextField.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
        self.nickNameTextField.placeholder = YSLocalized(@"Label.nicknamePlaceholder");
        [self.joinRoomBtn setTitle:YSLocalized(@"Login.EnterRoom") forState:UIControlStateNormal];
        [self.onlineSchoolBtn setTitle:YSLocalized(@"Button.onlineschool") forState:UIControlStateNormal];
        [self.joinRoomBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.nickNameTextField.mas_bottom).mas_offset(kScale_H(43));
            make.height.mas_equalTo(50);
            make.width.mas_equalTo(kScale_W(238));
            make.centerX.mas_equalTo(0);
        }];

    }

}

- (void)clickAction:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

- (void)getSchoolPublicKey
{
    AFHTTPSessionManager *manager = [YSApiRequest makeYSHTTPSessionManager];
    NSMutableURLRequest *request = [YSLiveApiRequest getSchoolPublicKey];
    if (request)
    {
        BMWeakSelf
        NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
                [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:YSLocalized(@"Error.ServerError") delay:0.5];
            }
            else
            {
                NSDictionary *dataDic = [YSLiveUtil convertWithData:responseObject];
                if ([dataDic bm_isNotEmptyDictionary])
                {
                    NSInteger statusCode = [dataDic bm_intForKey:YSSuperVC_StatusCode_Key];
                    if (statusCode == YSSuperVC_StatusCode_Succeed)
                    {
                        NSString *key = [dataDic bm_stringForKey:@"key"];
                        if ([key bm_isNotEmpty])
                        {
                            NSString *randomKey = [NSString bm_randomStringWithLength:10];
                            self.randomKey = randomKey;
                            [weakSelf loginSchoolWithPubKey:key randomKey:randomKey];

                            return;
                        }
                    }
                }
                
                [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:YSLocalized(@"Error.ServerError") delay:0.5];
            }
        }];
        [task resume];
    }
    else
    {
        [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:YSLocalized(@"Error.ServerError") delay:0.5];
    }
}

- (void)loginSchoolWithPubKey:(NSString *)key randomKey:(NSString *)randomKey
{
    AFHTTPSessionManager *manager = [YSApiRequest makeYSHTTPSessionManager];
    NSMutableURLRequest *request =
        [YSLiveApiRequest postLoginWithPubKey:key
                                       domain:self.roomTextField.inputTextField.text
                                admin_account:self.nickNameTextField.inputTextField.text
                                    admin_pwd:self.passOnlineTextField.inputTextField.text
                                    randomKey:randomKey];
    if (request)
    {
        BMWeakSelf
        NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
                                
                [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:YSLocalized(@"Error.ServerError") delay:0.5];
            }
            else
            {
                [self.m_ProgressHUD bm_hideAnimated:YES];
                
                NSDictionary *responseDic = [YSLiveUtil convertWithData:responseObject];
                
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
                        schoolUser.domain = weakSelf.roomTextField.inputTextField.text;
                        schoolUser.userAccount = weakSelf.nickNameTextField.inputTextField.text;
                        //schoolUser.userPassWord = weakSelf.passOnlineTextField.inputTextField.text;
                        schoolUser.randomKey = self.randomKey;
                        
                        NSDictionary *dataDic = [responseDic bm_dictionaryForKey:@"data"];
                        [schoolUser updateWithServerDic:dataDic];
                        
                        if ([schoolUser.userId bm_isNotEmpty] && [schoolUser.token bm_isNotEmpty])
                        {
                            [schoolUser saveSchoolUserLoginData];

                            YSTabBarViewController *tabBar = [[YSTabBarViewController alloc] initWithDefaultItems];
                            [tabBar addViewControllers];
                            [weakSelf.navigationController pushViewController:tabBar animated:YES];
                            
                            return;
                        }
                    }
                }
                
                [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:YSLocalized(@"Error.ServerError") delay:0.5];
            }
        }];
        [task resume];
    }
    else
    {
        [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:YSLocalized(@"Error.ServerError") delay:0.5];
    }
}

- (void)joinRoomBtnClicked:(UIButton *)btn
{
    if (![YSCoreStatus isNetworkEnable])
    {
        [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:@"请开启网络" delay:0.5];
        return;
    }

    if (self.isOnlineSchool)
    {
        [self.m_ProgressHUD bm_showAnimated:YES showBackground:YES];
        
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
        NSString *content =  YSLocalized(@"Prompt.RoomIDNotNull");
        [BMAlertView ys_showAlertWithTitle:content message:nil cancelTitle:YSLocalized(@"Prompt.OK") completion:nil];
        return;
    }
    
    if (![nickName bm_isNotEmpty])
    {
        // 昵称不能为空
        NSString *content = YSLocalized(@"Prompt.nicknameNotNull");
        [BMAlertView ys_showAlertWithTitle:content message:nil cancelTitle:YSLocalized(@"Prompt.OK") completion:nil];
        return;
    }
    
    if (self.role == YSUserType_Student)
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
                NSString *content =  YSLocalized(@"Prompt.kick");
                [BMAlertView ys_showAlertWithTitle:content message:content cancelTitle:nil completion:nil];
                return;
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:roomIdKey];
            }
        }
    }
#endif
    
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

#pragma mark - 检查房间类型
- (void)checkRoomType
{
    [self.m_ProgressHUD bm_showAnimated:YES showBackground:YES];
    
    BMWeakSelf
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableURLRequest *request = [YSLiveApiRequest checkRoomTypeWithRoomId:self.roomTextField.inputTextField.text];
    request.timeoutInterval = 30.0f;
    if (request)
    {
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
            @"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript",
            @"text/xml"
        ]];
    
        NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            [weakSelf.m_ProgressHUD bm_hideAnimated:NO];
            if (error)
            {
                [weakSelf.m_ProgressHUD bm_showAnimated:YES withText:YSLocalized(@"Error.CanNotConnectNetworkError") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
            }
            else
            {
                [self.m_ProgressHUD bm_hideAnimated:YES];
                
                NSDictionary *responseDic = [YSLiveUtil convertWithData:responseObject];

                if (![responseDic bm_isNotEmptyDictionary])
                {
                    [weakSelf.m_ProgressHUD bm_showAnimated:YES withText:YSLocalized(@"Error.ServerError") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
                    return;
                }

                NSInteger result = [responseDic bm_intForKey:@"result"];
                if (result == 4007)
                {
                    [weakSelf.m_ProgressHUD bm_showAnimated:YES withText:YSLocalized(@"Error.RoomTypeCheckError") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
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
                        [weakSelf.m_ProgressHUD bm_showAnimated:YES withText:YSLocalized(@"Error.CanNotConnectNetworkError") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
                        weakSelf.callNum = 0;
                    }
                    return;
                }
                
                NSDictionary * dataDict = [responseDic bm_dictionaryForKey:@"data"];
                // 'roomtype'=>房间类型3小班课，4直播，6会议
                weakSelf.room_UseTheType = [dataDict bm_intForKey:@"roomtype"];
                
                weakSelf.needpwd = [dataDict bm_boolForKey:@"needpwd"];
                
                if (weakSelf.needpwd)
                {
                    weakSelf.passwordTextField.hidden = NO;
                }
                else
                {
                    weakSelf.passwordTextField.hidden = YES;
                }
                
                switch (weakSelf.room_UseTheType)
                {
                    // 小班课
                    case 3:
                        weakSelf.room_UseTheType = YSAppUseTheTypeSmallClass;
                        
                        if ([UIDevice bm_isiPad])
                        {
                            [weakSelf showRoleSelectView];
                            
                        }
                        else
                        {
                            self.roleSelectView.hidden = YES;
                            [self joinRoom];
                        }
                        
                        [weakSelf.view endEditing:YES];
                        weakSelf.passwordTextField.inputTextField.text = nil;
                        return;
                    // 直播
                    case 4:
                        weakSelf.room_UseTheType = YSAppUseTheTypeLiveRoom;
                        [weakSelf joinRoom];
                        return;
                    // 会议室
                    case 6:
                        weakSelf.room_UseTheType = YSAppUseTheTypeMeeting;
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
        [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:YSLocalized(@"Error.ServerError") delay:0.5];
    }
}

- (void)joinRoom
{
    //进入教室
    [self.view endEditing:YES];
    
    YSLiveManager *liveManager = [YSLiveManager shareInstance];
    [liveManager registerRoomManagerDelegate:self];
    
    NSString *roomId = [self.roomTextField.inputTextField.text bm_trimAllSpace];
    NSString *nickName = self.nickNameTextField.inputTextField.text;
    NSString *passWordStr = self.passwordTextField.inputTextField.text;
    
    if ([passWordStr bm_isNotEmpty])
    {
        [liveManager joinRoomWithHost:liveManager.liveHost port:YSLive_Port nickName:nickName roomId:roomId roomPassword:passWordStr userRole:self.selectRoleType userId:nil userParams:nil];
    }
    else
    {
        [liveManager joinRoomWithHost:liveManager.liveHost port:YSLive_Port nickName:nickName roomId:roomId roomPassword:nil userRole:self.selectRoleType userId:nil userParams:nil];
    }
    
//    self.passwordTextField.hidden = YES;
    self.passwordTextField.inputTextField.text = nil;
    
    [self.m_ProgressHUD bm_showAnimated:YES showBackground:YES];
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
    
    YSLiveManager *liveManager = [YSLiveManager shareInstance];
    [liveManager registerRoomManagerDelegate:self];
    
    [[YSLiveManager shareInstance] joinRoomWithHost:liveManager.liveHost port:YSLive_Port nickName:@"" roomParams:roomParams userParams:userParams];
    
    [self.m_ProgressHUD bm_showAnimated:YES showBackground:YES];
    
    return YES;
}

- (void)onClickEye:(UIButton*)sender
{
    YSEyeCareVC *eyeCareVC = [[YSEyeCareVC alloc] init];
    [self.navigationController pushViewController:eyeCareVC animated:YES];
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

// 房间号输入框
- (YSInputView *)roomTextField
{
    if (!_roomTextField)
    {
        _roomTextField = [[YSInputView alloc] initWithFrame:CGRectZero withPlaceholder:YSLocalized(@"Label.roomPlaceholder") withImageName:@"login_room"];
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
        _nickNameTextField = [[YSInputView alloc] initWithFrame:CGRectZero withPlaceholder:YSLocalized(@"Label.nicknamePlaceholder") withImageName:@"login_name"];
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
        _passwordTextField = [[YSInputView alloc] initWithFrame:CGRectMake(76, 171, 348, 40) withPlaceholder:YSLocalized(@"Prompt.inputPwd") withImageName:@"login_password"];
        _passwordTextField.inputTextField.keyboardType = UIKeyboardTypeDefault;
        _passwordTextField.inputTextField.secureTextEntry = YES;
        _passwordTextField.inputTextField.clearButtonMode = UITextFieldViewModeNever;
        _passwordTextField.layer.cornerRadius = 20;
        _passwordTextField.layer.borderWidth = 1;
        _passwordTextField.layer.borderColor = [UIColor bm_colorWithHex:0x82ABEC].CGColor;

        if (![UIDevice bm_isiPad]) {
            self.passwordTextField.frame = CGRectMake((350-300)/2, 171, 300, 40);
        }
        
        UIButton * eyeBtn = [[UIButton alloc]initWithFrame:CGRectMake(_passwordTextField.bm_width-40, 0, 40, 40)];
        [eyeBtn setImage:[UIImage imageNamed:@"showPassword_no"] forState:UIControlStateNormal];
        [eyeBtn setImage:[UIImage imageNamed:@"showPassword_yes"] forState:UIControlStateSelected];
        [eyeBtn addTarget:self action:@selector(changeSecureTextEntry:) forControlEvents:UIControlEventTouchUpInside];
        [_passwordTextField addSubview:eyeBtn];
    }
    return _passwordTextField;
}

- (YSInputView *)passOnlineTextField
{
    if (!_passOnlineTextField)
    {
        _passOnlineTextField = [[YSInputView alloc] initWithFrame:CGRectMake(76, 171, 348, 40) withPlaceholder:YSLocalized(@"Prompt.inputPwd") withImageName:@"login_password"];
        _passOnlineTextField.inputTextField.keyboardType = UIKeyboardTypeDefault;
        _passOnlineTextField.inputTextField.secureTextEntry = YES;
        _passOnlineTextField.inputTextField.clearButtonMode = UITextFieldViewModeNever;
        _passOnlineTextField.layer.cornerRadius = 20;
        _passOnlineTextField.layer.borderWidth = 1;
        _passOnlineTextField.layer.borderColor = [UIColor bm_colorWithHex:0x82ABEC].CGColor;

        if (![UIDevice bm_isiPad]) {
            self.passOnlineTextField.frame = CGRectMake((350-300)/2, 171, 300, 40);
        }
        
        UIButton * eyeBtn = [[UIButton alloc]initWithFrame:CGRectMake(_passOnlineTextField.bm_width-40, 0, 40, 40)];
        [eyeBtn setImage:[UIImage imageNamed:@"showPassword_no"] forState:UIControlStateNormal];
        [eyeBtn setImage:[UIImage imageNamed:@"showPassword_yes"] forState:UIControlStateSelected];
        [eyeBtn addTarget:self action:@selector(changeSecureTextEntry:) forControlEvents:UIControlEventTouchUpInside];
        [_passOnlineTextField addSubview:eyeBtn];
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

/// 底部选择角色的view
- (UIView *)roleSelectView
{
    if (!_roleSelectView)
    {
        _roleSelectView = [[UIView alloc]initWithFrame:self.view.bounds];
        _roleSelectView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        [self.backImageView addSubview:_roleSelectView];
        
        //弹框
        UIImageView * alertView = [[UIImageView alloc]initWithFrame:CGRectMake((UI_SCREEN_WIDTH-500)/2, (UI_SCREEN_HEIGHT-330)/2, 500, 330)];
        alertView.image = [UIImage imageNamed:@"roleAlertBackImage"];
        alertView.layer.cornerRadius = 26;
        alertView.layer.masksToBounds = YES;
        alertView.userInteractionEnabled = YES;
        [self.roleSelectView addSubview:alertView];
        
        
        if (![UIDevice bm_isiPad]) {
            alertView.frame = CGRectMake((UI_SCREEN_WIDTH-350)/2, 100, 350, 330);
        }
        
        //删除按钮
        UIButton * cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(alertView.bm_width-50, 0, 50, 50)];
        cancelBtn.tag = 0;
        [cancelBtn setImage:[UIImage imageNamed:@"btn_close"] forState:UIControlStateNormal];
        [cancelBtn setBackgroundColor:UIColor.clearColor];
        [cancelBtn addTarget:self action:@selector(roleViewBtnsClick:) forControlEvents:UIControlEventTouchUpInside];
        [alertView addSubview:cancelBtn];
        
        UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
        titleLab.text = YSLocalized(@"Label.choiceIdentity");
        titleLab.font = UI_FONT_18;
        titleLab.textColor = UIColor.whiteColor;
        titleLab.textAlignment = NSTextAlignmentCenter;
        [alertView addSubview:titleLab];
        titleLab.bm_centerX = alertView.bm_width/2;
        
        //密码输入框
        [alertView addSubview:self.passwordTextField];
        
        //身份按钮个数
        NSInteger buttonNum = 2;
        
        CGFloat margin = (500-2*76-buttonNum*100)/(buttonNum+1);
               
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
                button = [[UIButton alloc]initWithFrame:CGRectMake(76+ margin + i*(margin+100), 93, 100, 40)];
            }
            
            [alertView addSubview:button];
            
            if (self.room_UseTheType == YSAppUseTheTypeMeeting) {
                if (i == 0)
                {
                    [button setTitle:YSLocalized(@"Role.Host") forState:UIControlStateNormal];
                    self.teacherRoleBtn = button;
                }
                else if (i == 1)
                {
                    
                    [button setTitle:YSLocalized(@"Role.Attendee") forState:UIControlStateNormal];
                    button.selected = YES;
                    self.selectedRoleBtn = button;
                    self.studentRoleBtn = button;
                }
                else if (i == 2)
                {
                    [button setTitle:YSLocalized(@"Role.Patrol") forState:UIControlStateNormal];
                    self.assistantRoleBtn = button;
                }
            }
            else
            {
                if (i == 0)
                {
                    [button setTitle:YSLocalized(@"Role.Teacher") forState:UIControlStateNormal];
                    self.teacherRoleBtn = button;
                }
                else if (i == 1)
                {
                    [button setTitle:YSLocalized(@"Role.Student") forState:UIControlStateNormal];
                    button.selected = YES;
                    self.selectedRoleBtn = button;
                    self.studentRoleBtn = button;
                }
                else if (i == 2)
                {
                    [button setTitle:YSLocalized(@"Role.Patrol") forState:UIControlStateNormal];
                    self.assistantRoleBtn = button;
                }
            }
            
            button.titleLabel.font = UI_FONT_14;
            [button setTitleColor:[UIColor bm_colorWithHex:0x5A8CDC] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateSelected];
            [button setBackgroundImage:[UIImage imageNamed:@"roleBtnBackImage"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"roleBtnBackImage_select"] forState:UIControlStateSelected];
            button.titleLabel.font = UI_FONT_18;
            button.layer.cornerRadius = 20;
            button.tag = i+1;
            [button addTarget:self action:@selector(roleViewBtnsClick:) forControlEvents:UIControlEventTouchUpInside];
        }
            
        //确定按钮
        UIButton * okBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, alertView.bm_height-77, 147, 50)];
        okBtn.bm_centerX = alertView.bm_width/2;
        [okBtn setBackgroundImage:[UIImage imageNamed:@"login_join_normal"] forState:UIControlStateNormal];
        [okBtn setBackgroundImage:[UIImage imageNamed:@"login_join_disabled"] forState:UIControlStateSelected];
        [okBtn setTitle:YSLocalized(@"Prompt.OK") forState:UIControlStateNormal];
        okBtn.titleLabel.font = UI_FONT_18;
        okBtn.layer.cornerRadius = 25;
        okBtn.layer.masksToBounds = YES;
        [okBtn setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
        [okBtn addTarget:self action:@selector(okBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [alertView addSubview:okBtn];
    }
    return _roleSelectView;
}


- (void)showRoleSelectView
{
    self.roleSelectView.hidden = NO;
    
    if (self.room_UseTheType == YSAppUseTheTypeMeeting)
    {
            [self.studentRoleBtn setTitle:YSLocalized(@"Role.Attendee") forState:UIControlStateNormal];
            [self.teacherRoleBtn setTitle:YSLocalized(@"Role.Host") forState:UIControlStateNormal];
            [self.assistantRoleBtn setTitle:YSLocalized(@"Role.Patrol") forState:UIControlStateNormal];
    }
    else
    {
        [self.studentRoleBtn setTitle:YSLocalized(@"Role.Student") forState:UIControlStateNormal];
        [self.teacherRoleBtn setTitle:YSLocalized(@"Role.Teacher") forState:UIControlStateNormal];
        [self.assistantRoleBtn setTitle:YSLocalized(@"Role.Patrol") forState:UIControlStateNormal];
    }
}

- (void)okBtnClick
{
    self.roleSelectView.hidden = YES;
    
    [self joinRoom];
    
//    self.selectedRoleBtn = self.studentRoleBtn;
//    self.studentRoleBtn.selected = YES;
//    self.teacherRoleBtn.selected = NO;
    
}

/// 选择角色的点击事件
- (void)roleViewBtnsClick:(UIButton *)sender
{
    if (sender.tag == 0)
    {
        self.selectedRoleBtn.selected = NO;
        self.passwordTextField.hidden = YES;
        self.passwordTextField.inputTextField.text = nil;
        self.selectedRoleBtn = self.studentRoleBtn;
        self.selectedRoleBtn.selected = YES;
        self.roleSelectView.hidden = YES;
        self.selectRoleType = YSUserType_Student;
    }
    else
    {
        self.selectedRoleBtn.selected = NO;
        sender.selected = YES;
        self.selectedRoleBtn = sender;
    }
    
    [self.view endEditing:YES];
    
    switch (sender.tag) {
//        case 0:
//            self.roleSelectView.hidden = YES;
//            self.passwordTextField.hidden = YES;
//            self.passwordTextField.inputTextField.text = nil;
//            self.selectedRoleBtn = self.studentRoleBtn;
//            break;
        case 1:
            self.selectRoleType = YSUserType_Teacher;
            self.passwordTextField.hidden = NO;
            break;
        case 2:
            self.selectRoleType = YSUserType_Student;
            if (self.needpwd)
            {
                self.passwordTextField.hidden = NO;
            }
            else
            {
                self.passwordTextField.hidden = YES;
            }
            break;
        case 3:
            self.selectRoleType = YSUserType_Patrol;
            if (self.needpwd)
            {
                self.passwordTextField.hidden = NO;
            }
            else
            {
                self.passwordTextField.hidden = YES;
            }
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
        [_logoImageView setImage:[UIImage imageNamed:@"login_icon"]];
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
        _bottomVersionL.textAlignment = NSTextAlignmentCenter;
        
    }
    return _bottomVersionL;
}

- (UIButton *)joinRoomBtn
{
    if (!_joinRoomBtn)
    {
        _joinRoomBtn = [UIButton bm_buttonWithFrame:CGRectMake(0, 0, 100, 50) color:[UIColor bm_colorWithHex:0x648CD6] highlightedColor:[UIColor bm_colorWithHex:0x336CC7] disableColor:[UIColor bm_colorWithHex:0x97B7EB]];
        [_joinRoomBtn setTitle:[NSString stringWithFormat:@"%@",YSLocalized(@"Login.EnterRoom")] forState:UIControlStateNormal];
        
        [_joinRoomBtn setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
        [_joinRoomBtn setTitleColor:[UIColor bm_colorWithHex:0x999999] forState:UIControlStateDisabled];
        _joinRoomBtn.titleLabel.textAlignment =  NSTextAlignmentCenter;
        _joinRoomBtn.titleLabel.font = UI_FSFONT_MAKE(FontNamePingFangSCMedium, 16);//UI_FSFONT_MAKE(FontNamePFSCMedium, 18);//(@"PingFang-SC-Medium", 18);
        
        [_joinRoomBtn bm_addShadow:4.0f Radius:25.0f BorderColor:[UIColor bm_colorWithHex:0x9DB7E7] ShadowColor:[UIColor lightGrayColor]];

#if USE_YSLIVE_ROOMID
        _joinRoomBtn.enabled = YES;
#else
        _joinRoomBtn.enabled = NO;
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
    if (self.roomTextField.inputTextField.text.length > 0 && self.nickNameTextField.inputTextField.text.length > 0)
    {
        self.joinRoomBtn.enabled = YES;
    }
    else
    {
#if USE_YSLIVE_ROOMID
        self.joinRoomBtn.enabled = YES;
#else
        self.joinRoomBtn.enabled = NO;
#endif
    }
    
    if (textField.tag ==102)
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
            
            [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:YSLocalized(@"Alert.NumberOfWords.10") delay:0.5];
        }
    }
}


#pragma mark -
#pragma mark YSRoomInterfaceDelegate

// 成功进入房间
- (void)onRoomJoined:(long)ts;
{
    BMLog(@"YSLoginVC onRoomJoined");
    
    [self.m_ProgressHUD bm_hideAnimated:YES];
    
    [YSUserDefault setLoginRoomID:[self.roomTextField.inputTextField.text bm_trimAllSpace]];
    [YSUserDefault setLoginNickName:[self.nickNameTextField.inputTextField.text bm_trimAllSpace]];

    YSLiveManager *liveManager = [YSLiveManager shareInstance];
#if YSCLASS
    
    YSAppUseTheType appUseTheType = liveManager.room_UseTheType;
    // 未通过check进入房间时
    if (self.room_UseTheType == 0)
    {
        self.room_UseTheType = appUseTheType;
    }

    // 3: 小班课  4: 直播  6： 会议
    BOOL isSmallClass = (self.room_UseTheType == YSAppUseTheTypeSmallClass || self.room_UseTheType == YSAppUseTheTypeMeeting);
    
    if (isSmallClass)
    {
        GetAppDelegate.allowRotation = YES;
        NSUInteger maxvideo = [[YSLiveManager shareInstance].roomDic bm_uintForKey:@"maxvideo"];
        YSRoomTypes roomusertype = maxvideo > 2 ? YSRoomType_More : YSRoomType_One;
        
        BOOL isWideScreen = liveManager.room_IsWideScreen;
        
        if (self.selectRoleType == YSUserType_Teacher && (self.room_UseTheType == YSAppUseTheTypeMeeting || ([UIDevice bm_isiPad] && self.room_UseTheType == YSAppUseTheTypeSmallClass))) {
            YSTeacherRoleMainVC *mainVC = [[YSTeacherRoleMainVC alloc] initWithRoomType:roomusertype isWideScreen:isWideScreen maxVideoCount:maxvideo whiteBordView:liveManager.whiteBordView userId:nil];
            mainVC.appUseTheType = self.room_UseTheType;
            BMNavigationController *nav = [[BMNavigationController alloc] initWithRootViewController:mainVC];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            nav.popOnBackButtonHandler = [YSSuperVC getPopOnBackButtonHandler];
            [self presentViewController:nav animated:YES completion:^{
                [[YSEyeCareManager shareInstance] freshWindowWithShowStatusBar:NO isRientationPortrait:NO];
            }];
            [YSEyeCareManager shareInstance].showRemindBlock = ^{
                [mainVC showEyeCareRemind];
            };
            
            self.selectedRoleBtn.selected = NO;
            self.passwordTextField.hidden = YES;
            self.passwordTextField.inputTextField.text = nil;
            self.selectedRoleBtn = self.studentRoleBtn;
            self.selectedRoleBtn.selected = YES;
            self.roleSelectView.hidden = YES;
            self.selectRoleType = YSUserType_Student;
        }
        else
        {
           SCMainVC *mainVC = [[SCMainVC alloc] initWithRoomType:roomusertype isWideScreen:isWideScreen maxVideoCount:maxvideo whiteBordView:liveManager.whiteBordView userId:nil];
            mainVC.appUseTheType = self.room_UseTheType;
            BMNavigationController *nav = [[BMNavigationController alloc] initWithRootViewController:mainVC];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            nav.popOnBackButtonHandler = [YSSuperVC getPopOnBackButtonHandler];
            [self presentViewController:nav animated:YES completion:^{
                [[YSEyeCareManager shareInstance] freshWindowWithShowStatusBar:NO isRientationPortrait:NO];
            }];
            
            [YSEyeCareManager shareInstance].showRemindBlock = ^{
                [mainVC showEyeCareRemind];
            };
        }
    }
    else
#endif
    {
        GetAppDelegate.allowRotation = NO;
        BOOL isWideScreen = liveManager.room_IsWideScreen;
        YSMainVC *mainVC = [[YSMainVC alloc] initWithWideScreen:isWideScreen whiteBordView:liveManager.whiteBordView userId:nil];
        BMNavigationController *nav = [[BMNavigationController alloc] initWithRootViewController:mainVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        nav.popOnBackButtonHandler = [YSSuperVC getPopOnBackButtonHandler];
        [self presentViewController:nav animated:YES completion:^{
            [[YSEyeCareManager shareInstance] freshWindowWithShowStatusBar:NO isRientationPortrait:YES];
        }];
        
        [YSEyeCareManager shareInstance].showRemindBlock = ^{
            [mainVC showEyeCareRemind];
        };
    }
    
    [[YSEyeCareManager shareInstance] stopRemindtime];
    if ([YSLiveManager shareInstance].roomConfig.isRemindEyeCare)
    {
        [[YSEyeCareManager shareInstance] startRemindtime];
    }
}

- (void)roomManagerNeedEnterPassWord:(YSRoomErrorCode)errorCode
{
    [self.m_ProgressHUD bm_hideAnimated:YES];

    [[YSLiveManager shareInstance] destroy];

    BMWeakSelf
    if (errorCode == YSErrorCode_CheckRoom_PasswordError ||
        errorCode == YSErrorCode_CheckRoom_WrongPasswordForRole)
    {
        [BMAlertView ys_showAlertWithTitle:YSLocalized(@"Error.PwdError") message:nil cancelTitle:YSLocalized(@"Prompt.OK") completion:^(BOOL cancelled, NSInteger buttonIndex) {
             [weakSelf theRoomNeedPassword];
        }];
        [[YSLiveManager shareInstance] destroy];
    }
    else
    {
        [self theRoomNeedPassword];
    }
}

- (void)theRoomNeedPassword
{
    // 需要密码
    if ([UIDevice bm_isiPad] || self.room_UseTheType == YSAppUseTheTypeMeeting) {
//        self.roleSelectView.hidden = NO;
        [self showRoleSelectView];
    }
    else
    {
        BMWeakSelf
        [YSPassWordAlert showPassWordInputAlerWithTopDistance:(UI_SCREEN_HEIGHT - 210)/2 inView:self.view backgroundEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0) sureBlock:^(NSString * _Nonnull passWord) {
            BMLog(@"%@",passWord);
            [[YSLiveManager shareInstance] destroy];
            
            YSLiveManager *liveManager = [YSLiveManager shareInstance];
            [liveManager registerRoomManagerDelegate:self];
            
            [liveManager joinRoomWithHost:[YSLiveManager shareInstance].liveHost port:YSLive_Port nickName:weakSelf.nickNameTextField.inputTextField.text roomId:weakSelf.roomTextField.inputTextField.text roomPassword:passWord userRole:YSUserType_Student userId:nil userParams:nil];
            
            [weakSelf.m_ProgressHUD bm_showAnimated:YES showBackground:YES];
        } dismissBlock:^(id  _Nullable sender, NSUInteger index) {
            if (index == 0)
            {
                [[YSLiveManager shareInstance] destroy];
            }
        }];
    }
}

- (void)roomManagerReportFail:(YSRoomErrorCode)errorCode descript:(NSString *)descript
{
    [self.m_ProgressHUD bm_hideAnimated:YES];
    if (![YSCoreStatus isNetworkEnable])
    {
        descript = YSLocalized(@"Prompt.NetworkChanged");
    }
    [BMAlertView ys_showAlertWithTitle:descript message:nil cancelTitle:YSLocalized(@"Prompt.OK") completion:nil];
    
    [[YSLiveManager shareInstance] destroy];
}

- (void)logoutOnlineSchool
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    self.passOnlineTextField.inputTextField.text = @"";
}

@end

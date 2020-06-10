//
//  YSChangePassWordVC.m
//  YSAll
//
//  Created by 宁杰英 on 2020/2/7.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSChangePassWordVC.h"
#import "YSPassWordChangeView.h"
#import "YSLiveApiRequest.h"
#import "AppDelegate.h"

#import "BMAlertView+YSDefaultAlert.h"
#import "YSCoreStatus.h"

#define YSSCHOOLPASSWORD_PATTERN                      @"^[0-9A-Za-z_\\.\\*\\&\\[\\]\\(\\)\%\\$#@]{6,20}$"

@interface YSChangePassWordVC ()
<
    YSPassWordChangeViewDelegate
>

/// 原密码
@property (nonatomic, strong)YSPassWordChangeView *oldPasswordView;
/// 新密码
@property (nonatomic, strong)YSPassWordChangeView *changePasswordView;
/// 确认密码
@property (nonatomic, strong)YSPassWordChangeView *againPasswordView;

@property (nonatomic, strong)UIButton *submitBtn;

@property (nonatomic, strong) NSURLSessionDataTask *changePassWordTask;

@end

@implementation YSChangePassWordVC

- (void)dealloc
{
    [_changePassWordTask cancel];
    _changePassWordTask = nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)even
{
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = YSSkinOnlineDefineColor(@"liveDefaultBgColor");
    
    self.bm_CanBackInteractive = NO;

    self.bm_NavigationItemTintColor = YSSkinOnlineDefineColor(@"login_placeholderColor");
    self.bm_NavigationTitleTintColor = YSSkinOnlineDefineColor(@"login_placeholderColor");
    [self bm_setNavigationWithTitle:YSLocalizedSchool(@"Title.OnlineSchool.ModifyPassWord") barTintColor:YSSkinOnlineDefineColor(@"timer_timeBgColor") leftItemTitle:nil leftItemImage:[UIImage imageNamed:@"navigationbar_back_icon"] leftToucheEvent:@selector(backAction:) rightItemTitle:nil rightItemImage:nil rightToucheEvent:nil];
    
    [self setupUI];
    
    [self bringSomeViewToFront];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

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

- (void)setupUI
{
//    YSPassWordChangeView *oldPasswordView = [[YSPassWordChangeView alloc] initWithFrame:CGRectMake(0, 40, UI_SCREEN_WIDTH, 40) withTitle:YSLocalizedSchool(@"Title.OnlineSchool.OriginalPassword") placeholder:YSLocalizedSchool(@"Prompt.OnlineSchool.oldPassword")];
//    oldPasswordView.delegate = self;
//    self.oldPasswordView = oldPasswordView;
//    [self.view addSubview:self.oldPasswordView];
    
    YSPassWordChangeView *changePasswordView = [[YSPassWordChangeView alloc] initWithFrame:CGRectMake(0, 40, BMUI_SCREEN_WIDTH, 40) withTitle:YSLocalizedSchool(@"Title.OnlineSchool.NewPassword") placeholder:YSLocalizedSchool(@"Prompt.OnlineSchool.changePassword")];
    self.changePasswordView = changePasswordView;
    changePasswordView.delegate = self;
    [self.view addSubview:self.changePasswordView];
    
    YSPassWordChangeView *againPasswordView = [[YSPassWordChangeView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(changePasswordView.frame) + 15, BMUI_SCREEN_WIDTH, 40) withTitle:YSLocalizedSchool(@"Title.OnlineSchool.againPassword") placeholder:YSLocalizedSchool(@"Prompt.OnlineSchool.againPassword")];
    againPasswordView.delegate = self;
    self.againPasswordView = againPasswordView;
    [self.view addSubview:self.againPasswordView];
    
    UIButton *submitBtn = [UIButton bm_buttonWithFrame:CGRectMake(0, 0, 155, 40) color:[UIColor bm_colorWithHex:0x5A8CDC] highlightedColor:[UIColor bm_colorWithHex:0x336CC7] disableColor:[UIColor bm_colorWithHex:0x97B7EB]];
    self.submitBtn = submitBtn;
//    submitBtn.frame = CGRectMake(0, 0, 224, 34);
    submitBtn.bm_centerX = self.view.bm_centerX;
    submitBtn.bm_bottom = self.view.bm_bottom - 30;
    [self.view addSubview:submitBtn];
    [submitBtn setTitle:YSLocalizedSchool(@"Title.OnlineSchool.Submit") forState:UIControlStateNormal];
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    submitBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [submitBtn setTitleColor:YSSkinOnlineDefineColor(@"defaultTitleColor") forState:UIControlStateNormal];
    submitBtn.layer.cornerRadius = 4;
    submitBtn.layer.masksToBounds = YES;
    submitBtn.enabled = NO;
    [submitBtn addTarget:self action:@selector(submitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewWillLayoutSubviews
{
    self.changePasswordView.frame = CGRectMake(0, 40, BMUI_SCREEN_WIDTH, 40);
    self.againPasswordView.frame = CGRectMake(0, CGRectGetMaxY(self.changePasswordView.frame) + 15, BMUI_SCREEN_WIDTH, 40);
    self.submitBtn.frame = CGRectMake(0, 0, 115, 40);
    self.submitBtn.bm_centerX = self.view.bm_centerX;
    self.submitBtn.bm_bottom = self.view.bm_bottom - 30;
}

- (void)submitBtnClicked:(UIButton *)btn
{
    NSString *newPwd = self.changePasswordView.inputTextField.text;
    NSString *confirmPwd = self.againPasswordView.inputTextField.text;
    if (![newPwd bm_isMatchWithPattern:YSSCHOOLPASSWORD_PATTERN])
    {
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLocalizedSchool(@"Error.PwdFormat") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
        
        return;
    }
    if (![confirmPwd bm_isMatchWithPattern:YSSCHOOLPASSWORD_PATTERN])
    {
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLocalizedSchool(@"Error.PwdFormat") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
        
        return;
    }
    
    if (![confirmPwd isEqualToString:newPwd])
    {
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLocalizedSchool(@"Error.PwdLength") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
        
        return;
    }

    [self.progressHUD bm_showAnimated:NO showBackground:YES];
    // 提交密码
     BMAFHTTPSessionManager *manager = [YSApiRequest makeYSHTTPSessionManager];
     NSString *organId = [YSSchoolUser shareInstance].organId;
     
    NSString *mobile = [YSSchoolUser shareInstance].mobile;
    NSMutableURLRequest *request = nil;
    
    YSSchoolUser *schoolUser = [YSSchoolUser shareInstance];
    if (schoolUser.userRoleType == YSUserType_Teacher)
    {
        request = [YSLiveApiRequest postTeacherNewpass:self.changePasswordView.inputTextField.text repass:self.againPasswordView.inputTextField.text teacherid:schoolUser.userId organid:organId];
    }
    else
    {
        request =  [YSLiveApiRequest postStudentUpdatePass:self.changePasswordView.inputTextField.text repass:self.againPasswordView.inputTextField.text studentid:schoolUser.userId organid:organId];
    }
    if (request)
    {
        [self.changePassWordTask cancel];
        self.changePassWordTask = nil;
        
        BMWeakSelf
        self.changePassWordTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
                
                NSString *errorMessage;
                if ([YSCoreStatus currentNetWorkStatus] == YSCoreNetWorkStatusNone)
                {
                    errorMessage = YSLocalized(@"Error.WaitingForNetwork");//@"网络错误，请稍后再试";
                }
                else
                {
                    errorMessage = YSLocalized(@"Error.CanNotConnectNetworkError");//@"服务器繁忙，请稍后再试";
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
                NSDictionary *responseDic = [YSLiveUtil convertWithData:responseObject];
#ifdef DEBUG
                NSString *str = [[NSString stringWithFormat:@"%@", responseDic] bm_convertUnicode];
                NSLog(@"%@", str);
#endif
                if ([responseDic bm_isNotEmptyDictionary])
                {
                    NSInteger resquestCode = [responseDic bm_intForKey:YSSuperVC_StatusCode_Key];
                    if (resquestCode == YSSuperVC_StatusCode_Succeed)
                    {
                        
                        BMWeakSelf
                        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:YSLocalizedSchool(@"Alert.prompt") message:YSLocalizedSchool(@"Alert.passwordSucceed") preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *confimAc = [UIAlertAction actionWithTitle:YSLocalizedSchool(@"Prompt.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [[YSSchoolUser shareInstance] clearUserdata];
                            [GetAppDelegate logoutOnlineSchool];
                        }];

                        [alertVc addAction:confimAc];
                        [self presentViewController:alertVc animated:YES completion:nil];
                        
                    }
                    else
                    {
                        NSString *message = [responseDic bm_stringTrimForKey:YSSuperVC_ErrorMessage_key withDefault:YSLocalized(@"Error.ServerError")];
#if YSShowErrorCode
                        message = [NSString stringWithFormat:@"%@: %@", @(resquestCode), message];
#endif
                        if ([weakSelf checkRequestStatus:resquestCode message:message responseDic:responseDic])
                        {
                            [weakSelf.progressHUD bm_hideAnimated:NO];
                        }
                        else
                        {
                            [weakSelf.progressHUD bm_showAnimated:NO withDetailText:message delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
                        }
                    }
                }
                else
                {
                    [weakSelf.progressHUD bm_showAnimated:NO withDetailText:YSLocalizedSchool(@"Error.ServerError") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
                }
                
            }
        }];
        [self.changePassWordTask resume];
    }
    else
    {
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLocalizedSchool(@"Error.ServerError") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
}

- (void)inpuTextFieldDidChanged:(UITextField *)textField
{
    if (/*self.oldPasswordView.inputTextField.text.length > 0 &&*/ self.changePasswordView.inputTextField.text.length > 0 && self.againPasswordView.inputTextField.text.length > 0)
    {
        self.submitBtn.enabled = YES;
    }
    else
    {
        self.submitBtn.enabled = NO;
    }
}

@end

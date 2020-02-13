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
@end

@implementation YSChangePassWordVC
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)even
{
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bm_colorWithHex:0x9DBEF3];
    self.bm_NavigationItemTintColor = [UIColor whiteColor];
    self.bm_NavigationTitleTintColor = [UIColor whiteColor];
    [self bm_setNavigationWithTitle:YSLocalizedSchool(@"Title.OnlineSchool.ModifyPassWord") barTintColor:[UIColor bm_colorWithHex:0x82ABEC] leftItemTitle:nil leftItemImage:[UIImage imageNamed:@"navigationbar_back_icon"] leftToucheEvent:@selector(backAction:) rightItemTitle:nil rightItemImage:nil rightToucheEvent:nil];
    
//        YSSchoolAVPlayerView *playerView = [[YSSchoolAVPlayerView alloc] init];
//        playerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 100, [UIScreen mainScreen].bounds.size.height - 100);
//        [self.view addSubview:playerView];
//        [playerView settingPlayerItemWithUrl:[NSURL URLWithString:@"https://v-cdn.zjol.com.cn/276982.mp4"]];
//        playerView.transform = CGAffineTransformMakeRotation(M_PI*0.5);
//        playerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 100, [UIScreen mainScreen].bounds.size.height - 100);
    [self setupUI];
    
}

- (void)setupUI
{
//    YSPassWordChangeView *oldPasswordView = [[YSPassWordChangeView alloc] initWithFrame:CGRectMake(0, 40, UI_SCREEN_WIDTH, 40) withTitle:YSLocalizedSchool(@"Title.OnlineSchool.OriginalPassword") placeholder:YSLocalizedSchool(@"Prompt.OnlineSchool.oldPassword")];
//    oldPasswordView.delegate = self;
//    self.oldPasswordView = oldPasswordView;
//    [self.view addSubview:self.oldPasswordView];
    
    YSPassWordChangeView *changePasswordView = [[YSPassWordChangeView alloc] initWithFrame:CGRectMake(0, 40, UI_SCREEN_WIDTH, 40) withTitle:YSLocalizedSchool(@"Title.OnlineSchool.NewPassword") placeholder:YSLocalizedSchool(@"Prompt.OnlineSchool.changePassword")];
    self.changePasswordView = changePasswordView;
    changePasswordView.delegate = self;
    [self.view addSubview:self.changePasswordView];
    
    YSPassWordChangeView *againPasswordView = [[YSPassWordChangeView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(changePasswordView.frame) + 15, UI_SCREEN_WIDTH, 40) withTitle:YSLocalizedSchool(@"Title.OnlineSchool.againPassword") placeholder:YSLocalizedSchool(@"Prompt.OnlineSchool.againPassword")];
    againPasswordView.delegate = self;
    self.againPasswordView = againPasswordView;
    [self.view addSubview:self.againPasswordView];
    
    UIButton *submitBtn = [UIButton bm_buttonWithFrame:CGRectMake(0, 0, 224, 34) color:[UIColor bm_colorWithHex:0x5A8CDC] highlightedColor:[UIColor bm_colorWithHex:0x336CC7] disableColor:[UIColor bm_colorWithHex:0x97B7EB]];
    self.submitBtn = submitBtn;
//    submitBtn.frame = CGRectMake(0, 0, 224, 34);
    submitBtn.bm_centerX = self.view.bm_centerX;
    submitBtn.bm_top = self.againPasswordView.bm_bottom + 50;
    [self.view addSubview:submitBtn];
    [submitBtn setTitle:YSLocalizedSchool(@"Title.OnlineSchool.Submit") forState:UIControlStateNormal];
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    submitBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [submitBtn setTitleColor:[UIColor bm_colorWithHex:0xFFE895] forState:UIControlStateNormal];
    submitBtn.layer.cornerRadius = 17;
    submitBtn.layer.borderColor = [UIColor bm_colorWithHex:0x97B7EB].CGColor;
    submitBtn.layer.borderWidth = 3;
    submitBtn.layer.masksToBounds = YES;
    submitBtn.enabled = NO;
    [submitBtn addTarget:self action:@selector(submitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)viewWillLayoutSubviews
{
    self.changePasswordView.frame = CGRectMake(0, 40, UI_SCREEN_WIDTH, 40);
    self.againPasswordView.frame = CGRectMake(0, CGRectGetMaxY(self.changePasswordView.frame) + 15, UI_SCREEN_WIDTH, 40);
    self.submitBtn.frame = CGRectMake(0, 0, 224, 34);
    self.submitBtn.bm_centerX = self.view.bm_centerX;
    self.submitBtn.bm_top = self.againPasswordView.bm_bottom + 50;
}

- (void)submitBtnClicked:(UIButton *)btn
{

    // 提交密码
    AFHTTPSessionManager *manager = [YSApiRequest makeYSHTTPSessionManager];
    
    NSString *organId = [YSSchoolUser shareInstance].organId;
    
    NSString *mobile = [YSSchoolUser shareInstance].mobile;
    NSMutableURLRequest *request =
    [YSLiveApiRequest postUpdatePass:self.againPasswordView.inputTextField.text mobile:mobile organid:organId];
    if (request)
    {
        
        NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
                
                [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:YSLocalizedSchool(@"Error.ServerError") delay:0.5];
            }
            else
            {
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
                        NSString *info = [responseDic bm_stringForKey:@"info"];
                        [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:info delay:0.5];
                        [[YSSchoolUser shareInstance] clearUserdata];
                        [GetAppDelegate logoutOnlineSchool];
                    }
                    else
                    {
                        NSString *info = [responseDic bm_stringForKey:@"info"];
                        [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:info delay:0.5];
                    }
                }
                else
                {
                    
                    [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:YSLocalizedSchool(@"Error.ServerError") delay:0.5];
                }
                
            }
        }];
        [task resume];
    }
    else
    {
        [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:YSLocalizedSchool(@"Error.ServerError") delay:0.5];
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

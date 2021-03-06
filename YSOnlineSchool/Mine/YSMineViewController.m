//
//  YSMineViewController.m
//  YSAll
//
//  Created by 迁徙鸟 on 2020/2/5.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSMineViewController.h"
#import "YSOnlineMineTableViewCell.h"
#import "YSChangePassWordVC.h"
#import "YSLoginVC.h"
#import "YSLiveApiRequest.h"
#import "AppDelegate.h"
#import "YSCoreStatus.h"

#import "BMAlertView+YSDefaultAlert.h"
static  NSString * const   YSOnlineMineTableViewCellID     = @"YSOnlineMineTableViewCell";
@interface YSMineViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource
>
@property (nonatomic, strong)UITableView *mineTableView;
@property (nonatomic, strong)UIImageView *userIconImg;
@property (nonatomic, strong)UILabel *userNameL;

@property (nonatomic, strong) NSURLSessionDataTask *mineTask;
@property (nonatomic, strong) NSURLSessionDataTask *signOutTask;

@end

@implementation YSMineViewController

- (void)dealloc
{
    [_mineTask cancel];
    _mineTask = nil;
    
    [_signOutTask cancel];
    _signOutTask = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = YSSkinOnlineDefineColor(@"liveDefaultBgColor");
    
    self.bm_NavigationTitleTintColor = YSSkinOnlineDefineColor(@"login_placeholderColor");
    self.bm_NavigationItemTintColor = YSSkinOnlineDefineColor(@"login_placeholderColor");
    [self bm_setNavigationWithTitle:YSLocalizedSchool(@"Title.OnlineSchool.Mine") barTintColor:YSSkinOnlineDefineColor(@"timer_timeBgColor") leftItemTitle:nil leftItemImage:nil leftToucheEvent:nil rightItemTitle:nil rightItemImage:nil rightToucheEvent:nil];
    
    self.title = nil;
    
    [self setupUI];
    
    [self bringSomeViewToFront];
}

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

- (void)setupUI
{
    self.mineTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.mineTableView.frame = CGRectMake(15, 46 , BMUI_SCREEN_WIDTH - 30, 200);
    self.mineTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.mineTableView.delegate = self;
    self.mineTableView.dataSource = self;
    self.mineTableView.showsVerticalScrollIndicator = NO;
    self.mineTableView.backgroundColor = [UIColor bm_colorWithHex:0xFFFFFF];
    self.mineTableView.layer.cornerRadius = 8;
    self.mineTableView.layer.masksToBounds = YES;
    self.mineTableView.scrollEnabled = NO;
    [self.view addSubview:self.mineTableView];
    
    [self.mineTableView registerClass:[YSOnlineMineTableViewCell class] forCellReuseIdentifier:YSOnlineMineTableViewCellID];
    
    
    self.userIconImg = [[UIImageView alloc] init];
    [self.view addSubview:self.userIconImg];
    self.userIconImg.backgroundColor = [UIColor whiteColor];
    self.userIconImg.frame = CGRectMake(0, 25 , 74, 74);
    self.userIconImg.bm_centerX = self.view.bm_centerX;
    self.userIconImg.layer.cornerRadius = 37;
    self.userIconImg.layer.borderColor = [UIColor whiteColor].CGColor;
    self.userIconImg.layer.borderWidth = 3.0f;
    self.userIconImg.layer.masksToBounds = YES;
    NSString *imgUrl = [YSSchoolUser shareInstance].imageUrl;
    if (![imgUrl bm_isNotEmpty]) {
        imgUrl = [YSSchoolUser shareInstance].organimageurl;
    }
    [self.userIconImg bmsd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"user_default_icon"]];
    
    self.userNameL = [[UILabel alloc] init];
    self.userNameL.frame = CGRectMake(0, 0, self.mineTableView.bm_width, 22);
    self.userNameL.bm_centerX = self.view.bm_centerX;
    self.userNameL.bm_top = self.userIconImg.bm_bottom + 13;
    self.userNameL.font = [UIFont systemFontOfSize:16.0f];
    self.userNameL.textAlignment = NSTextAlignmentCenter;
    self.userNameL.textColor = [UIColor bm_colorWithHex:0x828282];
    self.userNameL.text = [YSSchoolUser shareInstance].nickName;
    [self.view addSubview:self.userNameL];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSOnlineMineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:YSOnlineMineTableViewCellID forIndexPath:indexPath];
    cell.title = indexPath.row == 0 ? YSLocalizedSchool(@"Title.OnlineSchool.ModifyPassWord") : YSLocalizedSchool(@"Title.OnlineSchool.SignOut");
    return cell;
}

// 刷新
- (void)refreshBtnClick
{
    [self.progressHUD bm_showAnimated:NO showBackground:YES];

    BMAFHTTPSessionManager *manager = [YSApiRequest makeYSHTTPSessionManager];
    
    NSString *studentId = [YSSchoolUser shareInstance].userId;
    NSMutableURLRequest *request =
    [YSLiveApiRequest getStudentInfoWithfStudentId:studentId];
    if (request)
    {
        [self.mineTask cancel];
        self.mineTask = nil;
        
        BMWeakSelf
        self.mineTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
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
                        NSDictionary *dataDic = [responseDic bm_dictionaryForKey:@"data"];
                        [schoolUser updateWithServerDic:dataDic];
                    }
                    else
                    {
                        NSString *message = [responseDic bm_stringTrimForKey:YSSuperVC_ErrorMessage_key withDefault:YSLocalizedSchool(@"Error.ServerError")];
#if YSShowErrorCode
                        message = [NSString stringWithFormat:@"%@: %@", @(statusCode), message];
#endif
                        if ([weakSelf checkRequestStatus:statusCode message:message responseDic:responseDic])
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
        [self.mineTask resume];
    }
    else
    {
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLocalizedSchool(@"Error.ServerError") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] init];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BMLog(@"点击");
    if (indexPath.row == 0)
    {
        //修改密码
        YSChangePassWordVC *vc = [[YSChangePassWordVC alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else if (indexPath.row == 1)
    {
        //退出登录 清楚token 调用接口
        BMWeakSelf
        [BMAlertView ys_showAlertWithTitle:YSLocalizedSchool(@"Title.OnlineSchool.SignOut") message:nil cancelTitle:YSLocalizedSchool(@"Prompt.Cancel") otherTitle:YSLocalizedSchool(@"Prompt.OK") completion:^(BOOL cancelled, NSInteger buttonIndex) {
            // 关闭页面
            if (buttonIndex == 1)
            {
                [weakSelf signOut];
            }
        }];
    }
}

/// 退出
- (void)signOut
{
    [self.progressHUD bm_showAnimated:NO showBackground:YES];

    BMAFHTTPSessionManager *manager = [YSApiRequest makeYSHTTPSessionManager];
    
    NSString *token = [YSSchoolUser shareInstance].token;
    NSMutableURLRequest *request =
    [YSLiveApiRequest postExitLoginWithToken:token];
    if (request)
    {
        [self.signOutTask cancel];
        self.signOutTask = nil;
        
        BMWeakSelf
        self.signOutTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
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
                
                //NSDictionary *responseDic = [YSLiveUtil convertWithData:responseObject];
                [GetAppDelegate logoutOnlineSchool];
                [[YSSchoolUser shareInstance] clearUserdata];
            }
        }];
        [self.signOutTask resume];
    }
    else
    {
        [self.progressHUD bm_showAnimated:NO withDetailText:YSLocalizedSchool(@"Error.ServerError") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
}
@end

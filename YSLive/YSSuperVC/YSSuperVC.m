//
//  YSSuperVC.m
//  YSLive
//
//  Created by jiang deng on 2019/10/12.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSSuperVC.h"
#import "BMProgressHUD.h"
#if YSSDK
#else
#import "AppDelegate.h"
#endif

@interface YSSuperVC ()

@end

@implementation YSSuperVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (IOS_VERSION >= 7.0f)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        //self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    // 隐藏系统的返回按钮
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    //    temporaryBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
    self.bm_NavigationBarStyle = UIBarStyleDefault;
    self.bm_NavigationBarBgTintColor = YS_NAVIGATION_BGCOLOR;
    self.bm_NavigationItemTintColor = YS_NAVIGATION_ITEMCOLOR;
    self.bm_NavigationShadowHidden = NO;
    self.bm_NavigationShadowColor  = UI_COLOR_B6;
    
    self.view.backgroundColor = YS_VIEW_BGCOLOR;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Navigation Action

+ (shouldPopOnBackButtonHandler)getPopOnBackButtonHandler
{
    shouldPopOnBackButtonHandler handler = ^BOOL(UIViewController *vc) {
        if ([vc isKindOfClass:[YSSuperVC class]])
        {
            YSSuperVC *superVC = (YSSuperVC *)vc;
            return [superVC shouldPopOnBackButton];
        }
        return YES;
    };
    
    return handler;
}

- (BOOL)shouldPopOnBackButton
{
    return YES;
}

- (void)backAction:(id)sender
{
    if ([self shouldPopOnBackButton])
    {
        [self.view endEditing:YES];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)backRootAction:(id)sender
{
    if ([self shouldPopOnBackButton])
    {
        [self.view endEditing:YES];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)backToViewController:(UIViewController *)viewController
{
    if ([self shouldPopOnBackButton])
    {
        [self.view endEditing:YES];
        
        [self.navigationController popToViewController:viewController animated:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.view endEditing:YES];
}


#pragma mark -
#pragma mark GradientLayer

- (CAGradientLayer *)getGradientLayerWithFrame:(CGRect)frame colors:(NSArray *)colors startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = frame;
    gradientLayer.colors = colors;
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    
    return gradientLayer;
}


#pragma mark -
#pragma mark checkRequestStatus

- (BOOL)checkRequestStatus:(NSInteger)statusCode message:(NSString *)message responseDic:(NSDictionary *)responseDic
{
    switch (statusCode)
    {
#if YSSDK
#else
        // 过期 和 挤掉 都是 code==-40666   是：  当前账号在其他设备登录, 请重新登录
        case -40666:
        {
            [BMProgressHUD bm_showHUDAddedTo:GetAppDelegate.window animated:YES withDetailText:YSLocalizedSchool(@"Error.TokenError") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(PROGRESSBOX_DEFAULT_HIDE_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [GetAppDelegate logoutOnlineSchool];
            });
            
            return YES;
        }
#endif

/*
        // 未登录
        case 1001:
        case 1002:
        {
            [MBProgressHUD showHUDAddedTo:GetAppDelegate.window animated:YES withDetailText:@"登录信息已失效，请重新登录" delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(PROGRESSBOX_DEFAULT_HIDE_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [GetAppDelegate logOutQuit:quit showLogin:show];
            });
            return YES;
        }
        // 强制更新
        case 1008:
        {
            NSDictionary *dataDic = [responseDic bm_dictionaryForKey:@"data"];
            NSString *downUrl;
            NSString *httpLink = [dataDic bm_stringTrimForKey:@"link"];
            NSString *appId = [dataDic bm_stringTrimForKey:@"appId"];
            if ([httpLink bm_isNotEmpty])
            {
                downUrl = httpLink;
            }
            else if ([appId bm_isNotEmpty])
            {
                downUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/%@", appId];
            }
            else
            {
                downUrl = APPSTORE_DOWNLOADAPP_ADDRESS;
            }
            
            NSString *title = [dataDic bm_stringTrimForKey:@"title"];
            NSString *upgradeDesc = [dataDic bm_stringTrimForKey:@"upgradeDesc"];
            if (![upgradeDesc bm_isNotEmpty])
            {
                upgradeDesc = message;
            }
            if (![title bm_isNotEmpty])
            {
                title = upgradeDesc;
                upgradeDesc = nil;
            }
            
            NSString *status = [dataDic bm_stringTrimForKey:@"status"];
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                // FORCE 强制升级，每次app启动提示一次
                if ([status isEqualToString:@"FORCE"])
                {
                    [[BMAlertViewStack sharedInstance] closeAllAlertViews];
                    
                    FSAlertView *alertView = [FSAlertView showAlertWithTitle:title message:upgradeDesc cancelTitle:@"立即更新" otherTitle:nil completion:^(BOOL cancelled, NSInteger buttonIndex) {
                        //NSString *downString = APPSTORE_DOWNLOADAPP_ADDRESS;
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downUrl]];
                    }];
                    alertView.showClose = NO;
                    alertView.notDismissOnCancel = YES;
                    alertView.cancleBtnTextColor = [UIColor bm_colorWithHex:UI_NAVIGATION_BGCOLOR_VALU];
                }
                // OPTIONAL 可选升级，每次服务器变更版本只提示一次
                else if ([status isEqualToString:@"OPTIONAL"])
                {
                    NSString *version = [dataDic bm_stringTrimForKey:@"version"];
                    NSString *updateVersion = [FSAppInfo getUpdateVersion];
                    if (![version isEqualToString:updateVersion])
                    {
                        [FSAppInfo setUpdateVersion:version];
                        
                        FSAlertView *alertView = [FSAlertView showAlertWithTitle:title message:upgradeDesc cancelTitle:@"取消" otherTitle:@"立即更新" completion:^(BOOL cancelled, NSInteger buttonIndex) {
                            if (!cancelled)
                            {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downUrl]];
                            }
                        }];
                        alertView.showClose = YES;
                        alertView.otherBtnTextColor = [UIColor bm_colorWithHex:UI_NAVIGATION_BGCOLOR_VALU];
                    }
                }
            });
            
            return YES;
        }
*/
        default:
            break;
    }

    return NO;
}

@end

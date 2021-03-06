//
//  YSWebViewController.m
//  YSLive
//
//  Created by fzxm on 2020/7/28.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSWebViewController.h"
#import <WebKit/WebKit.h>
#import "AppDelegate.h"

#define CHLogin_Privacy_CHS         @"https://rddoccdnws.cloudhub.vip/document/IOS_Privacy_PolicyJ.pdf"
#define CHLogin_Privacy_CHT         @"https://rddoccdnws.cloudhub.vip/document/IOS_Privacy_PolicyF.pdf";
#define CHLogin_Privacy_EN          @"https://rddoccdnws.cloudhub.vip/document/IOS_Privacy_PolicyE.pdf"

#define CHLogin_UserAgreement_CHS   @"https://rddoccdnws.cloudhub.vip/document/IOS_User_AgreementJ.pdf"
#define CHLogin_UserAgreement_CHT   @"https://rddoccdnws.cloudhub.vip/document/IOS_User_AgreementF.pdf"
#define CHLogin_UserAgreement_EN    @"https://rddoccdnws.cloudhub.vip/document/IOS_User_AgreementE.pdf"

@interface YSWebViewController ()
<
    WKUIDelegate,
    WKNavigationDelegate
>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation YSWebViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *urlStr = @"";
    NSString *title = @"";
    NSString *currentLanguageRegion = [[NSLocale preferredLanguages] firstObject];
    
    if ([self.roteUrl isEqualToString:YSPrivacyClause])
    {
        // 隐私政策
        urlStr = @"";
        title = YSLocalized(@"Agreement.Privacy");

        if([currentLanguageRegion bm_containString:@"zh-Hans"])
        {
            urlStr = CHLogin_Privacy_CHS;
        }
        else if([currentLanguageRegion bm_containString:@"zh-Hant"])
        {
            urlStr = CHLogin_Privacy_CHT;
        }
        else
        {
            urlStr = CHLogin_Privacy_EN;
        }
    }
    else if ([self.roteUrl isEqualToString:YSUserAgreement])
    {
        // 用户协议
        title = YSLocalized(@"Agreement.User");
        if([currentLanguageRegion bm_containString:@"zh-Hans"])
        {
            urlStr = CHLogin_UserAgreement_CHS;
        }
        else if([currentLanguageRegion bm_containString:@"zh-Hant"])
        {
            urlStr = CHLogin_UserAgreement_CHT;
        }
        else
        {
            urlStr = CHLogin_UserAgreement_EN;
        }
    }
    
    self.bm_NavigationItemTintColor = [UIColor whiteColor];
    self.bm_NavigationTitleTintColor = [UIColor whiteColor];
    [self bm_setNavigationWithTitle:title barTintColor:[UIColor bm_colorWithHex:0x82ABEC] leftItemTitle:nil leftItemImage:[UIImage imageNamed:@"navigationbar_back_icon"] leftToucheEvent:@selector(backAction:) rightItemTitle:nil rightItemImage:nil rightToucheEvent:nil];
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bm_width, self.view.bm_height)];
    self.webView.UIDelegate = self;
    // 导航代理
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    urlStr = [urlStr bm_URLEncode];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [_webView loadRequest:request];
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


#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
//- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
//{
//
//}
//// 当内容开始返回时调用
//- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
//{
//
//}
//// 页面加载完成之后调用
//- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
//{
//
//}
//// 页面加载失败时调用
//- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
//{
//
//}
//// 接收到服务器跳转请求之后调用
//- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
//{
//
//}
//// 在收到响应后，决定是否跳转
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
//{
//
//    NSLog(@"%@",navigationResponse.response.URL.absoluteString);
//    //允许跳转
//    decisionHandler(WKNavigationResponsePolicyAllow);
//    //不允许跳转
//    //decisionHandler(WKNavigationResponsePolicyCancel);
//}
//// 在发送请求之前，决定是否跳转
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
//{
//
//     NSLog(@"%@",navigationAction.request.URL.absoluteString);
//    //允许跳转
//    decisionHandler(WKNavigationActionPolicyAllow);
//    //不允许跳转
//    //decisionHandler(WKNavigationActionPolicyCancel);
//}
//#pragma mark - WKUIDelegate
//// 创建一个新的WebView
//- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
//{
//    return [[WKWebView alloc]init];
//}
//// 输入框
//- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler
//{
//    completionHandler(@"http");
//}
//// 确认框
//- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
//{
//    completionHandler(YES);
//}
//// 警告框
//- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
//{
//    NSLog(@"%@",message);
//    completionHandler();
//}

@end

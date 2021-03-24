//
//  YSSetViewController.m
//  YSAll
//
//  Created by 马迪 on 2020/6/1.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSSetViewController.h"
#import "AppDelegate.h"
#import "YSSetTableViewCell.h"
#import "YSEyeCareVC.h"
#import "YSWebViewController.h"

@interface YSSetViewController ()<UITableViewDataSource,UITableViewDelegate>

/**
 *  tableView
 */
@property (nonatomic,weak) UITableView *tableView;

@end

@implementation YSSetViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bm_NavigationItemTintColor = [UIColor whiteColor];
    self.bm_NavigationTitleTintColor = [UIColor whiteColor];
    [self bm_setNavigationWithTitle:YSLocalized(@"Login.Seting") barTintColor:[UIColor bm_colorWithHex:0x82ABEC] leftItemTitle:nil leftItemImage:[UIImage imageNamed:@"navigationbar_back_icon"] leftToucheEvent:@selector(backAction:) rightItemTitle:nil rightItemImage:nil rightToucheEvent:nil];
    
    [self createTableView];
}

/**
 *  创建tableView
 */
- (void)createTableView{
    UITableView * tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bm_width, self.view.bm_height) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = NO;
    self.tableView = tableView;
    [self.view addSubview:tableView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YSSetTableViewCell *cell = [YSSetTableViewCell setTableViewCellWithTableView:tableView];
    cell.backgroundColor = [UIColor clearColor];

    if (indexPath.row == 0)
    {
        cell.titleText = YSLocalized(@"Agreement.User");
    }
    else if (indexPath.row == 1)
    {
        cell.titleText = YSLocalized(@"Agreement.Privacy");
    }
    else if (indexPath.row == 2)
    {
        cell.titleText = YSLocalized(@"EyeProtection.Btnsetup");
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        // 用户协议
        YSWebViewController *webVC = [[YSWebViewController alloc] init];
        webVC.roteUrl = YSUserAgreement;
        [self.navigationController pushViewController:webVC animated:YES];
    }
    else if (indexPath.row == 1)
    {
        // 隐私条款
        YSWebViewController *webVC = [[YSWebViewController alloc] init];
        webVC.roteUrl = YSPrivacyClause;
        [self.navigationController pushViewController:webVC animated:YES];
    }
    else if (indexPath.row == 2)
    {
        
        YSEyeCareVC *eyeCareVC = [[YSEyeCareVC alloc] init];
        [self.navigationController pushViewController:eyeCareVC animated:YES];
    }
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

@end

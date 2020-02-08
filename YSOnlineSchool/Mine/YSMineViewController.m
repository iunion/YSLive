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
static  NSString * const   YSOnlineMineTableViewCellID     = @"YSOnlineMineTableViewCell";
@interface YSMineViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource
>
@property (nonatomic, strong)UITableView *mineTableView;
@property (nonatomic, strong)UIImageView *userIconImg;
@property (nonatomic, strong)UILabel *userNameL;
@end

@implementation YSMineViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor bm_colorWithHex:0x9DBEF3];
    
    [self setupUI];
    [self getRequest];
        
    self.bm_NavigationTitleTintColor = UIColor.whiteColor;
    self.bm_NavigationBarTintColor = UIColor.whiteColor;
    [self bm_setNavigationWithTitle:YSLocalizedSchool(@"Title.OnlineSchool.Mine") barTintColor:[UIColor bm_colorWithHex:0x82ABEC] leftItemTitle:nil leftItemImage:nil leftToucheEvent:nil rightItemTitle:nil rightItemImage:[UIImage imageNamed:@"navigationbar_fresh_icon"] rightToucheEvent:@selector(refreshBtnClick)];
    self.title = nil;
}

- (void)getRequest
{
    /// 请求用户信息
}


- (void)setupUI
{
    self.mineTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.mineTableView.frame = CGRectMake(15, 46 , UI_SCREEN_WIDTH - 30, 200);
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
    self.userIconImg.backgroundColor = [UIColor redColor];
    self.userIconImg.frame = CGRectMake(0, 25 , 74, 74);
    self.userIconImg.bm_centerX = self.view.bm_centerX;
    self.userIconImg.layer.cornerRadius = 37;
    self.userIconImg.layer.borderColor = [UIColor whiteColor].CGColor;
    self.userIconImg.layer.borderWidth = 3.0f;
    self.userIconImg.layer.masksToBounds = YES;
    
    self.userNameL = [[UILabel alloc] init];
    self.userNameL.frame = CGRectMake(0, 0, self.mineTableView.bm_width, 22);
    self.userNameL.bm_centerX = self.view.bm_centerX;
    self.userNameL.bm_top = self.userIconImg.bm_bottom + 13;
    self.userNameL.font = [UIFont systemFontOfSize:16.0f];
    self.userNameL.textAlignment = NSTextAlignmentCenter;
    self.userNameL.textColor = [UIColor bm_colorWithHex:0x828282];
    self.userNameL.text = @"宁杰英";
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
    cell.title = indexPath.row == 0 ? @"修改密码" : @"退出登录";
    return cell;
}

//刷新
- (void)refreshBtnClick
{

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
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
        [self.tabBarController setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else if (indexPath.row == 1)
    {
        //退出登录
    }
}
@end

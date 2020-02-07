//
//  YSMineViewController.m
//  YSAll
//
//  Created by 迁徙鸟 on 2020/2/5.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSMineViewController.h"

@interface YSMineViewController ()

@end

@implementation YSMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.bm_NavigationTitleTintColor = UIColor.whiteColor;
//    self.bm_NavigationBarTintColor = UIColor.whiteColor;
    
    self.bm_NavigationBarBgTintColor = [UIColor bm_colorWithHex:0x82ABEC];
    
    self.navigationController.navigationItem.title = YSLocalizedSchool(@"Title.OnlineSchool.Calendar");
    [self bm_setNavigationWithTitle:@"我的" barTintColor:[UIColor bm_colorWithHex:0x82ABEC] leftItemTitle:nil leftItemImage:nil leftToucheEvent:nil rightItemTitle:nil rightItemImage:@"live_sel" rightToucheEvent:@selector(refreshBtnClick)];
    
}

//刷新
- (void)refreshBtnClick
{
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

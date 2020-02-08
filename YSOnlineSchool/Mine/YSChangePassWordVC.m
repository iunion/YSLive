//
//  YSChangePassWordVC.m
//  YSAll
//
//  Created by 宁杰英 on 2020/2/7.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSChangePassWordVC.h"

@interface YSChangePassWordVC ()

@end

@implementation YSChangePassWordVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bm_colorWithHex:0x9DBEF3];
    [self bm_setNavigationWithTitle:YSLocalizedSchool(@"Title.OnlineSchool.PassWord") barTintColor:[UIColor bm_colorWithHex:0x82ABEC] leftItemTitle:nil leftItemImage:nil leftToucheEvent:nil rightItemTitle:nil rightItemImage:@"live_sel" rightToucheEvent:@selector(refreshBtnClick)];
    
}


@end

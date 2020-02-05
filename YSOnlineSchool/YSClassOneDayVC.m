//
//  YSClassOneDayVC.m
//  YSAll
//
//  Created by 迁徙鸟 on 2020/2/5.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSClassOneDayVC.h"

@interface YSClassOneDayVC ()

@end

@implementation YSClassOneDayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    
    UIButton * backBtn = [[UIButton alloc]initWithFrame:CGRectMake(150, 100, 150, 30)];
    [backBtn setBackgroundColor:UIColor.redColor];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
}

- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

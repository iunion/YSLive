//
//  YSUpHandPopoverVC.m
//  YSLive
//
//  Created by 迁徙鸟 on 2020/2/17.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSUpHandPopoverVC.h"
#import "YSUpHandPopCell.h"

@interface YSUpHandPopoverVC ()
<
    UITableViewDelegate,
    UITableViewDataSource
>



@end

@implementation YSUpHandPopoverVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataArr = @[
        @{@"nickName":@"madi1",@"headImage":@"login_name"},
        @{@"nickName":@"madi2",@"headImage":@"login_name"},
        @{@"nickName":@"madi3",@"headImage":@"login_name"},
        @{@"nickName":@"madi4",@"headImage":@"login_name"},
        @{@"nickName":@"madi5",@"headImage":@"login_name"},
        @{@"nickName":@"madi6",@"headImage":@"login_name"},
        
    ];
    
    UITableView * tabView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,95, 146)];
    [self.view addSubview:tabView];
    self.tabView = tabView;
    tabView.showsVerticalScrollIndicator = NO;
    tabView.delegate = self;
    tabView.dataSource = self;
    tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YSUpHandPopCell * cell = [YSUpHandPopCell cellWithTableView:tableView];

    //在这里判断，看indexPath是否已经被选中,如果选中就将其对应的那一行的字体颜色设置为选中时的颜色，否则就是默认的颜色
//    if ([_indexArray containsObject:indexPath]) {
//        cell.textLabel.textColor = kMainColor;
//    }else{
//        cell.textLabel.textColor = [UIColor blackColor];
//    }
    cell.dataDict = self.dataArr[indexPath.row];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 24;
}

@end

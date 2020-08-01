//
//  YSUpHandPopoverVC.m
//  YSLive
//
//  Created by 迁徙鸟 on 2020/2/17.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSUpHandPopoverVC.h"

#import "YSLiveManager.h"

@interface YSUpHandPopoverVC ()
<
    UITableViewDelegate,
    UITableViewDataSource
>



@end

@implementation YSUpHandPopoverVC

- (void)setUserArr:(NSMutableArray *)userArr
{
    _userArr = userArr;
    
    [self.tabView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = YSSkinDefineColor(@"defaultBgColor");
    UITableView * tabView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,95, 146)];
    [self.view addSubview:tabView];
    self.tabView = tabView;
    tabView.delegate = self;
    tabView.dataSource = self;
    tabView.backgroundColor = UIColor.clearColor;
    tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tabView flashScrollIndicators];
    tabView.bounces = NO;
        
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YSUpHandPopCell * cell = [YSUpHandPopCell cellWithTableView:tableView];
    
//    cell.userModel = self.userArr[indexPath.row];
    cell.userDict = self.userArr[indexPath.row];
    __weak __typeof__(cell) weakCell = cell;
    cell.headButtonClick = ^{
        if (self->_letStudentUpVideo) {
            self->_letStudentUpVideo(weakCell);
        }
    };

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 23;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}



@end

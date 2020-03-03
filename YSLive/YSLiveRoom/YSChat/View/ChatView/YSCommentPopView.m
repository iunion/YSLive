//
//  CommentPopView.m
//  chatDemo01
//
//  Created by app on 16/9/23.
//  Copyright © 2016年 madi. All rights reserved.
//

#import "YSCommentPopView.h"

@interface YSCommentPopView()
<
    UITableViewDelegate,
    UITableViewDataSource
>



@property(nonatomic,weak)UITableView * tableview;

@property(nonatomic,strong)NSIndexPath * selectIndex;

@end

@implementation YSCommentPopView


- (void)setTitleArr:(NSArray *)titleArr
{
    _titleArr = titleArr;
    [self.tableview reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor bm_colorWithHexString:@"#97B7EB" alpha:0.8];
    
    self.selectIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    
    UITableView * tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,160, 135)];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview = tableview;
    tableview.showsVerticalScrollIndicator = NO;
    tableview.backgroundColor = [UIColor clearColor];
    tableview.delegate = self;
    tableview.dataSource = self;
    [self.view addSubview:tableview];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * key = @"popCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:key ];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
    }
    
    if ([self.selectIndex compare:indexPath] == NSOrderedSame) {
        cell.textLabel.textColor = [UIColor bm_colorWithHexString:@"#FFE895"];
    }else{
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    cell.backgroundColor = UIColor.clearColor;
    cell.textLabel.text = self.titleArr[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

#pragma mark - 下面两个方法实现变色功能
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_popoverCellClick)
    {
        _popoverCellClick(indexPath.row);
    }
    self.selectIndex = indexPath;
    [self.tableview reloadData];
}

@end



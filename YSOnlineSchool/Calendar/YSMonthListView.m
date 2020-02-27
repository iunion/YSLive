//
//  YSMonthListView.m
//  YSLive
//
//  Created by 迁徙鸟 on 2020/2/26.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSMonthListView.h"
#import "YSMonthListCell.h"


@interface YSMonthListView ()<UITableViewDelegate,UITableViewDataSource>



@end

@implementation YSMonthListView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = UIColor.clearColor;
        
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        imageView.image = [UIImage imageNamed:@"onlineSchool_allMonthBackView"];
//        imageView.backgroundColor = UIColor.redColor;
        [self addSubview:imageView];
        
        [self setTableView];
    }
    return self;
}

- (void)setTableView
{
    UITableView *tabView = [[UITableView alloc]initWithFrame:CGRectMake(1, 0, self.bm_width-2, self.bm_height-10) style:UITableViewStylePlain];
    [self addSubview:tabView];
    tabView.delegate = self;
    tabView.dataSource = self;
    tabView.backgroundColor = UIColor.clearColor;
    tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tabView = tabView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dateArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *key = @"YSMonthsListTableViewCellKey";
       
    YSMonthListCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
    if (!cell) {
        cell = [[YSMonthListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
    }
    
    NSString * dateStr = nil;
    if (indexPath.row<self.dateArr.count) {
        
        NSDate * date1 = [NSDate bm_dateFromString:self.dateArr[indexPath.row] withFormat:@"yyyy-MM-dd"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy MM";
        NSString * string1 = [formatter stringFromDate:date1];
        dateStr = [NSString stringWithFormat:@"%@%@",string1,YSLocalizedSchool(@"Label.Title.Month")];
    }

    cell.titleLab.text = dateStr;
    
    if ([self.selectMonth isEqualToString:dateStr])
    {
        cell.selected = YES;
        cell.titleLab.textColor = [UIColor bm_colorWithHex:0x82ABEC];
    }
    else
    {
        cell.titleLab.textColor = [UIColor bm_colorWithHex:0x828282];
    }
        
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 33;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSMonthListCell * cell = [self.tabView cellForRowAtIndexPath:indexPath];
    
    cell.titleLab.textColor = [UIColor bm_colorWithHex:0x82ABEC];
    self.selectMonth = cell.titleLab.text;
    
    if (indexPath.row<self.dateArr.count)
    {
        if (_selectMonthCellClick)
        {
            _selectMonthCellClick(self.dateArr[indexPath.row],indexPath);
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSMonthListCell * cell = [self.tabView cellForRowAtIndexPath:indexPath];
    cell.titleLab.textColor = [UIColor bm_colorWithHex:0x828282];
}

 - (void)setDateArr:(NSMutableArray *)dateArr
{
    _dateArr = dateArr;
    [self.tabView reloadData];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSIndexPath * index = [(UITableView *)scrollView indexPathForSelectedRow];
    
    BMLog(@"index.row = %ld",index.row);
    
}

@end

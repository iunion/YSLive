//
//  YSMonthsListTableView.m
//  YSLive
//
//  Created by 迁徙鸟 on 2020/2/26.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSMonthsListTableView.h"
#import "YSMonthListCell.h"

@interface YSMonthsListTableView()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation YSMonthsListTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style]) {
        self.delegate = self;
        self.dataSource = self;
        self.showsVerticalScrollIndicator = NO;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:frame];
        imageView.image = [UIImage imageNamed:@"onlineSchool_allMonthBackView"];
        imageView.backgroundColor = UIColor.redColor;
        [self addSubview:imageView];
        
    }
    return self;
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
        dateStr = self.dateArr[indexPath.row];
    }
        
    cell.titleLab.text = dateStr;
    cell.titleLab.textColor = [UIColor bm_colorWithHex:0x828282];
//    cell.titleLab.backgroundColor = UIColor.redColor;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 33;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSMonthListCell * cell = [self cellForRowAtIndexPath:indexPath];
    
    cell.textLabel.textColor = [UIColor bm_colorWithHex:0x82ABEC];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSMonthListCell * cell = [self cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor bm_colorWithHex:0x828282];
}



 - (void)setDateArr:(NSMutableArray *)dateArr
{
    _dateArr = dateArr;
    [self reloadData];
}
@end

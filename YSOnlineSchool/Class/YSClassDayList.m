//
//  YSClassDayList.m
//  YSAll
//
//  Created by jiang deng on 2020/2/6.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSClassDayList.h"
#import "YSClassModel.h"
#import "YSClassCell.h"

@interface YSClassDayList ()
<
    YSClassCellDelegate
>

@end

@implementation YSClassDayList
@synthesize freshViewType = _freshViewType;

- (void)viewDidLoad
{
    _freshViewType = BMFreshViewType_NONE;

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];

    [self loadApiData];

    [self bringSomeViewToFront];
}

- (void)createUI
{
}

- (void)refreshVC
{
    [self loadApiData];
}

- (NSMutableURLRequest *)setLoadDataRequest
{
    return nil;//[FSApiRequest getMeetingDetailWithId:self.m_MeetingId];
}

- (BOOL)succeedLoadedRequestWithDic:(NSDictionary *)data
{
    if (![data bm_isNotEmptyDictionary])
    {
        return NO;
    }
    
    self.showEmptyView = NO;
    
    if (self.isLoadNew)
    {
        [self.dataArray removeAllObjects];
    }
    
    NSArray *dicArray = [data bm_arrayForKey:@"classList"];
    for (NSDictionary *dic in dicArray)
    {
        YSClassModel *classModel = [YSClassModel classModelWithServerDic:dic];
        if (classModel)
        {
            [self.dataArray addObject:classModel];
        }
    }
    
    [self.tableView reloadData];
    
    return YES;
}


#pragma mark -
#pragma mark Table Data Source Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *taskCellIdentifier = @"YSClassCell";
    YSClassCell *cell = [tableView dequeueReusableCellWithIdentifier:taskCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[YSClassCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:taskCellIdentifier];
        cell.delegate = self;
    }
    
    YSClassModel *classModel = self.dataArray[indexPath.row];
    [cell drawCellWithModel:classModel isDetail:NO];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YSClassModel *classModel = self.dataArray[indexPath.row];
}

@end

//
//  YSClassDetailVC.m
//  YSAll
//
//  Created by jiang deng on 2020/2/6.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSClassDetailVC.h"
#import "YSClassCell.h"
#import "YSClassInstructionCell.h"
#import "YSClassMediumCell.h"

@interface YSClassDetailVC ()
<
    YSClassCellDelegate
>

@end

@implementation YSClassDetailVC
@synthesize freshViewType = _freshViewType;

- (void)viewDidLoad
{    
    _freshViewType = BMFreshViewType_NONE;

    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [UIColor bm_colorWithHex:0x9DBEF3];

    self.bm_NavigationItemTintColor = [UIColor whiteColor];
    self.bm_NavigationTitleTintColor = [UIColor whiteColor];
    [self bm_setNavigationWithTitle:YSLocalizedSchool(@"ClassDetail.Title") barTintColor:[UIColor bm_colorWithHex:0x82ABEC] leftItemTitle:nil leftItemImage:[UIImage imageNamed:@"navigationbar_back_icon"] leftToucheEvent:@selector(backAction:) rightItemTitle:nil rightItemImage:[UIImage imageNamed:@"navigationbar_fresh_icon"] rightToucheEvent:@selector(refreshVC)];
    
    [self createUI];

    [self refreshVC];

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
    
    
    [self.tableView reloadData];
    
    return YES;
}


#pragma mark -
#pragma mark Table Data Source Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *taskCellIdentifier = @"YSClassCell";
    YSClassCell *cell = [tableView dequeueReusableCellWithIdentifier:taskCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"YSClassCell" owner:self options:nil].firstObject;
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

    YSClassDetailVC *detailsVC = [[YSClassDetailVC alloc] init];
    detailsVC.linkClassModel = classModel;
    detailsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailsVC animated:YES];
}

@end

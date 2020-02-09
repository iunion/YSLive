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
    YSClassCellDelegate,
    YSClassMediumCellDelegate
>

@property (nonatomic, strong) YSClassDetailModel *classDetailModel;

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
    
    YSClassDetailModel *classDetailModel = [YSClassDetailModel classDetailModelWithServerDic:data linkClass:self.linkClassModel];
    // 获取新数据成功更新
    if (classDetailModel)
    {
        if (self.isLoadNew)
        {
            [self.dataArray removeAllObjects];
        }
        
        self.classDetailModel = classDetailModel;
        
        [self.dataArray addObject:classDetailModel];
        [self.tableView reloadData];
    }
    
    return YES;
}


#pragma mark -
#pragma mark Table Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.dataArray bm_isNotEmpty])
    {
        return 3;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
            return [YSClassCell cellHeight];
            
        case 1:
            return [self.classDetailModel calculateInstructionTextCellHeight];

        case 2:
            return [YSClassCell cellHeight];
    }
    
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            YSClassCell *cell = [[NSBundle mainBundle] loadNibNamed:@"YSClassCell" owner:self options:nil].firstObject;
            cell.delegate = self;
            if (self.linkClassModel)
            {
                [cell drawCellWithModel:self.linkClassModel isDetail:YES];
            }
            else
            {
                [cell drawCellWithModel:self.classDetailModel isDetail:YES];
            }
            
            return cell;
        }
        
        case 1:
            {
                YSClassInstructionCell *cell = [[NSBundle mainBundle] loadNibNamed:@"YSClassInstructionCell" owner:self options:nil].firstObject;
                [cell drawCellWithModel:self.classDetailModel];
                
                return cell;
            }

        case 2:
            {
                YSClassInstructionCell *cell = [[NSBundle mainBundle] loadNibNamed:@"YSClassInstructionCell" owner:self options:nil].firstObject;
                [cell drawCellWithModel:self.classDetailModel];
                
                return cell;
            }
    }

    static NSString *taskCellIdentifier = @"YSCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:taskCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:taskCellIdentifier];
    }
    cell.backgroundColor = YS_VIEW_BGCOLOR;
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = [UIColor bm_colorWithHex:0xEEEEEE];
    
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

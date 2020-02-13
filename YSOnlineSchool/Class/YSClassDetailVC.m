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
    
    self.showEmptyView = YES;

    [self createUI];

    [self refreshVC];

    [self bringSomeViewToFront];
}

- (void)createUI
{
    self.tableView.allowsSelection = NO;
}

- (void)refreshVC
{
    [self loadApiData];
    
#warning test
    YSClassDetailModel *classModel = [[YSClassDetailModel alloc] init];
    classModel.classId = @"111";
    classModel.title = @"邓老师讲课";
    classModel.teacherName = @"邓小平";
    classModel.classGist = @"马克思理论马克思理论马克思理论";
    
    classModel.startTime = [[NSDate date] timeIntervalSince1970];
    classModel.endTime = [[[NSDate date] bm_dateByAddingHours:1] timeIntervalSince1970];
    
    classModel.classInstruction = @"含有硒，是一种抗癌成分，它的抗癌功效是芦荟的十倍，而且可以增加人体的免疫力";

    classModel.classState = arc4random() % (YSClassState_End+1);
    
    YSClassReviewModel *classReviewModel1 = [[YSClassReviewModel alloc] init];
    classReviewModel1.title = @"课件1";
    classReviewModel1.duration = @"35'12''";
    classReviewModel1.size = @"112.36M";

    YSClassReviewModel *classReviewModel2 = [[YSClassReviewModel alloc] init];
    classReviewModel2.title = @"课件2";
    classReviewModel2.duration = @"55'32''";
    classReviewModel2.size = @"232.56M";

    if (arc4random()%2)
    {
        classModel.classReplayList = [[NSMutableArray alloc] init];
        [classModel.classReplayList addObject:classReviewModel1];
        [classModel.classReplayList addObject:classReviewModel2];
    }

    [self.dataArray removeAllObjects];
    [self.dataArray addObject:classModel];
    
    self.classDetailModel = classModel;
    
    [self.tableView reloadData];
}

- (BMEmptyViewType)getNoDataEmptyViewType
{
    return BMEmptyViewType_ClassError;
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
        if ([self.classDetailModel.classReplayList bm_isNotEmpty])
        {
            return 3;
        }
        else
        {
            return 2;
        }
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
            return [self.classDetailModel calculateMediumCellHeight];
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
                YSClassMediumCell *cell = [[NSBundle mainBundle] loadNibNamed:@"YSClassMediumCell" owner:self options:nil].firstObject;
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

@end

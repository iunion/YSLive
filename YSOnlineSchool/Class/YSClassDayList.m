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
#import "YSClassDetailVC.h"

#import "YSLiveApiRequest.h"

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

    self.view.backgroundColor = [UIColor bm_colorWithHex:0x9DBEF3];
    
    // iOS 获取设备当前语言和地区的代码
    NSString *currentLanguageRegion = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject];
    NSString *time;
    if ([currentLanguageRegion bm_containString:@"zh-Hant"] || [currentLanguageRegion bm_containString:@"zh-Hans"])
    {
        time = [self.selectedDate bm_stringWithFormat:@"yyyy年MM月dd日"];
    }
    else
    {
        time = [self.selectedDate bm_stringWithFormat:@"yyyy-MM-dd"];
    }

    NSString *title = [NSString stringWithFormat:@"%@ %@", time, YSLocalizedSchool(@"ClassDayList.Title")];

    self.bm_NavigationItemTintColor = [UIColor whiteColor];
    self.bm_NavigationTitleTintColor = [UIColor whiteColor];
    [self bm_setNavigationWithTitle:title barTintColor:[UIColor bm_colorWithHex:0x82ABEC] leftItemTitle:nil leftItemImage:[UIImage imageNamed:@"navigationbar_back_icon"] leftToucheEvent:@selector(backAction:) rightItemTitle:nil rightItemImage:[UIImage imageNamed:@"navigationbar_fresh_icon"] rightToucheEvent:@selector(refreshVC)];

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
    
//#warning test
//    YSClassModel *classModel = [[YSClassModel alloc] init];
//    classModel.classId = @"111";
//    classModel.title = @"邓老师讲课";
//    classModel.teacherName = @"邓小平";
//    classModel.classGist = @"马克思理论马克思理论马克思理论";
//
//    classModel.startTime = [[NSDate date] timeIntervalSince1970];
//    classModel.endTime = [[[NSDate date] bm_dateByAddingHours:1] timeIntervalSince1970];
//
//    classModel.classState = arc4random() % (YSClassState_End+1);
//
//    [self.dataArray addObject:classModel];
//
//    [self.tableView reloadData];
}

- (NSMutableURLRequest *)setLoadDataRequest
{
    //return [YSLiveApiRequest getClassListWithStudentId:@"268" date:[self.selectedDate bm_stringWithFormat:@"yyyy-MM-dd"] pagenum:1];
    return [YSLiveApiRequest getClassListWithStudentId:@"268" date:@"2020-02-10" pagenum:1];
}

- (BOOL)succeedLoadedRequestWithDic:(NSDictionary *)data
{
    if (![data bm_isNotEmptyDictionary])
    {
        return NO;
    }
    
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
    return [YSClassCell cellHeight];
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

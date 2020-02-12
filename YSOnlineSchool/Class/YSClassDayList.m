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
#import "YSSchoolUser.h"

#import "YSLiveApiRequest.h"

@interface YSClassDayList ()
<
    YSClassCellDelegate,
    YSLiveRoomManagerDelegate
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

    
    self.loadDataType = YSAPILoadDataType_Page;
    self.showEmptyView = YES;

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

- (BMEmptyViewType)getNoDataEmptyViewType
{
    return BMEmptyViewType_ClassError;
}

- (NSMutableURLRequest *)setLoadDataRequestWithFresh:(BOOL)isLoadNew
{
    YSSchoolUser *schoolUser = [YSSchoolUser shareInstance];
    
    return [YSLiveApiRequest getClassListWithStudentId:schoolUser.userId date:[self.selectedDate bm_stringWithFormat:@"yyyy-MM-dd"] pagenum:1];
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
    
    NSArray *dicArray = [data bm_arrayForKey:@"data"];
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



#pragma mark - YSClassCellDelegate

- (void)enterClassWith:(YSClassModel *)classModel
{
    [self.progressHUD bm_showAnimated:YES showBackground:YES];

    AFHTTPSessionManager *manager = [YSApiRequest makeYSHTTPSessionManager];
    NSMutableURLRequest *request = [YSLiveApiRequest enterOnlineSchoolClassWithToTeachId:classModel.toTeachId];
    if (request)
    {
        BMWeakSelf
        NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
                [self.progressHUD bm_showAnimated:YES withText:YSLocalized(@"Error.ServerError") delay:0.5f];
            }
            else
            {
                NSDictionary *responseDic = [YSLiveUtil convertWithData:responseObject];
                if ([responseDic bm_isNotEmptyDictionary])
                {
                    NSInteger statusCode = [responseDic bm_intForKey:YSSuperVC_StatusCode_Key];
                    if (statusCode == YSSuperVC_StatusCode_Succeed)
                    {
                        NSDictionary *dataDic = [responseDic bm_dictionaryForKey:YSSuperVC_DataDic_Key];
                        NSDictionary *urlParam = [dataDic bm_dictionaryForKey:@"urlParam"];
                        if ([urlParam bm_isNotEmptyDictionary])
                        {
                            NSString *serial = [urlParam bm_stringTrimForKey:@"serial"];
                            NSString *username = [urlParam bm_stringTrimForKey:@"username"];
                            NSString *userpassword = [urlParam bm_stringTrimForKey:@"userpassword"];
                            if ([serial bm_isNotEmpty])
                            {
                                [weakSelf enterSchoolRoomWithNickName:username roomId:serial passWord:userpassword];

                                return;
                            }
                        }
                    }
                }
                
                [self.progressHUD bm_showAnimated:YES withText:YSLocalized(@"Error.ServerError") delay:0.5f];
            }
        }];
        [task resume];
    }
    else
    {
         [self.progressHUD bm_showAnimated:YES withText:YSLocalized(@"Error.ServerError") delay:0.5f];
    }
}

- (void)enterSchoolRoomWithNickName:(NSString *)nickName roomId:(NSString *)roomId passWord:(NSString *)passWord
{
    [[YSLiveManager shareInstance] destroy];
    
    YSLiveManager *liveManager = [YSLiveManager shareInstance];
    [liveManager registerRoomManagerDelegate:self];
    
    [liveManager joinRoomWithHost:liveManager.liveHost port:YSLive_Port nickName:nickName roomId:roomId roomPassword:passWord userRole:YSUserType_Student userId:nil userParams:nil];
    
    [self.progressHUD bm_showAnimated:YES showBackground:YES];
}

/*
code: 0, data: {,…}, info: "操作成功"}
code: 0
data: {,…}
url: "http://api.roadofcloud.com/WebAPI/Entry?domain=wxcs&serial=908938221&username=%E9%82%93%E5%AD%A6%E7%94%9F&usertype=2&pid=0&ts=1581516064&auth=bedaeb97c20cd57d3260c31376706ed5&userpassword=6d379deb69df534bb1f50adcf956dd7e&servername=&jumpurl=http%3A%2F%2Fschool.roadofcloud.cn%2Fteacher"
urlParam: {domain: "wxcs", serial: 908938221, username: "邓学生", usertype: "2", pid: 0, ts: 1581516064,…}
domain: "wxcs"
serial: 908938221
username: "邓学生"
usertype: "2"
pid: 0
ts: 1581516064
auth: "bedaeb97c20cd57d3260c31376706ed5"
userpassword: "634708"
servername: ""
jumpurl: "school.roadofcloud.cn/student"
info: "操作成功"
*/

@end

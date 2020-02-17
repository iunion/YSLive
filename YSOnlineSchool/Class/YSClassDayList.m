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

#import "AppDelegate.h"

#import "YSLiveApiRequest.h"
#import "YSMainVC.h"
#import "SCMainVC.h"

#import "YSEyeCareManager.h"
#import "YSPassWordAlert.h"
#import "BMAlertView+YSDefaultAlert.h"
#import "YSCoreStatus.h"

#import "YSTeacherRoleMainVC.h"

@interface YSClassDayList ()
<
    YSClassCellDelegate,
    YSLiveRoomManagerDelegate,
    YSClassDetailVCDelegate
>

@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *userName;

@end

@implementation YSClassDayList
@synthesize freshViewType = _freshViewType;

- (void)viewDidLoad
{
    _freshViewType = BMFreshViewType_NONE;

    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.bm_CanBackInteractive = NO;

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
    [self bm_setNavigationWithTitle:title barTintColor:[UIColor bm_colorWithHex:0x82ABEC] leftItemTitle:nil leftItemImage:[UIImage imageNamed:@"navigationbar_back_icon"] leftToucheEvent:@selector(backAction:) rightItemTitle:nil rightItemImage:[UIImage imageNamed:@"onlineSchool_refresh"] rightToucheEvent:@selector(refreshVC)];

    
    self.loadDataType = YSAPILoadDataType_Page;
    self.showEmptyView = YES;

    [self createUI];

    [self bringSomeViewToFront];

    [self refreshVC];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)createUI
{
    //[self.progressHUD bm_showAnimated:NO withDetailText:YSLocalizedSchool(@"ClassListCell.Enter.EndError") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];

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
    
    if (schoolUser.userRoleType == YSUserType_Teacher)
    {
        return [YSLiveApiRequest getTeacherClassListWithPagesize:20 date:[self.selectedDate bm_stringWithFormat:@"yyyy-MM-dd"] pagenum:1];
    }
    else
    {
        return [YSLiveApiRequest getClassListWithStudentId:schoolUser.userId date:[self.selectedDate bm_stringWithFormat:@"yyyy-MM-dd"] pagenum:1];
    }
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

    //if (classModel.classState > YSClassState_Begin)
    {
        [self openClassWith:classModel];
    }
}


#pragma mark - YSClassCellDelegate

- (void)openClassWith:(YSClassModel *)classModel
{
    YSClassDetailVC *detailsVC = [[YSClassDetailVC alloc] init];
    detailsVC.selectedDate = self.selectedDate;
    detailsVC.linkClassModel = classModel;
    detailsVC.delegate = self;
    detailsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailsVC animated:YES];
}

- (void)enterClassWith:(YSClassModel *)classModel
{
    [self.progressHUD bm_showAnimated:NO showBackground:YES];

    YSUserRoleType schoolUserType = [YSSchoolUser shareInstance].userRoleType;

    AFHTTPSessionManager *manager = [YSApiRequest makeYSHTTPSessionManager];
    NSMutableURLRequest *request = [YSLiveApiRequest enterOnlineSchoolClassWithWithUserType:schoolUserType toTeachId:classModel.toTeachId];
    if (request)
    {
        BMWeakSelf
        NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
                [weakSelf.progressHUD bm_showAnimated:NO withText:YSLocalized(@"Error.ServerError") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
            }
            else
            {
                [weakSelf.progressHUD bm_hideAnimated:NO];

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
                            NSTimeInterval serverTime = [urlParam bm_doubleForKey:@"ts" withDefault:0];
                            if (serverTime > 0)
                            {
                                //serverTime = serverTime / 1000;
                                //NSString *str = [NSDate bm_stringFromTs:serverTime];
                                YSLiveManager *liveManager = [YSLiveManager shareInstance];
                                liveManager.tServiceTime = serverTime;
                                NSString *message = @"";
                                BOOL stop = NO;
                                if ((classModel.endTime - liveManager.tCurrentTime) <= 0)
                                {
                                    stop = YES;
                                    classModel.classState = YSClassState_End;
                                    message = YSLocalizedSchool(@"ClassListCell.Enter.EndError");
                                }
                                else if ((classModel.startTime - liveManager.tCurrentTime) >= 600)
                                {
                                    stop = YES;
                                    message = YSLocalizedSchool(@"ClassListCell.Enter.WaitError");
                                }

                                if (stop)
                                {
                                    [weakSelf.progressHUD bm_showAnimated:NO withDetailText:message delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
                                    return;
                                }
                            }
                            
                            NSString *serial = [urlParam bm_stringTrimForKey:@"serial"];
                            NSString *username = [urlParam bm_stringTrimForKey:@"username"];
                            NSString *userpassword = [urlParam bm_stringTrimForKey:@"userpassword"];
                            if ([serial bm_isNotEmpty])
                            {
                                classModel.classState = YSClassState_Begin;
                                weakSelf.roomId = serial;
                                weakSelf.userName = username;
                                [weakSelf enterSchoolRoomWithNickName:username roomId:serial passWord:userpassword];
                                
                                return;
                            }
                        }
                    }
                    else
                    {
                        NSString *message = [responseDic bm_stringTrimForKey:YSSuperVC_ErrorMessage_key withDefault:YSLocalized(@"Error.ServerError")];
                        if ([weakSelf checkRequestStatus:statusCode message:message responseDic:responseDic])
                        {
                            [weakSelf.progressHUD bm_hideAnimated:NO];
                        }
                        else
                        {
                            if (statusCode == -60016)
                            {
                                message = YSLocalizedSchool(@"ClassListCell.Enter.TeacherError");
                                //message = YSLocalizedSchool(@"ClassListCell.Enter.WaitError");
                            }
                            else if (statusCode == 23001)
                            {
                                message = YSLocalizedSchool(@"ClassListCell.Enter.SysError");
                            }
                            
                            [weakSelf.progressHUD bm_showAnimated:NO withDetailText:message delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
                        }
                        
                        return;
                    }
                }
                
                [weakSelf.progressHUD bm_showAnimated:NO withText:YSLocalized(@"Error.ServerError") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
            }
        }];
        [task resume];
    }
    else
    {
         [self.progressHUD bm_showAnimated:NO withText:YSLocalized(@"Error.ServerError") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
}

- (void)enterSchoolRoomWithNickName:(NSString *)nickName roomId:(NSString *)roomId passWord:(NSString *)passWord
{
    [[YSLiveManager shareInstance] destroy];
    
    YSLiveManager *liveManager = [YSLiveManager shareInstance];
    [liveManager registerRoomManagerDelegate:self];
    
    if (![passWord bm_isNotEmpty])
    {
        passWord = nil;
    }
    
    NSString *userId;
    YSSchoolUser *schoolUser = [YSSchoolUser shareInstance];
    if (schoolUser.userRoleType == YSUserType_Teacher)
    {
        userId = [NSString stringWithFormat:@"2_%@", schoolUser.userId];
    }
    else
    {
        userId = [NSString stringWithFormat:@"3_%@", schoolUser.userId];
    }
    YSUserRoleType userRoleType = [YSSchoolUser shareInstance].userRoleType;
    [liveManager joinRoomWithHost:liveManager.liveHost port:YSLive_Port nickName:nickName roomId:roomId roomPassword:passWord userRole:userRoleType userId:userId userParams:nil needCheckPermissions:NO];
    
    [self.progressHUD bm_showAnimated:NO showBackground:YES];
}


#pragma mark -
#pragma mark YSRoomInterfaceDelegate

// 成功进入房间
- (void)onRoomJoined:(long)ts;
{
    BMLog(@"YSLoginVC onRoomJoined");
    
    [self.progressHUD bm_hideAnimated:NO];
    
    YSLiveManager *liveManager = [YSLiveManager shareInstance];

    YSAppUseTheType appUseTheType = liveManager.room_UseTheType;

    // 3: 小班课  4: 直播  6： 会议
    if (appUseTheType == YSAppUseTheTypeSmallClass || appUseTheType == YSAppUseTheTypeMeeting)
    {
        GetAppDelegate.allowRotation = YES;
        NSUInteger maxvideo = [[YSLiveManager shareInstance].roomDic bm_uintForKey:@"maxvideo"];
        YSRoomTypes roomusertype = maxvideo > 2 ? YSRoomType_More : YSRoomType_One;
        
        BOOL isWideScreen = liveManager.room_IsWideScreen;
        
        YSUserRoleType roleType = liveManager.localUser.role;
        
        if (roleType == YSUserType_Teacher)
        {
            YSTeacherRoleMainVC *mainVC = [[YSTeacherRoleMainVC alloc] initWithRoomType:roomusertype isWideScreen:isWideScreen maxVideoCount:maxvideo whiteBordView:liveManager.whiteBordView userId:nil];
            mainVC.appUseTheType = appUseTheType;
            BMNavigationController *nav = [[BMNavigationController alloc] initWithRootViewController:mainVC];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            nav.popOnBackButtonHandler = [YSSuperVC getPopOnBackButtonHandler];
            [self presentViewController:nav animated:YES completion:^{
                [[YSEyeCareManager shareInstance] freshWindowWithShowStatusBar:NO isRientationPortrait:NO];
            }];
            [YSEyeCareManager shareInstance].showRemindBlock = ^{
                [mainVC showEyeCareRemind];
            };
        }
        else
        {
           SCMainVC *mainVC = [[SCMainVC alloc] initWithRoomType:roomusertype isWideScreen:isWideScreen maxVideoCount:maxvideo whiteBordView:liveManager.whiteBordView userId:nil];
            mainVC.appUseTheType = appUseTheType;
            BMNavigationController *nav = [[BMNavigationController alloc] initWithRootViewController:mainVC];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            nav.popOnBackButtonHandler = [YSSuperVC getPopOnBackButtonHandler];
            [self presentViewController:nav animated:YES completion:^{
                [[YSEyeCareManager shareInstance] freshWindowWithShowStatusBar:NO isRientationPortrait:NO];
            }];
            
            [YSEyeCareManager shareInstance].showRemindBlock = ^{
                [mainVC showEyeCareRemind];
            };
        }
    }
    else
    {
        GetAppDelegate.allowRotation = NO;
        BOOL isWideScreen = liveManager.room_IsWideScreen;
        YSMainVC *mainVC = [[YSMainVC alloc] initWithWideScreen:isWideScreen whiteBordView:liveManager.whiteBordView userId:nil];
        BMNavigationController *nav = [[BMNavigationController alloc] initWithRootViewController:mainVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        nav.popOnBackButtonHandler = [YSSuperVC getPopOnBackButtonHandler];
        [self presentViewController:nav animated:YES completion:^{
            [[YSEyeCareManager shareInstance] freshWindowWithShowStatusBar:NO isRientationPortrait:YES];
        }];
        
        [YSEyeCareManager shareInstance].showRemindBlock = ^{
            [mainVC showEyeCareRemind];
        };
    }
    
    [[YSEyeCareManager shareInstance] stopRemindtime];
    if ([YSLiveManager shareInstance].roomConfig.isRemindEyeCare)
    {
        [[YSEyeCareManager shareInstance] startRemindtime];
    }
}

- (void)roomManagerNeedEnterPassWord:(YSRoomErrorCode)errorCode
{
    [self.progressHUD bm_hideAnimated:NO];

    [[YSLiveManager shareInstance] destroy];

    BMWeakSelf
    if (errorCode == YSErrorCode_CheckRoom_PasswordError ||
        errorCode == YSErrorCode_CheckRoom_WrongPasswordForRole)
    {
        [BMAlertView ys_showAlertWithTitle:YSLocalized(@"Error.PwdError") message:nil cancelTitle:YSLocalized(@"Prompt.OK") completion:^(BOOL cancelled, NSInteger buttonIndex) {
             [weakSelf theRoomNeedPassword];
        }];
        [[YSLiveManager shareInstance] destroy];
    }
    else
    {
        [self theRoomNeedPassword];
    }
}

- (void)theRoomNeedPassword
{
    BMWeakSelf
    [YSPassWordAlert showPassWordInputAlerWithTopDistance:(UI_SCREEN_HEIGHT - 210)/2 inView:self.view backgroundEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0) sureBlock:^(NSString * _Nonnull passWord) {
        BMLog(@"%@",passWord);
        [[YSLiveManager shareInstance] destroy];
        
        YSLiveManager *liveManager = [YSLiveManager shareInstance];
        [liveManager registerRoomManagerDelegate:self];
        
        [liveManager joinRoomWithHost:[YSLiveManager shareInstance].liveHost port:YSLive_Port nickName:weakSelf.userName roomId:weakSelf.roomId roomPassword:passWord userRole:YSUserType_Student userId:nil userParams:nil needCheckPermissions:NO];
        
        [weakSelf.progressHUD bm_showAnimated:NO showBackground:YES];
    } dismissBlock:^(id  _Nullable sender, NSUInteger index) {
        if (index == 0)
        {
            [[YSLiveManager shareInstance] destroy];
        }
    }];
}

- (void)roomManagerReportFail:(YSRoomErrorCode)errorCode descript:(NSString *)descript
{
    [self.progressHUD bm_hideAnimated:NO];
    if (![YSCoreStatus isNetworkEnable])
    {
        descript = YSLocalized(@"Prompt.NetworkChanged");
    }
    [BMAlertView ys_showAlertWithTitle:descript message:nil cancelTitle:YSLocalized(@"Prompt.OK") completion:nil];
    
    [[YSLiveManager shareInstance] destroy];
}

- (void)onRoomConnectionLost
{
    [self.progressHUD bm_showAnimated:NO withText:YSLocalized(@"Error.ServerError") delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];

    [[YSLiveManager shareInstance] destroy];
}

@end

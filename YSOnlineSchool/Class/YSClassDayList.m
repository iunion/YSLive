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

#import <Bugly/Bugly.h>

#import "YSLiveApiRequest.h"
#import "YSMainVC.h"
#import "SCMainVC.h"

#import "YSEyeCareManager.h"
#import "YSPassWordAlert.h"
#import "BMAlertView+YSDefaultAlert.h"
#import "YSCoreStatus.h"

#import "YSTeacherRoleMainVC.h"

typedef void (^YSRoomLeftDoBlock)(void);

@interface YSClassDayList ()
<
    YSClassCellDelegate,
    CHSessionDelegate,
    YSClassDetailVCDelegate
>

@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *userName;

@property (nonatomic, strong) NSURLSessionDataTask *enterRoomTask;

#if 0
@property (nonatomic, strong) NSString *leftHUDmessage;
#endif

@end

@implementation YSClassDayList
@synthesize freshViewType = _freshViewType;

- (void)dealloc
{
    [_enterRoomTask cancel];
    _enterRoomTask = nil;
}

- (void)viewDidLoad
{
    _freshViewType = BMFreshViewType_NONE;

    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.bm_CanBackInteractive = NO;

    self.view.backgroundColor = YSSkinOnlineDefineColor(@"liveDefaultBgColor");
    
    // iOS 获取设备当前语言和地区的代码
    NSString *currentLanguageRegion = [[NSLocale preferredLanguages] firstObject];
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
    
    self.bm_NavigationTitleTintColor = YSSkinOnlineDefineColor(@"login_placeholderColor");
    self.bm_NavigationItemTintColor = YSSkinOnlineDefineColor(@"login_placeholderColor");
    [self bm_setNavigationWithTitle:title barTintColor:YSSkinOnlineDefineColor(@"timer_timeBgColor") leftItemTitle:nil leftItemImage:YSSkinOnlineDefineImage(@"navigationbar_back_icon") leftToucheEvent:@selector(backAction:) rightItemTitle:nil rightItemImage:YSSkinOnlineDefineImage(@"navigationbar_refresh_icon") rightToucheEvent:@selector(refreshVC)];

    
    self.loadDataType = YSAPILoadDataType_Page;
    self.showEmptyView = YES;

    [self createUI];

    [self bringSomeViewToFront];

    [self refreshVC];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [BMProgressHUD bm_hideAllHUDsForView:YSKeyWindow animated:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    GetAppDelegate.allowRotation = NO;
}

#pragma mark 横竖屏

/// 1.决定当前界面是否开启自动转屏，如果返回NO，后面两个方法也不会被调用，只是会支持默认的方向
- (BOOL)shouldAutorotate
{
    if (GetAppDelegate.useAllowRotation)
    {
        return NO;
    }
    
    return YES;
}

/// 2.返回支持的旋转方向
/// iPhone设备上，默认返回值UIInterfaceOrientationMaskAllButUpSideDwon
/// iPad设备上，默认返回值是UIInterfaceOrientationMaskAll
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

/// 3.返回进入界面默认显示方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
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
    
    if (schoolUser.userRoleType == CHUserType_Teacher)
    {
        return [YSLiveApiRequest getTeacherClassListWithUserId:schoolUser.userId
                pagesize:20 date:[self.selectedDate bm_stringWithFormat:@"yyyy-MM-dd"] pagenum:1];
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

    CHUserRoleType schoolUserType = [YSSchoolUser shareInstance].userRoleType;

    BMAFHTTPSessionManager *manager = [YSApiRequest makeYSHTTPSessionManager];
    NSMutableURLRequest *request = [YSLiveApiRequest enterOnlineSchoolClassWithWithUserType:schoolUserType toTeachId:classModel.toTeachId];
    if (request)
    {
        [self.enterRoomTask cancel];
        self.enterRoomTask = nil;
        BMWeakSelf
        self.enterRoomTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
                NSString *errorMessage;
                if ([YSCoreStatus currentNetWorkStatus] == YSCoreNetWorkStatusNone)
                {
                    errorMessage = YSLoginLocalized(@"Error.WaitingForNetwork");//@"网络错误，请稍后再试";
                }
                else
                {
                    errorMessage = YSLoginLocalized(@"Error.CanNotConnectNetworkError");//@"服务器繁忙，请稍后再试";
                }

#if YSShowErrorCode
                [weakSelf.progressHUD bm_showAnimated:NO withDetailText:[NSString stringWithFormat:@"%@: %@", @(error.code), error.localizedDescription] delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
#else
                [weakSelf.progressHUD bm_showAnimated:NO withDetailText:errorMessage delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
#endif
            }
            else
            {
                [weakSelf.progressHUD bm_hideAnimated:NO];

                NSDictionary *responseDic = [BMCloudHubUtil convertWithData:responseObject];
                if ([responseDic bm_isNotEmptyDictionary])
                {
                    NSInteger statusCode = [responseDic bm_intForKey:YSSuperVC_StatusCode_Key];
                    if (statusCode == YSSuperVC_StatusCode_Succeed)
                    {
                        NSDictionary *dataDic = [responseDic bm_dictionaryForKey:YSSuperVC_DataDic_Key];
                        
                        NSDictionary *urlParam = [dataDic bm_dictionaryForKey:@"urlParam"];
                        if ([urlParam bm_isNotEmptyDictionary])
                        {
#if 0
                            NSTimeInterval serverTime = [urlParam bm_doubleForKey:@"ts" withDefault:0];
                            if (serverTime > 0)
                            {
                                //serverTime = serverTime / 1000;
                                //NSString *str = [NSDate bm_stringFromTs:serverTime];
                                YSLiveManager *liveManager = [YSLiveManager sharedInstance];
                                liveManager.tServiceTime = serverTime;
                                NSString *message = @"";
                                BOOL stop = NO;
                                if ((liveManager.tCurrentTime - classModel.endTime) >= 30*60)
                                {
                                    stop = YES;
                                    classModel.classState = YSClassState_End;
                                    message = YSLocalizedSchool(@"ClassListCell.Enter.EndError");
                                }
                                //else if ((classModel.startTime - liveManager.tCurrentTime) >= 60*60)
                                //{
                                //    stop = YES;
                                //    message = YSLocalizedSchool(@"ClassListCell.Enter.WaitError");
                                //}

                                if (stop)
                                {
                                    [weakSelf.progressHUD bm_showAnimated:NO withDetailText:message delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
                                    return;
                                }
                            }
#endif
                            
                            NSString *serial = [urlParam bm_stringTrimForKey:@"serial"];
                            NSString *username = [urlParam bm_stringTrimForKey:@"username"];
                            NSString *userpassword = [urlParam bm_stringTrimForKey:@"userpassword"];
                            if ([serial bm_isNotEmpty])
                            {
                                YSSchoolUser *schoolUser = [YSSchoolUser shareInstance];
                                if (schoolUser.userRoleType == CHUserType_Teacher)
                                {
                                    classModel.classState = YSClassState_Begin;
                                }
                                weakSelf.roomId = serial;
                                weakSelf.userName = username;
                                [weakSelf enterSchoolRoomWithNickName:username roomId:serial passWord:userpassword];
                                
                                return;
                            }
                        }
                    }
                    else
                    {
                        NSString *message = [responseDic bm_stringTrimForKey:YSSuperVC_ErrorMessage_key withDefault:YSLoginLocalized(@"Error.ServerError")];
#if YSShowErrorCode
                        message = [NSString stringWithFormat:@"%@: %@", @(statusCode), message];
#endif
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
                            else if (statusCode == -1)
                            {
                                message = YSLocalizedSchool(@"ClassListCell.Enter.EndError");
                                classModel.classState = YSClassState_End;
                            }

                            [weakSelf.progressHUD bm_showAnimated:NO withDetailText:message delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
                        }
                        
                        return;
                    }
                }
                
                [weakSelf.progressHUD bm_showAnimated:NO withDetailText:YSLoginLocalized(@"Error.ServerError") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
            }
        }];
        [self.enterRoomTask resume];
    }
    else
    {
         [self.progressHUD bm_showAnimated:NO withDetailText:YSLoginLocalized(@"Error.ServerError") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
    }
}

- (void)enterSchoolRoomWithNickName:(NSString *)nickName roomId:(NSString *)roomId passWord:(NSString *)passWord
{
    if (![self checkKickTimeWithRoomId:roomId])
    {
        return;
    }

    //[[YSLiveManager shareInstance] destroy];
    YSLiveManager *liveManager = [YSLiveManager sharedInstance];
    [liveManager registerRoomDelegate:self];
    
    if (![passWord bm_isNotEmpty])
    {
        passWord = nil;
    }
    
    NSString *userId;
    YSSchoolUser *schoolUser = [YSSchoolUser shareInstance];
    if (schoolUser.userRoleType == CHUserType_Teacher)
    {
        userId = [NSString stringWithFormat:@"2_%@", schoolUser.userId];
    }
    else
    {
        userId = [NSString stringWithFormat:@"3_%@", schoolUser.userId];
    }
    CHUserRoleType userRoleType = schoolUser.userRoleType;

    if (![nickName bm_isNotEmpty])
    {
        nickName = userId;
        self.userName = nickName;
    }

    NSString *schoolUserAccount = schoolUser.userAccount;
    [Bugly setUserValue:roomId forKey:@"rommId"];
    [Bugly setUserValue:userId forKey:@"userId"];
    [Bugly setUserValue:nickName forKey:@"nickName"];
    [Bugly setUserValue:schoolUserAccount forKey:@"userAccount"];

    [liveManager joinRoomWithHost:liveManager.apiHost port:YSLive_Port nickName:nickName roomId:roomId roomPassword:passWord userRole:userRoleType userId:userId userParams:nil needCheckPermissions:NO];
    
    [self.progressHUD bm_showAnimated:NO showBackground:YES];
}

- (BOOL)checkKickTimeWithRoomId:(NSString *)roomId
{
    YSSchoolUser *schoolUser = [YSSchoolUser shareInstance];
    if (schoolUser.userRoleType == CHUserType_Student)
    {
        // 学生被T 3分钟内不能登录
        NSString *roomIdKey = [NSString stringWithFormat:@"%@_%@", YSKickTime, roomId];
        
        id idTime = [[NSUserDefaults standardUserDefaults] objectForKey:roomIdKey];
        if (idTime && [idTime isKindOfClass:NSDate.class])
        {
            NSDate *time = (NSDate *)idTime;
            NSDate *curTime = [NSDate date];
            // 计算出相差多少秒
            NSTimeInterval delta = [curTime timeIntervalSinceDate:time];
            
            if (delta < 60 * 3)
            {
                NSString *content =  YSLoginLocalized(@"Prompt.kick");
                [BMAlertView ys_showAlertWithTitle:content message:nil cancelTitle:nil completion:nil];
                return NO;
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:roomIdKey];
            }
        }
    }
    
    return YES;
}


#pragma mark -
#pragma mark YSRoomInterfaceDelegate

- (void)waitRoomLeft:(YSRoomLeftDoBlock)doSometing
{
    [self.progressHUD bm_showAnimated:NO showBackground:YES];
    [[YSLiveManager sharedInstance] leaveRoom:nil];
    if (doSometing)
    {
        doSometing();
    }
}

// 成功进入房间
- (void)onRoomDidCheckRoom
{
    BMLog(@"YSLoginVC onRoomDidCheckRoom");
    
    [self.progressHUD bm_hideAnimated:NO];
    
    YSLiveManager *liveManager = [YSLiveManager sharedInstance];

    YSSchoolUser *schoolUser = [YSSchoolUser shareInstance];

    NSString *roomId = liveManager.room_Id ? liveManager.room_Id : @"";
    NSString *userId = liveManager.localUser.peerID ? liveManager.localUser.peerID : @"";
    NSString *nickName = liveManager.localUser.nickName ? liveManager.localUser.nickName : @"";
    NSString *schoolUserAccount = schoolUser.userAccount;

    [Bugly setUserValue:roomId forKey:@"rommId"];
    [Bugly setUserValue:userId forKey:@"userId"];
    [Bugly setUserValue:nickName forKey:@"nickName"];
    [Bugly setUserValue:schoolUserAccount forKey:@"userAccount"];

    CHRoomUseType appUseTheType = liveManager.room_UseType;

    // 3: 小班课  4: 直播  6： 会议
    if (appUseTheType == CHRoomUseTypeSmallClass || appUseTheType == CHRoomUseTypeMeeting)
    {
        [YSLiveSkinManager shareInstance].skinBundle = [CHSessionManager sharedInstance].skinBundle;
        
        [YSLiveSkinManager shareInstance].isSmallVC = YES;
        
        GetAppDelegate.allowRotation = YES;
        NSUInteger maxvideo = [liveManager.roomDic bm_uintForKey:@"maxvideo"];
        CHRoomUserType roomusertype = liveManager.roomModel.roomUserType;

        BOOL isWideScreen = liveManager.room_IsWideScreen;
        
        CHUserRoleType roleType = liveManager.localUser.role;
        
        if (roleType == CHUserType_Teacher)
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
    if (liveManager.roomConfig.isRemindEyeCare)
    {
        [[YSEyeCareManager shareInstance] startRemindtime];
    }
}

- (void)roomManagerNeedEnterPassWord:(CHRoomErrorCode)errorCode
{
    [self.progressHUD bm_hideAnimated:NO];

    [YSLiveManager destroy];

    BMWeakSelf
    if (errorCode == CHErrorCode_CheckRoom_PasswordError ||
        errorCode == CHErrorCode_CheckRoom_WrongPasswordForRole)
    {
        [BMAlertView ys_showAlertWithTitle:YSLoginLocalized(@"Error.PwdError") message:nil cancelTitle:YSLoginLocalized(@"Prompt.OK") completion:^(BOOL cancelled, NSInteger buttonIndex) {
             [weakSelf theRoomNeedPassword];
        }];
    }
    else
    {
        [self theRoomNeedPassword];
    }
}

- (void)theRoomNeedPassword
{
    BMWeakSelf
    [YSPassWordAlert showPassWordInputAlerWithTopDistance:(BMUI_SCREEN_HEIGHT - 210)/2 inView:self.view backgroundEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0) sureBlock:^(NSString * _Nonnull passWord) {
        BMLog(@"%@",passWord);
        //[YSLiveManager destroy];
        
        YSLiveManager *liveManager = [YSLiveManager sharedInstance];
        [liveManager registerRoomDelegate:self];
        
        [liveManager joinRoomWithHost:liveManager.apiHost port:YSLive_Port nickName:weakSelf.userName roomId:weakSelf.roomId roomPassword:passWord userRole:CHUserType_Student userId:nil userParams:nil needCheckPermissions:NO];
        
        [weakSelf.progressHUD bm_showAnimated:NO showBackground:YES];
    } dismissBlock:^(id  _Nullable sender, NSUInteger index) {
        //if (index == 0)
        //{
        //    [YSLiveManager destroy];
        //}
    }];
}

/// 进入房间失败
- (void)onRoomJoinFailed:(NSDictionary *)errorDic
{
    NSError *error = [errorDic objectForKey:@"error"];
    CHRoomErrorCode errorCode = error.code;
    NSString *descript = [YSLiveUtil getOccuredErrorCode:errorCode];
    
    NSLog(@"================================== onRoomJoinFailed: %@, %@", @(errorCode), descript);
    
    if (errorCode == CHErrorCode_CheckRoom_NeedPassword ||
        errorCode == CHErrorCode_CheckRoom_PasswordError ||
        errorCode == CHErrorCode_CheckRoom_WrongPasswordForRole)
    {
        [self roomManagerNeedEnterPassWord:errorCode];
        return;
    }

#if YSShowErrorCode
    NSString *errorMessage = [NSString stringWithFormat:@"%@: %@", @(errorCode), descript];
#else
    NSString *errorMessage = descript;
#endif
    [self.progressHUD bm_showAnimated:NO withDetailText:errorMessage delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];

#if 0
#if YSShowErrorCode
    self.leftHUDmessage = [NSString stringWithFormat:@"%@: %@", @(errorCode), descript];
#else
    self.leftHUDmessage = descript;
#endif
    
    [self waitRoomLeft:nil];
#endif
    
//    [self.progressHUD bm_hideAnimated:NO];
//    if (![YSCoreStatus isNetworkEnable])
//    {
//        descript = YSLoginLocalized(@"Prompt.NetworkChanged");
//    }
//    [BMAlertView ys_showAlertWithTitle:descript message:nil cancelTitle:YSLoginLocalized(@"Prompt.OK") completion:nil];
//
//    [YSLiveManager destroy];
}

- (void)onRoomConnectionLost
{
    [self waitRoomLeft:nil];
//    [self.progressHUD bm_showAnimated:NO withDetailText:YSLoginLocalized(@"Error.ServerError") delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
//
//    [YSLiveManager destroy];
}

/// 发生错误 回调
- (void)onRoomDidOccuredError:(CloudHubErrorCode)errorCode withMessage:(NSString *)message
{
    NSLog(@"================================== onRoomDidOccuredError: %@", message);
    
#if YSShowErrorCode
    NSString *errorMessage = [NSString stringWithFormat:@"%@: %@", @(errorCode), message];
#else
    NSString *errorMessage = message;
#endif
    
    [self.progressHUD bm_showAnimated:NO withDetailText:errorMessage delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
}

// 已经离开房间
- (void)onRoomLeft
{
    NSString *errorMessage;
#if 0
    if (self.leftHUDmessage)
    {
        errorMessage = self.leftHUDmessage;
    }
    else
#endif
    {
        if ([YSCoreStatus currentNetWorkStatus] == YSCoreNetWorkStatusNone)
        {
            errorMessage = YSLoginLocalized(@"Error.WaitingForNetwork");//@"网络错误，请稍后再试";
        }
        else
        {
            errorMessage = YSLoginLocalized(@"Error.CanNotConnectNetworkError");//@"服务器繁忙，请稍后再试";
        }
    }

    [self.progressHUD bm_showAnimated:NO withDetailText:errorMessage delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
    
#if 0
    self.leftHUDmessage = nil;
#endif

    [YSLiveManager destroy];
}

@end

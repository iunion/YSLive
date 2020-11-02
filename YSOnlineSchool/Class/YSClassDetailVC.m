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
#import "AppDelegate.h"

#import "YSLiveApiRequest.h"
#import "YSSchoolUser.h"
#import "YSMP4PlayerMaskView.h"
#import "YSCoreStatus.h"

@interface YSClassDetailVC ()
<
    YSClassCellDelegate,
    YSClassMediumCellDelegate
>

@property (nonatomic, strong) YSClassReplayListModel *classReplayListModel;
@property (nonatomic, strong) YSMP4PlayerMaskView *playerMaskView;
@property (nonatomic, assign) BOOL statusHiden;
@end

@implementation YSClassDetailVC
@synthesize freshViewType = _freshViewType;

- (void)viewDidLoad
{    
    _freshViewType = BMFreshViewType_NONE;

    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = YSSkinOnlineDefineColor(@"liveDefaultBgColor");

    self.bm_NavigationTitleTintColor = YSSkinOnlineDefineColor(@"login_placeholderColor");
    self.bm_NavigationItemTintColor = YSSkinOnlineDefineColor(@"login_placeholderColor");
    [self bm_setNavigationWithTitle:YSLocalizedSchool(@"ClassDetail.Title") barTintColor:YSSkinOnlineDefineColor(@"timer_timeBgColor") leftItemTitle:nil leftItemImage:YSSkinOnlineDefineImage(@"navigationbar_back_icon") leftToucheEvent:@selector(backAction:) rightItemTitle:nil rightItemImage:YSSkinOnlineDefineImage(@"navigationbar_refresh_icon") rightToucheEvent:@selector(refreshVC)];
    
    self.showEmptyView = YES;

    [self createUI];
    
    [self bringSomeViewToFront];

    [self.dataArray addObject:@"1"];

    [self refreshVC];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [BMProgressHUD bm_hideAllHUDsForView:YSKeyWindow animated:YES];
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
    self.tableView.allowsSelection = NO;
}

- (void)refreshVC
{
    [self loadApiData];
    
    /*
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
    classReviewModel1.part = @"1";
    classReviewModel1.duration = @"35'12''";
    classReviewModel1.size = @"112.36M";

    YSClassReviewModel *classReviewModel2 = [[YSClassReviewModel alloc] init];
    classReviewModel2.part = @"2";
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
     */
}

- (BMEmptyViewType)getNoDataEmptyViewType
{
    return BMEmptyViewType_ClassError;
}

- (NSMutableURLRequest *)setLoadDataRequest
{
    YSSchoolUser *schoolUser = [YSSchoolUser shareInstance];
    NSString *organId = schoolUser.organId;
    NSString *toTeachId = self.linkClassModel.toTeachId;
    NSString *lessonsId = self.linkClassModel.lessonsId;
    NSString *starttime = self.linkClassModel.startTimeStr;
    NSString *endtime = self.linkClassModel.endTimeStr;

    if (schoolUser.userRoleType == CHUserType_Teacher)
    {
        return [YSLiveApiRequest getTeacherClassInfoWithToteachtimeid:toTeachId lessonsid:lessonsId starttime:starttime endtime:endtime date:[self.selectedDate bm_stringWithFormat:@"yyyy-MM-dd"]];
    }
    else
    {
        return [YSLiveApiRequest getClassReplayListWithOrganId:organId toTeachId:toTeachId];
    }

}

- (BOOL)succeedLoadedRequestWithDic:(NSDictionary *)data
{
    if (![data bm_isNotEmptyDictionary])
    {
        return NO;
    }
    
#if DEBUG
    NSString *sss = [[NSString stringWithFormat:@"%@", data] bm_convertUnicode];
#endif
    
    YSSchoolUser *schoolUser = [YSSchoolUser shareInstance];
    if (schoolUser.userRoleType == CHUserType_Teacher)
    {
        data = [data bm_dictionaryForKey:@"playback"];
        data = [data bm_dictionaryForKey:@"data"];
    }

    YSClassReplayListModel *classReplayListModel = [YSClassReplayListModel classReplayListModelWithServerDic:data];
    self.classReplayListModel = classReplayListModel;
    
    [self.tableView reloadData];
    
    return YES;
}


#pragma mark -
#pragma mark Table Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.linkClassModel bm_isNotEmpty])
    {
        return 2;
//        if ([self.classReplayListModel.classReplayList bm_isNotEmpty])
//        {
//            return 2;
//        }
//        else
//        {
//            return 1;
//        }
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
            if (self.classReplayListModel)
            {
                return [self.classReplayListModel calculateMediumCellHeight];
            }
            else
            {
                return YSClassReplayView_NoDateHeight+45.0f+5.0f;
            }
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
            [cell drawCellWithModel:self.linkClassModel isDetail:YES];
            
            return cell;
        }
        
//        case 1:
//            {
//                YSClassInstructionCell *cell = [[NSBundle mainBundle] loadNibNamed:@"YSClassInstructionCell" owner:self options:nil].firstObject;
//                [cell drawCellWithModel:self.classDetailModel];
//
//                return cell;
//            }

        case 1:
            {
                YSClassMediumCell *cell = [[NSBundle mainBundle] loadNibNamed:@"YSClassMediumCell" owner:self options:nil].firstObject;
                [cell drawCellWithModel:self.classReplayListModel withClassState:self.linkClassModel.classState];
                cell.delegate = self;
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


- (void)playReviewClassWithClassReviewModel:(YSClassReviewModel *)classReviewModel index:(NSUInteger)replayIndex
{
    
    self.navigationController.navigationBarHidden = YES;
    self.statusHiden = YES;
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    
    _playerMaskView = [[YSMP4PlayerMaskView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
    _playerMaskView.isWiFi = [YSCoreStatus isWifiEnable];
    _playerMaskView.titleLab.text = [NSString stringWithFormat:@"%@_%@", self.classReplayListModel.lessonsName, classReviewModel.part];
    [self.view addSubview:_playerMaskView];
    //@"http://vfx.mtime.cn/Video/2019/03/21/mp4/190321153853126488.mp4"
    [_playerMaskView playWithVideoUrl:classReviewModel.linkUrl];
//    [_playerMaskView playWithVideoUrl:@"http://vfx.mtime.cn/Video/2019/03/21/mp4/190321153853126488.mp4"];
    [_playerMaskView.player play];
    _playerMaskView.transform = CGAffineTransformMakeRotation(M_PI*0.5);
    _playerMaskView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    _playerMaskView.showFullBtn = NO;
    BMWeakSelf
    _playerMaskView.closeBlock = ^{
        [weakSelf.playerMaskView.player stop];
        weakSelf.navigationController.navigationBarHidden = NO;
        weakSelf.statusHiden = NO;
        [weakSelf performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        [weakSelf.playerMaskView removeFromSuperview];
    };
}

- (BOOL)prefersStatusBarHidden
{
    return self.statusHiden;
}

#pragma mark - YSClassCellDelegate

- (void)enterClassWith:(YSClassModel *)classModel
{
    if ([self.delegate respondsToSelector:@selector(enterClassWith:)])
    {
        [self.delegate enterClassWith:self.linkClassModel];
    }
}

@end

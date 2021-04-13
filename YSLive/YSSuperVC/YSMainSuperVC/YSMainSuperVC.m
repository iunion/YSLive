//
//  YSMainSuperVC.m
//  YSLive
//
//  Created by jiang deng on 2019/11/7.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSMainSuperVC.h"
#if YSSDK
#import "YSSDKManager.h"
#else
#import "AppDelegate.h"
#endif
//#import <AVFoundation/AVFoundation.h>

#define YSChangeMediaLine_Delay     5.0f

@interface YSMainSuperVC ()
<
    BMKeystoneCorrectionViewDelegate
>

@property (nonatomic, weak) YSLiveManager *liveManager;
/// 白板视图whiteBord
@property (nonatomic, weak) UIView *whiteBordView;

/// 视频矫正窗口
@property (nonatomic, strong) BMKeystoneCorrectionView *keystoneCorrectionView;

@end

@implementation YSMainSuperVC

- (NSMutableArray<CHVideoView *> *)teacherVideoViewArray
{
    if (!_teacherVideoViewArray)
    {
        _teacherVideoViewArray = [NSMutableArray array];
    }
    return _teacherVideoViewArray;
}

- (NSMutableArray<CHVideoView *> *)teacherVideoViewArrayFull
{
    if (!_teacherVideoViewArrayFull)
    {
        _teacherVideoViewArrayFull = [NSMutableArray array];
    }
    return _teacherVideoViewArrayFull;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.bm_CanBackInteractive = NO;
        [self setRoomManagerDelegate];
        
        self.videoViewArrayDic = [[NSMutableDictionary alloc] init];
        self.videoViewArrayDicFull = [[NSMutableDictionary alloc] init];
        self.myVideoViewArrFull = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithWhiteBordView:(UIView *)whiteBordView;
{
    self = [self init];
    if (self)
    {
        self.whiteBordView = whiteBordView;
    }
    return self;
}

- (void)setRoomManagerDelegate
{
    self.liveManager = [YSLiveManager sharedInstance];
    [self.liveManager registerRoomDelegate:self];
    self.liveManager.whiteBoardDelegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupKeystoneCorrectionView];
}

- (void)setupKeystoneCorrectionView
{
    if (!self.liveManager.roomConfig.hasVideoAdjustment)
    {
        return;
    }
    
    BMKeystoneCorrectionView *keystoneCorrectionView = [[BMKeystoneCorrectionView alloc] initWithFrame:self.view.bounds liveManager:self.liveManager];
    [self.view addSubview:keystoneCorrectionView];
    keystoneCorrectionView.delegate = self;
    keystoneCorrectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.keystoneCorrectionView = keystoneCorrectionView;
    self.keystoneCorrectionView.hidden = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.keystoneCorrectionView bm_bringToFront];
    [self.progressHUD bm_bringToFront];
}

- (void)showKeystoneCorrectionView
{
    if (!self.keystoneCorrectionView.hidden)
    {
        return;
    }
    
    self.keystoneCorrectionView.hidden = NO;
    
    NSString *userId = CHLocalUser.peerID;
    CloudHubVideoRenderMode renderType = CloudHubVideoRenderModeFit;
    CloudHubVideoMirrorMode videoMirrorMode = CloudHubVideoMirrorModeDisabled;
    NSString *streamId = [NSString stringWithFormat:@"%@:video:%@", userId, sCHUserDefaultSourceId];

    [self.liveManager stopVideoWithUserId:userId streamID:streamId];
    [self.liveManager playVideoWithUserId:userId streamID:streamId renderMode:renderType mirrorMode:videoMirrorMode inView:self.keystoneCorrectionView.liveView];
}

- (void)hideKeystoneCorrectionView
{
    self.keystoneCorrectionView.hidden = YES;
    
    if (!self.myVideoView)
    {
        return;
    }
    
    [self playVideoAudioWithNewVideoView:self.myVideoView];
}


#pragma mark - BMKeystoneCorrectionViewDelegate

- (void)keystoneCorrectionViewClose
{
    [self hideKeystoneCorrectionView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // 关闭自动锁屏，保证屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 自动锁屏
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

/// 1.决定当前界面是否开启自动转屏，如果返回NO，后面两个方法也不会被调用，只是会支持默认的方向
- (BOOL)shouldAutorotate
{
#if YSAutorotateNO
    return NO;
#else
#if YSSDK
    if ([YSSDKManager sharedInstance].useAppDelegateAllowRotation)
    {
        return NO;
    }
#else
    if (GetAppDelegate.useAllowRotation)
    {
        return NO;
    }
#endif
    
    return YES;
#endif
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

- (void)showEyeCareRemind
{
    
}

#pragma mark - videoViewArray

- (NSUInteger)getVideoViewCount
{
    NSUInteger count = 0;

    for (CHVideoView *videoView in self.videoSequenceArr)
    {
        if (!videoView.isDragOut && !videoView.isFullScreen)
        {
            count++;
        }
    }

    return count;
}


#pragma mark - 视频窗口

- (void)playVideoAudioWithVideoView:(CHVideoView *)videoView
{
    [self playVideoAudioWithVideoView:videoView needFreshVideo:NO];
}

// 在原视窗刷新视频
- (void)playVideoAudioWithVideoView:(CHVideoView *)videoView needFreshVideo:(BOOL)fresh
{
    if (!videoView)
    {
        return;
    }
    
    NSString *userId = videoView.roomUser.peerID;
    if ([userId isEqualToString:CHLocalUser.peerID])
    {
        self.myVideoView = videoView;

        if (self.keystoneCorrectionView && !self.keystoneCorrectionView.hidden)
        {
            [self showKeystoneCorrectionView];
            return;
        }
    }

    NSDictionary * sourceDict = [videoView.roomUser.sourceListDic bm_dictionaryForKey:videoView.sourceId];
    
    CHSessionMuteState newVideoMute = [sourceDict bm_uintForKey:sCHUserDiveceMute];
    CloudHubVideoRenderMode renderType = CloudHubVideoRenderModeHidden;

    fresh = NO;
    
    CloudHubVideoMirrorMode videoMirrorMode = CloudHubVideoMirrorModeDisabled;
    if (self.appUseTheType != CHRoomUseTypeLiveRoom)
    {
        if (self.liveManager.roomConfig.isMirrorVideo)
        {
            if ([videoView.roomUser.properties bm_boolForKey:sCHUserIsVideoMirror])
            {
                videoMirrorMode = CloudHubVideoMirrorModeEnabled;
            }
        }
    }
        
    if (videoView.streamId == nil)
    {
        NSArray *streamIdArray = [self.liveManager.userStreamIds_userId bm_arrayForKey:userId];
        
        for (NSString * streamId in streamIdArray)
        {
            if ([streamId containsString:videoView.sourceId])
            {
                videoView.streamId = streamId;
            }
        }
    }
    
    if (newVideoMute == CHSessionMuteState_UnMute)
    {
        [self.liveManager playVideoWithUserId:userId streamID:videoView.streamId renderMode:renderType mirrorMode:videoMirrorMode inView:videoView.contentView];
    }
    else
    {
        [self.liveManager stopVideoWithUserId:userId streamID:videoView.streamId];
    }
    
#if FRESHWITHROOMUSER
    [videoView freshWithRoomUserProperty:videoView.roomUser];
    videoView.audioMute = videoView.roomUser.audioMute;
    videoView.videoMute = [sourceDict bm_uintForKey:sCHUserDiveceMute];
#endif
}

// 创建或更换视窗显示视频
- (void)playVideoAudioWithNewVideoView:(CHVideoView *)videoView
{
    if (!videoView)
    {
        return;
    }

    NSString *userId = videoView.roomUser.peerID;
    if ([userId isEqualToString:CHLocalUser.peerID])
    {
        self.myVideoView = videoView;

        if (self.keystoneCorrectionView && !self.keystoneCorrectionView.hidden)
        {
            [self showKeystoneCorrectionView];
            return;
        }
    }

    NSDictionary * sourceDict = [videoView.roomUser.sourceListDic bm_dictionaryForKey:videoView.sourceId];
    
    CHSessionMuteState newVideoMute = [sourceDict bm_uintForKey:sCHUserDiveceMute];
    CloudHubVideoRenderMode renderType = CloudHubVideoRenderModeHidden;
    CloudHubVideoMirrorMode videoMirrorMode = CloudHubVideoMirrorModeDisabled;
    if (self.appUseTheType != CHRoomUseTypeLiveRoom)
    {
        if (self.liveManager.roomConfig.isMirrorVideo)
        {
            if ([videoView.roomUser.properties bm_boolForKey:sCHUserIsVideoMirror])
            {
                videoMirrorMode = CloudHubVideoMirrorModeEnabled;
            }
        }
    }
    
    if (newVideoMute == CHSessionMuteState_UnMute)
    {
        [self.liveManager stopVideoWithUserId:userId streamID:videoView.streamId];
        [self.liveManager playVideoWithUserId:userId streamID:videoView.streamId renderMode:renderType mirrorMode:videoMirrorMode inView:videoView.contentView];
    }
    else
    {
        [self.liveManager stopVideoWithUserId:userId streamID:videoView.streamId];
    }
    
#if FRESHWITHROOMUSER
    [videoView freshWithRoomUserProperty:videoView.roomUser];

    videoView.audioMute = videoView.roomUser.audioMute;
    videoView.videoMute = [sourceDict bm_uintForKey:sCHUserDiveceMute];
#endif
}

- (void)stopVideoAudioWithVideoView:(CHVideoView *)videoView
{
    if (!videoView)
    {
        return;
    }
    
    NSString *userId = videoView.roomUser.peerID;
    if ([userId isEqualToString:CHLocalUser.peerID])
    {
        self.myVideoView = videoView;

        if (self.keystoneCorrectionView && !self.keystoneCorrectionView.hidden)
        {
            [self showKeystoneCorrectionView];
            return;
        }
    }
    
    [self.liveManager stopVideoWithUserId:userId streamID:videoView.streamId];
}

///视频窗口排序
- (void)videoViewsSequence
{
    self.videoSequenceArr = [NSMutableArray array];
    self.videoSequenceArrFull = [NSMutableArray array];
    if (!self.liveManager.isClassBegin)
    {
        NSArray * videoArray = self.videoViewArrayDic.allValues.firstObject;
        if (videoArray.count == 1)
        {
            [self.videoSequenceArr addObject:videoArray[0]];
        }
        else if (videoArray.count > 1)
        {
            CHVideoView * videoView0 = videoArray[0];
            CHVideoView * videoView1 = videoArray[1];
            NSComparisonResult result =  [videoView0.sourceId compare:videoView1.sourceId];
            
            if (result == NSOrderedAscending)
            {//左边小于右边
                [self.videoSequenceArr addObjectsFromArray:videoArray];
            }
            else
            {
                [self.videoSequenceArr addObject:videoView1];
                [self.videoSequenceArr addObject:videoView0];
            }
        }
        
        //（全屏浮窗用）-----------
        NSArray * videoArrayFull = self.videoViewArrayDicFull.allValues.firstObject;
        if (videoArrayFull.count == 1)
        {
            [self.videoSequenceArrFull addObject:videoArrayFull[0]];
        }
        else if (videoArrayFull.count > 1)
        {
            CHVideoView * videoView0 = videoArrayFull[0];
            CHVideoView * videoView1 = videoArrayFull[1];
            NSComparisonResult result =  [videoView0.sourceId compare:videoView1.sourceId];
            
            if (result == NSOrderedAscending)
            {//左边小于右边
                [self.videoSequenceArrFull addObjectsFromArray:videoArrayFull];
            }
            else
            {
                [self.videoSequenceArrFull addObject:videoView1];
                [self.videoSequenceArrFull addObject:videoView0];
            }
        }
    }
    else
    {
        NSMutableArray * idArr = [self.videoViewArrayDic.allKeys mutableCopy];
        [idArr removeObject:self.liveManager.teacher.peerID];
        [idArr removeObject:self.liveManager.classMaster.peerID];
        
        // id正序排序
        [idArr sortUsingComparator:^NSComparisonResult(NSString * _Nonnull peerId1, NSString * _Nonnull peerId2) {
            return [peerId1 compare:peerId2];
        }];
        
        for (NSString *peerId in idArr)
        {
            NSArray * arr = [self.videoViewArrayDic bm_arrayForKey:peerId];
            
            if (arr.count == 1)
            {
                [self.videoSequenceArr addObject:arr[0]];
            }
            else if (arr.count > 1)
            {
                CHVideoView * videoView0 = arr[0];
                CHVideoView * videoView1 = arr[1];
                NSComparisonResult result =  [videoView0.sourceId compare:videoView1.sourceId];
                
                if (result == NSOrderedAscending)
                {//左边小于右边
                    [self.videoSequenceArr addObjectsFromArray:arr];
                }
                else
                {
                    [self.videoSequenceArr addObject:videoView1];
                    [self.videoSequenceArr addObject:videoView0];
                }
            }
        }
        
        //（全屏浮窗用）-----------
        NSMutableArray * idArrFull = [self.videoViewArrayDicFull.allKeys mutableCopy];
        [idArrFull removeObject:self.liveManager.teacher.peerID];
        [idArrFull removeObject:self.liveManager.classMaster.peerID];
        
        // id正序排序
        [idArrFull sortUsingComparator:^NSComparisonResult(NSString * _Nonnull peerId1, NSString * _Nonnull peerId2) {
            return [peerId1 compare:peerId2];
        }];
        
        for (NSString *peerId in idArrFull)
        {
            NSArray * arr = [self.videoViewArrayDicFull bm_arrayForKey:peerId];
            
            if (arr.count == 1)
            {
                [self.videoSequenceArrFull addObject:arr[0]];
            }
            else if (arr.count > 1)
            {
                CHVideoView * videoView0 = arr[0];
                CHVideoView * videoView1 = arr[1];
                NSComparisonResult result =  [videoView0.sourceId compare:videoView1.sourceId];
                
                if (result == NSOrderedAscending)
                {//左边小于右边
                    [self.videoSequenceArrFull addObjectsFromArray:arr];
                }
                else
                {
                    [self.videoSequenceArrFull addObject:videoView1];
                    [self.videoSequenceArrFull addObject:videoView0];
                }
            }
        }
        
        // 分组教室
        if (self.liveManager.isGroupRoom)
        {
            [self insertVideoViewWithArray:self.classMasterVideoViewArray];
            [self insertVideoViewWithArrayFull:self.classMasterVideoViewArrayFull];
            
//            if (self.liveManager.isGroupBegin)
//            {
                [self insertVideoViewWithArray:self.teacherVideoViewArray];
            [self insertVideoViewWithArrayFull:self.teacherVideoViewArrayFull];
//            }
        }
        else
        {
            ///把老师插入最前面
            [self insertVideoViewWithArray:self.teacherVideoViewArray];
            [self insertVideoViewWithArrayFull:self.teacherVideoViewArrayFull];
        }
    }
}

- (void)insertVideoViewWithArray:(NSArray<CHVideoView *>*)videoViewArray
{
    if (videoViewArray.count == 1)
    {
        [self.videoSequenceArr insertObject:videoViewArray[0] atIndex:0];
    }
    else if (videoViewArray.count > 1)
    {
        CHVideoView * videoView0 = videoViewArray[0];
        CHVideoView * videoView1 = videoViewArray[1];
        NSComparisonResult result =  [videoView0.sourceId compare:videoView1.sourceId];
        
        if (result == NSOrderedAscending)
        {//左边小于右边
            [self.videoSequenceArr insertObject:videoView1 atIndex:0];
            [self.videoSequenceArr insertObject:videoView0 atIndex:0];
        }
        else
        {
            [self.videoSequenceArr insertObject:videoView0 atIndex:0];
            [self.videoSequenceArr insertObject:videoView1 atIndex:0];
        }
    }
}

- (void)insertVideoViewWithArrayFull:(NSArray<CHVideoView *>*)videoViewArray
{
    if (videoViewArray.count == 1)
    {
        [self.videoSequenceArrFull insertObject:videoViewArray[0] atIndex:0];
    }
    else if (videoViewArray.count > 1)
    {
        CHVideoView * videoView0 = videoViewArray[0];
        CHVideoView * videoView1 = videoViewArray[1];
        NSComparisonResult result =  [videoView0.sourceId compare:videoView1.sourceId];
        
        if (result == NSOrderedAscending)
        {//左边小于右边
            [self.videoSequenceArrFull insertObject:videoView1 atIndex:0];
            [self.videoSequenceArrFull insertObject:videoView0 atIndex:0];
        }
        else
        {
            [self.videoSequenceArrFull insertObject:videoView0 atIndex:0];
            [self.videoSequenceArrFull insertObject:videoView1 atIndex:0];
        }
    }
}


///给videoViewArrayDic中添加视频
- (void)addVideoViewToVideoViewArrayDic:(CHVideoView *)videoView
{
    if (videoView)
    {
        NSMutableArray * videoArr = [self.videoViewArrayDic bm_mutableArrayForKey:videoView.roomUser.peerID];
        if (![videoArr containsObject:videoView])
        {
            [videoArr addObject:videoView];
        }
        
        [self.videoViewArrayDic setObject:videoArr forKey:videoView.roomUser.peerID];

        [self videoViewsSequence];
        
        if (videoView.roomUser.role == CHUserType_Teacher)
        {
            self.teacherVideoViewArray = videoArr;
        }
        else if (videoView.roomUser.role == CHUserType_ClassMaster)
        {
            self.classMasterVideoViewArray = videoArr;
        }
    }
}

///给videoViewArrayDicFull中添加视频（全屏浮窗用）
- (void)addVideoViewToVideoViewArrayDicFull:(CHVideoView *)videoView
{
    if (videoView)
    {
        NSMutableArray * videoArrFull = [self.videoViewArrayDicFull bm_mutableArrayForKey:videoView.roomUser.peerID];
        if (![videoArrFull containsObject:videoView])
        {
            [videoArrFull addObject:videoView];
        }
        
        [self.videoViewArrayDicFull setObject:videoArrFull forKey:videoView.roomUser.peerID];

        [self videoViewsSequence];
        
        if (videoView.roomUser.role == CHUserType_Teacher)
        {
            self.teacherVideoViewArrayFull = videoArrFull;
        }
        else if (videoView.roomUser.role == CHUserType_ClassMaster)
        {
            self.classMasterVideoViewArrayFull = videoArrFull;
        }
    }
}

///从videoViewArrayDic中移除视频
- (void)deleteVideoViewfromVideoViewArrayDic:(CHVideoView *)videoView
{
    NSMutableArray * videoArr = [self.videoViewArrayDic bm_mutableArrayForKey:videoView.roomUser.peerID];
    
    if ([videoArr containsObject:videoView])
    {
        [videoArr removeObject:videoView];
        [self.videoSequenceArr removeObject:videoView];
        if (videoArr.count)
        {
            [self.videoViewArrayDic setObject:videoArr forKey:videoView.roomUser.peerID];
        }
        else
        {
            [self.videoViewArrayDic removeObjectForKey:videoView.roomUser.peerID];
        }
        
        if (videoView.roomUser.role == CHUserType_Teacher)
        {
            self.teacherVideoViewArray = videoArr;
        }
        else if (videoView.roomUser.role == CHUserType_ClassMaster)
        {
            self.classMasterVideoViewArray = videoArr;
        }
    }
}

///从videoViewArrayDicFull中移除视频（全屏浮窗用）
- (void)deleteVideoViewfromVideoViewArrayDicFull:(CHVideoView *)videoView
{
    //（全屏浮窗用）
    NSMutableArray * videoArrFull = [self.videoViewArrayDicFull bm_mutableArrayForKey:videoView.roomUser.peerID];
    if ([videoArrFull containsObject:videoView])
    {
        [videoArrFull removeObject:videoView];
        
        [self.videoSequenceArrFull removeObject:videoView];
        if (videoArrFull.count)
        {
            [self.videoViewArrayDicFull setObject:videoArrFull forKey:videoView.roomUser.peerID];
        }
        else
        {
            [self.videoViewArrayDicFull removeObjectForKey:videoView.roomUser.peerID];
        }
    }
    
    if (videoView.roomUser.role == CHUserType_Teacher)
    {
        self.teacherVideoViewArrayFull = videoArrFull;
    }
    else if (videoView.roomUser.role == CHUserType_ClassMaster)
    {
        self.classMasterVideoViewArrayFull = videoArrFull;
    }
    
    if ([YSCurrentUser.peerID isEqualToString:videoView.roomUser.peerID])
    {
        self.myVideoViewArrFull = videoArrFull;
    }
}


#pragma mark  添加视频窗口
- (NSMutableArray<CHVideoView *> *)addVideoViewWithPeerId:(NSString *)peerId
{
    return [self addVideoViewWithPeerId:peerId withMaxCount:0];
}

///新上台时添加
- (NSMutableArray<CHVideoView *> *)addVideoViewWithPeerId:(NSString *)peerId withMaxCount:(NSUInteger)count
{
    CHRoomUser *roomUser = [self.liveManager getRoomUserWithId:peerId];
    if (!roomUser)
    {
        return nil;
    }
    
    //本人的视频数组
    NSMutableArray *myVideoArray = [self.videoViewArrayDic bm_mutableArrayForKey:self.liveManager.localUser.peerID];
    //本人的视频数组（全屏浮窗用）
    NSMutableArray *myVideoArrayFull = [self.videoViewArrayDicFull bm_mutableArrayForKey:self.liveManager.localUser.peerID];
    
    // 删除本人占位视频
    for (CHVideoView *avideoView in myVideoArray)
    {
        if (avideoView.isForPerch)
        {
            [myVideoArray removeObject:avideoView];
            
            [self.videoViewArrayDic setObject:myVideoArray forKey:self.liveManager.localUser.peerID];
            [self.videoSequenceArr removeObject:avideoView];
            
            break;
        }
    }
    
    for (CHVideoView *avideoView in myVideoArrayFull)
    {
        if (avideoView.isForPerch)
        {
            [myVideoArrayFull removeObject:avideoView];
            
            [self.videoViewArrayDicFull setObject:myVideoArrayFull forKey:self.liveManager.localUser.peerID];
            [self.videoSequenceArrFull removeObject:avideoView];
            
            break;
        }
    }
    
    //用户新下发的设备id数组
    NSMutableArray *theSourceIdArray = [roomUser.sourceListDic.allKeys mutableCopy];
    
    //视频数组
    NSMutableArray *theVideoArray = [NSMutableArray array];
    //视频数组（全屏浮窗用）
    NSMutableArray *theVideoArrayFull = [NSMutableArray array];
    
    if (!theSourceIdArray.count)
    {
        CHVideoView *newVideoView = [[CHVideoView alloc] initWithRoomUser:roomUser withSourceId:sCHUserDefaultSourceId withDelegate:self];
        newVideoView.appUseTheType = self.appUseTheType;
        newVideoView.sourceId = sCHUserDefaultSourceId;
        if (newVideoView)
        {
            if (count == 0)
            {
                [theVideoArray addObject:newVideoView];
            }
            else
            {
                [theVideoArray bm_addObject:newVideoView withMaxCount:count];
            }
            
            if (roomUser.role == CHUserType_Teacher)
            {
                self.teacherVideoViewArray = theVideoArray;
            }
            else if (roomUser.role == CHUserType_ClassMaster)
            {
                self.classMasterVideoViewArray = theVideoArray;
            }
            
            [self.videoViewArrayDic setObject:theVideoArray forKey:peerId];
            [newVideoView bm_bringToFront];
        }
        
        //（全屏浮窗用）-----------
        CHVideoView *newVideoViewFull = [[CHVideoView alloc] initWithRoomUser:roomUser withSourceId:sCHUserDefaultSourceId withDelegate:self];
        newVideoViewFull.appUseTheType = self.appUseTheType;
        newVideoViewFull.sourceId = sCHUserDefaultSourceId;
        if (newVideoViewFull)
        {
            if (count == 0)
            {
                [theVideoArrayFull addObject:newVideoViewFull];
            }
            else
            {
                [theVideoArrayFull bm_addObject:newVideoViewFull withMaxCount:count];
            }
            
            if (roomUser.role == CHUserType_Teacher)
            {
                self.teacherVideoViewArrayFull = theVideoArrayFull;
            }
            else if (roomUser.role == CHUserType_ClassMaster)
            {
                self.classMasterVideoViewArrayFull = theVideoArrayFull;
            }
            
            [self.videoViewArrayDicFull setObject:theVideoArrayFull forKey:peerId];
            
            
            if ([YSCurrentUser.peerID isEqualToString:peerId])
            {
                self.myVideoViewArrFull = theVideoArrayFull;
            }
        }
        
        [self videoViewsSequence];
    }
    else
    {
        for (NSString *sourceId in theSourceIdArray)
        {
            CHVideoView *newVideoView = [[CHVideoView alloc] initWithRoomUser:roomUser withSourceId:sourceId withDelegate:self];
            newVideoView.appUseTheType = self.appUseTheType;
            if (newVideoView)
            {
                if (count == 0)
                {
                    [theVideoArray addObject:newVideoView];
                }
                else
                {
                    [theVideoArray bm_addObject:newVideoView withMaxCount:count];
                }
                
                if (roomUser.role == CHUserType_Teacher)
                {
                    self.teacherVideoViewArray = theVideoArray;
                    if (self.liveManager.isGroupRoom)
                    {
                        newVideoView.groupRoomState = CHGroupRoomState_Discussing;
                    }
                }
                else if (roomUser.role == CHUserType_ClassMaster)
                {
                    self.classMasterVideoViewArray = theVideoArray;
                }
                
                [newVideoView bm_bringToFront];
            }
            
            //（全屏浮窗用）-----------
            CHVideoView *newVideoViewFull = [[CHVideoView alloc] initWithRoomUser:roomUser withSourceId:sourceId withDelegate:self];
            newVideoViewFull.appUseTheType = self.appUseTheType;
            if (newVideoViewFull)
            {
                if (count == 0)
                {
                    [theVideoArrayFull addObject:newVideoViewFull];
                }
                else
                {
                    [theVideoArrayFull bm_addObject:newVideoViewFull withMaxCount:count];
                }
                
                if (roomUser.role == CHUserType_Teacher)
                {
                    self.teacherVideoViewArrayFull = theVideoArrayFull;
                    if (self.liveManager.isGroupRoom)
                    {
                        newVideoViewFull.groupRoomState = CHGroupRoomState_Discussing;
                    }
                }
                else if (roomUser.role == CHUserType_ClassMaster)
                {
                    self.classMasterVideoViewArrayFull = theVideoArrayFull;
                }
                
            }
        }
        [self.videoViewArrayDic setObject:theVideoArray forKey:peerId];
        [self.videoViewArrayDicFull setObject:theVideoArrayFull forKey:peerId];
        
        [self videoViewsSequence];
        
        if ([YSCurrentUser.peerID isEqualToString:peerId])
        {
            self.myVideoViewArrFull = theVideoArrayFull;
        }
        
        if (self.fullFloatVideoView.hidden)
        {
            for (CHVideoView * videoView in theVideoArray)
            {
                [self playVideoAudioWithVideoView:videoView];
            }
        }
        else
        {
            for (CHVideoView * videoView in theVideoArrayFull)
            {
                [self playVideoAudioWithVideoView:videoView];
            }
        }
        
    }
    if (self.fullFloatVideoView.hidden)
    {
        return theVideoArray;
    }
    else
    {
        return theVideoArrayFull;
    }
}

//设备变化时
- (NSMutableArray<CHVideoView *> *)freshVideoViewsCountWithPeerId:(NSString *)peerId withSourceIdArray:(NSMutableArray<NSString *> *)sourceIdArray withMaxCount:(NSUInteger)count
{
    CHRoomUser *roomUser = [self.liveManager getRoomUserWithId:peerId];
    if (!roomUser)
    {
        return nil;
    }
    
    //本人的视频数组
    NSMutableArray * myVideoArray = [self.videoViewArrayDic bm_mutableArrayForKey:self.liveManager.localUser.peerID];
    
    //本人的视频数组（全屏浮窗用）
    NSMutableArray *myVideoArrayFull = [self.videoViewArrayDicFull bm_mutableArrayForKey:self.liveManager.localUser.peerID];

    // 删除本人占位视频
    for (CHVideoView *avideoView in myVideoArray)
    {
        if (avideoView.isForPerch)
        {
            [self deleteVideoViewfromVideoViewArrayDic:avideoView];
            break;
        }
    }
    
    for (CHVideoView *avideoView in myVideoArrayFull)
    {
        if (avideoView.isForPerch)
        {
            [self deleteVideoViewfromVideoViewArrayDicFull:avideoView];
            break;
        }
    }
    
    //最后要返回的这个用户的所有视频的数组
    NSMutableArray * theAddVideoArray = [NSMutableArray array];
    //视频数组（全屏浮窗用）
    NSMutableArray *theAddVideoArrayFull = [NSMutableArray array];
    
    //已有的视频数组
    NSMutableArray * theVideoArray = [self.videoViewArrayDic bm_mutableArrayForKey:peerId];
    NSMutableArray * theVideoArrayFull = [self.videoViewArrayDicFull bm_mutableArrayForKey:peerId];
    
    
    if (!sourceIdArray.count)
    {//摄像头全部拔掉时
        
        for (CHVideoView * videoView in theVideoArray)
        {
            [self deleteVideoViewfromVideoViewArrayDic:videoView];
        }
        
        CHVideoView *newVideoView = [[CHVideoView alloc] initWithRoomUser:roomUser withSourceId:sCHUserDefaultSourceId withDelegate:self];
        newVideoView.appUseTheType = self.appUseTheType;
        if (newVideoView)
        {
            if (count == 0)
            {
                [theAddVideoArray addObject:newVideoView];
            }
            else
            {
                [theAddVideoArray bm_addObject:newVideoView withMaxCount:count];
            }
            
            if (roomUser.role == CHUserType_Teacher)
            {
                self.teacherVideoViewArray = theAddVideoArray;
            }
            else if (roomUser.role == CHUserType_ClassMaster)
            {
                self.classMasterVideoViewArray = theVideoArray;
            }
            [newVideoView bm_bringToFront];
        }
        
        [self addVideoViewToVideoViewArrayDic:newVideoView];
        
        
        //（全屏浮窗用）-----------
        for (CHVideoView * videoView in theVideoArrayFull)
        {
            [self deleteVideoViewfromVideoViewArrayDicFull:videoView];
        }
        
        CHVideoView *newVideoViewFull = [[CHVideoView alloc] initWithRoomUser:roomUser withSourceId:sCHUserDefaultSourceId withDelegate:self];
        newVideoViewFull.appUseTheType = self.appUseTheType;
        if (newVideoViewFull)
        {
            if (count == 0)
            {
                [theAddVideoArrayFull addObject:newVideoViewFull];
            }
            else
            {
                [theAddVideoArrayFull bm_addObject:newVideoViewFull withMaxCount:count];
            }
            
            if (roomUser.role == CHUserType_Teacher)
            {
                self.teacherVideoViewArrayFull = theAddVideoArrayFull;
            }
            else if (roomUser.role == CHUserType_ClassMaster)
            {
                self.classMasterVideoViewArrayFull = theVideoArrayFull;
            }
        }
        
        [self addVideoViewToVideoViewArrayDicFull:newVideoViewFull];
        
        if (self.fullFloatVideoView.hidden)
        {
            return theAddVideoArray;
        }
        else
        {
            return theAddVideoArrayFull;
        }
    }
    else
    {//摄像头变更时
                
        for (CHVideoView *videoView in theVideoArray)
        {
            if ([sourceIdArray containsObject:videoView.sourceId])
            {
                [theAddVideoArray addObject:videoView];
                [sourceIdArray removeObject:videoView.sourceId];
                // property刷新原用户的值没有变化，需要重新赋值user
                [videoView freshWithRoomUserProperty:roomUser];
                [videoView bm_bringToFront];
            }
            else
            {
                [self deleteVideoViewfromVideoViewArrayDic:videoView];
                [self stopVideoAudioWithVideoView:videoView];
                
                //焦点用户退出
                if ([self.fouceView.roomUser.peerID isEqualToString:videoView.roomUser.peerID])
                {
                    self.roomLayout = CHRoomLayoutType_VideoLayout;
                    [self.liveManager sendSignalingToChangeLayoutWithLayoutType:self.roomLayout appUserType:self.appUseTheType withFouceUserId:videoView.roomUser.peerID withStreamId:self.fouceView.streamId];
                    self.fouceView = nil;
                    self.controlPopoverView.fouceStreamId = nil;
                    self.controlPopoverView.foucePeerId = nil;
                }
            }
        }
        
        for (NSString *sourceId in sourceIdArray)
        {
            CHVideoView *newVideoView = [[CHVideoView alloc] initWithRoomUser:roomUser withSourceId:sourceId withDelegate:self];
            newVideoView.appUseTheType = self.appUseTheType;
            if (newVideoView)
            {
                if (count == 0)
                {
                    [theAddVideoArray addObject:newVideoView];
                }
                else
                {
                    [theAddVideoArray bm_addObject:newVideoView withMaxCount:count];
                }
                
                if (roomUser.role == CHUserType_Teacher)
                {
                    self.teacherVideoViewArray = theAddVideoArray;
                    if (self.liveManager.isGroupRoom)
                    {
                        newVideoView.groupRoomState = CHGroupRoomState_Discussing;
                    }
                }
                else if (roomUser.role == CHUserType_ClassMaster)
                {
                    self.classMasterVideoViewArray = theVideoArray;
                }
                
                [self addVideoViewToVideoViewArrayDic:newVideoView];
                
                if (self.fullFloatVideoView.hidden)
                {
                    [self playVideoAudioWithVideoView:newVideoView];
                }
                [newVideoView bm_bringToFront];
            }
        }
        
        //(全屏浮窗用）-----------
        for (CHVideoView *videoViewFull in theVideoArrayFull)
        {
            if ([sourceIdArray containsObject:videoViewFull.sourceId])
            {
                [theAddVideoArrayFull addObject:videoViewFull];
                [sourceIdArray removeObject:videoViewFull.sourceId];
                // property刷新原用户的值没有变化，需要重新赋值user
                [videoViewFull freshWithRoomUserProperty:roomUser];
            }
            else
            {
                [self deleteVideoViewfromVideoViewArrayDicFull:videoViewFull];
                [self stopVideoAudioWithVideoView:videoViewFull];
            }
        }
        for (NSString *sourceId in sourceIdArray)
        {
            CHVideoView *newVideoViewFull = [[CHVideoView alloc] initWithRoomUser:roomUser withSourceId:sourceId withDelegate:self];
            newVideoViewFull.appUseTheType = self.appUseTheType;
            if (newVideoViewFull)
            {
                if (count == 0)
                {
                    [theAddVideoArrayFull addObject:newVideoViewFull];
                }
                else
                {
                    [theAddVideoArrayFull bm_addObject:newVideoViewFull withMaxCount:count];
                }
                
                if (roomUser.role == CHUserType_Teacher)
                {
                    self.teacherVideoViewArrayFull = theAddVideoArrayFull;
                    if (self.liveManager.isGroupRoom)
                    {
                        newVideoViewFull.groupRoomState = CHGroupRoomState_Discussing;
                    }
                }
                else if (roomUser.role == CHUserType_ClassMaster)
                {
                    self.classMasterVideoViewArrayFull = theVideoArrayFull;
                }
                [self addVideoViewToVideoViewArrayDicFull:newVideoViewFull];
                if (!self.fullFloatVideoView.hidden)
                {
                    [self playVideoAudioWithVideoView:newVideoViewFull];
                }
            }
        }
    }
    
    if (self.fullFloatVideoView.hidden)
    {
        return theAddVideoArray;
    }
    else
    {
        return theAddVideoArrayFull;
    }
}



#pragma mark  获取视频窗口

- (CHVideoView *)getVideoViewWithPeerId:(NSString *)peerId andSourceId:(nonnull NSString *)sourceId
{
    NSMutableArray * videoArray = [self.videoViewArrayDic bm_mutableArrayForKey:peerId];
    
    for (CHVideoView *videoView in videoArray)
    {
        if ([sourceId bm_isNotEmpty])
        {
            if ([videoView.sourceId isEqualToString:sourceId])
            {
                return videoView;
            }
        }
        else
        {
           return videoView;
        }
    }

    return nil;
}

#pragma mark  删除视频窗口
///删除某个设备ID为sourceId的视频窗口
- (CHVideoView *)delVideoViewWithPeerId:(NSString *)peerId andSourceId:(NSString *)sourceId
{
    NSMutableArray * videoArray = [self.videoViewArrayDic bm_mutableArrayForKey:peerId];
    
    NSMutableArray * videoArrayFull = [self.videoViewArrayDicFull bm_mutableArrayForKey:peerId];
    
    CHVideoView *delVideoView = nil;
    CHVideoView *delVideoViewFull = nil;
    
    for (CHVideoView * videoView in videoArray)
    {
        if ([videoView.sourceId isEqualToString:sourceId])
        {
            delVideoView = videoView;
            break;
        }
    }
    
    for (CHVideoView * videoViewFull in videoArrayFull)
    {
        if ([videoViewFull.sourceId isEqualToString:sourceId])
        {
            delVideoViewFull = videoViewFull;
            break;
        }
    }
    
    [self deleteVideoViewfromVideoViewArrayDic:delVideoView];
    [self deleteVideoViewfromVideoViewArrayDicFull:delVideoViewFull];
    
    if (delVideoView)
    {
        [self stopVideoAudioWithVideoView:delVideoView];
    }
    
    if (delVideoViewFull)
    {
        [self stopVideoAudioWithVideoView:delVideoViewFull];
    }
    
    return delVideoView;
}

#pragma -
#pragma mark CHVideoViewDelegate

///点击手势事件
- (void)clickViewToControlWithVideoView:(CHVideoView*)videoView
{
    
}

///拖拽手势事件
- (void)panToMoveVideoView:(CHVideoView*)videoView withGestureRecognizer:(UIPanGestureRecognizer *)pan
{
    
}


#pragma -
#pragma mark YSSessionDelegate

/// 发生错误 回调
- (void)onRoomDidOccuredError:(CloudHubErrorCode)errorCode withMessage:(NSString *)message
{
    
}

/// 失去连接
- (void)onRoomConnectionLost
{
//    [BMProgressHUD bm_showHUDAddedTo:YSKeyWindow animated:YES];
    [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES];
}

// 成功进入房间
- (void)onRoomJoined
{
    // 断开的时候不再发送这个
    // onRoomConnectionLost
    BMLog(@"=========== reconnect onRoomJoined");
    [BMProgressHUD bm_hideAllHUDsForView:YSKeyWindow animated:YES];
}

- (void)onRoomReJoined
{
    // 断开的时候会发这个
    // onRoomConnectionLost
    
    BMLog(@"=========== reconnect onRoomReJoined");
//    [BMProgressHUD bm_hideAllHUDsForView:YSKeyWindow animated:YES];
    [BMProgressHUD bm_hideAllHUDsForView:self.view animated:YES];
}

// 已经离开房间
- (void)onRoomLeft
{
    [BMProgressHUD bm_hideAllHUDsForView:YSKeyWindow animated:YES];
}

- (void)onRoomKickedOut:(NSInteger)reasonCode
{
    // 暂不限制踢出再进入等待时间
//    if (reasonCode == 1)
//    {
//        NSString *roomIdKey = YSKickTime;
//        if ([self.liveManager.room_Id bm_isNotEmpty])
//        {
//            roomIdKey = [NSString stringWithFormat:@"%@_%@", YSKickTime, self.liveManager.room_Id ];
//        }
//        
//        // 存储被踢时间
//        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:roomIdKey];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
}

#pragma mark 用户user

/// 用户进入
- (void)onRoomUserJoined:(CHRoomUser *)user isHistory:(BOOL)isHistory
{
    NSString *roleName = nil;
    if (user.role == CHUserType_Teacher)
    {
        roleName = YSLocalized(@"Role.Teacher");
    }
    else if (user.role == CHUserType_Assistant)
    {
        roleName = YSLocalized(@"Role.Assistant");
    }
    else if (user.role == CHUserType_Student)
    {
        roleName = YSLocalized(@"Role.Student");
    }
    
    if (!self.liveManager.isBigRoom && !isHistory && roleName)
    {
        NSString *message = [NSString stringWithFormat:@"%@(%@) %@", user.nickName, roleName, YSLocalized(@"Action.EnterRoom")];
        [self.liveManager sendTipMessage:message tipType:CHChatMessageType_Tips];
    }
}

/// 用户退出
- (void)onRoomUserLeft:(CHRoomUser *)user
{
    NSString *roleName = nil;
    if (user.role == CHUserType_Teacher)
    {
        roleName = YSLocalized(@"Role.Teacher");
    }
    else if(user.role == CHUserType_Assistant)
    {
        roleName = YSLocalized(@"Role.Assistant");
    }
    else if (user.role == CHUserType_Student)
    {
        roleName = YSLocalized(@"Role.Student");
    }
    
    if (!self.liveManager.isBigRoom && roleName)
    {
        NSString *message = [NSString stringWithFormat:@"%@(%@) %@", user.nickName, roleName, YSLocalized(@"Action.ExitRoom")];
        [self.liveManager sendTipMessage:message tipType:CHChatMessageType_Tips];
    }
}


#pragma mark 用户流

/// 大房间同步上台用户属性
- (void)handleSignalingSyncProperty:(CHRoomUser *)roomUser
{
    [self userPublishstatechange:roomUser];
}

- (void)userPublishstatechange:(CHRoomUser *)roomUser
{
    
}

/// 用户本地视频流第一帧
- (void)onRoomFirstLocalVideoFrameWithSize:(CGSize)size
{
    // 刷新视频编辑尺寸
    //[self.keystoneCorrectionView freshTouchView];
}

/// 用户视频流开关状态
- (void)onRoomMuteLocalVideoStream:(BOOL)mute
{
#if 0
    NSString *userId = CHLocalUser.peerID;
    
    NSMutableArray *videoArray = [self.videoViewArrayDic bm_mutableArrayForKey:userId];
    CHVideoView *userVideoView = nil;
    
    for (CHVideoView *videoView in videoArray)
    {
        if ([videoView.sourceId isEqualToString:sCHUserDefaultSourceId])
        {
            userVideoView = videoView;
            break;
        }
    }

    if (!userVideoView)
    {
        return;
    }
#endif
    
    if (!self.myVideoView)
    {
        return;
    }
    
    CHVideoView *userVideoView = self.myVideoView;

    if (mute)
    {
        [self stopVideoAudioWithVideoView:userVideoView];
    }
    else
    {
        [self playVideoAudioWithVideoView:userVideoView];
    }
}

/// 用户流音量变化
- (void)onRoomAudioVolumeWithSpeakers:(NSArray<CloudHubAudioVolumeInfo *> *)speakers
{
    for (CloudHubAudioVolumeInfo *info in speakers)
    {
        CHRoomUser *roomUser = [self.liveManager getRoomUserWithId:info.uid];
        
        if (roomUser)
        {
            roomUser.iVolume = info.volume;
        }
    }
}
/// 开关摄像头
- (void)onRoomCloseVideo:(BOOL)close withUid:(NSString *)uid  sourceID:(nullable NSString *)sourceId streamId:(nonnull NSString *)streamId
{
    if (close)
    {
        [self onRoomStopVideoOfUid:uid sourceID:sourceId streamId:streamId];
#if FRESHWITHROOMUSER
        CHVideoView *view = [self getVideoViewWithPeerId:uid andSourceId:sourceId];
        [view freshWithRoomUserProperty:view.roomUser];
#endif
    }
    else
    {
        [self onRoomStartVideoOfUid:uid sourceID:sourceId streamId:streamId];
    }
}

/// 开关麦克风
- (void)onRoomCloseAudio:(BOOL)close withUid:(NSString *)uid
{
#if FRESHWITHROOMUSER
    NSMutableArray *videoViewArray = [self.videoViewArrayDic bm_mutableArrayForKey:uid];
    for (CHVideoView * videoView in videoViewArray)
    {
        videoView.audioMute = close;
        [videoView freshWithRoomUserProperty:videoView.roomUser];
        [self addVideoViewToVideoViewArrayDic:videoView];
    }
#endif
}

/// 收到音视频流
- (void)onRoomStartVideoOfUid:(NSString *)uid sourceID:(nullable NSString *)sourceId streamId:(nullable NSString *)streamId
{
    CHVideoView *videoView = [self getVideoViewWithPeerId:uid andSourceId:sourceId];
    videoView.sourceId = sourceId;
    videoView.streamId = streamId;
    if (videoView)
    {
        CHRoomUser *roomUser = videoView.roomUser;
        BOOL isVideoMirror = [roomUser.properties bm_boolForKey:sCHUserIsVideoMirror];
        CloudHubVideoMirrorMode videoMirrorMode = CloudHubVideoMirrorModeDisabled;
        if (isVideoMirror)
        {
            videoMirrorMode = CloudHubVideoMirrorModeEnabled;
        }
        if (self.liveManager.isGroupRoom && videoView.roomUser.role == CHUserType_Teacher)
        {
            videoView.groupRoomState = CHGroupRoomState_Normal;
        }
        [self.liveManager playVideoWithUserId:uid streamID:streamId renderMode:CloudHubVideoRenderModeHidden mirrorMode:videoMirrorMode inView:videoView.contentView];
#if FRESHWITHROOMUSER
        [videoView freshWithRoomUserProperty:roomUser];
#endif
    }
}

/// 停止音视频流
- (void)onRoomStopVideoOfUid:(NSString *)uid sourceID:(nullable NSString *)sourceId streamId:(nullable NSString *)streamId
{
    if ([uid isEqualToString:CHLocalUser.peerID])
    {
        //self.myVideoView = nil;

        if (self.keystoneCorrectionView && !self.keystoneCorrectionView.hidden)
        {
            [self showKeystoneCorrectionView];
            return;
        }
    }

    [self.liveManager stopVideoWithUserId:uid streamID:streamId];
}

#pragma mark 用户网络差，被服务器切换媒体线路

- (void)roomManagerChangeMediaLine
{
    [BMProgressHUD bm_showHUDAddedTo:self.view animated:YES withText:nil detailText:YSLocalized(@"HUD.NetworkPoor") images:@[@"hud_network_poor0", @"hud_network_poor1", @"hud_network_poor2", @"hud_network_poor3"] duration:0.8f delay:YSChangeMediaLine_Delay];
}

/// 全体禁言
- (void)handleSignalingToDisAbleEveryoneBanChatWithIsDisable:(BOOL)isDisable
{
    if (isDisable)
    {
        [self.liveManager sendTipMessage:YSLocalized(@"Prompt.BanChatInView") tipType:CHChatMessageType_Tips];
    }
    else
    {
        [self.liveManager sendTipMessage:YSLocalized(@"Prompt.CancelBanChatInView") tipType:CHChatMessageType_Tips];
    }
}

#pragma mark meidia
/// 媒体流发布状态
- (void)onRoomShareMediaFile:(CHSharedMediaFileModel *)mediaFileModel
{
    if (![self.liveManager.whiteBoardManager isOneWhiteBoardView])
    {
        /// 多课件不做处理
        return;
    }

    if (mediaFileModel.state == CHMediaState_Play || mediaFileModel.state == CHMediaState_Pause)
    {
        self.mediaFileModel = mediaFileModel;
        [self handleWhiteBordPlayMediaFileWithMedia:mediaFileModel];
    }
    else
    {
        [self handleWhiteBordStopMediaFileWithMedia:mediaFileModel];
        self.mediaFileModel = nil;
    }
}

/// 更新媒体流的信息
- (void)onRoomUpdateMediaFileStream:(CHSharedMediaFileModel *)mediaFileModel isSetPos:(BOOL)isSetPos
{
    if (![self.liveManager.whiteBoardManager isOneWhiteBoardView])
    {
        return;
    }
    
    if (isSetPos)
    {
        [self onRoomUpdateMediaStream:mediaFileModel.duration pos:mediaFileModel.pos isPlay:YES];
    }
    else
    {
        if (mediaFileModel.state == CHMediaState_Play)
        {
            [self handleWhiteBordPlayMediaStream:mediaFileModel];
        }
        else
        {
            [self handleWhiteBordPauseMediaStream:mediaFileModel];
        }
    }
}

- (void)handleWhiteBordPlayMediaFileWithMedia:(CHSharedMediaFileModel *)mediaModel
{
    
}

- (void)handleWhiteBordStopMediaFileWithMedia:(CHSharedMediaFileModel *)mediaModel
{
    
}

- (void)handleWhiteBordPlayMediaStream:(CHSharedMediaFileModel *)mediaFileModel
{
    
}

- (void)handleWhiteBordPauseMediaStream:(CHSharedMediaFileModel *)mediaFileModel
{
    
}

- (void)onRoomUpdateMediaStream:(NSTimeInterval)duration
                            pos:(NSTimeInterval)pos
                         isPlay:(BOOL)isPlay
{
    
}


/// 本地movie 流
- (void)onRoomLocalMovieStreamID:(NSString *)movieStreamID userID:(NSString *)userID isStart:(BOOL)isStart
{
    if (![self.liveManager.whiteBoardManager isOneWhiteBoardView])
    {
        /// 多课件不做处理
        return;
    }

    if (isStart)
    {
        
        [self handlePlayMovieStreamID:movieStreamID userID:userID];
    }
    else
    {
        [self handleStopMovieStreamID:movieStreamID userID:userID];
    }
}

- (void)handlePlayMovieStreamID:(NSString *)movieStreamID userID:(NSString *)userID
{
    
}
- (void)handleStopMovieStreamID:(NSString *)movieStreamID userID:(NSString *)userID
{
    
}
/*
- (void)addBaseNotification
{
    // 声音
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(routeChange:)
                                                name:AVAudioSessionRouteChangeNotification
                                              object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAudioSessionInterruption:)
                                                 name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMediaServicesReset:)
                                                 name:AVAudioSessionMediaServicesWereResetNotification object:nil];
}


#pragma mark -
#pragma mark 音频相关

/// 判断是否有耳机
- (BOOL)hasHeadset
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    AVAudioSessionRouteDescription *currentRoute = [audioSession currentRoute];

    for (AVAudioSessionPortDescription *output in currentRoute.outputs)
    {
          if ([[output portType] isEqualToString:AVAudioSessionPortBuiltInReceiver])
          {
                return NO;
          }
    }
    return YES;
}

- (void)handleAudioSessionInterruption:(NSNotification*)notification
{
    NSNumber *interruptionType = [[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey];
    NSNumber *interruptionOption = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey];
    
    switch (interruptionType.unsignedIntegerValue)
    {
        case AVAudioSessionInterruptionTypeBegan:
        {
            // • Audio has stopped, already inactive
            // • Change state of UI, etc., to reflect non-playing state
        }
            break;
        case AVAudioSessionInterruptionTypeEnded:
        {
            // • Make session active
            // • Update user interface
            // • AVAudioSessionInterruptionOptionShouldResume option
            if (interruptionOption.unsignedIntegerValue == AVAudioSessionInterruptionOptionShouldResume)
            {
                // Here you should continue playback.
                //[player play];
            }
        }
            break;
        default:
            break;
    }
    
    AVAudioSessionInterruptionType type = (AVAudioSessionInterruptionType)[notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    BMLog(@"音频相关===== 当前声音被打断 %@", @(type));
}

- (void)handleMediaServicesReset:(NSNotification *)aNotification
{
    AVAudioSessionInterruptionType type = (AVAudioSessionInterruptionType)[aNotification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    BMLog(@"音频相关===== 当前AVAudioSessionMediaServicesWereResetNotification: 打断 %@", @(type));
}

// 音频设备切换
- (void)routeChange:(NSNotification *)notification
{
    if (notification)
    {
        AVAudioSession *audioSession = (AVAudioSession *)notification.userInfo;
        if (([AVAudioSession sharedInstance].categoryOptions !=AVAudioSessionCategoryOptionMixWithOthers )||([AVAudioSession sharedInstance].category !=AVAudioSessionCategoryPlayAndRecord))
        {
        }
        
        [self pluggInOrOutMicrophone:notification.userInfo];
        [self printAudioCurrentCategory];
        [self printAudioCurrentMode];
        [self printAudioCategoryOption];
        
    }
}

- (void)pluggInOrOutMicrophone:(NSDictionary *)userInfo
{
    NSDictionary *interuptionDict = userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason)
    {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            BMLog(@"耳机插入");
            self.isHeadphones = YES;
            self.iVolume = 0.5;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ysPluggInMicrophoneNotification object:nil];
            break;
            
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            BMLog(@"耳机拔出，停止播放操作");
            self.isHeadphones = NO;
            self.iVolume = 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:ysUnunpluggingHeadsetNotification object:nil];
            
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            BMLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

- (void)printAudioCurrentCategory
{
    NSString *audioCategory =  [AVAudioSession sharedInstance].category;
    if ( audioCategory == AVAudioSessionCategoryAmbient ){
        BMLog(@"---jin current category is : AVAudioSessionCategoryAmbient");
    } else if ( audioCategory == AVAudioSessionCategorySoloAmbient ){
        BMLog(@"---jin current category is : AVAudioSessionCategorySoloAmbient");
    } else if ( audioCategory == AVAudioSessionCategoryPlayback ){
        BMLog(@"---jin current category is : AVAudioSessionCategoryPlayback");
    }  else if ( audioCategory == AVAudioSessionCategoryRecord ){
        BMLog(@"---jin current category is : AVAudioSessionCategoryRecord");
    } else if ( audioCategory == AVAudioSessionCategoryPlayAndRecord ){
        BMLog(@"---jin current category is : AVAudioSessionCategoryPlayAndRecord");
    } else if ( audioCategory == AVAudioSessionCategoryAudioProcessing ){
        BMLog(@"---jin current category is : AVAudioSessionCategoryAudioProcessing");
    } else if ( audioCategory == AVAudioSessionCategoryMultiRoute ){
        BMLog(@"---jin current category is : AVAudioSessionCategoryMultiRoute");
    }  else {
        BMLog(@"---jin current category is : unknow");
    }
    
}

- (void)printAudioCurrentMode
{
    NSString *audioMode =  [AVAudioSession sharedInstance].mode;
    if ( audioMode == AVAudioSessionModeDefault ){
        BMLog(@"---jin current mode is : AVAudioSessionModeDefault");
    } else if ( audioMode == AVAudioSessionModeVoiceChat ){
        BMLog(@"---jin current mode is : AVAudioSessionModeVoiceChat");
    } else if ( audioMode == AVAudioSessionModeGameChat ){
        BMLog(@"---jin current mode is : AVAudioSessionModeGameChat");
    }  else if ( audioMode == AVAudioSessionModeVideoRecording ){
        BMLog(@"---jin current mode is : AVAudioSessionModeVideoRecording");
    } else if ( audioMode == AVAudioSessionModeMeasurement ){
        BMLog(@"---jin current mode is : AVAudioSessionModeMeasurement");
    } else if ( audioMode == AVAudioSessionModeMoviePlayback ){
        BMLog(@"---jin current mode is : AVAudioSessionModeMoviePlayback");
    } else if ( audioMode == AVAudioSessionModeVideoChat ){
        BMLog(@"---jin current mode is : AVAudioSessionModeVideoChat");
    }else if ( audioMode == AVAudioSessionModeSpokenAudio ){
        BMLog(@"---jin current mode is : AVAudioSessionModeSpokenAudio");
    } else {
        BMLog(@"---jin current mode is : unknow");
    }
}

- (void)printAudioCategoryOption
{
    NSString *tSString = @"AVAudioSessionCategoryOptionMixWithOthers";
    switch ([AVAudioSession sharedInstance].categoryOptions) {
        case AVAudioSessionCategoryOptionDuckOthers:
            tSString = @"AVAudioSessionCategoryOptionDuckOthers";
            break;
        case AVAudioSessionCategoryOptionAllowBluetooth:
            tSString = @"AVAudioSessionCategoryOptionAllowBluetooth";
//            if (![YSEduSessionHandle shareInstance].isPlayMedia) {
//                BMLog(@"---jin sessionManagerUserPublished");
//            }
            break;
        case AVAudioSessionCategoryOptionDefaultToSpeaker:
            tSString = @"AVAudioSessionCategoryOptionDefaultToSpeaker";
            break;
        case AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers:
            tSString = @"AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers";
            break;
        case AVAudioSessionCategoryOptionAllowBluetoothA2DP:
            tSString = @"AVAudioSessionCategoryOptionAllowBluetoothA2DP";
            break;
        case AVAudioSessionCategoryOptionAllowAirPlay:
            tSString = @"AVAudioSessionCategoryOptionAllowAirPlay";
            break;
        default:
            break;
    }
    
    BMLog(@"---jin current categoryOptions is :%@", tSString);
}
*/

@end

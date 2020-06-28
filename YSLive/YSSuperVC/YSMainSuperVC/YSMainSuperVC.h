//
//  YSMainSuperVC.h
//  YSLive
//
//  Created by jiang deng on 2019/11/7.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSSuperNetVC.h"
#import "SCVideoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSMainSuperVC : YSSuperNetVC
<
    YSSessionDelegate,
    YSLiveForWhiteBoardDelegate
>

@property (nonatomic, weak, readonly) YSLiveManager *liveManager;
/// 白板视图whiteBord
@property (nonatomic, weak, readonly) UIView *whiteBordView;

///app使用场景  3：小班课  4：直播   6：会议
@property (nonatomic, assign) YSRoomUseType appUseTheType;

///成为焦点的用户的peerID
@property (nullable,nonatomic, copy) NSString *foucePeerId;

/// 视频View列表
@property (nonatomic, strong) NSMutableArray <SCVideoView *> *videoViewArray;
/// 老师视频
@property (nullable, nonatomic, strong) SCVideoView *teacherVideoView;
/// 自己视频
@property (nullable, nonatomic, strong) SCVideoView *myVideoView;


- (instancetype)initWithWhiteBordView:(UIView *)whiteBordView;

- (void)beforeDoMsgCachePool;

- (void)afterDoMsgCachePool;

- (void)showEyeCareRemind;

- (NSUInteger)getVideoViewCount;

@end

NS_ASSUME_NONNULL_END

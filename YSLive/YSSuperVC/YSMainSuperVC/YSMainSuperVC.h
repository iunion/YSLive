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
    YSLiveForWhiteBoardDelegate,
    SCVideoViewDelegate
>

@property (nonatomic, weak, readonly) YSLiveManager *liveManager;
/// 白板视图whiteBord
@property (nonatomic, weak, readonly) UIView *whiteBordView;

///app使用场景  3：小班课  4：直播   6：会议
@property (nonatomic, assign) YSRoomUseType appUseTheType;

/// 排序后的视频View列表
@property (nonatomic, strong) NSMutableArray <SCVideoView *> *videoSequenceArr;
@property (nonatomic, strong) NSMutableDictionary *videoViewArrayDic;

/// 老师视频
@property (nullable, nonatomic, strong) NSMutableArray<SCVideoView *> *teacherVideoViewArray;
/// 自己视频
@property (nullable, nonatomic, strong) SCVideoView *myVideoView;

/// 打开的音视频课件，目前只支持一个音视频
@property (nullable, nonatomic, strong) YSSharedMediaFileModel *mediaFileModel;


- (instancetype)initWithWhiteBordView:(UIView *)whiteBordView;

- (void)beforeDoMsgCachePool;

- (void)afterDoMsgCachePool;

- (void)showEyeCareRemind;

///视频窗口排序后存储为array
- (void)videoViewsSequence;

///给videoViewArrayDic中添加视频
- (void)addVideoViewToVideoViewArrayDic:(SCVideoView *)videoView;
///从videoViewArrayDic中移除视频
- (void)deleteVideoViewfromVideoViewArrayDic:(SCVideoView *)videoView;


- (void)playVideoAudioWithVideoView:(SCVideoView *)videoView;
- (void)playVideoAudioWithVideoView:(SCVideoView *)videoView needFreshVideo:(BOOL)fresh;
- (void)playVideoAudioWithNewVideoView:(SCVideoView *)videoView;
- (void)stopVideoAudioWithVideoView:(SCVideoView *)videoView;


- (NSUInteger)getVideoViewCount;
- (nullable NSMutableArray<SCVideoView *> *)addVideoViewWithPeerId:(NSString *)peerId;
- (nullable NSMutableArray<SCVideoView *> *)addVideoViewWithPeerId:(NSString *)peerId withMaxCount:(NSUInteger)count;

//设备变化时
- (NSMutableArray<SCVideoView *> *)freshVideoViewsCountWithPeerId:(NSString *)peerId withSourceIdArray:(NSMutableArray<NSString *> *)sourceIdArray withMaxCount:(NSUInteger)count;

- (nullable SCVideoView *)getVideoViewWithPeerId:(NSString *)peerId andSourceId:(NSString *)sourceId;
//- (nullable NSMutableArray<SCVideoView *> *)delVideoViewWithPeerId:(NSString *)peerId;
- (nullable SCVideoView *)delVideoViewWithPeerId:(NSString *)peerId  andSourceId:(NSString *)sourceId;

- (void)userPublishstatechange:(YSRoomUser *)roomUser;

@end

NS_ASSUME_NONNULL_END

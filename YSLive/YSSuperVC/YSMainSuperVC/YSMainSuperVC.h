//
//  YSMainSuperVC.h
//  YSLive
//
//  Created by jiang deng on 2019/11/7.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSSuperNetVC.h"
#import "CHVideoView.h"
#import "YSControlPopoverView.h"
#import "BMKeystoneCorrectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSMainSuperVC : YSSuperNetVC
<
    CHSessionDelegate,
    YSLiveForWhiteBoardDelegate,
    CHVideoViewDelegate,
    YSControlPopoverViewDelegate
>

@property (nonatomic, weak, readonly) YSLiveManager *liveManager;
/// 白板视图whiteBord
@property (nonatomic, weak, readonly) UIView *whiteBordView;

///app使用场景  3：小班课  4：直播   6：会议
@property (nonatomic, assign) CHRoomUseType appUseTheType;

/// 房间类型 0:表示一对一教室  非0:表示一多教室
@property (nonatomic, assign) CHRoomUserType roomtype;
/// 视频ratio 16:9
@property (nonatomic, assign) BOOL isWideScreen;

/// 固定UserId
@property (nonatomic, strong) NSString *userId;

/// 排序后的视频View列表
@property (nonatomic, strong) NSMutableArray <CHVideoView *> *videoSequenceArr;
@property (nonatomic, strong) NSMutableDictionary *videoViewArrayDic;

///全屏浮窗
@property (nonatomic, strong) NSMutableArray <CHVideoView *> *videoSequenceArrFull;
@property (nonatomic, strong) NSMutableDictionary *videoViewArrayDicFull;

/// 老师视频
@property (nullable, nonatomic, strong) NSMutableArray<CHVideoView *> *teacherVideoViewArray;
/// 老师视频
@property (nullable, nonatomic, strong) NSMutableArray<CHVideoView *> *classMasterVideoViewArray;
/// 自己视频
@property (nullable, nonatomic, weak) CHVideoView *myVideoView;

/// 打开的音视频课件，目前只支持一个音视频
@property (nullable, nonatomic, strong) CHSharedMediaFileModel *mediaFileModel;

/// 当前的焦点视图
@property(nullable, nonatomic, strong) CHVideoView *fouceView;

///标识布局变化的值
@property (nonatomic, assign) CHRoomLayoutType roomLayout;

/// 视频控制popoverView
@property(nonatomic, strong) YSControlPopoverView *controlPopoverView;

/// 视频矫正窗口
@property (nonatomic, strong, readonly) BMKeystoneCorrectionView *keystoneCorrectionView;

@property (nonatomic,strong) NSMutableArray<CHVideoView *> *myVideoViewArrFull;

- (instancetype)initWithWhiteBordView:(UIView *)whiteBordView;

- (void)showEyeCareRemind;

///视频窗口排序
- (void)videoViewsSequence;

///给videoViewArrayDic中添加视频
- (void)addVideoViewToVideoViewArrayDic:(CHVideoView *)videoView;
///给videoViewArrayDicFull中添加视频（全屏浮窗用）
- (void)addVideoViewToVideoViewArrayDicFull:(CHVideoView *)videoView;
///从videoViewArrayDic中移除视频
- (void)deleteVideoViewfromVideoViewArrayDic:(CHVideoView *)videoView;


- (void)playVideoAudioWithVideoView:(CHVideoView *)videoView;
- (void)playVideoAudioWithVideoView:(CHVideoView *)videoView needFreshVideo:(BOOL)fresh;
- (void)playVideoAudioWithNewVideoView:(CHVideoView *)videoView;
- (void)stopVideoAudioWithVideoView:(CHVideoView *)videoView;


- (NSUInteger)getVideoViewCount;
- (nullable NSMutableArray<CHVideoView *> *)addVideoViewWithPeerId:(NSString *)peerId;
- (nullable NSMutableArray<CHVideoView *> *)addVideoViewWithPeerId:(NSString *)peerId withMaxCount:(NSUInteger)count;

//- (nullable NSMutableArray<CHVideoView *> *)addFullFloatVideoViewWithPeerId:(NSString *)peerId;


//设备变化时
- (NSMutableArray<CHVideoView *> *)freshVideoViewsCountWithPeerId:(NSString *)peerId withSourceIdArray:(NSMutableArray<NSString *> *)sourceIdArray withMaxCount:(NSUInteger)count;

- (nullable CHVideoView *)getVideoViewWithPeerId:(NSString *)peerId andSourceId:(NSString *)sourceId;
//- (nullable NSMutableArray<CHVideoView *> *)delVideoViewWithPeerId:(NSString *)peerId;
- (nullable CHVideoView *)delVideoViewWithPeerId:(NSString *)peerId  andSourceId:(NSString *)sourceId;

- (void)userPublishstatechange:(CHRoomUser *)roomUser;

@end

NS_ASSUME_NONNULL_END

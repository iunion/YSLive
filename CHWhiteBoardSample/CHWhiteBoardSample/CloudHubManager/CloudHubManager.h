//
//  CloudHubManager.h
//  YSLiveSample
//
//

#import <Foundation/Foundation.h>
#import "CloudHubManagerDelegate.h"
#import "CloudHubManagerDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface CloudHubManager : NSObject

/// 外部传入host地址
@property (nonatomic, strong) NSString *apiHost;
/// 外部传入port
@property (nonatomic, assign) NSUInteger apiPort;


/// 音视频SDK干管理
@property (nonatomic, strong, readonly) CloudHubRtcEngineKit *cloudHubRtcEngineKit;

/// 房间相关消息回调
@property (nonatomic, weak) id <CloudHubManagerDelegate> delegate;

/// 当前用户数据
@property (nonatomic, strong, readonly) CHRoomUser *localUser;

#pragma mark - 时间相关

/// 服务器时间与本地时间差 tServiceTime-now
@property (nonatomic, assign) NSTimeInterval tHowMuchTimeServerFasterThenMe;

/// 当前服务器时间 now+tHowMuchTimeServerFasterThenMe
@property (nonatomic, assign, readonly) NSTimeInterval tCurrentTime;

#pragma mark - 白板

/// 白板管理
@property (nonatomic, strong, readonly) CHWhiteBoardSDKManager *whiteBoardManager;
/// 白板视图whiteBord
@property (nonatomic, weak, readonly) UIView *whiteBordView;

/// 课件列表
@property (nonatomic, strong, readonly) NSArray <CHFileModel *> *fileList;
/// 当前课件数据
@property (nonatomic, strong, readonly) CHFileModel *currentFile;

+ (instancetype)sharedInstance;
/// 管理销毁
+ (void)destroy;

- (BOOL)joinRoomWithHost:(nullable NSString *)host port:(NSUInteger)port nickName:(NSString *)nickName roomId:(NSString *)roomId roomPassword:(nullable NSString *)roomPassword userId:(nullable NSString *)userId;
- (BOOL)joinRoomWithHost:(nullable NSString *)host port:(NSUInteger)port nickName:(NSString *)nickName roomParams:(NSDictionary *)roomParams;


@end

NS_ASSUME_NONNULL_END

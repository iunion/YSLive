//
//  CHRoomUser.h
//  CHSession
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CHRoomUser : NSObject

/// 用户Id
@property (nonatomic, strong) NSString *peerID;

///// 用户视频流
//@property (nonatomic, strong) NSString *videoSourceID;
///// 用户屏幕共享视频流
//@property (nonatomic, strong) NSString *shareSourceID;
///// 用户媒体课件视频流
//@property (nonatomic, strong) NSString *mediaSourceID;
///// 用户本地媒体文件视频流
//@property (nonatomic, strong) NSString *fileSourceID;


#pragma mark - 用户属性

/// 用户属性
@property (nonatomic, strong) NSMutableDictionary *properties;

/// 用户昵称
@property (nonatomic, weak) NSString *nickName;

/// 用户身份，0：老师；1：助教；2：学生；3：旁听；4：隐身用户(巡课)
@property (nonatomic, assign) CHUserRoleType role;

/// 该用户是否有权在白板和文档上进行绘制
@property (nonatomic, assign) BOOL canDraw;

/// 画笔颜色编码 #RRGGBB
@property (nonatomic, weak) NSString *primaryColor;

/// 该用户是否有麦克风
@property (nonatomic, assign) BOOL hasAudio;

/// 麦克风
/// 麦克风状态
@property (nonatomic, assign, readonly) NSDictionary *mic;

/// 开关是否静音
@property (nonatomic, assign) CHSessionMuteState audioMute;

/// 麦克风设备故障
@property (nonatomic, assign) CHDeviceFaultType afail;

/// 摄像头列表 sourceId1:  { mute: 0/1, vfail: 0 }
@property (nonatomic, strong) NSDictionary *sourceListDic;

/// 上台状态，0：未上台，1：已上台；
@property (nonatomic, assign) CHPublishState publishState;

/// 用户应用是否进入后台运行
@property (nonatomic, assign) BOOL isInBackGround;

- (instancetype)init NS_UNAVAILABLE;

/**
 初始化一个用户
 
 @param peerID 用户id
 @return 用户对象
 */
- (instancetype)initWithPeerId:(NSString *)peerID;

/**
 初始化一个用户
 
 @param peerID  用户id
 @param properties 用户属性
 @return 用户对象
 */
- (instancetype)initWithPeerId:(NSString *)peerID properties:(NSDictionary *)properties;

- (void)updateWithProperties:(NSDictionary *)properties;

/// 开关是否静音，修改时发送修改通知
- (void)sendToChangeAudioMute:(CHSessionMuteState)mute;

/// 麦克风设备故障，修改时发送修改通知
- (void)sendToChangeAfail:(CHDeviceFaultType)afail;

/// 发送修改通知去改变video设备列表字典
- (void)sendToChangeSourceListDic:(NSDictionary *)sourceListDic;

/// 获取第一个设备Id
- (nullable NSString *)getFirstVideoSourceId;
/// 获取设备Id
- (nullable NSString *)getVideoSourceIdWithIndex:(NSUInteger)index;

/// 获取video设备的vfail
- (CHDeviceFaultType)getVideoVfailWithSourceId:(NSString *)sourceId;

/// 发送修改通知去改变video设备的vfail
- (void)sendToChangeVideoVfail:(CHDeviceFaultType)vfail withSourceId:(NSString *)sourceId;

/// 获取video设备的Mute
- (CHSessionMuteState)getVideoMuteWithSourceId:(NSString *)sourceId;

/// 改变video设备的Mute
- (void)setVideoMute:(CHSessionMuteState)mute WithSourceId:(NSString *)sourceId;

/// 改变video设备的Mute
- (void)setAllVideoMute:(CHSessionMuteState)mute;

/// 发送修改通知去改变video设备的Mute
- (void)sendToChangeVideoMute:(CHSessionMuteState)mute WithSourceId:(NSString *)sourceId;

/// 用户上台
- (void)sendToPublishStateUPTellWhom:(NSString *)whom;

/// 发送修改通知
- (void)sendToChangeProperty:(id _Nonnull)property forKey:(NSString * _Nonnull)propertyKey tellWhom:(NSString * _Nullable)whom;

@end

NS_ASSUME_NONNULL_END

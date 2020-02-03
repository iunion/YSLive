//
//  YSRoomUser.h
//  YSRoomSDK
//

#import <Foundation/Foundation.h>
#import "YSRoomDefines.h"

@interface YSRoomUser : NSObject
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
- (instancetype)initWithPeerId:(NSString *)peerID AndProperties:(NSDictionary*)properties;

/**
 获取 某个视频设备的视频发布状态

 @param deviceId 设备ID
 @return 发布状态
 */
- (YSPublishState)getPublishStateForDeviceId:(NSString *)deviceId;

/**
 用户Id
 */
@property (nonatomic, copy) NSString *peerID;
/**
 用户昵称
 */
@property (nonatomic, copy) NSString *nickName;
/**
 用户身份，0：老师；1：助教；2：学生；3：旁听；4：隐身用户
 */

@property (nonatomic) YSUserRoleType role;
/**
 该用户是否有麦克风
 */
@property (nonatomic) BOOL hasAudio;
/**
 该用户是否有摄像头
 */
@property (nonatomic) BOOL hasVideo; 
/**
 该用户是否有权在白板和文档上进行绘制
 */
@property (nonatomic) BOOL canDraw;
/**
 发布状态，0：未发布，1：发布音频；2：发布视频；3：发布音视频
 */
@property (nonatomic) YSPublishState publishState;
/**
 用户属性
 */
@property (nonatomic, strong) NSMutableDictionary *properties;

/**
 用户是否关闭视频
 */
@property (nonatomic, assign) BOOL disableVideo;
/**
 用户是否关闭音频
 */
@property (nonatomic, assign) BOOL disableAudio;
/**
 是否开启多码流
 */
- (BOOL)enableDualStream;

@end

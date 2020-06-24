//
//  YSRoomUser.h
//  YSRoomSDK
//
//  Created by jiang deng on 2020/5/28.
//  Copyright © 2020 Road of Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSRoomUser : NSObject

/// 用户Id
@property (nonatomic, strong) NSString *peerID;

/// 用户视频流
@property (nonatomic, strong) NSString *videoSourceID;
/// 用户屏幕共享视频流
@property (nonatomic, strong) NSString *shareSourceID;
/// 用户媒体课件视频流
@property (nonatomic, strong) NSString *mediaSourceID;
/// 用户本地媒体文件视频流
@property (nonatomic, strong) NSString *fileSourceID;


#pragma mark - 用户属性


/// 用户属性
@property (nonatomic, strong) NSMutableDictionary *properties;


/// 用户昵称
@property (nonatomic, weak) NSString *nickName;

/// 用户身份，0：老师；1：助教；2：学生；3：旁听；4：隐身用户(巡课)
@property (nonatomic, assign) YSUserRoleType role;

/// 该用户是否有麦克风
//@property (nonatomic, assign, readonly) BOOL hasAudio;
/// 该用户是否有摄像头
//@property (nonatomic, assign, readonly) BOOL hasVideo;

/// 该用户是否有权在白板和文档上进行绘制
@property (nonatomic, assign) BOOL canDraw;
/// 画笔颜色编码 #RRGGBB
@property (nonatomic, weak) NSString *primaryColor;

/// 发布状态，0：未发布，1：发布音频；2：发布视频；3：发布音视频
@property (nonatomic, assign, readonly) YSPublishState publishState;
/// 关联publishState
@property (nonatomic, assign) YSUserMediaPublishState mediaPublishState;

/// 麦克风设备故障
@property (nonatomic, assign) YSDeviceFaultType afail;
/// 摄像头设备故障
@property (nonatomic, assign) YSDeviceFaultType vfail;

/// 用户应用是否进入后台运行
@property (nonatomic, assign) BOOL isInBackGround;


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

- (void)changeProperty:(id _Nonnull)property forKey:(NSString * _Nonnull)propertyKey tellWhom:(NSString * _Nullable)whom;

@end

NS_ASSUME_NONNULL_END

//
//  YSRoomConfiguration.h
//  YSRoomSDK
//
//  Created by jiang deng on 2020/5/18.
//  Copyright © 2020 Road of Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#
#pragma mark - YSRoomConfiguration 房间设置的相关配置项
#

NS_ASSUME_NONNULL_BEGIN

@interface YSRoomConfiguration : NSObject

/// 配置项字符串
@property (nonatomic, strong) NSString *configurationString;


/// 课堂结束时自动退出房间 7
@property (nonatomic, assign) BOOL autoQuitClassWhenClassOverFlag;

/// 自动开启音视频 23
@property (nonatomic, assign) BOOL autoOpenAudioAndVideoFlag;

/// 自动上课 32
@property (nonatomic, assign) BOOL autoStartClassFlag;

/// 学生是否有翻页权限 38
@property (nonatomic, assign) BOOL canPageTurningFlag;

/// 课前是否全体禁言 119
@property (nonatomic, assign) BOOL isBeforeClassBanChat;

/// 画笔穿透 131
@property (nonatomic, assign) BOOL isPenCanPenetration;

/// 护眼模式 141
@property (nonatomic, assign) BOOL isRemindEyeCare;

/// 是否同步镜像视频 148
@property (nonatomic, assign) BOOL isMirrorVideo;

/// 是否多课件 150
@property (nonatomic, assign) BOOL isMultiCourseware;

/// 是否允许课前互动 201
@property (nonatomic, assign) BOOL isChatBeforeClass;

/// 是否禁止观众私聊 202
@property (nonatomic, assign) BOOL isDisablePrivateChat;


- (instancetype)initWithConfigurationString:(NSString *)configurationString;

@end

NS_ASSUME_NONNULL_END

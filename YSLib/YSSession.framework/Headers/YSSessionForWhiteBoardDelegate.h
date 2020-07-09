//
//  YSSessionForWhiteBoardDelegate.h
//  YSSession
//
//  Created by jiang deng on 2020/6/10.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSSharedMediaFileModel.h"

#ifndef YSSessionForWhiteBoardDelegate_h
#define YSSessionForWhiteBoardDelegate_h

NS_ASSUME_NONNULL_BEGIN

@protocol YSSessionForWhiteBoardDelegate <NSObject>

/// checkRoom获取房间信息
- (void)roomWhiteBoardOnCheckRoom:(NSDictionary *)roomDic;
/// 获取服务器地址
- (void)roomWhiteBoardOnChangeServerAddrs:(NSDictionary *)serverDic;

/// 获取房间文件列表
- (void)roomWhiteBoardOnFileList:(NSArray <NSDictionary *> *)fileList;

/// 链接教室成功传递缓存消息列表，已通过"seq"属性desc排序
//- (void)roomWhiteBoardOnRoomConnected:(NSArray <NSDictionary *> *)msgList;

/// 消息列表
//- (void)roomWhiteBoardOnMsgList:(NSArray <NSDictionary *> *)msgList;
- (void)roomWhiteBoardOnMsgListFinished;

/// 断开链接
- (void)roomWhiteBoardOnDisconnect;

/// 用户属性改变
- (void)roomWhiteBoardOnRoomUserPropertyChangedUserId:(NSString *)userId fromeUserId:(NSString *)fromeUserId properties:(NSDictionary *)properties;

/// pubMsg消息通知
- (void)roomWhiteBoardOnRemotePubMsg:(NSDictionary *)messageDic;
/// delMsg消息通知
- (void)roomWhiteBoardOnRemoteDelMsg:(NSDictionary *)messageDic;

/// 媒体流发布状态
- (void)roomWhiteBoardOnShareMediaFile:(YSSharedMediaFileModel *)mediaFileModel;
/// 更新媒体流的信息
- (void)roomWhiteBoardOnUpdateMediaFileStream:(YSSharedMediaFileModel *)mediaFileModel isSetPos:(BOOL)isSetPos;


@optional

/// pubMsg消息通知
- (void)roomWhiteBoardOnRemotePubMsg:(NSString *)msgName msgId:(NSString *)msgId from:(nullable NSString *)fromuid withData:(nullable NSString *)data ts:(NSTimeInterval)ts isHistory:(BOOL)isHistory;

/// delMsg消息通知
- (void)roomWhiteBoardOnRemoteDelMsg:(NSString *)msgName msgId:(NSString *)msgId from:(nullable NSString *)fromuid withData:(nullable NSString *)data;

@end

NS_ASSUME_NONNULL_END

#endif /* YSSessionForWhiteBoardDelegate_h */

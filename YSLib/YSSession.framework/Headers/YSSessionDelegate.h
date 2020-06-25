//
//  YSSessionDelegate.h
//  YSSession
//
//  Created by jiang deng on 2020/6/10.
//  Copyright © 2020 YS. All rights reserved.
//

#ifndef YSSessionDelegate_h
#define YSSessionDelegate_h

#import "YSRoomUser.h"
#import "YSSessionForSignalingDelegate.h"

@protocol YSSessionForUserDelegate;
@protocol YSSessionForBigRoomDelegate;
@protocol YSSessionForMessageDelegate;

@protocol YSSessionDelegate <YSSessionForUserDelegate, YSSessionForBigRoomDelegate, YSSessionForSignalingDelegate, YSSessionForMessageDelegate>

/**
 发生错误 回调

 @param error error
 */
- (void)onRoomDidOccuredError:(NSError *)error;

/**
 发生警告 回调

 @param code 警告码
 */
- (void)onRoomDidOccuredWaring:(YSRoomWarningCode)code;

/// 进入房间失败
- (void)onRoomJoinFailed:(NSDictionary *)errorDic;

@end

#pragma mark 用户
@protocol YSSessionForUserDelegate <NSObject>

// 只用于普通房间
/// 用户进入
- (void)onRoomUserJoined:(YSRoomUser *)user inList:(BOOL)inList;
/// 用户退出
- (void)onRoomUserLeft:(YSRoomUser *)user;

/// 老师进入
- (void)onRoomTeacherJoined;
/// 老师退出
- (void)onRoomTeacherLeft;

@end

#pragma mark 房间状态变为大房间
@protocol YSSessionForBigRoomDelegate <NSObject>

/// 由小房间变为大房间(只调用一次)
- (void)onRoomChangeToBigRoomInList:(BOOL)inlist;
/// 大房间刷新用户数量
- (void)onRoomBigRoomFreshUserCountInList:(BOOL)inlist;
/// 大房间刷新数据
- (void)onRoomBigRoomFreshInList:(BOOL)inlist;

@end

#pragma mark 消息
@protocol YSSessionForMessageDelegate <NSObject>

/// 收到信息
- (void)handleMessageWith:(YSChatMessageModel *)message;

@end



#endif /* YSSessionDelegate_h */

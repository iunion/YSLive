//
//  CloudHubManagerDelegate.h
//  YSLiveSample
//
//  Created by jiang deng on 2020/9/6.
//  Copyright © 2020 yunshuxunlian. All rights reserved.
//

#ifndef CloudHubManagerDelegate_h
#define CloudHubManagerDelegate_h

NS_ASSUME_NONNULL_BEGIN

@protocol CloudHubManagerDelegate <CHWhiteBoardManagerDelegate>

/// 发生错误 回调
- (void)onRoomDidOccuredError:(CloudHubErrorCode)errorCode withMessage:(nullable NSString *)message;

- (void)onUpdateTimeWithTimeInterval:(NSTimeInterval)timeInterval;

/// 成功进入房间
- (void)onRoomJoined;

/// 成功重连房间
- (void)onRoomReJoined;

/// 已经离开房间
- (void)onRoomLeft;

/// 失去连接
- (void)onRoomConnectionLost;

/// 被踢出
- (void)onRoomKickedOut:(NSInteger)reasonCode;

@end

NS_ASSUME_NONNULL_END


#endif /* CloudHubManagerDelegate_h */

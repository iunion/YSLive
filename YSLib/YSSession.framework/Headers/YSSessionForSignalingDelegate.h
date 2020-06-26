//
//  YSSessionForSignalingDelegate.h
//  YSSession
//
//  Created by jiang deng on 2020/6/19.
//  Copyright © 2020 YS. All rights reserved.
//

#ifndef YSSessionForSignalingDelegate_h
#define YSSessionForSignalingDelegate_h

NS_ASSUME_NONNULL_BEGIN

@protocol YSSessionForSignalingDelegate <NSObject>

/// 同步服务器时间
- (BOOL)handleSignalingUpdateTimeWithTimeInterval:(NSTimeInterval)TimeInterval;

/// 上课
- (void)handleSignalingClassBeginWihInList:(BOOL)inlist;

/// 全体静音
- (void)handleSignalingliveAllNoAudio:(BOOL)noAudio;

@end

NS_ASSUME_NONNULL_END

#endif /* YSSessionForSignalingDelegate_h */

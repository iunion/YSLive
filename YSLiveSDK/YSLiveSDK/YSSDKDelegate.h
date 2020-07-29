//
//  YSSDKDelegate.h
//  YSLiveSDK
//
//  Created by jiang deng on 2019/11/28.
//  Copyright © 2019 YS. All rights reserved.
//
#import "YSSDKDefine.h"

#ifndef YSSDKDelegate_h
#define YSSDKDelegate_h

@protocol YSSDKDelegate <NSObject>

@optional

/**
   成功进入房间
   @param roomType 房间类型
   @param userType 登入用户身份
*/
- (void)onRoomJoinWithRoomType:(YSSDKUseTheType)roomType userType:(YSSDKUserRoleType)userType;

/**
    失去连接
 */
- (void)onRoomConnectionLost;

/**
    已经离开房间
 */
- (void)onRoomLeft;

/**
    自己被踢出房间
    @param reasonCode 被踢原因
 */
- (void)onRoomKickedOut:(NSInteger)reasonCode;

/**
    发生密码错误 回调
    需要重新输入密码

    @param errorCode errorCode
 */
- (void)onRoomNeedEnterPassWord:(YSSDKErrorCode)errorCode;

/**
    发生其他错误 回调
    需要重新登陆
 
    @param errorCode errorCode
*/
- (void)onRoomReportFail:(YSSDKErrorCode)errorCode descript:(NSString *)descript;

@end

#endif /* YSSDKDelegate_h */

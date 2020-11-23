//
//  YSUserDefault.h
//  YSLive
//
//  Created by fzxm on 2019/10/30.
//  Copyright © 2019 FS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 登录时 输入框记录的房间号
static NSString *const YSLOGIN_USERDEFAULT_ROOMID = @"ysLOGIN_USERDEFAULT_ROOMID";
/// 登录时 输入框记录的昵称
static NSString *const YSLOGIN_USERDEFAULT_NICKNAME = @"ysLOGIN_USERDEFAULT_NICKNAME";
/// 扬声器权限
static NSString *const YSPERMISSION_USERDEFAULT_REPRODUCER = @"ysPERMISSION_USERDEFAULT_REPRODUCER";

/// 是否同意用户协议
static NSString *const YS_UserAgreement = @"ys_USERAGREEMENT";
/// 是否签到
static NSString *const YS_UserSignin = @"ys_UserSignin";

@interface YSUserDefault : NSObject

+ (void)setLoginRoomID:(NSString *)roomID;
+ (NSString *)getLoginRoomID;

+ (void)setLoginNickName:(NSString *)nickName;
+ (NSString *)getLoginNickName;

/// 用户协议
+ (void)setUserAgreement:(BOOL)agree;
+ (BOOL)getUserAgreement;

//+ (void)setLoginRoleType:(YSUserRoleType)roleType;
//+ (NSString *)getLoginRoleType;

/// 扬声器权限
+ (void)setReproducerPermission:(BOOL)reproducerPermission;
/// 扬声器权限
+ (BOOL)getReproducerPermission;

/// 是否签到
+ (void)setUserSignin:(NSString *)sign;
/// 是否签到
+ (NSString *)getUserSignin;
@end

NS_ASSUME_NONNULL_END

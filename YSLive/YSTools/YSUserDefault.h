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
/// 网校登录时 域名
static NSString *const YSLOGIN_ONLINESCHOOL_REALMNAME = @"ysYSLOGIN_ONLINESCHOOL_REALMNAME";
/// 网校登录时 账户
static NSString *const YSLOGIN_ONLINESCHOOL_USERNUMBER = @"ysYSLOGIN_ONLINESCHOOL_USERNUMBER";
/// 网校登录时 密码
static NSString *const YSLOGIN_ONLINESCHOOL_PASSWORD = @"ysYSLOGIN_ONLINESCHOOL_PASSWORD";

@interface YSUserDefault : NSObject
+ (void)setLoginRoomID:(NSString *)roomID;
+ (NSString *)getLoginRoomID;

+ (void)setLoginNickName:(NSString *)nickName;
+ (NSString *)getLoginNickName;

/// 域名
+ (void)setRealmName:(NSString *)realmName;
+ (NSString *)getRealmName;
/// 账号
+ (void)setUserNumber:(NSString *)userNumber;
+ (NSString *)getUserNumber;
/// 密码
+ (void)setPassWord:(NSString *)passWord;
+ (NSString *)getPassWord;
//+ (void)setLoginRoleType:(YSUserRoleType)roleType;
//+ (NSString *)getLoginRoleType;

/// 扬声器权限
+ (void)setReproducerPermission:(BOOL)reproducerPermission;
/// 扬声器权限
+ (BOOL)getReproducerPermission;

@end

NS_ASSUME_NONNULL_END

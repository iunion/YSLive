//
//  YSUserDefault.m
//  YSLive
//
//  Created by fzxm on 2019/10/30.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSUserDefault.h"

@implementation YSUserDefault

+ (void)setLoginRoomID:(NSString *)roomID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:roomID forKey:YSLOGIN_USERDEFAULT_ROOMID];
    [defaults synchronize];
}

+ (NSString *)getLoginRoomID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *loginRoomID = [defaults objectForKey:YSLOGIN_USERDEFAULT_ROOMID];
    return loginRoomID;
}

+ (void)setLoginNickName:(NSString *)nickName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nickName forKey:YSLOGIN_USERDEFAULT_NICKNAME];
    [defaults synchronize];
}

+ (NSString *)getLoginNickName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *nickName = [defaults objectForKey:YSLOGIN_USERDEFAULT_NICKNAME];
    return nickName;
}

+ (void)setReproducerPermission:(BOOL)reproducerPermission
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:reproducerPermission forKey:YSPERMISSION_USERDEFAULT_REPRODUCER];
    [defaults synchronize];
}

+ (BOOL)getReproducerPermission
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL reproducerPermission = [defaults boolForKey:YSPERMISSION_USERDEFAULT_REPRODUCER];
    return reproducerPermission;
}


+ (void)setUserAgreement:(BOOL)agree
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:agree forKey:YS_UserAgreement];
    [defaults synchronize];
    
}
+ (BOOL)getUserAgreement
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL agree = [defaults boolForKey:YS_UserAgreement];
    return agree;
}

/// 是否签到
+ (void)setUserSignin:(NSString *)sign
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:sign forKey:YS_UserSignin];
    
    [defaults synchronize];
}

/// 是否签到
+ (NSString *)getUserSignin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *signin = [defaults objectForKey:YS_UserSignin];
    return signin;
}
@end

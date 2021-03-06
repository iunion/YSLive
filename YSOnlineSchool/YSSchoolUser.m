//
//  YSSchoolUser.m
//  YSAll
//
//  Created by 宁杰英 on 2020/2/11.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSSchoolUser.h"

@implementation YSSchoolUser

+ (instancetype)shareInstance
{
    static YSSchoolUser *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[YSSchoolUser alloc] init];
    });
    return _instance;
}

- (void)updateWithServerDic:(NSDictionary *)dic
{
    if (![dic bm_isNotEmptyDictionary])
    {
        return;
    }

    /// id: uid
    NSString *userId = [dic bm_stringTrimForKey:@"uid"];
    if (![userId bm_isNotEmpty])
    {
        return;
    }
    
    /// token: token
    NSString *token = [dic bm_stringTrimForKey:@"token"];
    if (![token bm_isNotEmpty])
    {
        return;
    }

    self.userId = userId;
    self.token = token;

    /// 用户类型: usertype
    if ([dic bm_containsObjectForKey:@"usertype"])
    {
        NSInteger userType = [dic bm_intForKey:@"usertype"];
        if (userType == 2)
        {
            self.userRoleType = CHUserType_Teacher;
        }
        else
        {
            self.userRoleType = CHUserType_Student;
        }
    }
    else
    {
        self.userRoleType = CHUserType_Student;
    }

    /// 昵称: nickname
    self.nickName = [dic bm_stringTrimForKey:@"nickname"];

    /// 头像: imageurl
    self.imageUrl = [dic bm_stringTrimForKey:@"imageurl"];
    
    self.organimageurl = [dic bm_stringTrimForKey:@"organimageurl"];
    /// organid
    self.organId = [dic bm_stringTrimForKey:@"organid"];
    self.mobile =[dic bm_stringTrimForKey:@"mobile"];
    self.schoolUserDic = dic;
}

- (void)clearUserdata
{
    self.randomKey = nil;
    
    self.schoolUserDic = nil;
    self.userId = nil;
    self.token = nil;
    self.userRoleType = CHUserType_Student;
    self.nickName = nil;
    self.imageUrl = nil;
    self.organId = nil;
    self.organimageurl = nil;
    self.mobile = nil;
}

- (void)saveSchoolUserLoginData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.domain forKey:YSLOGIN_ONLINESCHOOL_DOMAIN];
    [defaults setObject:self.userAccount forKey:YSLOGIN_ONLINESCHOOL_USERACCOUNT];
    //[defaults setObject:self.admin_pwd forKey:YSLOGIN_ONLINESCHOOL_PASSWORD];

    [defaults synchronize];
}

- (void)getSchoolUserLoginData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.domain = [defaults objectForKey:YSLOGIN_ONLINESCHOOL_DOMAIN];
    self.userAccount = [defaults objectForKey:YSLOGIN_ONLINESCHOOL_USERACCOUNT];
    //self.admin_pwd = [defaults objectForKey:YSLOGIN_ONLINESCHOOL_PASSWORD];

    [defaults synchronize];
}

@end

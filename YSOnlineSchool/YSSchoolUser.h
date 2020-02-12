//
//  YSSchoolUser.h
//  YSAll
//
//  Created by 宁杰英 on 2020/2/11.
//  Copyright © 2020 YS. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 网校登录时 域名
static NSString *const YSLOGIN_ONLINESCHOOL_DOMAIN = @"ysLOGIN_ONLINESCHOOL_DOMAIN";
/// 网校登录时 账户
static NSString *const YSLOGIN_ONLINESCHOOL_USERACCOUNT = @"ysLOGIN_ONLINESCHOOL_USERACCOUNT";
/// 网校登录时 密码
//static NSString *const YSLOGIN_ONLINESCHOOL_PASSWORD = @"ysLOGIN_ONLINESCHOOL_PASSWORD";

//NS_ASSUME_NONNULL_BEGIN

@interface YSSchoolUser : NSObject

/// 企业域名
@property (nonatomic, strong) NSString *domain;
/// 登录名
@property (nonatomic, strong) NSString *userAccount;
/// 登录密码
//@property (nonatomic, strong) NSString *userPassWord;

/// api使用随机Key
@property (nonatomic, strong) NSString *randomKey;


// api返回

@property (nonatomic, strong) NSDictionary *schoolUserDic;

/// id: uid
@property (nonatomic, strong) NSString *userId;

/// token: token
@property (nonatomic, strong) NSString *token;

/// 昵称: nickname
@property (nonatomic, strong) NSString *nickName;

/// 头像: imageurl
@property (nonatomic, strong) NSString *imageUrl;

/// organid
@property (nonatomic, strong) NSString *organId;


+ (instancetype)shareInstance;

- (void)updateWithServerDic:(NSDictionary *)dic;

- (void)clearUserdata;
- (void)saveSchoolUserLoginData;
- (void)getSchoolUserLoginData;

@end

//NS_ASSUME_NONNULL_END

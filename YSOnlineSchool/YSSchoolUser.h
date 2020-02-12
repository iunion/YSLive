//
//  YSSchoolUser.h
//  YSAll
//
//  Created by 宁杰英 on 2020/2/11.
//  Copyright © 2020 YS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSSchoolUser : NSObject

/// 企业域名
@property (nonatomic, strong) NSString *domain;
/// 登录名
@property (nonatomic, strong) NSString *admin_account;
/// 登录密码
@property (nonatomic, strong) NSString *admin_pwd;

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


+ (instancetype)shareInstance;

- (void)updateWithServerDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END

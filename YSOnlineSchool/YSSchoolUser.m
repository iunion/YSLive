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

    /// 昵称: nickname
    self.nickName = [dic bm_stringTrimForKey:@"nickname"];

    /// 头像: imageurl
    self.imageUrl = [dic bm_stringTrimForKey:@"imageurl"];
    
    self.schoolUserDic = dic;
}

@end

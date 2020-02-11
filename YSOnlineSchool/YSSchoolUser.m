//
//  YSSchoolUser.m
//  YSAll
//
//  Created by 宁杰英 on 2020/2/11.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSSchoolUser.h"

@implementation YSSchoolUser

+ (instancetype)shareInstance {
    static YSSchoolUser *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[YSSchoolUser alloc] init];
    });
    return _instance;
}

@end

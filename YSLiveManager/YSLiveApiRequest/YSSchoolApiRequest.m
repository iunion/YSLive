//
//  YSSchoolApiRequest.m
//  YSAll
//
//  Created by jiang deng on 2020/2/11.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSLiveApiRequest.h"

@implementation YSLiveApiRequest (School)

/// 获取登录密匙
+ (NSMutableURLRequest *)getSchoolPublicKey
{
    //http://school.roadofcloud.cn/index/Login/getPublicKey
    NSString *urlStr = [NSString stringWithFormat:@"%@/index/Login/getPublicKey", YSSchool_Server];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters];
}

/// 登录接口
+ (NSMutableURLRequest *)postLoginWithPubKey:(NSString *)pubKey
                                      domain:(NSString *)domain
                               admin_account:(NSString *)admin_account
                                   admin_pwd:(NSString *)admin_pwd
                                   randomKey:(NSString *)randomKey
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/index/Login/loginV1", YSSchool_Server];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setObject:domain forKey:@"domain"];
    [parameters setObject:admin_account forKey:@"admin_account"];
    [parameters setObject:admin_pwd forKey:@"admin_pwd"];
//    [parameters setObject:@"wxcs" forKey:@"domain"];
//    [parameters setObject:@"deng123" forKey:@"admin_account"];
//    [parameters setObject:@"123456" forKey:@"admin_pwd"];
    [parameters setObject:@(3) forKey:@"type"];
    [parameters setObject:randomKey forKey:@"key"];
    
    NSError *error = nil;

    NSMutableDictionary *loginParameter = [[NSMutableDictionary alloc] init];
    NSString *jsonStr = [parameters bm_toJSON];
    NSString *encodeString = [BMRSA encryptString:jsonStr publicPemKey:pubKey error:&error];
    NSLog(@"%@", encodeString);
    
    [loginParameter setObject:encodeString forKey:@"login_data"];

    return [YSApiRequest makeRequestWithURL:urlStr parameters:loginParameter];
}

/// 获取课表日历数据
+ (NSMutableURLRequest *)getClassListWithStudentId:(NSString *)studentId Withdate:(NSString *)dateStr
{
    // http://school.roadofcloud.cn/student/Mycourse/studentCourseList
    NSString *urlStr = [NSString stringWithFormat:@"%@/student/Mycourse/studentCourseList", YSSchool_Server];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters bm_setString:studentId forKey:@"studentid"];
    [parameters bm_setString:dateStr forKey:@"date"];

    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters isOnlineSchool:YES];
}


/// 获取课程列表
+ (NSMutableURLRequest *)getClassListWithStudentId:(NSString *)studentId date:(NSString *)date pagenum:(NSUInteger)pagenum
{
    // http://school.roadofcloud.cn/student/Mycourse/getLessonsByDate
    NSString *urlStr = [NSString stringWithFormat:@"%@/student/Mycourse/getLessonsByDate", YSSchool_Server];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters bm_setString:studentId forKey:@"studentid"];
    [parameters bm_setString:date forKey:@"date"];
    [parameters bm_setInteger:pagenum forKey:@"pagenum"];

    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters isOnlineSchool:YES];
}

@end

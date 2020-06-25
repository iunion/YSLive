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
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/index/Login/getPublicKey", YSLive_Http, [YSLiveManager sharedInstance].schoolApiHost];
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
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/index/Login/loginV1", YSLive_Http, [YSLiveManager sharedInstance].schoolApiHost];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters bm_setString:domain forKey:@"domain"];
    [parameters bm_setString:admin_account forKey:@"admin_account"];
    [parameters bm_setString:admin_pwd forKey:@"admin_pwd"];
//    [parameters setObject:@"wxcs" forKey:@"domain"];
//    [parameters setObject:@"deng123" forKey:@"admin_account"];
//    [parameters setObject:@"123456" forKey:@"admin_pwd"];
//    [parameters setObject:@(3) forKey:@"type"];
    [parameters bm_setString:randomKey forKey:@"key"];
    
    NSError *error = nil;

    NSMutableDictionary *loginParameter = [[NSMutableDictionary alloc] init];
    NSString *jsonStr = [parameters bm_toJSON];
    NSString *encodeString = [BMRSA encryptString:jsonStr publicPemKey:pubKey error:&error];
    NSLog(@"%@", encodeString);
    
    [loginParameter bm_setString:encodeString forKey:@"login_data"];

    return [YSApiRequest makeRequestWithURL:urlStr parameters:loginParameter];
}

/// 登出
+ (NSMutableURLRequest *)postExitLoginWithToken:(NSString *)token
{
    // http://school.roadofcloud.cn/index/Login/exitLogin
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/index/Login/exitLogin", YSLive_Http, [YSLiveManager sharedInstance].schoolApiHost];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters bm_setString:token forKey:@"token"];
    
    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters isOnlineSchool:YES];
    
}

/// 获取课表日历数据
+ (NSMutableURLRequest *)getClassListWithUserId:(NSString *)userId WithOrganId:(NSString *)organId WithUserType:(YSUserRoleType)userRoleType Withdate:(NSString *)dateStr
{
    // http://school.roadofcloud.cn/student/Mycourse/studentCourseList
    NSString *urlStr = nil;
        
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters bm_setString:dateStr forKey:@"date"];
    [parameters bm_setString:organId forKey:@"organid"];
    
    if (userRoleType == YSUserType_Teacher)
    {
        urlStr = [NSString stringWithFormat:@"%@://%@/teacher/Personalcourse/teachCourseList", YSLive_Http, [YSLiveManager sharedInstance].schoolApiHost];
        [parameters bm_setString:userId forKey:@"teacherid"];
    }
    else
    {
        urlStr = [NSString stringWithFormat:@"%@://%@/student/Mycourse/studentCourseList", YSLive_Http, [YSLiveManager sharedInstance].schoolApiHost];
        [parameters bm_setString:userId forKey:@"studentid"];
    }
    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters isOnlineSchool:YES];
}

/// 获取课程列表
+ (NSMutableURLRequest *)getClassListWithStudentId:(NSString *)studentId date:(NSString *)date pagenum:(NSUInteger)pagenum
{
    // http://school.roadofcloud.cn/student/Mycourse/getLessonsByDate
    
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/student/Mycourse/getLessonsByDate", YSLive_Http, [YSLiveManager sharedInstance].schoolApiHost];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters bm_setString:studentId forKey:@"studentid"];
    [parameters bm_setString:date forKey:@"date"];
    [parameters bm_setInteger:pagenum forKey:@"pagenum"];

    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters isOnlineSchool:YES];
}

/// 获取老师课程列表
+ (NSMutableURLRequest *)getTeacherClassListWithUserId:(NSString *)userId pagesize:(NSUInteger)pagesize date:(NSString *)date pagenum:(NSUInteger)pagenum
{
    // http://school.roadofcloud.net/teacher/Personalcourse/getLessonsByDate
    
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/teacher/Personalcourse/getLessonsByDate", YSLive_Http, [YSLiveManager sharedInstance].schoolApiHost];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters bm_setString:userId forKey:@"teacherid"];
//    [parameters bm_setInteger:pagesize forKey:@"pagesize"];
    [parameters bm_setString:date forKey:@"date"];
    [parameters bm_setInteger:pagenum forKey:@"pagenum"];

    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters isOnlineSchool:YES];
}

/// 获取课程回放列表
+ (NSMutableURLRequest *)getClassReplayListWithOrganId:(NSString *)organid toTeachId:(NSString *)toteachid
{
    // student/Mycourse/getLessonsPlayback
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/student/Mycourse/getLessonsPlayback", YSLive_Http, [YSLiveManager sharedInstance].schoolApiHost];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
//    [parameters bm_setString:organid forKey:@"organid"];
    [parameters bm_setString:toteachid forKey:@"toteachid"];

    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters isOnlineSchool:YES];
}

/// 获取老师课程信息，包含课程回放列表
+ (NSMutableURLRequest *)getTeacherClassInfoWithToteachtimeid:(NSString *)toteachtimeid lessonsid:(NSString *)lessonsid starttime:(NSString *)starttime endtime:(NSString *)endtime date:(NSString *)date
{
    // http://school.roadofcloud.net/teacher/Personalcourse/getPeriodinfo
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/teacher/Personalcourse/getPeriodinfo", YSLive_Http, [YSLiveManager sharedInstance].schoolApiHost];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters bm_setString:toteachtimeid forKey:@"toteachtimeid"];
    [parameters bm_setString:lessonsid forKey:@"id"];
    [parameters bm_setString:starttime forKey:@"starttime"];
    [parameters bm_setString:endtime forKey:@"endtime"];
    [parameters bm_setString:date forKey:@"date"];
    [parameters bm_setInteger:2 forKey:@"type"];

    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters isOnlineSchool:YES];
}

/// 获取个人信息
+ (NSMutableURLRequest *)getStudentInfoWithfStudentId:(NSString *)studentId
{
    // http://school.roadofcloud.cn/appstudent/User/getStudentInfo
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/appstudent/User/getStudentInfo", YSLive_Http, [YSLiveManager sharedInstance].schoolApiHost];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters bm_setString:studentId forKey:@"studentid"];
    
    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters isOnlineSchool:YES];
}

/// 进入教室
+ (NSMutableURLRequest *)enterOnlineSchoolClassWithWithUserType:(YSUserRoleType)userRoleType toTeachId:(NSString *)toteachid
{
    // /student/Mycourse/intoClassroom
    // https://school.roadofcloud.net/teacher/Personalcourse/intoClassroom
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/student/Mycourse/intoClassroom", YSLive_Http, [YSLiveManager sharedInstance].schoolApiHost];
    if (userRoleType == YSUserType_Teacher)
    {
        urlStr = [NSString stringWithFormat:@"%@://%@/teacher/Personalcourse/intoClassroom", YSLive_Http, [YSLiveManager sharedInstance].schoolApiHost];
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters bm_setString:toteachid forKey:@"toteachid"];

    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters isOnlineSchool:YES];
}

///  修改学生密码
+ (NSMutableURLRequest *)postStudentUpdatePass:(NSString *)updatePass repass:(NSString *)repass studentid:(NSString *)studentid organid:(NSString *)organid
{
    //http://school.roadofcloud.cn/student/Homepage/updatePass
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/student/User/updateUserPass", YSLive_Http, [YSLiveManager sharedInstance].schoolApiHost];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters bm_setString:studentid forKey:@"studentid"];
    [parameters bm_setString:organid forKey:@"organid"];
    [parameters bm_setString:repass forKey:@"repass"];
    [parameters bm_setString:updatePass forKey:@"newpass"];
    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters isOnlineSchool:YES];
}

///  修改老师密码
+ (NSMutableURLRequest *)postTeacherNewpass:(NSString *)newpass repass:(NSString *)repass teacherid:(NSString *)teacherid organid:(NSString *)organid
{
    //http://school.roadofcloud.net/teacher/Teacher/updatePass
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/teacher/Teacher/updatePass", YSLive_Http, [YSLiveManager sharedInstance].schoolApiHost];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters bm_setString:teacherid forKey:@"teacherid"];
    [parameters bm_setString:organid forKey:@"organid"];
    [parameters bm_setString:newpass forKey:@"newpass"];
    [parameters bm_setString:repass forKey:@"repass"];
    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters isOnlineSchool:YES];
}

@end


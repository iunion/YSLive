//
//  YSSchoolApiRequest.m
//  YSAll
//
//  Created by jiang deng on 2020/2/11.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSLiveApiRequest.h"

@implementation YSLiveApiRequest (School)


/// 获取b课表日历数据
+ (void )getCalendarCalendarWithdate:(NSString *)dateStr success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSInteger errorCode))failure
{
    NSString *urlStr = @"http://school.roadofcloud.cn/student/Mycourse/studentCourseList.html";
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:dateStr forKey:@"date"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
               @"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript",
               @"text/xml", @"image/jpeg", @"image/*"
           ]];
    NSURLSessionTask * task = [manager POST:urlStr parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = [YSLiveUtil convertWithData:responseObject];
        
        if ([dict bm_uintForKey:@"code"] == 0) {
            success(dict[@"data"]);
        }else
        {
            failure([dict bm_uintForKey:@"code"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error.code);
    }];
    [task resume];
}

+ (NSMutableURLRequest *)getClassListWithStudentId:(NSString *)studentId date:(NSString *)date pagenum:(NSUInteger)pagenum
{
    // http://school.roadofcloud.cn/student/Mycourse/getLessonsByDate
    NSString *urlStr = [NSString stringWithFormat:@"%@/student/Mycourse/getLessonsByDate", YSSchool_Server];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters bm_setString:studentId forKey:@"studentid"];
    [parameters bm_setString:date forKey:@"date"];
    [parameters bm_setInteger:pagenum forKey:@"pagenum"];

    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters];
}

@end

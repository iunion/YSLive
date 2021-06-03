//
//  YSLiveApiRequest.m
//  YSLive
//
//  Created by jiang deng on 2019/10/23.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSLiveApiRequest.h"
//#import "YSLiveManager.h"



@implementation YSLiveApiRequest

///// 获取升级信息
//+ (NSMutableURLRequest *)checkUpdateVersionNum:(NSString *)versionNum
//{
//    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/ClientAPI/getupdateinfo", YSLive_Http, [YSLiveManager sharedInstance].apiHost];
//    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
////    NSString *nowStr = [NSDate bm_stringFromDate:[NSDate date] formatter:@"yyyyMMdd"];
////    NSString *version = [NSString stringWithFormat:@"%@%@",nowStr,versionNum];
//    [parameters bm_setString:versionNum forKey:@"version"];
//    [parameters bm_setString:@"3" forKey:@"type"];
//    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters];
//}

/// 获取服务器时间
+ (NSMutableURLRequest *)getServerTime
{
    //NSString *urlStr = [NSString stringWithFormat:@"%@://%@/ClientAPI/systemtime", YSLive_Http, [YSLiveManager shareInstance].liveHost];
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/%@/systemtime", YSLive_Http, [YSLiveManager sharedInstance].apiHost, CHRoomWebApiInterface];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters];
}

/// 获取房间类型
+ (NSMutableURLRequest *)checkRoomTypeWithRoomId:(NSString *)roomId
{
//    * 检测房间类型
//    * 接口地址： /ClientAPI/checkroomtype
//    * 参数： serial ： 房间号
//    * 返回： ['result'=>'0 正常返回有data数据，4007 房间号异常','data'=>['roomtype'=>房间类型3小班课，4直播，6会议]]

    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/%@/checkroomtype", YSLive_Http, [YSLiveManager sharedInstance].apiHost, CHRoomWebApiInterface];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters bm_setString:roomId forKey:@"serial"];
    
    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters];
}

/// 点名签到请求
+ (NSMutableURLRequest *)liveCallRollSigninWithCallRollId:(NSString *)callRollId
{
    NSString *urlStr = [NSString stringWithFormat:@"%@", YS_SIGNINADDRESS];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    YSLiveManager *liveManager = [YSLiveManager sharedInstance];
    [parameters bm_setString:liveManager.room_Id forKey:@"serial"];
    [parameters bm_setString:liveManager.localUser.peerID forKey:@"userId"];
    [parameters bm_setString:liveManager.localUser.nickName forKey:@"nickname"];
    [parameters bm_setString:callRollId forKey:@"callrollid"];
    
    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters];
}

/// 获取用户奖杯数
+ (NSMutableURLRequest *)getGiftCountWithRoomId:(NSString *)roomId peerId:(NSString *)peerId
{
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/%@/getgiftinfo", YSLive_Http, [YSLiveManager sharedInstance].apiHost, CHRoomWebApiInterface];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters bm_setInteger:roomId.integerValue forKey:@"serial"];
    [parameters bm_setString:peerId forKey:@"receiveid"];
    
    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters];

//    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/ClientAPI/getgiftinfo/serial/%@", YSLive_Http, [YSLiveManager shareInstance].liveHost, roomId];
//    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
//
//    //[parameters setObject:roomId forKey:@"serial"];
//    //[parameters setObject:peerId forKey:@"receiveid"];
//
//    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters isPost:NO];
}

/// 给用户发送奖杯
+ (NSMutableURLRequest *)sendGiftWithRoomId:(NSString *)roomId sendUserId:(NSString *)sendUserId sendUserName:(NSString *)sendUserName receiveUserId:(NSString *)receiveUserId receiveUserName:(NSString *)receiveUserName
{
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/%@/sendgift", YSLive_Http, [YSLiveManager sharedInstance].apiHost, CHRoomWebApiInterface];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters bm_setInteger:roomId.integerValue forKey:@"serial"];
    [parameters bm_setString:sendUserId forKey:@"sendid"];
    [parameters bm_setString:sendUserName forKey:@"sendname"];
    NSString *receiverKey = [NSString stringWithFormat:@"receivearr[%@]", receiveUserId];
    [parameters bm_setString:receiveUserName forKey:receiverKey];
    
    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters];
}

/// 送花
+ (NSMutableURLRequest *)liveGivigGiftsSigninWithGiftsCount:(NSUInteger)count
{
    NSString *urlStr = [NSString stringWithFormat:@"%@", YS_FLOWERADDRESS];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    YSLiveManager *liveManager = [YSLiveManager sharedInstance];
    [parameters bm_setString:liveManager.room_Id forKey:@"serial"];
    [parameters bm_setString:liveManager.localUser.peerID forKey:@"senderid"];
    [parameters bm_setString:liveManager.localUser.nickName forKey:@"sendername"];
    [parameters bm_setString:liveManager.teacher.peerID forKey:@"flowerid"];
    [parameters bm_setString:liveManager.teacher.nickName forKey:@"flowername"];
    [parameters bm_setInteger:count forKey:@"number"];
    
    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters];
}

#pragma mark - 上传图片

/// 上传图片
+ (NSMutableURLRequest *)uploadImage
{
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/%@/uploaddocument", YSLive_Http, [YSLiveManager sharedInstance].apiHost, CHRoomWebApiInterface];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters];
}

/// 上传图片
+ (void)uploadImageWithImage:(UIImage *)image withImageUseType:(NSInteger)imageUseType success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSInteger errorCode))failure
{
    BMAFHTTPSessionManager *manager = [BMAFHTTPSessionManager manager];
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/%@/uploaddocument", YSLive_Http, [YSLiveManager sharedInstance].apiHost, CHRoomWebApiInterface];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
        @"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript",
        @"text/xml", @"image/jpeg", @"image/*"
    ]];
    
    NSString *fileName  = [NSString stringWithFormat:@"%@_mobile_%@.jpg",YSCurrentUser.nickName, [NSDate bm_stringFromDate:[NSDate date] formatter:@"yyyy-MM-dd_HH_mm_ss"]];
    
    NSDictionary * paraDict = @{
        @"serial" : [YSLiveManager sharedInstance].room_Id,
        @"userid" : YSCurrentUser.peerID,
        @"sender" : YSCurrentUser.nickName ? YSCurrentUser.nickName : @"",
        @"conversion" : @1,
        @"isconversiondone" : @0,
        @"writedb" : imageUseType>0? @0 : @1,
        @"fileoldname" : fileName,
        @"filetype" : @"jpg",
        @"alluser" : @1
    };
    
    NSData *imgData = UIImageJPEGRepresentation(image, 0.5);
    NSURLSessionTask * task = [manager POST:urlStr parameters:paraDict headers:nil constructingBodyWithBlock:^(id<BMAFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:imgData name:@"filedata" fileName:fileName mimeType:@"image/jpge, image/gif, image/jpeg, image/pjpeg, image/pjpeg"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [BMCloudHubUtil convertWithData:responseObject];
        if ([dict bm_uintForKey:@"result" withDefault:-1] == 0) {
            success(dict);
        }
        else
        {
            failure([dict bm_uintForKey:@"result"]);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BMLog(@"上传失败");
        failure(error.code);
    }];
    [task resume];
}

+ (NSMutableURLRequest *)getSimplifyAnswerCountWithRoomId:(NSString *)roomId answerId:(NSString *)answerId startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime
{
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/%@/simplifyAnswer", YSLive_Http, [YSLiveManager sharedInstance].apiHost, CHRoomWebApiInterface];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters bm_setInteger:roomId.integerValue forKey:@"serial"];
    [parameters bm_setString:answerId forKey:@"id"];
    [parameters bm_setDouble:startTime forKey:@"starttime"];
    [parameters bm_setDouble:(int)endTime forKey:@"endtime"];
    [parameters bm_setInteger:0 forKey:@"page"];
    [parameters bm_setInteger:200 forKey:@"pageNum"];
    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters];
}

#if 0
// 点名签到
- (void)sendLiveCallRollSigninWithCallRollId:(NSString *)callRollId
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableURLRequest *request = [YSLiveApiRequest liveCallRollSigninWithCallRollId:callRollId];
    if (request)
    {
        [self.liveCallRollSigninTask cancel];
        self.liveCallRollSigninTask = nil;
        
        BMWeakSelf
        self.liveCallRollSigninTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
                [weakSelf liveCallRollSigninRequestFailed:response error:error];
                
            }
            else
            {
#ifdef DEBUG
                NSString *responseStr = [[NSString stringWithFormat:@"%@", responseObject] bm_convertUnicode];
                BMLog(@"%@ %@", response, responseStr);
#endif
                [weakSelf liveCallRollSigninRequestFinished:response responseDic:responseObject];
            }
        }];
        [self.liveCallRollSigninTask resume];
    }
}
#endif

/// 删除课件
+ (NSMutableURLRequest *)deleteCoursewareWithRoomId:(NSString *)roomId fileId:(NSString *)fileId
{
    //https://demo.roadofcloud.com/ClientAPI/delroomfile?ts=1578305280751
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@/%@/delroomfile", YSLive_Http, [YSLiveManager sharedInstance].apiHost, CHRoomWebApiInterface];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters bm_setInteger:roomId.integerValue forKey:@"serial"];
    [parameters bm_setString:fileId forKey:@"fileid"];
    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters];
}

@end

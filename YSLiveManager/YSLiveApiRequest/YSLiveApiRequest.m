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
    [parameters bm_setString:liveManager.localUser.peerID forKey:@"user_id"];
    [parameters bm_setString:liveManager.localUser.nickName forKey:@"nickname"];
    [parameters bm_setString:callRollId forKey:@"call_roll_id"];
    
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
    [parameters bm_setString:liveManager.localUser.peerID forKey:@"sender_id"];
    [parameters bm_setString:liveManager.localUser.nickName forKey:@"sender_name"];
    [parameters bm_setString:liveManager.teacher.peerID forKey:@"flower_id"];
    [parameters bm_setString:liveManager.teacher.nickName forKey:@"flower_name"];
    [parameters bm_setInteger:count forKey:@"number"];
    
    return [YSApiRequest makeRequestWithURL:urlStr parameters:parameters];
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


@end

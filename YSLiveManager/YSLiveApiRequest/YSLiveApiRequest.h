//
//  YSLiveApiRequest.h
//  YSLive
//
//  Created by jiang deng on 2019/10/23.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSApiRequest.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^YSUploadProgress)(NSProgress *uploadProgress);
typedef void (^YSUploadResponse)(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error);

@interface YSLiveApiRequest : YSApiRequest


/// 获取升级信息 versionNum  发版的年月日 加上 版本递增的两位整数  例子：2019122201
+ (NSMutableURLRequest *)checkUpdateVersionNum:(NSString *)versionNum;

/// 获取服务器时间
+ (NSMutableURLRequest *)getServerTime;

/// 获取房间类型
+ (NSMutableURLRequest *)checkRoomTypeWithRoomId:(NSString *)roomId;

// 点名签到请求
+ (NSMutableURLRequest *)liveCallRollSigninWithCallRollId:(NSString *)callRollId;

/// 获取用户奖杯数
+ (NSMutableURLRequest *)getGiftCountWithRoomId:(NSString *)roomId peerId:(NSString *)peerId;
/// 给用户发送奖杯
+ (NSMutableURLRequest *)sendGiftWithRoomId:(NSString *)roomId sendUserId:(NSString *)sendUserId sendUserName:(NSString *)sendUserName receiveUserId:(NSString *)receiveUserId receiveUserName:(NSString *)receiveUserName;

/// 送花
+ (NSMutableURLRequest *)liveGivigGiftsSigninWithGiftsCount:(NSUInteger)count;

/// 上传图片
+ (void)uploadImageWithImage:(UIImage *)image withImageUseType:(NSInteger)imageUseType success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSInteger errorCode))failurel;

/// 获取答题统计信息
+ (NSMutableURLRequest *)getSimplifyAnswerCountWithRoomId:(NSString *)roomId answerId:(NSString *)answerId startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime;
/// 删除课件
+ (NSMutableURLRequest *)deleteCoursewareWithRoomId:(NSString *)roomId fileId:(NSString *)fileId;


@end


@interface YSLiveApiRequest (School)

/// 登录
/// @param domain 机构域名
/// @param admin_pwd 密码
/// @param admin_account 用户名 账号
+ (NSMutableURLRequest *)postLoginWithDomain:(NSString *)domain
                                   admin_pwd:(NSString *)admin_pwd
                               admin_account:(NSString *)admin_account;


/// 获取课表日历数据
+ (void)getCalendarCalendarWithdate:(NSString *)dateStr success:(void(^)(NSDictionary *dict))success failure:(void(^)(NSInteger errorCode))failure;


/// 获取课程列表
+ (NSMutableURLRequest *)getClassListWithStudentId:(NSString *)studentId date:(NSString *)date pagenum:(NSUInteger)pagenum;

@end

NS_ASSUME_NONNULL_END

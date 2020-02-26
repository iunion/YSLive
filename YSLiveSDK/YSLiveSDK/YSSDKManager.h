//
//  YSLiveSDKManager.h
//  YSLiveSDK
//
//  Created by jiang deng on 2019/11/27.
//  Copyright © 2019 YS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSSDKDelegate.h"

NS_ASSUME_NONNULL_BEGIN


@interface YSSDKManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, weak, readonly) id <YSSDKDelegate> delegate;

+ (NSString *)SDKVersion;

- (void)registerManagerDelegate:(nullable id <YSSDKDelegate>)managerDelegate;


- (BOOL)joinRoomWithRoomId:(NSString *)roomId nickName:(NSString *)nickName roomPassword:(nullable NSString *)roomPassword userId:(nullable NSString *)userId userParams:(nullable NSDictionary *)userParams needCheckPermissions:(BOOL)needCheckPermissions;

/// 注意：小班课和会议支持老师和学生身份登入房间，直播只支持学生身份
- (BOOL)joinRoomWithRoomId:(NSString *)roomId nickName:(NSString *)nickName roomPassword:(nullable NSString *)roomPassword userRole:(YSSDKUserRoleType)userRole userId:(nullable NSString *)userId userParams:(nullable NSDictionary *)userParams needCheckPermissions:(BOOL)needCheckPermissions;

///探测房间类型接口  3：小班课  4：直播  6：会议
/**探测房间类型接口  3：小班课  4：直播  6：会议
 * 注意：小班课和会议支持老师和学生身份登入房间，直播只支持学生身份
 *  返回参数：
   1、roomtype: YSSDKUseTheType 类型，房间类型
   2、needpwd: BOOL类型，参会人员(学生)是否需要密码
 */
- (void)checkRoomTypeBeforeJoinRoomWithRoomId:(NSString *)roomId success:(void(^)(YSSDKUseTheType roomType, BOOL needpassword))success failure:(void(^)(NSInteger code, NSString *errorStr))failure;

@end

NS_ASSUME_NONNULL_END

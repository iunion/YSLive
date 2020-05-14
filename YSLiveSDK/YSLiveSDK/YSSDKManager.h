//
//  YSLiveSDKManager.h
//  YSLiveSDK
//
//  Created by jiang deng on 2019/11/27.
//  Copyright © 2019 YS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YSSDKDelegate.h"

NS_ASSUME_NONNULL_BEGIN


@interface YSSDKManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, weak, readonly) UIViewController <YSSDKDelegate> * delegate;

+ (NSString *)SDKVersion;
+ (NSString *)SDKDetailVersion;

- (void)registerManagerDelegate:(nullable UIViewController <YSSDKDelegate> *)managerDelegate;
- (void)registerUseHttpDNSForWhiteBoard:(BOOL)needUseHttpDNSForWhiteBoard;

/// 改变白板背景颜色和水印底图
- (void)setWhiteBoardBackGroundColor:(nullable UIColor *)color maskImage:(nullable UIImage *)image;

/// needCheckPermissions设置是否检测设备权限
- (BOOL)joinRoomWithRoomId:(NSString *)roomId nickName:(NSString *)nickName roomPassword:(nullable NSString *)roomPassword userId:(nullable NSString *)userId userParams:(nullable NSDictionary *)userParams;
- (BOOL)joinRoomWithRoomId:(NSString *)roomId nickName:(NSString *)nickName roomPassword:(nullable NSString *)roomPassword userId:(nullable NSString *)userId userParams:(nullable NSDictionary *)userParams needCheckPermissions:(BOOL)needCheckPermissions;

/// 注意：小班课和会议支持老师和学生身份登入房间，直播只支持学生身份
- (BOOL)joinRoomWithRoomId:(NSString *)roomId nickName:(NSString *)nickName roomPassword:(nullable NSString *)roomPassword userRole:(YSSDKUserRoleType)userRole userId:(nullable NSString *)userId userParams:(nullable NSDictionary *)userParams;
- (BOOL)joinRoomWithRoomId:(NSString *)roomId nickName:(NSString *)nickName roomPassword:(nullable NSString *)roomPassword userRole:(YSSDKUserRoleType)userRole userId:(nullable NSString *)userId userParams:(nullable NSDictionary *)userParams needCheckPermissions:(BOOL)needCheckPermissions;

///探测房间类型接口  3：小班课  4：直播  6：会议
/**探测房间类型接口  3：小班课  4：直播  6：会议
 * 注意：小班课和会议支持老师和学生身份登入房间，直播只支持学生身份
 *  返回参数：
   1、roomType: YSSDKUseTheType 类型，房间类型
   2、needpassword: BOOL类型，参会人员(学生)是否需要密码
 */
- (void)checkRoomTypeBeforeJoinRoomWithRoomId:(NSString *)roomId success:(void(^)(YSSDKUseTheType roomType, BOOL needpassword))success failure:(void(^)(NSInteger code, NSString *errorStr))failure;

/// 添加H5课件地址参数，此方法会刷新当前H5课件以变更新参数
- (void)addConnectH5CoursewareUrlParameters:(NSDictionary *)parameters;
/// 变更H5课件地址参数，此方法会刷新当前H5课件以变更新参数
- (void)changeConnectH5CoursewareUrlParameters:(NSDictionary *)parameters;

/// 设置H5课件Cookies
- (void)setConnectH5CoursewareUrlCookies:(nullable NSArray <NSDictionary *> *)cookies;

@end

NS_ASSUME_NONNULL_END

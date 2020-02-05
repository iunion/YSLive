//
//  YSCoreStatus.h
//  YSLive
//
//  Created by jiang deng on 2019/10/12.
//  Copyright © 2019 FS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworkReachabilityManager.h"

/** 网络状态 */
typedef NS_ENUM(NSUInteger, YSCoreNetWorkStatus)
{
    /** 无网络 */
    YSCoreNetWorkStatusNone = 0,
    
    /** Wifi网络 */
    YSCoreNetWorkStatusWifi,
    
    /** 蜂窝网络 */
    YSCoreNetWorkStatusWWAN,
    
    /** 2G网络 */
    YSCoreNetWorkStatus2G,
    
    /** 3G网络 */
    YSCoreNetWorkStatus3G,
    
    /** 4G网络 */
    YSCoreNetWorkStatus4G,
    
    /** 未知网络 */
    YSCoreNetWorkStatusUnkhow
};

@protocol YSCoreNetWorkStatusProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface YSCoreStatus : NSObject

/** 获取当前网络状态：枚举 */
+ (YSCoreNetWorkStatus)currentNetWorkStatus;

/** 获取当前网络状态：字符串 */
+ (NSString *)currentNetWorkStatusString;
+ (NSString *)currentFSNetWorkStatusString;

/** 获取当前网络运营商：字符串 */
+ (NSString *)currentBrandName;

/** 开始网络监听 */
+ (void)beginMonitorNetwork:(id<YSCoreNetWorkStatusProtocol>)listener;

/** 停止网络监听 */
+ (void)endMonitorNetwork:(id<YSCoreNetWorkStatusProtocol>)listener;


/** 是否是Wifi */
+ (BOOL)isWifiEnable;

/** 是否有网络 */
+ (BOOL)isNetworkEnable;

/** 是否处于高速网络环境：3G、4G、Wifi */
+ (BOOL)isHighSpeedNetwork;

@end

@protocol YSCoreNetWorkStatusProtocol <NSObject>

@required

/** 网络状态变更 */
- (void)coreNetworkChanged:(NSNotification *)noti;

@optional

@end

NS_ASSUME_NONNULL_END

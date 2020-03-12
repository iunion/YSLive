//
//  YSCoreStatus.m
//  YSLive
//
//  Created by jiang deng on 2019/10/12.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSCoreStatus.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

static NSString *const YSCoreStatusChangedNotify = @"YSCoreStatusChangedNotify";

@interface YSCoreStatus ()

/** 2G数组 */
@property (nonatomic, strong) NSArray *technology2GArray;

/** 3G数组 */
@property (nonatomic, strong) NSArray *technology3GArray;

/** 4G数组 */
@property (nonatomic, strong) NSArray *technology4GArray;

/** 网络状态中文数组 */
@property (nonatomic, strong) NSArray *coreNetworkStatusStringArray;
@property (nonatomic, strong) NSArray *fsNetworkStatusStringArray;

@property (nonatomic, strong) CTTelephonyNetworkInfo *m_TelephonyNetworkInfo;

@property (nonatomic, copy) NSString *m_CurrentRaioAccess;

/** 是否正在监听 */
@property (nonatomic,assign) BOOL m_isMonitor;

@end

@implementation YSCoreStatus

+ (instancetype)sharedCoreStatus
{
    static id _instace;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    
    return _instace;
}

+ (void)initialize
{
    YSCoreStatus *status = [YSCoreStatus sharedCoreStatus];
    status.m_TelephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
    status.m_isMonitor = NO;
}

/** 获取当前网络状态：枚举 */
+ (YSCoreNetWorkStatus)currentNetWorkStatus
{
    YSCoreStatus *status = [YSCoreStatus sharedCoreStatus];
    
    return [status statusWithRadioAccessTechnology];
}

/** 获取当前网络状态：字符串 */
+ (NSString *)currentNetWorkStatusString
{
    YSCoreStatus *status = [YSCoreStatus sharedCoreStatus];
    
    return status.coreNetworkStatusStringArray[[self currentNetWorkStatus]];
}

+ (NSString *)currentFSNetWorkStatusString
{
    YSCoreStatus *status = [YSCoreStatus sharedCoreStatus];
    
    return status.fsNetworkStatusStringArray[[self currentNetWorkStatus]];
}

/** 获取当前网络运营商：字符串 */
+ (NSString *)currentBrandName
{
    YSCoreNetWorkStatus netWorkStatus = [YSCoreStatus currentNetWorkStatus];
    if (netWorkStatus > YSCoreNetWorkStatusWifi && netWorkStatus < YSCoreNetWorkStatusUnkhow)
    {
        YSCoreStatus *status = [YSCoreStatus sharedCoreStatus];
        
        CTCarrier *carrier = [status.m_TelephonyNetworkInfo subscriberCellularProvider];
        
        NSString *mcc = carrier.mobileCountryCode;
        if ([mcc isEqualToString:@"460"])
        {
            NSString *mnc = carrier.mobileNetworkCode;
            if ([mnc isEqualToString:@"00"] || [mnc isEqualToString:@"02"] || [mnc isEqualToString:@"07"])
            {
                return @"中国移动";
            }
            else if ([mnc isEqualToString:@"01"] || [mnc isEqualToString:@"06"] || [mnc isEqualToString:@"09"])
            {
                return @"中国联通";
            }
            else if ([mnc isEqualToString:@"03"] || [mnc isEqualToString:@"05"] || [mnc isEqualToString:@"11"])
            {
                return @"中国电信";
            }
            else if ([mnc isEqualToString:@"20"])
            {
                return @"中国铁通";
            }
        }
        else
        {
            return @"非中国大陆";
        }
    }
    
    return @"未知";
}

- (YSCoreNetWorkStatus)statusWithRadioAccessTechnology
{
    BMAFNetworkReachabilityStatus networkReachabilityStatus = [[BMAFNetworkReachabilityManager sharedManager] networkReachabilityStatus];
    
    YSCoreNetWorkStatus netWorkStatus = YSCoreNetWorkStatusNone;
    
    switch (networkReachabilityStatus)
    {
        case BMAFNetworkReachabilityStatusUnknown:
        {
            netWorkStatus = YSCoreNetWorkStatusUnkhow;
            break;
        }
        case BMAFNetworkReachabilityStatusNotReachable:
        {
            netWorkStatus = YSCoreNetWorkStatusNone;
            break;
        }
        case BMAFNetworkReachabilityStatusReachableViaWiFi:
        {
            netWorkStatus = YSCoreNetWorkStatusWifi;
            break;
        }
        case BMAFNetworkReachabilityStatusReachableViaWWAN:
        {
            netWorkStatus = YSCoreNetWorkStatusWWAN;
            break;
        }
    }
    
    NSString *technology = self.m_CurrentRaioAccess;
    
    if (netWorkStatus == YSCoreNetWorkStatusWWAN && technology != nil)
    {
        if ([self.technology2GArray containsObject:technology])
        {
            netWorkStatus = YSCoreNetWorkStatus2G;
        }
        else if ([self.technology3GArray containsObject:technology])
        {
            netWorkStatus = YSCoreNetWorkStatus3G;
        }
        else if ([self.technology4GArray containsObject:technology])
        {
            netWorkStatus = YSCoreNetWorkStatus4G;
        }
    }
    
    return netWorkStatus;
}

/** 开始网络监听 */
+ (void)beginMonitorNetwork:(id<YSCoreNetWorkStatusProtocol>)listener
{
    YSCoreStatus *status = [YSCoreStatus sharedCoreStatus];
    
    if (status.m_isMonitor)
    {
        BMLog(@"CoreStatus已经处于监听中，请检查其他页面是否关闭监听！");
        
        [self endMonitorNetwork:listener];
    }
    
    // 注册监听
    [[NSNotificationCenter defaultCenter] addObserver:listener selector:@selector(coreNetworkChanged:) name:YSCoreStatusChangedNotify object:status];
    [[NSNotificationCenter defaultCenter] addObserver:status selector:@selector(coreNetWorkStatusChanged:) name:BMAFNetworkingReachabilityDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:status selector:@selector(coreNetWorkStatusChanged:) name:CTRadioAccessTechnologyDidChangeNotification object:nil];
    
    // 开始监测
    [[BMAFNetworkReachabilityManager sharedManager] startMonitoring];

    // 标记
    status.m_isMonitor = YES;
}

/** 停止网络监听 */
+ (void)endMonitorNetwork:(id<YSCoreNetWorkStatusProtocol>)listener
{
    YSCoreStatus *status = [YSCoreStatus sharedCoreStatus];
    
    if (!status.m_isMonitor)
    {
        BMLog(@"CoreStatus监听已经被关闭");
        return;
    }
    
    // 解除监听
    [[NSNotificationCenter defaultCenter] removeObserver:status name:BMAFNetworkingReachabilityDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:status name:CTRadioAccessTechnologyDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:listener name:YSCoreStatusChangedNotify object:status];

    [[BMAFNetworkReachabilityManager sharedManager] stopMonitoring];

    // 标记
    status.m_isMonitor = NO;
}

- (void)coreNetWorkStatusChanged:(NSNotification *)notification
{
    // 发送通知
    if (notification.name == CTRadioAccessTechnologyDidChangeNotification && notification.object != nil)
    {
        self.m_CurrentRaioAccess = self.m_TelephonyNetworkInfo.currentRadioAccessTechnology;
    }
    
    // 再次发出通知
    NSDictionary *userInfo = @{@"currentStatusEnum": @([YSCoreStatus currentNetWorkStatus]),
                               @"currentStatusString": [YSCoreStatus currentNetWorkStatusString],
                               @"currentBrandName": [YSCoreStatus currentBrandName]
                               };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:YSCoreStatusChangedNotify object:self userInfo:userInfo];
}

/** 是否是Wifi */
+ (BOOL)isWifiEnable
{
    return [YSCoreStatus currentNetWorkStatus] == YSCoreNetWorkStatusWifi;
}

/** 是否有网络 */
+ (BOOL)isNetworkEnable
{
    YSCoreNetWorkStatus networkStatus = [YSCoreStatus currentNetWorkStatus];
    
    return networkStatus != YSCoreNetWorkStatusUnkhow && networkStatus != YSCoreNetWorkStatusNone;
}

/** 是否处于高速网络环境：3G、4G、Wifi */
+ (BOOL)isHighSpeedNetwork
{
    YSCoreNetWorkStatus networkStatus = [self currentNetWorkStatus];
    return networkStatus == YSCoreNetWorkStatus3G || networkStatus == YSCoreNetWorkStatus4G || networkStatus == YSCoreNetWorkStatusWifi;
}


#pragma mark -
#pragma mark 懒加载

- (CTTelephonyNetworkInfo *)m_TelephonyNetworkInfo
{
    if (_m_TelephonyNetworkInfo == nil)
    {
        _m_TelephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
    }
    
    return _m_TelephonyNetworkInfo;
}


- (NSString *)m_CurrentRaioAccess
{
    if (_m_CurrentRaioAccess == nil)
    {
        _m_CurrentRaioAccess = self.m_TelephonyNetworkInfo.currentRadioAccessTechnology;
    }
    
    return _m_CurrentRaioAccess;
}

/** 2G数组 */
- (NSArray *)technology2GArray
{
    if (_technology2GArray == nil)
    {
        _technology2GArray = @[CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyGPRS];
    }
    
    return _technology2GArray;
}


/** 3G数组 */
- (NSArray *)technology3GArray
{
    if (_technology3GArray == nil)
    {
        _technology3GArray = @[CTRadioAccessTechnologyHSDPA,
                               CTRadioAccessTechnologyWCDMA,
                               CTRadioAccessTechnologyHSUPA,
                               CTRadioAccessTechnologyCDMA1x,
                               CTRadioAccessTechnologyCDMAEVDORev0,
                               CTRadioAccessTechnologyCDMAEVDORevA,
                               CTRadioAccessTechnologyCDMAEVDORevB,
                               CTRadioAccessTechnologyeHRPD];
    }
    
    return _technology3GArray;
}

/** 4G数组 */
- (NSArray *)technology4GArray
{
    if (_technology4GArray == nil)
    {
        _technology4GArray = @[CTRadioAccessTechnologyLTE];
    }
    
    return _technology4GArray;
}

/** 网络状态中文数组 */
- (NSArray *)coreNetworkStatusStringArray
{
    if (_coreNetworkStatusStringArray == nil)
    {
        _coreNetworkStatusStringArray = @[@"无网络", @"Wifi", @"蜂窝网络", @"2G", @"3G", @"4G", @"未知网络"];
    }
    
    return _coreNetworkStatusStringArray;
}

- (NSArray *)fsNetworkStatusStringArray
{
    // 2G/3G/4G/WIFI/unknown
    if (_fsNetworkStatusStringArray == nil)
    {
        _fsNetworkStatusStringArray = @[@"no", @"WIFI", @"cellular", @"2G", @"3G", @"4G", @"unknown"];
    }
    
    return _fsNetworkStatusStringArray;
}

@end

//
//  YSWhiteBordHttpDNSUtil.h
//  YSWhiteBoard
//
//  Created by jiang deng on 2019/12/11.
//  Copyright © 2019 YS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class YSLiveManager;
@interface YSWhiteBordHttpDNSUtil : NSObject

+ (instancetype)sharedInstanceWithLiveManager:(YSLiveManager *)liveManager;
+ (instancetype)sharedInstance;

+ (void)destroy;

/// 获取host的ip地址
- (nullable NSString *)getHttpDNSIpWithHost:(NSString *)host;

/// 停止获取W网宿ip
- (void)cancelGetHttpDNSIp;

@end

NS_ASSUME_NONNULL_END

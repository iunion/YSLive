//
//  YSLiveManager.h
//  YSLive
//
//  Created by jiang deng on 2020/6/24.
//  Copyright © 2020 YS. All rights reserved.
//

#import <YSSession/YSSession.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSLiveManager : YSSessionManager

/// 网校api请求host
@property (nonatomic, strong) NSString *schoolApiHost;

@end

NS_ASSUME_NONNULL_END

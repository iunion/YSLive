//
//  YSApiRequest.h
//  YSLive
//
//  Created by jiang deng on 2019/10/12.
//  Copyright © 2019 FS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "YSAPIMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSApiRequest : NSObject

+ (NSString *)publicErrorMessageWithCode:(NSInteger)code;

+ (AFHTTPSessionManager *)makeYSHTTPSessionManager;
+ (AFHTTPRequestSerializer *)requestSerializer;

+ (nullable NSMutableURLRequest *)makeRequestWithURL:(NSString *)URLString parameters:(NSDictionary *)parameters;
+ (nullable NSMutableURLRequest *)makeRequestWithURL:(NSString *)URLString parameters:(NSDictionary *)parameters isPost:(BOOL)isPost;

@end

NS_ASSUME_NONNULL_END

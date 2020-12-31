//
//  YSApiRequest.h
//  YSLive
//
//  Created by jiang deng on 2019/10/12.
//  Copyright © 2019 FS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSAPIMacros.h"


#define YSShowErrorCode     0

NS_ASSUME_NONNULL_BEGIN

@interface YSApiRequest : NSObject

+ (NSString *)publicErrorMessageWithCode:(NSInteger)code;

+ (BMAFHTTPSessionManager *)makeYSHTTPSessionManager;
+ (BMAFHTTPSessionManager *)makeYSJSONSessionManager;

+ (BMAFHTTPRequestSerializer *)HTTPRequestSerializer;
+ (BMAFJSONRequestSerializer *)JSONRequestSerializer;

+ (nullable NSMutableURLRequest *)makeRequestWithURL:(NSString *)URLString parameters:(nullable NSDictionary *)parameters;
+ (nullable NSMutableURLRequest *)makeRequestWithURL:(NSString *)URLString parameters:(NSDictionary *)parameters isPost:(BOOL)isPost;
+ (NSMutableURLRequest *)makeRequestWithURL:(NSString *)URLString parameters:(NSDictionary *)parameters isOnlineSchool:(BOOL)isOnlineSchool;
+ (nullable NSMutableURLRequest *)makeRequestWithURL:(NSString *)URLString parameters:(NSDictionary *)parameters isPost:(BOOL)isPost isOnlineSchool:(BOOL)isOnlineSchool;

@end

NS_ASSUME_NONNULL_END

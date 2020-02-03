//
//  YSHttpClientRequest.h
//  YSRoomSDK
//
//  Created by MAC-MiNi on 2018/4/19.
//  Copyright © 2018年 MAC-MiNi. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@class YSConfigServer;

typedef void(^YSHttpRequestComplete)(id _Nullable response, NSError *_Nullable error);
typedef void(^YSHttpRequestSucess)(id _Nonnull response, NSInteger statusCode);
typedef void(^YSHttpRequestFail)(NSError *_Nonnull error, NSInteger statusCode);
typedef void(^YSHttpRequestSpeedComplete)(id _Nullable response, YSConfigServer * server,NSError *_Nullable error);
@interface YSHttpClientRequest : NSObject

+ (void)post:(NSString * _Nonnull)url parameters:(NSDictionary * _Nonnull)parameters success:(YSHttpRequestSucess)sucess failure:(YSHttpRequestFail)failure;
+ (void)get:(NSString * _Nonnull)url success:(YSHttpRequestSucess)sucess failure:(YSHttpRequestFail)failure;

- (void)checkRoomWithURL:(NSString * _Nonnull)url params:(NSDictionary * _Nonnull)params complete:(YSHttpRequestComplete _Nullable)complete;
- (void)getRoomFileListWithURL:(NSString * _Nonnull)url params:(NSDictionary * _Nonnull)params complete:(YSHttpRequestComplete _Nullable)complete;
- (void)getConfigWithURL:(NSString * _Nonnull)url params:(NSDictionary * _Nonnull)params complete:(YSHttpRequestComplete _Nullable)complete;

- (void)getWhereWithHost:(NSString * _Nonnull)host port:(NSString * _Nonnull)port complete:(YSHttpRequestComplete _Nullable)complete;

- (void)getRoomJsonWithPath:(NSString * _Nonnull)path aComplete:(YSHttpRequestComplete _Nullable)aComplete;
- (void)getServerListWithURL:(NSString * _Nonnull)url complete:(YSHttpRequestComplete _Nullable)complete;

- (void)postWithURL:(NSString * _Nonnull)url api:(NSString * _Nonnull)api paramData:(id)param complete:(YSHttpRequestComplete _Nullable)complete;
- (void)postWithURL:(NSString * _Nonnull)url interface:(NSString * _Nonnull)interfaceName api:(NSString * _Nonnull)api paramData:(id)param complete:(YSHttpRequestComplete _Nullable)complete;
- (void)getServerSpeedWithURL:(NSString *)url server:(YSConfigServer *)server complete:(YSHttpRequestSpeedComplete _Nullable)complete;
- (void)webRPCWithURL:(NSString * _Nonnull)url
           api:(NSString * _Nonnull)api
      postData:(id _Nonnull)post
      complete:(YSHttpRequestComplete _Nullable)complete;
@end

@interface YSConfigServer : NSObject
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *signaladdr;
@property (strong, nonatomic) NSNumber *signalport;
@property (copy, nonatomic) NSString *webaddr;
@property (strong, nonatomic) NSArray *docaddr;
@property (copy, nonatomic) NSString *change;
@end
NS_ASSUME_NONNULL_END


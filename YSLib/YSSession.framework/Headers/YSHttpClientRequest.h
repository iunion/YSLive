//
//  YSHttpClientRequest.h
//  YSRoomSDK
//
//  Created by jiang deng on 2020/5/26.
//  Copyright © 2020 Road of Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YSConfigServer;

NS_ASSUME_NONNULL_BEGIN

typedef void(^YSHttpRequestComplete)(id _Nullable response, NSError *_Nullable error);
typedef void(^YSHttpRequestSucess)(id _Nonnull response, NSInteger statusCode);
typedef void(^YSHttpRequestFail)(NSError *_Nonnull error, NSInteger statusCode);
typedef void(^YSHttpRequestSpeedComplete)(id _Nullable response, YSConfigServer *server, NSError *_Nullable error);

@interface YSHttpClientRequest : NSObject

- (void)destroy;

+ (NSURLSessionDataTask *)post:(NSString * _Nonnull)url parameters:(NSDictionary * _Nonnull)parameters success:(YSHttpRequestSucess)sucess failure:(YSHttpRequestFail)failure;
+ (NSURLSessionDataTask *)get:(NSString * _Nonnull)url success:(YSHttpRequestSucess)sucess failure:(YSHttpRequestFail)failure;

- (NSURLSessionDataTask *)webRPCWithURL:(NSString * _Nonnull)url
                                    api:(NSString * _Nonnull)api
                               postData:(id _Nonnull)post
                               complete:(YSHttpRequestComplete _Nullable)complete;

- (NSURLSessionDataTask *)checkRoomWithURL:(NSString * _Nonnull)url params:(NSDictionary * _Nonnull)params complete:(YSHttpRequestComplete _Nullable)complete;
- (NSURLSessionDataTask *)getRoomFileListWithURL:(NSString * _Nonnull)url params:(NSDictionary * _Nonnull)params complete:(YSHttpRequestComplete _Nullable)complete;
- (NSURLSessionDataTask *)getConfigWithURL:(NSString * _Nonnull)url params:(NSDictionary * _Nonnull)params complete:(YSHttpRequestComplete _Nullable)complete;

- (NSURLSessionDataTask *)getWhereWithHost:(NSString * _Nonnull)host port:(NSString * _Nonnull)port complete:(YSHttpRequestComplete _Nullable)complete;

- (NSURLSessionDataTask *)getRoomJsonWithPath:(NSString * _Nonnull)path complete:(YSHttpRequestComplete _Nullable)complete;
- (NSURLSessionDataTask *)getServerListWithURL:(NSString * _Nonnull)url complete:(YSHttpRequestComplete _Nullable)complete;

- (NSURLSessionDataTask *)postWithURL:(NSString * _Nonnull)url api:(NSString * _Nonnull)api paramData:(id)param complete:(YSHttpRequestComplete _Nullable)complete;
- (NSURLSessionDataTask *)postWithURL:(NSString * _Nonnull)url interface:(NSString * _Nonnull)interfaceName api:(NSString * _Nonnull)api paramData:(id)param complete:(YSHttpRequestComplete _Nullable)complete;

@end


#pragma mark - YSConfigServer

@interface YSConfigServer : NSObject

/// 线路名
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *signaladdr;
@property (nonatomic, assign) NSUInteger signalport;

@property (nonatomic, strong) NSString *webaddr;

@property (nonatomic, strong) NSArray *docaddr;

@property (nonatomic, strong) NSString *change;

+ (instancetype)configServerWithDic:(NSDictionary *)dic;
- (void)updateWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END

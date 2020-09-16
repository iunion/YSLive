//
//  CHWhiteBoradRequest.h
//  CHWhiteBoard
//
//  Created by jiang deng on 2020/9/16.
//

#import <BMKit/BMKit.h>

#define CHWhiteBoradRequestErrorDomain @"CHWhiteBoradRequestErrorDomain"

NS_ASSUME_NONNULL_BEGIN

typedef void(^CHWhiteBoradRequestComplete)(id _Nullable response, NSError *_Nullable error);
typedef void(^CHWhiteBoradRequestSucess)(id _Nonnull response, NSInteger statusCode);
typedef void(^CHWhiteBoradRequestFail)(NSError *_Nonnull error, NSInteger statusCode);

@interface CHWhiteBoradRequest : BMHttpRequest

- (NSURLSessionDataTask *)getRoomFileListWithURL:(NSString * _Nonnull)url params:(NSDictionary * _Nonnull)params complete:(CHWhiteBoradRequestComplete _Nullable)complete;

@end

NS_ASSUME_NONNULL_END

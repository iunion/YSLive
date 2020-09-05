//
//  BMHttpRequest.h
//  BMKit
//
//  Created by jiang deng on 2020/9/5.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^BMHttpRequestSucess)(id _Nonnull response, NSInteger statusCode);
typedef void(^BMHttpRequestFail)(NSError *_Nonnull error, NSInteger statusCode);

@interface BMHttpRequest : NSObject

- (void)destroy;

+ (NSURLSessionDataTask *)post:(NSString * _Nonnull)url parameters:(NSDictionary * _Nonnull)parameters success:(BMHttpRequestSucess)sucess failure:(BMHttpRequestFail)failure;
+ (NSURLSessionDataTask *)get:(NSString * _Nonnull)url success:(BMHttpRequestSucess)sucess failure:(BMHttpRequestFail)failure;

@end


NS_ASSUME_NONNULL_END

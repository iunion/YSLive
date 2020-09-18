//
//  BMHttpRequest.m
//  BMKit
//
//  Created by jiang deng on 2020/9/5.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#import "BMHttpRequest.h"

#define BMRequest_TimeoutInterval     (60.0f)

@interface BMHttpRequest()
<
    NSURLSessionDelegate
>

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation BMHttpRequest

+ (void)runOnMainQueueAsync:(dispatch_block_t)block
{
    if (!block)
    {
        return;
    }
    
    if ([NSThread mainThread])
    {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

+ (NSURLSessionDataTask *)get:(NSString *)url success:(BMHttpRequestSucess)sucess failure:(BMHttpRequestFail)failure
{
    NSURL *urlAdd = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlAdd];
    [request setTimeoutInterval:BMRequest_TimeoutInterval];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *tSessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSInteger code = ((NSHTTPURLResponse *)response).statusCode;
        if (!error)
        {
            sucess(data, code);
        }
        else
        {
            failure(error, code);
        }
    }];
    
    [tSessionTask resume];
    
    return tSessionTask;
}

+ (NSURLSessionDataTask *)post:(NSString * _Nonnull)url parameters:(NSDictionary * _Nonnull)parameters success:(BMHttpRequestSucess)sucess failure:(BMHttpRequestFail)failure
{
    if (!parameters)
    {
        return nil;
    }
    
    NSURL *URL = [NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    NSMutableString *postString = [[NSMutableString alloc] init];
    if ([parameters bm_isNotEmptyDictionary])
    {
        for (id key in [parameters allKeys])
        {
            [postString appendFormat:@"%@=%@&", key, [parameters objectForKey:key]];
        }
        [postString deleteCharactersInRange:NSMakeRange([postString length] - 1, 1)];
    }
    // 将请求参数字符串转成NSData类型
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"]; //指定请求方式
    [request setURL:URL]; //设置请求的地址
    [request setHTTPBody:postData];  //设置请求的参数
    [request setTimeoutInterval:BMRequest_TimeoutInterval];
    // 保证同步
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSInteger code = ((NSHTTPURLResponse *)response).statusCode;
        if (!error)
        {
            NSError *parseError = nil;
            id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&parseError];
            if (parseError)
            {
                if (failure)
                {
                    [self runOnMainQueueAsync:^{
                        failure(parseError, code);
                    }];
                }
            }
            else
            {
                if (sucess && json)
                {
                    [self runOnMainQueueAsync:^{
                        sucess(json, code);
                    }];
                }
            }
        }
        else
        {
            if (failure)
            {
                [self runOnMainQueueAsync:^{
                    failure(error, code);
                }];
            }
        }
    }];
    [task resume];
    
    return task;
}

- (instancetype)init
{
    if (self = [super init])
    {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.HTTPAdditionalHeaders = @{
                                         @"User-Agent" : @"XXXX/3.5.0 (iPhone; iOS 10.0; Scale/2.00)",
                                         @"Accept-Language" : @"zh-Hans-US;q=1, en;q=0.9"//,
//                                         @"Accept-Encoding" : @"gzip"
                                         };
        self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

- (void)destroy
{
    [self.session invalidateAndCancel];
}

@end

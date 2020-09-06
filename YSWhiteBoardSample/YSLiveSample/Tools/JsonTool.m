//
//  JsonTool.m
//  YSLiveSample
//
//  Created by jiang deng on 2020/9/6.
//  Copyright © 2020 yunshuxunlian. All rights reserved.
//

#import "JsonTool.h"

@implementation NSDictionary (CHJson)

- (NSString *)ch_toJSON
{
    // NSJSONWritingPrettyPrinted
    return [self ch_toJSONWithOptions:0];
}

- (NSString *)ch_toJSONWithOptions:(NSJSONWritingOptions)options
{
    NSString *json = nil;
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:options error:&error];
    
    if (!jsonData)
    {
        return @"{}";
    }
    else if (!error)
    {
        json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return json;
    }
    else
    {
        NSLog(@"%@", error.localizedDescription);
    }
    
    return nil;
}

+ (NSDictionary *)ch_dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end



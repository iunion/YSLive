//
//  JsonTool.h
//  YSLiveSample
//
//  Created by jiang deng on 2020/9/6.
//  Copyright © 2020 yunshuxunlian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (CHJson)

- (nullable NSString *)ch_toJSON;
- (nullable NSString *)ch_toJSONWithOptions:(NSJSONWritingOptions)options;
+ (nullable NSDictionary *)ch_dictionaryWithJsonString:(nullable NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END

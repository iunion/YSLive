//
//  YSLiveUtil.h
//  YSLive
//
//  Created by jiang deng on 2019/10/19.
//  Copyright © 2019 FS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSLiveUtil : NSObject

+ (NSString *)makeApiSignWithData:(NSObject *)data;
+ (NSString *)getOccuredErrorCode:(NSInteger)errorCode;
+ (NSString *)getOccuredErrorCode:(NSInteger)errorCode defaultMessage:(nullable NSString *)message;

@end

NS_ASSUME_NONNULL_END

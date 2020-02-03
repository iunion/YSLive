//
//  YSAppInfo.h
//  YSLive
//
//  Created by jiang deng on 2019/10/12.
//  Copyright © 2019 FS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSAppInfo : NSObject

// 渠道名称
+ (NSString *)catchChannelName;

// OpenUDID
//+ (NSString *)getOpenUDID;
//+ (void)setOpenUDID:(NSString *)openUDID;

// 用户标识
+ (NSString *)getCurrentPhoneNum;
+ (void)setCurrentPhoneNum:(NSString *)phoneNum;

// 升级版本
+ (NSString *)getUpdateVersion;
+ (void)setUpdateVersion:(NSString *)version;

@end

NS_ASSUME_NONNULL_END

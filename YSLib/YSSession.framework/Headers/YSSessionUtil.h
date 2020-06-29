//
//  YSSessionUtil.h
//  YSSession
//
//  Created by jiang deng on 2020/6/15.
//  Copyright © 2020 YS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSSessionUtil : NSObject

+ (BOOL)isDomain:(NSString *)host;

/// 检查数据类型
+ (BOOL)checkDataClass:(id)data;
/// 将数据转换成字典类型NSDictionary
+ (nullable NSDictionary *)convertWithData:(nullable id)data;


/// 文件扩展名检查，是否是媒体文件
+ (BOOL)checkIsMedia:(NSString *)filetype;
/// 文件扩展名检查，是否是视频文件
+ (BOOL)checkIsVideo:(NSString *)filetype;
/// 文件扩展名检查，是否是音频文件
+ (BOOL)checkIsAudio:(NSString *)filetype;

/// 设备型号性能判断
+ (BOOL)deviceisConform;

/// 生成UUID
+ (NSString *)createUUID;

@end

NS_ASSUME_NONNULL_END

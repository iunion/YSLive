//
//  BMCloudHubUtil.h
//  BMKit
//
//  Created by jiang deng on 2020/9/9.
//  Copyright © 2020 DennisDeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMCloudHubUtil : NSObject

/// 获取设备语言
+ (NSString *)getCurrentLanguage;

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
+ (BOOL)deviceIsConform;

/// 生成UUID
+ (NSString *)createUUID;

/// 替换URL的host
+ (NSString *)changeUrl:(NSURL *)url withProtocol:(nullable NSString *)protocol host:(NSString *)host;

@end

NS_ASSUME_NONNULL_END

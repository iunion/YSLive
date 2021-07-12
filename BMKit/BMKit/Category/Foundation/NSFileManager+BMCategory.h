//
//  NSFileManager+BMCategory.h
//  BMKit
//
//  Created by jiang deng on 2021/7/12.
//  Copyright © 2021 DennisDeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (BMCategory)

/// 判断文件是否存在
+ (BOOL)bm_fileIsExists:(NSString *)path;

/// 创建目录(已判断是否存在)
+ (BOOL)bm_creatDirectory:(NSString *)path;

/// 删除文件
+ (BOOL)bm_removeFileWithPath:(NSString *)filePath;

/// 重置文件夹
+ (BOOL)bm_resetFinderWithPath:(NSString *)finderPath;

/// 路径是否是目录类型
+ (BOOL)bm_isDirectory:(NSString *)filePath;

/// 移动文件
+ (BOOL)bm_moveFilesInPath:(NSString *)srcPath toPath:(NSString *)dstPath;

/// 获取创建时间
+ (NSDate *)bm_creationDateWithPath:(NSString *)path;
/// 计算指定路径下的文件是否超过了规定时间
+ (BOOL)bm_isTimeoutWithPath:(NSString *)path time:(NSTimeInterval)timeout;

/// 获取单个文件的大小
+ (double)bm_fileSizeAtPath:(NSString *)filePath;
/// 获取单个文件的大小 B,KB,MB,GB 保留两位
+ (NSString *)bm_fileSizeStringAtPath:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END

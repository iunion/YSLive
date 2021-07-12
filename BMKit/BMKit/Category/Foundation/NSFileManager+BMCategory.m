//
//  NSFileManager+BMCategory.m
//  BMKit
//
//  Created by jiang deng on 2021/7/12.
//  Copyright © 2021 DennisDeng. All rights reserved.
//

#import "NSFileManager+BMCategory.h"

@implementation NSFileManager (BMCategory)

+ (BOOL)bm_fileIsExists:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)bm_creatDirectory:(NSString *)path
{
    BOOL isDir = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    // 目标路径的目录不存在则创建目录
    if (isDir && existed)
    {
        return YES;
    }
    else if(!existed && isDir)
    {
        return [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    else
    {
        return NO;
    }
}

+ (BOOL)bm_removeFileWithPath:(NSString *)filePath
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return YES;
    }
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

+ (BOOL)bm_resetFinderWithPath:(NSString *)finderPath
{
    BOOL ret = YES;
    if ([NSFileManager bm_removeFileWithPath:finderPath])
    {
        ret = [[NSFileManager defaultManager] createDirectoryAtPath:finderPath
                                        withIntermediateDirectories:YES
                                                         attributes:nil
                                                              error:nil];
    }
    
    return ret;
}

+ (BOOL)bm_isDirectory:(NSString *)filePath
{
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    
    return isDirectory;
}

+ (BOOL)bm_moveFilesInPath:(NSString *)srcPath toPath:(NSString *)dstPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![srcPath bm_isNotEmpty])
    {
        return NO;
    }
    BOOL srcExisted = [fileManager fileExistsAtPath:srcPath isDirectory:nil];
    if (!srcExisted)
    {
        return NO;
    }
    
    // 如果不存在则创建父目录
    BOOL flag = [self bm_creatDirectory:[dstPath stringByDeletingLastPathComponent]];
    if (!flag)
    {
        return NO;
    }
    
    // 检查并清空目标目录
    if ([NSFileManager bm_fileIsExists:dstPath])
    {
        [NSFileManager bm_removeFileWithPath:dstPath];
    }
    
    NSError *error;
    BOOL moveSuccess = [fileManager moveItemAtPath:srcPath toPath:dstPath error:&error];
    return moveSuccess;
}

+ (NSDate *)bm_creationDateWithPath:(NSString *)path
{
    NSDictionary *info = [[NSFileManager defaultManager]
                          attributesOfItemAtPath:path error:nil];
    
    NSDate *creationDate = [info valueForKey:NSFileCreationDate];
    return creationDate;
}

+ (BOOL)bm_isTimeoutWithPath:(NSString *)path time:(NSTimeInterval)timeout
{
    NSDate *creationDate = [NSFileManager bm_creationDateWithPath:path];
    NSDate *currentDate = [NSDate date];
    
    return [currentDate timeIntervalSinceDate:creationDate] > timeout;
}

+ (double)bm_fileSizeAtPath:(NSString *)filePath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath])
    {
        double theSize = [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
        return theSize;
    }
    
    return 0.0;
}

+ (NSString *)bm_fileSizeStringAtPath:(NSString *)filePath
{
    double fileSize = [NSFileManager bm_fileSizeAtPath:filePath];
    NSString *ret = [NSString bm_storeStringWithBitSize:fileSize];
    return ret;
}

@end

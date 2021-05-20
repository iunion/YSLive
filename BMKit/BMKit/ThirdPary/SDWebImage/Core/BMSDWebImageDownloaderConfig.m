/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDWebImageDownloaderConfig.h"

static BMSDWebImageDownloaderConfig * _defaultBMDownloaderConfig;

@implementation BMSDWebImageDownloaderConfig

+ (BMSDWebImageDownloaderConfig *)defaultDownloaderConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultBMDownloaderConfig = [BMSDWebImageDownloaderConfig new];
    });
    return _defaultBMDownloaderConfig;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _maxConcurrentDownloads = 6;
        _downloadTimeout = 15.0;
        _executionOrder = BMSDWebImageDownloaderFIFOExecutionOrder;
        _acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    BMSDWebImageDownloaderConfig *config = [[[self class] allocWithZone:zone] init];
    config.maxConcurrentDownloads = self.maxConcurrentDownloads;
    config.downloadTimeout = self.downloadTimeout;
    config.minimumProgressInterval = self.minimumProgressInterval;
    config.sessionConfiguration = [self.sessionConfiguration copyWithZone:zone];
    config.operationClass = self.operationClass;
    config.executionOrder = self.executionOrder;
    config.urlCredential = self.urlCredential;
    config.username = self.username;
    config.password = self.password;
    config.acceptableStatusCodes = self.acceptableStatusCodes;
    config.acceptableContentTypes = self.acceptableContentTypes;

    return config;
}


@end

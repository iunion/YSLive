//
//  CloudHubRtcEngineKit.h
//  CloudHubRtcEngineKit
//
//  Copyright (c) 2020 CloudHub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudHubObjects.h"
#import "CloudHubRtcEngineDelegate.h"
#import "CloudHubRtcEngineDelegate.internal.h"

/**
 The CloudHubRtcEngineKit class is the entry point of the SDK providing API methods for apps to easily start voice and video communication.
 */
@class CloudHubRtcEngineKitInternal;

#pragma mark - CloudHubRtcEngineKitInternal

__attribute__((visibility("default"))) @interface CloudHubRtcEngineKitInternal : CloudHubRtcEngineKit

#pragma mark internal use only

+ (instancetype _Nonnull)sharedEngineWithAppId:(NSString * _Nonnull)appId config:(NSString * _Nullable)config;

- (int) addInjectStreamUrl:(NSString * _Nonnull)url attributes:(NSString* _Nullable)attributes;

- (int) removeInjectStreamUrl:(NSString *_Nonnull)url;

- (void) seekInjectStreamUrl:(NSString *_Nonnull)url positionByMS:(NSUInteger)position;

- (void) pauseInjectStreamUrl:(NSString *_Nonnull)url pause:(BOOL)pause;

- (void)logMessage:(NSInteger)level log:(NSString* _Nonnull)log file:(NSString* _Nonnull)file line:(NSInteger)line;

- (int)setPublishToID:(NSString* _Nonnull)toID;

- (int)publishStreamTo:(NSString* _Nonnull)toID;

@property (nonatomic, weak) id<CloudHubRtcEngineDelegate> _Nullable wb;

@property (nonatomic, weak) id<CloudHubRtcEngineDelegateInternal> _Nullable internaldelegate;
@end

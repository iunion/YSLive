//
//  CloudHubRtcEngineKit.h
//  CloudHubRtcEngineKit
//
//  Copyright (c) 2020 CloudHub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudHubObjects.h"

@class CloudHubRtcEngineKit;

@protocol CloudHubRtcEngineDelegateInternal <NSObject>

@optional

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onStreamInjectedStatus:(NSString * _Nonnull)uid streamID:(NSString * _Nonnull)streamID attributes:(NSString * _Nonnull)attributes status:(CloudHubStreamInjectStatus)status;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onStreamInjectedPosition:(NSString * _Nonnull)uid streamID:(NSString * _Nonnull)streamID pos:(NSUInteger)pos;

@end

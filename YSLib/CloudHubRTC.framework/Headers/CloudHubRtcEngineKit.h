//
//  CloudHubRtcEngineKit.h
//  CloudHubRtcEngineKit
//
//  Copyright (c) 2020 CloudHub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudHubObjects.h"
#import "CloudHubRtcEngineDelegate.h"

/**
 The CloudHubRtcEngineKit class is the entry point of the SDK providing API methods for apps to easily start voice and video communication.
 */
@class CloudHubRtcEngineKit;

#pragma mark - CloudHubRtcEngineKit

__attribute__((visibility("default"))) @interface CloudHubRtcEngineKit : NSObject

#pragma mark Core Service

+ (instancetype _Nonnull)sharedEngineWithAppId:(NSString * _Nonnull)appId config:(NSString * _Nullable)config;

- (int)setChannelProfile:(CloudHubChannelProfile)profile;

- (int)setClientRole:(CloudHubClientRole)role;

- (int)joinChannelByToken:(NSString * _Nullable)token
                channelId:(NSString * _Nonnull)channelId
               properties:(NSString * _Nullable)properties
                      uid:(NSString * _Nullable)uid
              joinSuccess:(void(^ _Nullable)(NSString * _Nonnull channel, NSString * _Nonnull uid, NSInteger elapsed))joinSuccessBlock;

- (int)leaveChannel:(void(^ _Nullable)(void))leaveChannelBlock;

- (int)renewToken:(NSString * _Nonnull)token;

- (CloudHubConnectionStateType)getConnectionState;

#pragma mark Publishing

- (int)publishStream;

- (int)unPublishStream;

#pragma mark Subscribing

// Please read the documents before using these interfaces.
- (void)setAutoSubscribe:(BOOL)bAuto;

- (int)subscribeWithUID:(NSString * _Nonnull)uid
              videoType:(CloudHubMediaType)type;

- (int)unSubscribeWithUID:(NSString * _Nonnull)uid
                videoType:(CloudHubMediaType)type;

#pragma mark Subscribing (Plus)

- (int)subscribe:(NSString * _Nullable)streamID;

- (int)unSubscribe:(NSString * _Nullable)streamID;

#pragma mark Core Audio

- (int)enableAudio;

- (int)disableAudio;

- (int)enableLocalAudio:(BOOL)enabled;

- (int)muteLocalAudioStream:(BOOL)mute;

- (int)muteRemoteAudioStream:(NSString* _Nonnull)uid mute:(BOOL)mute;

- (int)muteAllRemoteAudioStreams:(BOOL)mute;

- (int)setDefaultMuteAllRemoteAudioStreams:(BOOL)mute;

- (int)enableAudioVolumeIndication:(NSInteger)interval smooth:(NSInteger)smooth reportVAD:(BOOL)reportVad;

#pragma mark Core Video

- (int)enableVideo;

- (int)disableVideo;

- (int)setVideoEncoderConfiguration:(CloudHubVideoEncoderConfiguration * _Nonnull)config;

- (int)setVideoRotation:(CloudHubVideoRotation)rotation;

- (int)startPlayingLocalVideo:(VIEW_CLASS * _Nonnull)view
                   renderMode:(CloudHubVideoRenderMode) renderMode
                   mirrorMode:(CloudHubVideoMirrorMode) mirrorMode;

- (int)stopPlayingLocalVideo;

- (int)startPlayingRemoteVideo:(VIEW_CLASS * _Nonnull)view
                       withUID:(NSString * _Nonnull)uid
                     videoType:(CloudHubMediaType)type
                    renderMode:(CloudHubVideoRenderMode) renderMode
                    mirrorMode:(CloudHubVideoMirrorMode) mirrorMode;

- (int)stopPlayingRemoteVideoUID:(NSString * _Nonnull)uid
                       videoType:(CloudHubMediaType)type;

- (int)setLocalRenderMode:(CloudHubVideoRenderMode) renderMode
               mirrorMode:(CloudHubVideoMirrorMode) mirrorMode;

- (int)setRemoteRenderModeWithUID:(NSString * _Nonnull)uid
                        videoType:(CloudHubMediaType)type
                       renderMode:(CloudHubVideoRenderMode) renderMode
                       mirrorMode:(CloudHubVideoMirrorMode) mirrorMode;

- (int)enableLocalVideo:(BOOL)enabled;

- (int)muteLocalVideoStream:(BOOL)mute;

- (int)muteRemoteVideoStreamWithUID:(NSString * _Nonnull)uid
                               mute:(BOOL)mute
                           deviceID:(NSString * _Nullable)deviceID;

- (int)muteAllRemoteVideoStreams:(BOOL)mute;

- (int)setDefaultMuteAllRemoteVideoStreams:(BOOL)mute;

#pragma mark Core Video (Plus)

- (int)startPlayingRemoteVideo:(VIEW_CLASS * _Nonnull)view
                      streamID:(NSString * _Nonnull)streamID
                    renderMode:(CloudHubVideoRenderMode) renderMode
                    mirrorMode:(CloudHubVideoMirrorMode) mirrorMode;

- (int)stopPlayingRemoteVideo:(NSString * _Nonnull)streamID;

- (int)setRemoteRenderMode:(NSString * _Nonnull)streamID
                renderMode:(CloudHubVideoRenderMode) renderMode
                mirrorMode:(CloudHubVideoMirrorMode) mirrorMode;

#if TARGET_OS_IPHONE
#pragma mark Audio Routing Controller

- (int)setEnableSpeakerphone:(BOOL)enableSpeaker;

- (BOOL)isSpeakerphoneEnabled;
#endif

#pragma mark Online Media File Playing

- (int) addInjectStreamUrl:(NSString * _Nonnull)url attributes:(NSString* _Nullable)attributes;

- (int) removeInjectStreamUrl:(NSString *_Nonnull)url;

- (void) seekInjectStreamUrl:(NSString *_Nonnull)url positionByMS:(NSUInteger)position;

- (void) pauseInjectStreamUrl:(NSString *_Nonnull)url pause:(BOOL)pause;

#pragma mark Local Movie File Playback

- (int) startPlayingMovie:(NSString * _Nonnull)filepath cycle:(BOOL)cycle;

- (int) stopPlayingMovie:(NSString * _Nonnull)filepath;

- (int) pausePlayingMovie:(NSString * _Nonnull)filepath;

- (int) resumePlayingMovie:(NSString * _Nonnull)filepath;

- (CloudHubLocalMovieInfo * _Nullable) getMovieInfo:(NSString * _Nonnull)filepath;

- (NSUInteger) getMovieCurrentPosition:(NSString * _Nonnull)filepath;

- (int) setMoviePosition:(NSUInteger)pos withFile:(NSString * _Nonnull)filepath;

#if TARGET_OS_IPHONE
#pragma mark Camera Control

- (int)switchCamera:(BOOL)front;

#endif

#pragma mark Conrolling Methods

- (int)setPropertyOfUid:(NSString * _Nonnull)uid tell:(NSString * _Nullable)whom properties:(NSString * _Nonnull)prop;

- (int)sendChatMsg:(NSString * _Nonnull)message to:(NSString * _Nullable)whom withExtraData:(NSString * _Nullable)extraData;

- (int)pubMsg:(NSString * _Nonnull)msgName
        msgId:(NSString * _Nonnull)msgId
           to:(NSString * _Nullable)whom
     withData:(NSString * _Nullable)data
associatedWithUser:(NSString * _Nullable)uid
associatedWithMsg:(NSString * _Nullable)assMsgID
save:(BOOL)save
extraData:(NSString * _Nullable)extra;


- (int)delMsg:(NSString * _Nonnull)msgName
        msgId:(NSString * _Nonnull)msgId
           to:(NSString * _Nullable)whom;

- (int)delMsg:(NSString * _Nonnull)msgName
        msgId:(NSString * _Nonnull)msgId
           to:(NSString * _Nullable)whom
     withData:(NSString * _Nullable)data;

- (int)evictUser:(NSString * _Nonnull)uid reason:(NSInteger)reason;

#pragma mark Miscellaneous Methods

- (NSString * _Nullable)getCallId;

+ (NSString * _Nonnull)getSdkVersion;

- (int)setLogFilter:(NSUInteger)filter;

@property (nonatomic, weak) id<CloudHubRtcEngineDelegate> _Nullable delegate;

@property (nonatomic, weak) id<CloudHubRtcEngineDelegate> _Nullable wb;

#pragma mark internal use only

- (void)logMessage:(NSInteger)level log:(NSString* _Nonnull)log file:(NSString* _Nonnull)file line:(NSInteger)line;

- (int)setPublishToID:(NSString* _Nonnull)toID;

- (int)publishStreamTo:(NSString* _Nonnull)toID;

@end

//
//  CloudHubRtcEngineKit.h
//  CloudHubRtcEngineKit
//
//  Copyright (c) 2020 CloudHub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudHubObjects.h"

@class CloudHubRtcEngineKit;

@protocol CloudHubRtcEngineDelegate <NSObject>

@optional
#pragma mark Core Delegate Methods

/**-----------------------------------------------------------------------------
 * @name Core Delegate Methods
 * -----------------------------------------------------------------------------
 */

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine didOccurError:(CloudHubErrorCode)errorCode withMessage:(NSString * _Nonnull)message;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine didJoinChannel:(NSString * _Nonnull)channel withUid:(NSString * _Nonnull)uid  elapsed:(NSInteger) elapsed;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine didReJoinChannel:(NSString * _Nonnull)channel withUid:(NSString * _Nonnull)uid  elapsed:(NSInteger) elapsed;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onServerTime:(NSUInteger)serverts;//reserved

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onDocAddr:(NSString * _Nonnull)docaddr serial:(NSString * _Nonnull)serial;//reserved

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine didLeaveChannel:(CloudHubChannelStats * _Nonnull)stats;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onClientRoleChangedFrom:(CloudHubClientRole)oldRole to:(CloudHubClientRole)newRole;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine didJoinedOfUid:(NSString * _Nonnull)uid properties:(NSString * _Nullable)properties isHistory:(BOOL)isHistory;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine didOfflineOfUid:(NSString * _Nonnull)uid;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine connectionChangedToState:(CloudHubConnectionStateType)state;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine tokenPrivilegeWillExpire:(NSString *_Nonnull)token;

- (void)rtcEngineRequestToken:(CloudHubRtcEngineKit * _Nonnull)engine;


#pragma mark Mannual Subscribing Delegate Methods
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onUserPublished:(NSString * _Nonnull)uid
             type:(CloudHubMediaType)type;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onUserUnPublished:(NSString * _Nonnull)uid
             type:(CloudHubMediaType)type;

#pragma mark Mannual Subscribing Delegate Methods (Plus)
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onUserPublished:(NSString * _Nonnull)uid
             type:(CloudHubMediaType)type sourceID:(NSString *_Nonnull)sourceID streamID:(NSString *_Nonnull)streamID;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onUserUnPublished:(NSString * _Nonnull)uid
             type:(CloudHubMediaType)type sourceID:(NSString *_Nonnull)sourceID streamID:(NSString *_Nonnull)streamID;

#pragma mark Audio Delegate Methods

/**-----------------------------------------------------------------------------
 * @name Audio Delegate Methods
 * -----------------------------------------------------------------------------
 */

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine reportAudioVolumeIndication:(NSArray * _Nonnull)speakers totalVolume:(NSInteger)totalVolume;

- (void)rtcEngineFirstLocalAudioFrame:(CloudHubRtcEngineKit * _Nonnull)engine;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine firstRemoteAudioFrameOfUid:(NSString * _Nonnull)uid;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine remoteAudioStateChangedOfUid:(NSString * _Nonnull)uid state:(CloudHubAudioRemoteState)state reason:(CloudHubAudioRemoteStateReason)reason;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine localAudioStateChange:(CloudHubAudioLocalState)state error:(CloudHubAudioLocalError)error;

#pragma mark Local Video Delegate Methods

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine localVideoStateChangeWithState:(CloudHubLocalVideoStreamState)state error:(CloudHubLocalVideoStreamError)error;


#pragma mark Remote Video Delegate Methods

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine firstRemoteVideoFrameOfUID:(NSString * _Nonnull)uid type:(CloudHubMediaType)type Size:(CGSize)size;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine remoteVideoSizeChangedOfUID:(NSString * _Nonnull)uid  type:(CloudHubMediaType)type size:(CGSize)size;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine remoteVideoStateChangedOfUid:(NSString * _Nonnull)uid  type:(CloudHubMediaType)type state:(CloudHubVideoRemoteState)state reason:(CloudHubVideoRemoteStateReason)reason;

#pragma mark Remote Video Delegate Methods (Plus)

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine firstRemoteVideoFrameOfUID:(NSString * _Nonnull)uid sourceID:(NSString * _Nonnull)sourceID streamID:(NSString * _Nonnull)streamID type:(CloudHubMediaType)type Size:(CGSize)size;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine remoteVideoSizeChangedOfUID:(NSString * _Nonnull)uid sourceID:(NSString * _Nonnull)sourceID streamID:(NSString * _Nonnull)streamID type:(CloudHubMediaType)type size:(CGSize)size;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine remoteVideoStateChangedOfUid:(NSString * _Nonnull)uid sourceID:(NSString * _Nonnull)sourceID streamID:(NSString * _Nonnull)streamID type:(CloudHubMediaType)type state:(CloudHubVideoRemoteState)state reason:(CloudHubVideoRemoteStateReason)reason;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onStreamInjectedStatus:(NSString * _Nonnull)uid streamID:(NSString * _Nonnull)streamID attributes:(NSString * _Nonnull)attributes status:(CloudHubStreamInjectStatus)status;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onStreamInjectedPosition:(NSString * _Nonnull)uid streamID:(NSString * _Nonnull)streamID pos:(NSUInteger)pos;

#pragma mark Statistics Delegate Methods

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine localAudioStats:(CloudHubRtcLocalAudioStats * _Nonnull)stats;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine localVideoStats:(CloudHubRtcLocalVideoStats * _Nonnull)stats;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine remoteAudioStats:(CloudHubRtcRemoteAudioStats * _Nonnull)stats;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine remoteVideoStats:(CloudHubRtcRemoteVideoStats * _Nonnull)stats;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onRtcStats:(CloudHubChannelStats * _Nonnull)stats;

#pragma mark Movie Player Delegate Methods

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onLocalMovieStateChanged:(NSString * _Nonnull)filepath
    state:(CloudHubMovieStateCode)state
    errorCode:(CloudHubMovieErrorCode)errorCode;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onLocalMovieProgress:(NSString * _Nonnull)filepath
              pos:(NSUInteger)pos
            total:(NSUInteger)total;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine firstLocalMovieVideoFrame:(NSString * _Nonnull)filepath
             size:(CGSize)size;

#pragma mark Conrolling Message Delegate Methods
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine
onSetPropertyOfUid:(NSString * _Nonnull)uid
             from:(NSString * _Nullable)fromuid
       properties:(NSString * _Nonnull)prop;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine
onChatMessageArrival:(NSString * _Nonnull)message
             from:(NSString * _Nullable)fromuid
    withExtraData:(NSString * _Nullable)extraData;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine
         onPubMsg:(NSString * _Nonnull)msgName
            msgId:(NSString * _Nonnull)msgId
             from:(NSString * _Nullable)fromuid
         withData:(NSString * _Nullable)data
associatedWithUser:(NSString * _Nullable)uid
associatedWithMsg:(NSString * _Nullable)assMsgID
               ts:(NSUInteger)ts
    withExtraData:(NSString * _Nullable)extraData
        isHistory:(BOOL)isHistory;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine
         onDelMsg:(NSString * _Nonnull)msgName
            msgId:(NSString * _Nonnull)msgId
             from:(NSString * _Nullable)fromuid
         withData:(NSString * _Nullable)data;

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onLocalUserEvicted:(NSInteger)reason;
@end

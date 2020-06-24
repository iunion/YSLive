//
//  CloudHubRtcEngineKit.h
//  CloudHubRtcEngineKit
//
//  Copyright (c) 2020 CloudHub. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "CloudHubConstants.h"
#import "CloudHubObjects.h"
#import "CloudHubRtcEngineDelegate.h"
//#import "CloudHubMediaIO.h"
//#import "CloudHubMediaMetadata.h"

/** CloudHub provides ensured quality of experience (QoE) for worldwide Internet-based voice and video communications through a virtual global network optimized for real-time web and mobile-to-mobile applications.

 The CloudHubRtcEngineKit class is the entry point of the SDK providing API methods for apps to easily start voice and video communication.
 */
@class CloudHubRtcEngineKit;
@class CloudHubRtcChannel;

#pragma mark - CloudHubRtcEngineKit

/** The CloudHubRtcEngineKit class provides all methods invoked by your app.

 CloudHub provides ensured quality of experience (QoE) for worldwide Internet-based voice and video communications through a virtual global network optimized for real-time web and mobile-to-mobile apps.

 CloudHubRtcEngineKit is the basic interface class of the SDK. Creating an CloudHubRtcEngineKit object and then calling the methods of this object enables the use of the SDK’s communication functionality.
*/
__attribute__((visibility("default"))) @interface CloudHubRtcEngineKit : NSObject

#pragma mark Core Service

/**-----------------------------------------------------------------------------
 * @name Core Service
 * -----------------------------------------------------------------------------
 */

/** Initializes the CloudHubRtcEngineKit object.

 Call this method to initialize the service before using CloudHubRtcEngineKit.
 @note Ensure that you call this method before calling any other API.
 @warning Only users with the same App ID can call each other.
 @warning One CloudHubRtcEngineKit can use only one App ID. If you need to change the App ID, call [destroy](destroy) to release the current instance first, and then call this method to create a new instance.
 @param appId    App ID issued to you by CloudHub. Apply for a new one from CloudHub if it is missing in your kit. Each project is assigned a unique App ID. The App ID identifies your project and organization in the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method to access the CloudHub Global Network, and enable one-to-one or one-to-more communication or live-broadcast sessions using a unique channel name for your App ID.
 @param delegate CloudHubRtcEngineDelegate.

 @return An object of the CloudHubRtcEngineKit class.
 */
+ (instancetype _Nonnull)sharedEngineWithAppId:(NSString * _Nonnull)appId;

/** Sets the channel profile of the CloudHubRtcEngineKit.

The CloudHubRtcEngineKit differentiates channel profiles and applies optimization algorithms accordingly. For example, it prioritizes smoothness and low latency for a video call, and prioritizes video quality for a video broadcast.

**Note:**

* To ensure the quality of real-time communication, we recommend that all users in a channel use the same channel profile.
* Call this method before calling [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]). You cannot set the channel profile once you have joined the channel.

 @param profile The channel profile of the CloudHubRtcEngineKit: [CloudHubChannelProfile](CloudHubChannelProfile).

 @return * 0: Success.
* < 0: Failure.
 */
- (int)setChannelProfile:(CloudHubChannelProfile)profile;

/** Sets the role of a user.

This method is applicable only to the Live-broadcast profile.

Sets the role of a user, such as a host or an audience (default), before joining a channel.

This method can be used to switch the user role after a user joins a channel.

When a user switches user roles after joining a channel, a successful method call triggers the following callback:

- The local client: [didClientRoleChanged]([CloudHubRtcEngineDelegate rtcEngine:didClientRoleChanged:newRole:])
- Remote clients: [didJoinedOfUid]([CloudHubRtcEngineDelegate rtcEngine:didJoinedOfUid:elapsed:]) or [didOfflineOfUid(CloudHubUserOfflineReasonBecomeAudience)]([CloudHubRtcEngineDelegate rtcEngine:didOfflineOfUid:reason:])

 @param role Role of the client: CloudHubClientRole.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)setClientRole:(CloudHubClientRole)role;

/** Joins a channel with the user ID.

Users in the same channel can talk to each other, and multiple users in the same channel can start a group chat. Users with different App IDs cannot call each other even if they join the same channel.

You must call the [leaveChannel]([CloudHubRtcEngineKit leaveChannel:]) method to exit the current call before entering another channel. This method call is asynchronous; therefore, you can call this method in the main user interface thread.

The SDK uses the iOS's AVAudioSession shared object for audio recording and playback. Using this object may affect the SDK’s audio functions.

If the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method call succeeds, the SDK triggers`joinSuccessBlock`. If you implement both `joinSuccessBlock` and [didJoinChannel]([CloudHubRtcEngineDelegate rtcEngine:didJoinChannel:withUid:elapsed:]), `joinSuccessBlock` takes higher priority than [didJoinChannel]([CloudHubRtcEngineDelegate rtcEngine:didJoinChannel:withUid:elapsed:]).

We recommend you set `joinSuccessBlock` as nil to use [didJoinChannel]([CloudHubRtcEngineDelegate rtcEngine:didJoinChannel:withUid:elapsed:]).

A successful joinChannel method call triggers the following callbacks:

- The local client: [didJoinChannel]([CloudHubRtcEngineDelegate rtcEngine:didJoinChannel:withUid:elapsed:])
- The remote client: [didJoinedOfUid]([CloudHubRtcEngineDelegate rtcEngine:didJoinedOfUid:elapsed:]), if the user joining the channel is in the Communication profile, or is a BROADCASTER in the Live Broadcast profile.

When the connection between the client and CloudHub's server is interrupted due to poor network conditions, the SDK tries reconnecting to the server. When the local client successfully rejoins the channel, the SDK triggers the [didRejoinChannel]([CloudHubRtcEngineDelegate rtcEngine:didRejoinChannel:withUid:elapsed:]) callback on the local client.

**Note:**

- A channel does not accept duplicate UIDs, such as two users with the same `uid`. If you set `uid` as 0, the system automatically assigns a `uid`. If you want to join the same channel on different devices, ensure that different uids are used for each device.
- When joining a channel, the SDK calls `setCategory(AVAudioSessionCategoryPlayAndRecord)` to set `AVAudioSession` to `PlayAndRecord` mode. When `AVAudioSession` is set to `PlayAndRecord` mode, the sound played (for example a ringtone) is interrupted. The app should not set `AVAudioSession` to any other mode.

 @param token A `token` generated by the app server. In most circumstances, the static App ID suffices. For added security, use a `token`.

 * If the user uses a static App ID, `token` is optional and can be set as nil.
 * If the user uses a `token`, CloudHub issues an additional App Certificate for you to generate a token based on the algorithm and App Certificate for user authentication on the server.
 * Ensure that the App ID used for creating the `token` is the same App ID used by [sharedEngineWithappId]([CloudHubRtcEngineKit sharedEngineWithAppId:delegate:]) for initializing the RTC engine. Otherwise, the CDN live streaming may fail.

 @param channelId Unique channel name for the CloudHubRTC session in the string format. The string length must be less than 64 bytes.
 Supported character scopes are:

 * The 26 lowercase English letters: a to z
 * The 26 uppercase English letters: A to Z
 * The 10 numbers: 0 to 9
 * The space
 * "!", "#", "$", "%", "&", "(", ")", "+", "-", ":", ";", "<", "=", ".", ">", "?", "@", "[", "]", "^", "_", "{", "}", "|", "~", ","

@param info (Optional) Additional information about the channel. This parameter can be set to nil or contain channel related information. Other users in the channel do not receive this message.
@param uid User ID. A 32-bit unsigned integer with a value ranging from 1 to (2<sup>32</sup>-1). The `uid` must be unique. If a `uid` is not assigned (or set to 0), the SDK assigns and returns a `uid` in `joinSuccessBlock`. Your app must record and maintain the returned `uid` since the SDK does not do so.
@param joinSuccessBlock Returns that the user joins the specified channel. Same as [didJoinChannel]([CloudHubRtcEngineDelegate rtcEngine:didJoinChannel:withUid:elapsed:]). If `joinSuccessBlock` is nil, the SDK triggers the [didJoinChannel]([CloudHubRtcEngineDelegate rtcEngine:didJoinChannel:withUid:elapsed:]) callback.

@return * 0: Success.
* < 0: Failure.

   - `CloudHubErrorCodeInvalidArgument`(-2)
   - `CloudHubErrorCodeNotReady`(-3)
   - `CloudHubErrorCodeRefused`(-5)
*/
- (int)joinChannelByToken:(NSString * _Nullable)token
                channelId:(NSString * _Nonnull)channelId
               properties:(NSString * _Nullable)properties
                      uid:(NSString * _Nullable)uid
              joinSuccess:(void(^ _Nullable)(NSString * _Nonnull channel, NSString * _Nonnull uid, NSInteger elapsed))joinSuccessBlock;

/** Switches to a different channel.

 This method allows the audience of a Live-broadcast channel to switch to a different channel.

 After the user successfully switches to another channel, the [didLeaveChannelWithStats]([CloudHubRtcEngineDelegate rtcEngine:didLeaveChannelWithStats:]) and [didJoinChannel]([CloudHubRtcEngineDelegate rtcEngine:didJoinChannel:withUid:elapsed:]) callbacks are triggered to indicate that the user has left the original channel and joined a new one.

 @param token The token generated at your server:

 - For low-security requirements: You can use the temporary token generated in Console. For details, see [Get a temporary token](https://docs.CloudHub.io/en/CloudHub%20Platform/token?platform=All%20Platforms#get-a-temporary-token).
 - For high-security requirements: Use the token generated at your server. For details, see [Get a token](https://docs.CloudHub.io/en/CloudHub%20Platform/token?platform=All%20Platforms#get-a-token).
 @param channelId Unique channel name for the CloudHubRTC session in the string format. The string length must be less than 64 bytes. Supported character scopes are:

 - The 26 lowercase English letters: a to z.
 - The 26 uppercase English letters: A to Z.
 - The 10 numbers: 0 to 9.
 - The space.
 - "!", "#", "$", "%", "&", "(", ")", "+", "-", ":", ";", "<", "=", ".", ">", "?", "@", "[", "]", "^", "_", " {", "}", "|", "~", ",".
 @param joinSuccessBlock Returns that the user joins the specified channel. Same as [didJoinChannel]([CloudHubRtcEngineDelegate rtcEngine:didJoinChannel:withUid:elapsed:]). If `joinSuccessBlock` is nil, the SDK triggers the [didJoinChannel]([CloudHubRtcEngineDelegate rtcEngine:didJoinChannel:withUid:elapsed:]) callback.
 
 @note This method applies to the audience role in a Live-broadcast channel only.

 @return - 0: Success.
 - <0: Failure.
 */
- (int)switchChannelByToken:(NSString * _Nullable)token
                  channelId:(NSString * _Nonnull)channelId
                joinSuccess:(void(^ _Nullable)(NSString * _Nonnull channel, NSString * _Nonnull uid, NSInteger elapsed))joinSuccessBlock;

/** Allows a user to leave a channel, such as hanging up or exiting a call.

After joining a channel, the user must call the leaveChannel method to end the call before joining another channel.

This method returns 0 if the user leaves the channel and releases all resources related to the call.

This method call is asynchronous, and the user has not exited the channel when the method call returns.

A successful leaveChannel method call triggers the following callbacks:

- The local client: [didLeaveChannelWithStats]([CloudHubRtcEngineDelegate rtcEngine:didLeaveChannelWithStats:])
- The remote client: [didOfflineOfUid(CloudHubUserOfflineReasonBecomeAudience)]([CloudHubRtcEngineDelegate rtcEngine:didOfflineOfUid:reason:]), if the user leaving the channel is in the Communication channel, or is a BROADCASTER in the Live Broadcast profile.

**Note:**

- If you call [destroy](destroy) immediately after leaveChannel, the leaveChannel process interrupts, and the SDK does not trigger the [didLeaveChannelWithStats]([CloudHubRtcEngineDelegate rtcEngine:didLeaveChannelWithStats:]) callback.
- If you call this method during CDN live streaming, the SDK triggers the [removePublishStreamUrl](removePublishStreamUrl:) method.
- When you call this method, the SDK deactivates the audio session on iOS by default, and may affect other apps. If you do not want this default behavior, use [setAudioSessionOperationRestriction](setAudioSessionOperationRestriction:) to set `CloudHubAudioSessionOperationRestrictionDeactivateSession` so that when you call the [leaveChannel]([CloudHubRtcEngineKit leaveChannel:]) method, the SDK does not deactivate the audio session.

 @param leaveChannelBlock This callback indicates that a user leaves a channel, and provides the statistics of the call. See [CloudHubChannelStats](CloudHubChannelStats).

 @return * 0: Success.
* < 0: Failure.
 */
- (int)leaveChannel:(void(^ _Nullable)(void))leaveChannelBlock;


/** Gets a new token when the current token expires after a period of time.

The `token` expires after a period of time once the token schema is enabled when:

  - The SDK triggers the [tokenPrivilegeWillExpire]([CloudHubRtcEngineDelegate rtcEngine:tokenPrivilegeWillExpire:]) callback, or
  - [connectionChangedToState]([CloudHubRtcEngineDelegate rtcEngine:connectionChangedToState:reason:]) reports CloudHubConnectionChangedTokenExpired(9) in the`reason` parameter.

 **Note:**

 CloudHub recommends using the [rtcEngineRequestToken]([CloudHubRtcEngineDelegate rtcEngineRequestToken:]) callback to report the CloudHubErrorCodeTokenExpired(-109) error, not using the [didOccurError]([CloudHubRtcEngineDelegate rtcEngine:didOccurError:]) callback.

 The app should call this method to get the `token`. Failure to do so results in the SDK disconnecting from the server.

 @param token The new token.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)renewToken:(NSString * _Nonnull)token;

/** Gets the connection state of the app.

@return The connection state, see [CloudHubConnectionStateType](CloudHubConnectionStateType).
*/
- (CloudHubConnectionStateType)getConnectionState;

#pragma mark Publishing
- (int)PublishStream;

- (int)UnPublishStream;

#pragma mark Core Audio

/**-----------------------------------------------------------------------------
 * @name Core Audio
 * -----------------------------------------------------------------------------
 */

/** Enables the audio module.

 The audio module is enabled by default.

 **Note:**

- This method affects the internal engine and can be called after the [leaveChannel]([CloudHubRtcEngineKit leaveChannel:]) method. You can call this method either before or after joining a channel.
- This method resets the internal engine and takes some time to take effect. CloudHub recommends using the following API methods to control the audio engine modules separately:

    * [enableLocalAudio]([CloudHubRtcEngineKit enableLocalAudio:]): Whether to enable the microphone to create the local audio stream.
    * [muteLocalAudioStream]([CloudHubRtcEngineKit muteLocalAudioStream:]): Whether to publish the local audio stream.
    * [muteRemoteAudioStream]([CloudHubRtcEngineKit muteRemoteAudioStream:mute:]): Whether to subscribe to and play the remote audio stream.
    * [muteAllRemoteAudioStreams]([CloudHubRtcEngineKit muteAllRemoteAudioStreams:]): Whether to subscribe to and play all remote audio streams.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)enableAudio;

/** Disables the audio module.

 **Note:**

- This method affects the internal engine and can be called after the [leaveChannel]([CloudHubRtcEngineKit leaveChannel:]) method. You can call this method either before or after joining a channel.
- This method resets the internal engine and takes some time to take effect. CloudHub recommends using the following API methods to control the audio engine modules separately:

    * [enableLocalAudio]([CloudHubRtcEngineKit enableLocalAudio:]): Whether to enable the microphone to create the local audio stream.
    * [muteLocalAudioStream]([CloudHubRtcEngineKit muteLocalAudioStream:]): Whether to publish the local audio stream.
    * [muteRemoteAudioStream]([CloudHubRtcEngineKit muteRemoteAudioStream:mute:]): Whether to subscribe to and play the remote audio stream.
    * [muteAllRemoteAudioStreams]([CloudHubRtcEngineKit muteAllRemoteAudioStreams:]): Whether to subscribe to and play all remote audio streams.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)disableAudio;

/** Adjusts the recording volume.

 @param volume Recording volume. The value ranges between 0 and 400:

 * 0: Mute.
 * 100: Original volume.
 * 400: (Maximum) Four times the original volume with signal clipping protection.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)adjustRecordingSignalVolume:(NSInteger)volume;

/** Adjusts the playback volume of all remote users.
 
 **Note**

 - This method adjusts the playback volume which is mixed volume of all remote users.
 - Since v2.3.2, to mute the local audio playback, call both `adjustPlaybackSignalVolume` and [adjustAudioMixingVolume]([CloudHubRtcEngineKit adjustAudioMixingVolume:]), and set `volume` as 0.

 @param volume The playback volume of all remote users. The value ranges from 0 to 400:

 * 0: Mute.
 * 100: Original volume.
 * 400: (Maximum) Four times the original volume with signal clipping protection.

 @return * 0: Success.
 * < 0: Failure.
 */
- (int)adjustPlaybackSignalVolume:(NSInteger)volume;

/** Enables the SDK to regularly report to the app on which users are speaking and the speakers' volume.

 @param interval Sets the time interval between two consecutive volume indications:

 * &le; 0: Disables the volume indication.
 * &gt; 0: The time interval (ms) between two consecutive volume indications. CloudHub recommends setting `interval` &ge; 200 ms. Once this method is enabled, the SDK returns the volume indications at the set time interval in the [reportAudioVolumeIndicationOfSpeakers]([CloudHubRtcEngineDelegate rtcEngine:reportAudioVolumeIndicationOfSpeakers:totalVolume:]) and [audioVolumeIndicationBlock](audioVolumeIndicationBlock:) callbacks, regardless of whether any user is speaking in the channel.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)enableAudioVolumeIndication:(NSInteger)interval;

/** Enables/Disables the local audio capture.

When an app joins a channel, the audio module is enabled by default. This method disables or re-enables the local audio capture, that is, to stop or restart local audio capturing and processing.

This method does not affect receiving or playing the remote audio streams, and enableLocalAudio(NO) is applicable to scenarios where the user wants to receive remote audio streams without sending any audio stream to other users in the channel.

The SDK triggers the [didMicrophoneEnabled]([CloudHubRtcEngineDelegate rtcEngine:didMicrophoneEnabled:]) callback once the local audio module is disabled or re-enabled.

**Note:**

- Call this method after the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method.
- This method is different from the [muteLocalAudioStream]([CloudHubRtcEngineKit muteLocalAudioStream:]) method:

  - [enableLocalAudio]([CloudHubRtcEngineKit enableLocalAudio:]): Disables/Re-enables the local audio capturing and processing. If you disable or re-enable local audio recording using the `enableLocalAudio` method, the local user may hear a pause in the remote audio playback.
  - [muteLocalAudioStream]([CloudHubRtcEngineKit muteLocalAudioStream:]): Sends/Stops sending the local audio stream.

 @param enabled * YES: (Default) Enable the local audio module, that is, to start local audio capturing and processing.
 * NO: Disable the local audio module, that is, to stop local audio capturing and processing.
 @return * 0: Success.
* < 0: Failure.
 */
- (int)enableLocalAudio:(BOOL)enabled;

/** Sends/Stops sending the local audio stream.

 Use this method to stop/start sending the local audio stream. A successful `muteLocalAudioStream` method call triggers the [didAudioMuted]([CloudHubRtcEngineDelegate rtcEngine:didAudioMuted:byUid:]) callback on the remote client.

 **Note:**

 - When `mute` is set as `YES`, this method does not disable the microphone and thus does not affect any ongoing recording.
 - If you call [setChannelProfile]([CloudHubRtcEngineKit setChannelProfile:]) after this method, the SDK resets whether or not to mute the local audio according to the channel profile and user role. Therefore, we recommend calling this method after the `setChannelProfile` method.

 @param mute Sets whether to send/stop sending the local audio stream:

 * YES: Stops sending the local audio stream.
 * NO: (Default) Sends the local audio stream.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)muteLocalAudioStream:(BOOL)mute;

/** Receives/Stops receiving a specified remote user’s audio stream.

 **Note:**

 If you call the [muteAllRemoteAudioStreams]([CloudHubRtcEngineKit muteAllRemoteAudioStreams:]) method and set `mute` as `YES` to mute all remote audio streams, call the `muteAllRemoteAudioStreams` method again and set `mute` as `NO` before calling this method. The `muteAllRemoteAudioStreams` method sets all remote streams, while the `muteRemoteAudioStream` method sets a specified stream.

 @param uid  User ID of the specified remote user.
 @param mute Sets whether to receive/stop receiving a specified remote user’s audio stream:

 * YES: Stop receiving a specified remote user’s audio stream.
 * NO: (Default) Receive a specified remote user’s audio stream.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)muteRemoteAudioStream:(NSString* _Nonnull)uid mute:(BOOL)mute;

/** Receives/Stops receiving all remote audio streams.

 @param mute Sets whether to receive/stop receiving all remote audio streams:

 * YES: Stop receiving all remote audio streams.
 * NO: (Default) Receive all remote audio streams.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)muteAllRemoteAudioStreams:(BOOL)mute;

/** Sets whether to receive all remote audio streams by default.

You can call this method either before or after joining a channel. If you call this method after joining a channel, then the audio streams of all users joining afterwards are not received.

 @param mute Sets whether to receive/stop receiving all remote audio streams by default:

 * YES: Stop receiving all remote audio streams by default.
 * NO: (Default) Receive all remote audio streams by default.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)setDefaultMuteAllRemoteAudioStreams:(BOOL)mute;

/** Adjust the playback volume of a specified remote user.
 
 **Since** v3.0.0.

 You can call this method as many times as necessary to adjust the playback volume of different remote users, or to repeatedly adjust the playback volume of the same remote user.

 **Note**
 
 - Call this method after joining a channel.
 - The playback volume here refers to the mixed volume of a specified remote user.
 - This method can only adjust the playback volume of one specified remote user at a time. To adjust the playback volume of different remote users, call the method as many times, once for each remote user.

 @param uid The ID of the remote user.
 @param volume The playback volume of the specified remote user. The value ranges from 0 to 100:
 
 - 0: Mute.
 - 100: Original volume.

 @return - 0: Success.
 - < 0: Failure.
 */
- (int)adjustUserPlaybackSignalVolume:(NSUInteger)uid volume:(int)volume;


#pragma mark Core Video

/**-----------------------------------------------------------------------------
 * @name Core Video
 * -----------------------------------------------------------------------------
 */

/** Enables the video module.

You can call this method either before entering a channel or during a call. If you call this method before entering a channel, the service starts in the video mode. If you call this method during an audio call, the audio mode switches to the video mode.

A successful enableVideo method call triggers the [didVideoEnabled(YES)]([CloudHubRtcEngineDelegate rtcEngine:didVideoEnabled:byUid:]) callback on the remote client.


To disable the video, call the disableVideo method.

**Note:**

- This method affects the internal engine and can be called after the [leaveChannel]([CloudHubRtcEngineKit leaveChannel:]) method.
- This method resets the internal engine and takes some time to take effect. CloudHub recommends using the following API methods to control the video engine modules separately:

    * [enableLocalVideo]([CloudHubRtcEngineKit enableLocalVideo:]): Whether to enable the camera to create the local video stream.
    * [muteLocalVideoStream]([CloudHubRtcEngineKit muteLocalVideoStream:]): Whether to publish the local video stream.
    * [muteRemoteVideoStream]([CloudHubRtcEngineKit muteRemoteVideoStream:mute:]): Whether to subscribe to and play the remote video stream.
    * [muteAllRemoteVideoStreams]([CloudHubRtcEngineKit muteAllRemoteVideoStreams:]): Whether to subscribe to and play all remote video streams.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)enableVideo;

/** Disables the video module.

   You can call this method before entering a channel or during a call. If you call this method before entering a channel, the service starts in the audio mode. If you call this method during a video call, the video mode switches to the audio mode. To enable the video module, call the [enableVideo](enableVideo) method.

   A successful disableVideo method call triggers the [didVideoEnabled(NO)]([CloudHubRtcEngineDelegate rtcEngine:didVideoEnabled:byUid:]) callback on the remote client.

 **Note:**

- This method affects the internal engine and can be called after the [leaveChannel]([CloudHubRtcEngineKit leaveChannel:]) method.
- This method resets the internal engine and takes some time to take effect. CloudHub recommends using the following API methods to control the video engine modules separately:

    * [enableLocalVideo]([CloudHubRtcEngineKit enableLocalVideo:]): Whether to enable the camera to create the local video stream.
    * [muteLocalVideoStream]([CloudHubRtcEngineKit muteLocalVideoStream:]): Whether to publish the local video stream.
    * [muteRemoteVideoStream]([CloudHubRtcEngineKit muteRemoteVideoStream:mute:]): Whether to subscribe to and play the remote video stream.
    * [muteAllRemoteVideoStreams]([CloudHubRtcEngineKit muteAllRemoteVideoStreams:]): Whether to subscribe to and play all remote video streams.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)disableVideo;

/** Sets the video encoder configuration.

Each video encoder configuration corresponds to a set of video parameters, including the resolution, frame rate, bitrate, and video orientation.

The parameters specified in this method are the maximum values under ideal network conditions. If the video engine cannot render the video using the specified parameters due to unreliable network conditions, the parameters further down the list are considered until a successful configuration is found.

 If you do not need to set the video encoder configuration after joining a channel, you can call this method before calling the enableVideo method to reduce the render time of the first video frame.

 **Note:**

 From v2.3.0, the following API methods are deprecated:

 - [setVideoProfile](setVideoProfile:swapWidthAndHeight:)
 - [setVideoResolution](setVideoResolution:andFrameRate:bitrate:)

 @param config Video encoder configuration: AgoraVideoEncoderConfiguration
 @return * 0: Success.
* < 0: Failure.
 */
- (int)setVideoEncoderConfiguration:(CloudHubVideoEncoderConfiguration * _Nonnull)config;

/** Initializes the local video view.

 This method initializes the video view of the local stream on the local device. It affects only the video view that the local user sees, not the published local video stream.

 Call this method to bind the local video stream to a video view and to set the rendering and mirror modes of the video view. To unbind the `view`, set the `view` in CloudHubRtcVideoCanvas to `nil`.

 **Note**
 
 - Call this method before joining a channel.
 - To update the rendering or mirror mode of the local video view during a call, use [setLocalRenderMode]([CloudHubRtcEngineKit setLocalRenderMode:mirrorMode:]).
 
 @param local Sets the local video view and settings. See CloudHubRtcVideoCanvas.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)setupLocalVideo:(CloudHubRtcVideoCanvas * _Nonnull)local;

/** Initializes the video view of a remote user.

 This method initializes the video view of a remote stream on the local device. It affects only the video view that the local user sees.

 Call this method to bind the remote video stream to a video view and to set the rendering and mirror modes of the video view.

 The app specifies the `uid` of the remote video in this method call before the user joins a channel.

 If the remote `uid` is unknown to the app, set it after the app receives the [userJoinedBlock]([CloudHubRtcEngineKit userJoinedBlock:]) callback.

 If the Video Recording function is enabled, the Video Recording Service joins the channel as a dummy client, causing other clients to also receive the [didJoinedOfUid]([CloudHubRtcEngineDelegate rtcEngine:didJoinedOfUid:elapsed:]) callback. Do not bind the dummy client to the app view because the dummy client does not send any video streams. If your app does not recognize the dummy client, bind the remote user to the view when the SDK triggers the [firstRemoteVideoDecodedOfUid]([CloudHubRtcEngineDelegate rtcEngine:firstRemoteVideoDecodedOfUid:size:elapsed:]) callback.

 To unbind the remote user from the view, set the `view` in CloudHubRtcVideoCanvas as nil. Once the remote user leaves the channel, the SDK unbinds the remote user.

 @note To update the rendering or mirror mode of the remote video view during a call, use [setRemoteRenderMode]([CloudHubRtcEngineKit setRemoteRenderMode:renderMode:mirrorMode:]).
 
 @param remote Sets the remote video view and settings. See CloudHubRtcVideoCanvas.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)setupRemoteVideo:(CloudHubRtcVideoCanvas * _Nonnull)remote;


/** Updates the display mode of the local video view.

 **Since** v3.0.0.

 After initializing the local video view, you can call this method to update its rendering and mirror modes. It affects only the video view that the local user sees, not the published local video stream.
 
 **Note**

 - Ensure that you have called [setupLocalVideo]([CloudHubRtcEngineKit setupLocalVideo:]) to initialize the local video view before calling this method.
 - During a call, you can call this method as many times as necessary to update the display mode of the local video view.

 @param renderMode The rendering mode of the local video view. See [CloudHubVideoRenderMode](CloudHubVideoRenderMode).
 @param mirrorMode The mirror mode of the local video view. See [CloudHubVideoMirrorMode](CloudHubVideoMirrorMode).
 
 **Note**
 
 If you use a front camera, the SDK enables the mirror mode by default; if you use a rear camera, the SDK disables the mirror mode by default.
 
 @return * 0: Success.
 * < 0: Failure.
 */
- (int)setLocalRenderMode:(CloudHubVideoRenderMode) renderMode
               mirrorMode:(CloudHubVideoMirrorMode) mirrorMode;

/** Sets the remote video display mode.
 
 **Since** v3.0.0.

 After initializing the video view of a remote user, you can call this method to update its rendering and mirror modes. This method affects only the video view that the local user sees.

 **Note**

 - Ensure that you have called [setupRemoteVideo]([CloudHubRtcEngineKit setupRemoteVideo:]) to initialize the remote video view before calling this method.
 - During a call, you can call this method as many times as necessary to update the display mode of the video view of a remote user.

 @param uid The ID of the remote user.
 @param renderMode The rendering mode of the remote video view. See [CloudHubVideoRenderMode](CloudHubVideoRenderMode).
 @param mirrorMode The mirror mode of the remote video view. See [CloudHubVideoMirrorMode](CloudHubVideoMirrorMode).

 **Note**

 The SDK disables the mirror mode by default.

 @return * 0: Success.
 * < 0: Failure.
 */
- (int)setRemoteRenderMode:(NSString* _Nonnull)uid
                  sourceID:(NSString* _Nullable)sourceID
                renderMode:(CloudHubVideoRenderMode) renderMode
                mirrorMode:(CloudHubVideoMirrorMode) mirrorMode;

/** Starts the local video preview before joining a channel.

By default, the local preview enables the mirror mode.

Before calling this method, you must:

 - Call the [setupLocalVideo]([CloudHubRtcEngineKit setupLocalVideo:]) method to set up the local preview window and configure the attributes.
 - Call the [enableVideo]([CloudHubRtcEngineKit enableVideo]) method to enable video.

**Note:**

 Once you call this method to start the local video preview, if you leave the channel by calling the [leaveChannel]([CloudHubRtcEngineKit leaveChannel:]) method, the local video preview remains until you call the stopPreview method to disable it.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)startPreview;

/** Stops the local video preview and the video.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)stopPreview;

/** Disables the local video.
 
 This method disables or re-enables the local video capturer, and does not affect receiving the remote video stream.

 After you call the [enableVideo]([CloudHubRtcEngineKit enableVideo]) method, the local video capturer is enabled by default. You can call [enableLocalVideo(NO)]([CloudHubRtcEngineKit enableLocalVideo:]) to disable the local video capturer. If you want to re-enable it, call [enableLocalVideo(YES)]([CloudHubRtcEngineKit enableLocalVideo:]).

 After the local video capturer is successfully disabled or re-enabled, the SDK triggers the [didLocalVideoEnabled]([CloudHubRtcEngineDelegate rtcEngine:didLocalVideoEnabled:byUid:]) callback on the remote client.
     
 
 **Note:**

 This method enables the internal engine and can be called after calling the [leaveChannel]([CloudHubRtcEngineKit leaveChannel:]) method.

 @param enabled Sets whether to enable/disable the local video, including the capturer, renderer, and sender:

 * YES: (Default) Enable the local video.
 * NO: Disable the local video. Once the local video is disabled, the remote users can no longer receive the video stream of this user, while this user can still receive the video streams of other remote users.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)enableLocalVideo:(BOOL)enabled;

/** Sends/Stops sending the local video stream.

 A successful `muteLocalVideoStream` method call triggers the [didVideoMuted]([CloudHubRtcEngineDelegate rtcEngine:didVideoMuted:byUid:]) callback on the remote client.
 
 **Note:**

 - When you set `mute` as `YES`, this method does not disable the camera, and thus does not affect the retrieval of the local video stream. This method responds faster compared to the [enableLocalVideo]([CloudHubRtcEngineKit enableLocalVideo:]) method which controls the sending of local video streams.
 - If you call [setChannelProfile]([CloudHubRtcEngineKit setChannelProfile:]) after this method, the SDK resets whether or not to mute the local video according to the channel profile and user role. Therefore, we recommend calling this method after the `setChannelProfile` method.

 @param mute Sets whether to send/stop sending the local video stream:

 * YES: Stop sending the local video stream.
 * NO: (Default) Send the local video stream.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)muteLocalVideoStream:(BOOL)mute;

/** Receives/Stops receiving all remote video streams.

 @param mute Sets whether to receive/stop receiving all remote video streams:

 * YES: Stops receiving all remote video streams.
 * NO: (Default) Receives all remote video streams.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)muteAllRemoteVideoStreams:(BOOL)mute;

/** Receives/Stops receiving a specified remote user’s video stream.

**Note:**

 If you call the [muteAllRemoteVideoStreams]([CloudHubRtcEngineKit muteAllRemoteVideoStreams:]) method and set `mute` as `YES` to stop receiving all remote video streams, call the muteAllRemoteVideoStreams method again and set `mute` as `NO` before calling this method.

 @param uid  User ID of the specified remote user.
 @param sourceID  source ID of the specified stream.
 @param mute Sets whether to receive/stop receiving a specified remote user’s video stream.

 * YES: Stops receiving a specified remote user’s video stream.
 * NO: (Default) Receives a specified remote user’s video stream.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)muteRemoteVideoStream:(NSString* _Nonnull)uid
                    sourceID:(NSString* _Nullable)sourceID
                        mute:(BOOL)mute;

/** Sets whether to receive all remote video streams by default.

 @param mute Sets whether to receive/stop receiving all remote video streams by default.

 * YES: Stop receiving all remote video streams by default.
 * NO: (Default) Receive all remote video streams by default.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)setDefaultMuteAllRemoteVideoStreams:(BOOL)mute;



#pragma mark Audio Routing Controller

/**-----------------------------------------------------------------------------
 * @name Audio Routing Controller
 * -----------------------------------------------------------------------------
 */

#if TARGET_OS_IPHONE
/** Sets the default audio route. (iOS only.)

 This method sets whether the received audio is routed to the earpiece or speakerphone by default before joining a channel. If a user does not call this method, the audio is routed to the earpiece by default.

 If you need to change the default audio route after joining a channel, call the [setEnableSpeakerphone](setEnableSpeakerphone:) method.

 **Note:**

 * This method only works in audio mode.
 * Call this method before calling the [joinChannel](joinChannelByToken:channelId:info:uid:joinSuccess:) method.

 The default settings for each mode:

 * Voice: Earpiece.
 * Video: Speakerphone. If a user in the Communication profile calls the [disableVideo](disableVideo) method or if a user calls the [muteLocalVideoStream]([CloudHubRtcEngineKit muteLocalVideoStream:]) and [muteAllRemoteVideoStreams]([CloudHubRtcEngineKit muteAllRemoteVideoStreams:]) methods, the default audio route is switched to the earpiece automatically.
 * Live Broadcast: Speakerphone.
 * Gaming Voice: Speakerphone.

 @param defaultToSpeaker Sets the default audio route:

 * YES: Speakerphone.
 * NO: (Default) Earpiece.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)setDefaultAudioRouteToSpeakerphone:(BOOL)defaultToSpeaker;

/** Enables/Disables the audio route to the speakerphone. (iOS only.)

 This method sets whether the audio is routed to the speakerphone. After this method is called, the SDK returns the [didAudioRouteChanged]([CloudHubRtcEngineDelegate rtcEngine:didAudioRouteChanged:]) callback, indicating that the audio route changes.

 **Note:**

 * Ensure that you have successfully called the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method before calling this method.
 * The SDK calls setCategory(AVAudioSessionCategoryPlayAndRecord) with options to configure the headset/speakerphone, so this method applies to all audio playback in the system.

 @param enableSpeaker Sets whether to route the audio to the speakerphone or earpiece:

 * YES: Route the audio to the speakerphone.
 * NO: Route the audio to the earpiece. If a headset is plugged in, the audio is routed to the headset.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)setEnableSpeakerphone:(BOOL)enableSpeaker;

/** Checks whether the speakerphone is enabled. (iOS only.)

 @return * YES: The speakerphone is enabled, and the audio plays from the speakerphone.
 * NO: The speakerphone is not enabled, and the audio plays from devices other than the speakerphone. For example, the headset or earpiece.
 */
- (BOOL)isSpeakerphoneEnabled;
#endif

#pragma mark Music File Playback and Mixing

/**-----------------------------------------------------------------------------
 * @name Music File Playback and Mixing
 * -----------------------------------------------------------------------------
 */

//cyjtodo comments
- (int) addInjectStreamUrl:(NSString * _Nonnull)url attributes:(NSString* _Nullable)attributes;
- (int) removeInjectStreamUrl:(NSString *_Nonnull)url;
- (int) seekInjectStreamUrl:(NSString *_Nonnull)url positionByMS:(NSUInteger)position;
- (int) pauseInjectStreamUrl:(NSString *_Nonnull)url pause:(BOOL)pause;


/** Starts audio mixing.

  This method mixes the specified local audio file with the audio stream from the microphone, or replaces the microphone's audio stream with the specified local audio file. You can choose whether the other user can hear the local audio playback and specify the number of playback loops. This method also supports online music playback.

 A successful startAudioMixing method call triggers the [localAudioMixingStateDidChanged]([CloudHubRtcEngineDelegate rtcEngine:localAudioMixingStateDidChanged:errorCode:])(CloudHubAudioMixingStatePlaying) callback on the local client.

 When the audio mixing file playback finishes, the SDK triggers the [localAudioMixingStateDidChanged]([CloudHubRtcEngineDelegate rtcEngine:localAudioMixingStateDidChanged:errorCode:])(CloudHubAudioMixingStateStopped) callback on the local client.

 **Note:**

 * To use this method, ensure that the iOS device version is 8.0 and later.
 * Call this method when you are in a channel.
 * If you want to play an online music file, ensure that the time interval between playing the online music file and calling this method is greater than 100 ms, or the AudioFileOpenTooFrequent(702) warning occurs.
 * If the local audio mixing file does not exist, or if the SDK does not support the file format or cannot access the music file URL, the SDK returns CloudHubWarningCodeAudioMixingOpenError(701).

 @param filePath The absolute path of the local or online audio file to be mixed. Supported audio formats: mp3, aac, m4a, 3gp, and wav.

 @param loopback Sets which user can hear the audio mixing:

 * YES: Only the local user can hear the audio mixing.
 * NO: Both users can hear the audio mixing.

 @param replace Sets the audio mixing content:

 * YES: Only the specified audio file is published; the audio stream received by the microphone is not published.
 * NO: The local audio file mixed with the audio stream from the microphone.

 @param cycle Sets the number of playback loops:

 * Positive integer: Number of playback loops.
 * -1：Infinite playback loops.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)startAudioMixing:(NSString *  _Nonnull)filePath
               loopback:(BOOL)loopback
                replace:(BOOL)replace
                  cycle:(NSInteger)cycle;

/** Stops audio mixing.

 Call this method when you are in a channel.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)stopAudioMixing;

/** Pauses audio mixing.

 Call this method when you are in a channel.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)pauseAudioMixing;

/** Resumes audio mixing.

 Call this method when you are in a channel.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)resumeAudioMixing;

/** Adjusts the volume of audio mixing.

 Call this method when you are in a channel.
 
 **Note:**
 
 Calling this method does not affect the volume of audio effect file playback invoked by the [playEffect]([CloudHubRtcEngineKit playEffect:filePath:loopCount:pitch:pan:gain:publish:]) method.

 @param volume Audio mixing volume. The value ranges between 0 and 100 (default).
 @return * 0: Success.
* < 0: Failure.
 */
- (int)adjustAudioMixingVolume:(NSInteger)volume;

/** Adjusts the volume of audio mixing for local playback.

 Call this method when you are in a channel.

 @param volume Audio mixing volume for local playback. The value ranges between 0 and 100 (default).
 @return * 0: Success.
 * < 0: Failure.
 */
- (int)adjustAudioMixingPlayoutVolume:(NSInteger)volume;

/** Adjusts the volume of audio mixing for publishing (sending to other users).

 Call this method when you are in a channel.

 @param volume Audio mixing volume for publishing. The value ranges between 0 and 100 (default).
 @return * 0: Success.
 * < 0: Failure.
 */
- (int)adjustAudioMixingPublishVolume:(NSInteger)volume;

/** Gets the audio mixing volume for publishing.

This method helps troubleshoot audio volume related issues.
*/
- (int)getAudioMixingPublishVolume;

/** Gets the audio mixing volume for local playback.

This method helps troubleshoot audio volume related issues.
*/
- (int)getAudioMixingPlayoutVolume;

/** Retrieves the duration (ms) of audio mixing.

 Call this method when you are in a channel.

 @return * &ge; 0: The audio mixing duration, if this method call is successful.

* < 0: Failure.
 */

- (int)getAudioMixingDuration;

/** Retrieves the playback position (ms) of the audio mixing file.

 Call this method when you are in a channel.

 @return * &ge; 0: The current playback position of the audio mixing file, if this method call is successful.

* < 0: Failure.
 */
- (int)getAudioMixingCurrentPosition;

/** Sets the playback position of the audio mixing file to a different starting position (the default plays from the beginning).

 @param pos The playback starting position (ms) of the audio mixing file.

 @return * 0: Success.
* < 0: Failure.

 */
- (int)setAudioMixingPosition:(NSInteger)pos;


#pragma mark Audio Effect File Playback

/**-----------------------------------------------------------------------------
 * @name Audio Effect File Playback
 * -----------------------------------------------------------------------------
 */

/** Retrieves the volume of the audio effects.

The value ranges between 0.0 and 100.0.

@return * &ge; 0: Volume of the audio effects, if this method call is successful.

* < 0: Failure.
 */
- (double)getEffectsVolume;

/** Sets the volume of the audio effects.

 @param volume Volume of the audio effects. The value ranges between 0.0 and 100.0 (default).

 @return * 0: Success.
* < 0: Failure.
 */
- (int)setEffectsVolume:(double)volume;

/** Sets the volume of a specified audio effect.

 @param soundId ID of the audio effect. Each audio effect has a unique ID.
 @param volume Volume of the audio effect. The value ranges between 0.0 and 100.0 (default).

 @return * 0: Success.
* < 0: Failure.
 */
- (int)setVolumeOfEffect:(int)soundId
              withVolume:(double)volume;

/** Plays a specified audio effect.

You can use this method to add specific audio effects for specific scenarios, for example, gaming.

With this method, you can set the loop count, pitch, pan, and gain of the audio effect file and whether the remote user can hear the audio effect.

To play multiple audio effect files simultaneously, call this method multiple times with different soundIds and filePaths. We recommend playing no more than three audio effect files at the same time.

When the audio effect file playback is finished, the SDK triggers the [rtcEngineDidAudioEffectFinish]([CloudHubRtcEngineDelegate rtcEngineDidAudioEffectFinish:soundId:]) callback.

@note Playing multiple online audio effect files simultaneously is not supported on macOS.
 @param soundId ID of the specified audio effect. Each audio effect has a unique ID.
 If the audio effect is preloaded into the memory through the [preloadEffect](preloadEffect:filePath:) method, ensure that the `soundId` value is set to the same value as in [preloadEffect](preloadEffect:filePath:).
 @param filePath The absolute path of the local audio effect file or the URL of the online audio effect file.
 @param loopCount Sets the number of times the audio effect loops:

 * 0: Plays the audio effect once.
 * 1: Plays the audio effect twice.
 * -1: Plays the audio effect in an indefinite loop until you call the [stopEffect](stopEffect:) or [stopAllEffects](stopAllEffects) method.

 @param pitch Sets the pitch of the audio effect. The value ranges between 0.5 and 2. The default value is 1 (no change to the pitch). The lower the value, the lower the pitch.
 @param pan Sets the spatial position of the audio effect. The value ranges between -1.0 and 1.0.

 * 0.0: The audio effect displays ahead.
 * 1.0: The audio effect displays to the right.
 * -1.0: The audio effect displays to the left.

 @param gain Sets the volume of the audio effect. The value ranges between 0.0 and 100.0 (default). The lower the value, the lower the volume of the audio effect.
 @param publish Sets whether or not to publish the specified audio effect to the remote stream:

 * YES: The played audio effect is published to the CloudHub Cloud and the remote users can hear it.
 * NO: The played audio effect is not published to the CloudHub Cloud and the remote users cannot hear it.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)playEffect:(int)soundId
         filePath:(NSString * _Nullable)filePath
        loopCount:(int)loopCount
            pitch:(double)pitch
              pan:(double)pan
             gain:(double)gain
          publish:(BOOL)publish;

/** Stops playing a specified audio effect.

 @param soundId ID of the audio effect. Each audio effect has a unique ID.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)stopEffect:(int)soundId;

/** Stops playing all audio effects.
 */
- (int)stopAllEffects;

/** Preloads a specified audio effect file into the memory.

 To ensure smooth communication, limit the size of the audio effect file. CloudHub recommends using this method to preload the audio effect before calling the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method.

 Supported audio formats: mp3, aac, m4a, 3gp, and wav.

 @note This method does not support online audio effect files.
 @param soundId  ID of the audio effect. Each audio effect has a unique ID.
 @param filePath Absolute path of the audio effect file.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)preloadEffect:(int)soundId
            filePath:(NSString * _Nullable)filePath;

/** Releases a specified preloaded audio effect from the memory.

 @param soundId ID of the audio effect. Each audio effect has a unique ID.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)unloadEffect:(int)soundId;

/** Pauses a specified audio effect.

 @param soundId ID of the audio effect. Each audio effect has a unique ID.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)pauseEffect:(int)soundId;

/** Pauses all audio effects.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)pauseAllEffects;

/** Resumes playing a specified audio effect.

 @param soundId ID of the audio effect. Each audio effect has a unique ID.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)resumeEffect:(int)soundId;

/** Resumes playing all audio effects.

 @return * 0: Success.
* < 0: Failure.
 */
- (int)resumeAllEffects;

#if TARGET_OS_IPHONE
#pragma mark Camera Control

/**-----------------------------------------------------------------------------
 * @name Camera Control
 * -----------------------------------------------------------------------------
 */

/** Switches between front and rear cameras. (iOS only)

 @return * 0: Success.
* < 0: Failure.
 */
- (int)switchCamera:(BOOL)front;
#endif

#pragma mark Conrolling Methods
- (int)setPropertyOfUid:(NSString * _Nonnull)uid tell:(NSString * _Nullable)whom properties:(NSDictionary * _Nonnull)prop;//cyjtodo comments

- (int)sendChatMsg:(NSString * _Nonnull)message to:(NSString * _Nullable)whom withExtraData:(NSString * _Nullable)extraData;//cyjtodo comments

- (int)pubMsg:(NSString * _Nonnull)msgName
        msgId:(NSString * _Nonnull)msgId
           to:(NSString * _Nullable)whom
     withData:(NSString * _Nullable)data
associatedWithUser:(NSString * _Nullable)uid
associatedWithMsg:(NSString * _Nullable)assMsgID
save:(BOOL)save
extraData:(NSString * _Nullable)extra;//cyjtodo comments


- (int)delMsg:(NSString * _Nonnull)msgName
        msgId:(NSString * _Nonnull)msgId
           to:(NSString * _Nullable)whom;//cyjtodo comments

- (int)delMsg:(NSString * _Nonnull)msgName
        msgId:(NSString * _Nonnull)msgId
           to:(NSString * _Nullable)whom
     withData:(NSString * _Nullable)data;//cyjtodo comments

#pragma mark Miscellaneous Methods

/**-----------------------------------------------------------------------------
 * @name Miscellaneous Methods
 * -----------------------------------------------------------------------------
 */

/** Retrieves the current call ID.

 When a user joins a channel on a client, a `callId` is generated to identify the call from the client. Feedback methods, such as the [rate](rate:rating:description:) and [complain](complain:description:) methods, must be called after the call ends to submit feedback to the SDK.

 The [rate](rate:rating:description:) and [complain](complain:description:) methods require the `callId` parameter retrieved from the `getCallId` method during a call. *callId* is passed as an argument into the [rate](rate:rating:description:) and [complain](complain:description:) methods after the call ends.

 @return callId The current call ID.
 */
- (NSString * _Nullable)getCallId;

/** Retrieves the SDK version.

 This method returns the string of the version number.

 @return The version of the current SDK in the string format. For example, 2.3.0
 */
+ (NSString * _Nonnull)getSdkVersion;

/** Retrieves the description of a warning or error code.

 @param code The warning or error code that the [didOccurWarning]([CloudHubRtcEngineDelegate rtcEngine:didOccurWarning:]) or [didOccurError]([CloudHubRtcEngineDelegate rtcEngine:didOccurError:]) callback returns.

 @return CloudHubWarningCode or CloudHubErrorCode.
 */
//cyjtodo+ (NSString * _Nullable)getErrorDescription:(NSInteger)code;

/** Specifies an SDK output log file.

The log file records all log data for the SDK’s operation. Ensure that the directory to save the log file exists and is writable.

 **Note:**

 - The default log file location is as follows:
   - iOS: `App Sandbox/Library/caches/CloudHubsdk.log`
   - macOS
     - Sandbox enabled: `App Sandbox/Library/Logs/CloudHubsdk.log`, for example `/Users/<username>/Library/Containers/<App Bundle Identifier>/Data/Library/Logs/CloudHubsdk.log`.
     - Sandbox disabled: `～/Library/Logs/CloudHubsdk.log`.
 - Ensure that you call this method immediately after calling the [sharedEngineWithAppId]([CloudHubRtcEngineKit sharedEngineWithAppId:delegate:]) method, otherwise the output log might not be complete.

 @param filePath Absolute path of the log file. The string of the log file is in UTF-8.

 @return * 0: Success.
 * < 0: Failure.
 */
- (int)setLogFile:(NSString * _Nonnull)filePath;

/** Sets the output log level of the SDK.

You can use one or a combination of the filters. The log level follows the sequence of OFF, CRITICAL, ERROR, WARNING, INFO, and DEBUG. Choose a level to see the logs preceding that level.

For example, if you set the log level to WARNING, you see the logs within levels CRITICAL, ERROR, and WARNING.

 @param filter Log filter level: CloudHubLogFilter.

 @return * 0: Success.
 * < 0: Failure.
 */
- (int)setLogFilter:(NSUInteger)filter;

/** Sets the log file size (KB).

The SDK has two log files, each with a default size of 512 KB. If you set fileSizeInBytes as 1024 KB, the SDK outputs log files with a total maximum size of 2 MB. If the total size of the log files exceed the set value, the new output log files overwrite the old output log files.

@param fileSizeInKBytes The SDK log file size (KB).

@return * 0: Success.
* < 0: Failure.
*/
- (int)setLogFileSize:(NSUInteger)fileSizeInKBytes;

/** Returns the native handler of the SDK engine.

 This interface is used to get the native C++ handler of the SDK engine used in special scenarios, such as registering the audio and video frame observer.
 */
- (void * _Nullable)getNativeHandle;

/** Sets and retrieves the SDK delegate.

 The SDK uses the delegate to inform the app on engine runtime events. All methods defined in the delegate are optional implementation methods.

 */
@property (nonatomic, weak) id<CloudHubRtcEngineDelegate> _Nullable delegate;

@end

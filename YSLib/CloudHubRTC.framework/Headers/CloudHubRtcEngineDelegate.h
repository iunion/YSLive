//
//  CloudHubRtcEngineKit.h
//  CloudHubRtcEngineKit
//
//  Copyright (c) 2020 CloudHub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudHubObjects.h"

/** CloudHub provides ensured quality of experience (QoE) for worldwide Internet-based voice and video communications through a virtual global network optimized for real-time web and mobile-to-mobile applications.

 The CloudHubRtcEngineKit class is the entry point of the SDK providing API methods for apps to easily start voice and video communication.
 */
@class CloudHubRtcEngineKit;

/** The CloudHubRtcEngineDelegate protocol enables callbacks to your app.

 The SDK uses delegate callbacks in the CloudHubRtcEngineDelegate protocol to report runtime events to the app.
 From v1.1, some block callbacks in the SDK are replaced with delegate callbacks. The old block callbacks are therefore deprecated, but can still be used in the current version. However, CloudHub recommends replacing block callbacks with delegate callbacks. The SDK calls the block callback if a callback is defined in both the block and delegate callbacks.
 */
@protocol CloudHubRtcEngineDelegate <NSObject>

@optional
#pragma mark Core Delegate Methods

/**-----------------------------------------------------------------------------
 * @name Core Delegate Methods
 * -----------------------------------------------------------------------------
 */

/** Reports a warning during SDK runtime.

 In most cases, the app can ignore the warning reported by the SDK because the SDK can usually fix the issue and resume running.

 For instance, the SDK may report an CloudHubWarningCodeOpenChannelTimeout(106) warning upon disconnection from the server and attempts to reconnect.

 See [CloudHubWarningCode](CloudHubWarningCode).

 @param engine      CloudHubRtcEngineKit object
 @param warningCode Warning code: CloudHubWarningCode
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine didOccurWarning:(CloudHubWarningCode)warningCode;

/** Reports an error during SDK runtime.

In most cases, the SDK cannot fix the issue and resume running. The SDK requires the app to take action or informs the user about the issue.

For example, the SDK reports an CloudHubErrorCodeStartCall = 1002 error when failing to initialize a call. The app informs the user that the call initialization failed and invokes the [leaveChannel]([CloudHubRtcEngineKit leaveChannel:]) method to leave the channel.

See [CloudHubErrorCode](CloudHubErrorCode).

 @param engine    CloudHubRtcEngineKit object
 @param errorCode Error code: CloudHubErrorCode
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine didOccurError:(CloudHubErrorCode)errorCode;

/** Occurs when the local user joins a specified channel.

 Same as `joinSuccessBlock` in the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method.

 @param engine  CloudHubRtcEngineKit object.
 @param channel Channel name.
 @param uid     User ID. If the `uid` is specified in the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method, the specified user ID is returned. If the user ID is not specified when the joinChannel method is called, the server automatically assigns a `uid`.
 @param elapsed Time elapsed (ms) from the user calling the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method until the SDK triggers this callback.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine didJoinChannel:(NSString * _Nonnull)channel withUid:(NSString * _Nonnull)uid elapsed:(NSInteger) elapsed;

/** Occurs when the local user rejoins a channel.

 If the client loses connection with the server because of network problems, the SDK automatically attempts to reconnect and then triggers this callback upon reconnection, indicating that the user rejoins the channel with the assigned channel ID and user ID.

 @param engine  CloudHubRtcEngineKit object.
 @param channel Channel name.
 @param uid     User ID. If the `uid` is specified in the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method, the specified user ID is returned. If the user ID is not specified when the joinChannel method is called, the server automatically assigns a `uid`.
 @param elapsed Time elapsed (ms) from starting to reconnect to a successful reconnection.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine didRejoinChannel:(NSString * _Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed;

/** Occurs when the local user leaves a channel.

 When the app calls the [leaveChannel]([CloudHubRtcEngineKit leaveChannel:]) method, this callback notifies the app that a user leaves a channel.

 With this callback, the app retrieves information, such as the call duration and the statistics of the received/transmitted data reported by the [audioQualityOfUid]([CloudHubRtcEngineDelegate rtcEngine:audioQualityOfUid:quality:delay:lost:]) callback.

 @param engine CloudHubRtcEngineKit object.
 */
- (void)rtcEngineDidLeaveChannel:(CloudHubRtcEngineKit * _Nonnull)engine;

/** Occurs when the local user successfully registers a user account by calling the [registerLocalUserAccount]([CloudHubRtcEngineKit registerLocalUserAccount:appId:]) or [joinChannelByUserAccount]([CloudHubRtcEngineKit joinChannelByUserAccount:token:channelId:joinSuccess:]) method.

 - Communication profile: This callback notifies the app that another user joins the channel. If other users are already in the channel, the SDK also reports to the app on the existing users.
 - Live-broadcast profile: This callback notifies the app that a host joins the channel. If other hosts are already in the channel, the SDK also reports to the app on the existing hosts. CloudHub recommends limiting the number of hosts to 17.

 The SDK triggers this callback under one of the following circumstances:
 - A remote user/host joins the channel by calling the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method.
 - A remote user switches the user role to the host by calling the [setClientRole]([CloudHubRtcEngineKit setClientRole:]) method after joining the channel.
 - A remote user/host rejoins the channel after a network interruption.
 - A host injects an online media stream into the channel by calling the [addInjectStreamUrl]([CloudHubRtcEngineKit addInjectStreamUrl:config:]) method.

 **Note:**

 Live-broadcast profile:

 * The host receives this callback when another host joins the channel.
 * The audience in the channel receives this callback when a new host joins the channel.
 * When a web application joins the channel, the SDK triggers this callback as long as the web application publishes streams.

 @param engine  CloudHubRtcEngineKit object.
 @param uid     ID of the user or host who joins the channel. If the `uid` is specified in the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method, the specified user ID is returned. If the `uid` is not specified in the joinChannelByToken method, the CloudHub server automatically assigns a `uid`.
 joinChannelByToken:channelId:info:uid:joinSuccess:]) or [setClientRole]([CloudHubRtcEngineKit setClientRole:]) method until the SDK triggers this callback.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine didJoinedOfUid:(NSString * _Nonnull)uid properties:(NSString * _Nullable)properties;

/** Occurs when a remote user (Communication)/host (Live Broadcast) leaves a channel. Same as [userOfflineBlock]([CloudHubRtcEngineKit userOfflineBlock:]).

There are two reasons for users to be offline:

- Leave a channel: When the user/host leaves a channel, the user/host sends a goodbye message. When the message is received, the SDK assumes that the user/host leaves a channel.
- Drop offline: When no data packet of the user or host is received for a certain period of time (20 seconds for the Communication profile, and more for the Live-broadcast profile), the SDK assumes that the user/host drops offline. Unreliable network connections may lead to false detections, so CloudHub recommends using a signaling system for more reliable offline detection.

 @param engine CloudHubRtcEngineKit object.
 @param uid    ID of the user or host who leaves a channel or goes offline.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine didOfflineOfUid:(NSString * _Nonnull)uid;//ok

/** Occurs when the network connection state changes.

The SDK triggers this callback to report on the current network connection state when it changes, and the reason of the change.

@param engine CloudHubRtcEngineKit object.
@param state The current network connection state, see CloudHubConnectionStateType.
@param reason The reason of the connection state change, see CloudHubConnectionChangedReason.
*/
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine connectionChangedToState:(CloudHubConnectionStateType)state;//ok


/** Occurs when the SDK cannot reconnect to CloudHub's edge server 10 seconds after its connection to the server is interrupted.

The SDK triggers this callback when it cannot connect to the server 10 seconds after calling the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method, regardless of whether it is in the channel or not.

This callback is different from [rtcEngineConnectionDidInterrupted]([CloudHubRtcEngineDelegate rtcEngineConnectionDidInterrupted:]):

- The SDK triggers the [rtcEngineConnectionDidInterrupted]([CloudHubRtcEngineDelegate rtcEngineConnectionDidInterrupted:]) callback when it loses connection with the server for more than four seconds after it successfully joins the channel.
- The SDK triggers the [rtcEngineConnectionDidLost]([CloudHubRtcEngineDelegate rtcEngineConnectionDidLost:]) callback when it loses connection with the server for more than 10 seconds, regardless of whether it joins the channel or not.

If the SDK fails to rejoin the channel 20 minutes after being disconnected from CloudHub's edge server, the SDK stops rejoining the channel.

@param engine CloudHubRtcEngineKit object.
 */
- (void)rtcEngineConnectionDidLost:(CloudHubRtcEngineKit * _Nonnull)engine;

/** Occurs when the token expires in 30 seconds.

 The user becomes offline if the `token` used in the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method expires. The SDK triggers this callback 30 seconds before the `token` expires to remind the app to get a new `token`.
 Upon receiving this callback, generate a new `token` on the server and call the [renewToken]([CloudHubRtcEngineKit renewToken:]) method to pass the new `token` to the SDK.

 @param engine CloudHubRtcEngineKit object.
 @param token  The `token` that expires in 30 seconds.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine tokenPrivilegeWillExpire:(NSString *_Nonnull)token;//cyjtodo

/** Occurs when the token expires.

 After a `token` is specified by calling the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method, if the SDK losses connection to the CloudHub server due to network issues, the `token` may expire after a certain period of time and a new `token` may be required to reconnect to the server.

 Th SDK triggers this callback to notify the app to generate a new `token`. Call the [renewToken]([CloudHubRtcEngineKit renewToken:]) method to renew the `token`.

 @param engine CloudHubRtcEngineKit object.
 */
- (void)rtcEngineRequestToken:(CloudHubRtcEngineKit * _Nonnull)engine;//cyjtodo


#pragma mark Media Delegate Methods

/**-----------------------------------------------------------------------------
 * @name Media Delegate Methods
 * -----------------------------------------------------------------------------
 */

/** Reports which users are speaking, the speakers' volumes, and whether the local user is speaking.

 Same as [audioVolumeIndicationBlock]([CloudHubRtcEngineKit audioVolumeIndicationBlock:]).

 This callback reports the IDs and volumes of the loudest speakers at the moment in the channel, and whether the local user is speaking.

 By default, this callback is disabled. You can enable it by calling the `enableAudioVolumeIndication` method. Once enabled, this callback is triggered at the set interval, regardless of whether a user speaks or not.

 The SDK triggers two independent [reportAudioVolumeIndicationOfSpeakers]([CloudHubRtcEngineDelegate rtcEngine:reportAudioVolumeIndicationOfSpeakers:totalVolume:]) callbacks at one time, which separately report the volume information of the local user and all the remote speakers. For more information, see the detailed parameter descriptions.

**Note:**

 - To enable the voice activity detection of the local user, ensure that you set `report_vad(YES)` in the [enableAudioVolumeIndication]([CloudHubRtcEngineKit enableAudioVolumeIndication:smooth:report_vad:]) method.
 - Calling the [muteLocalAudioStream]([CloudHubRtcEngineKit muteLocalAudioStream:]) method affects the behavior of the SDK:
  - If the local user calls the `muteLocalAudioStream` method, the SDK stops triggering the local user’s callback immediately.
  - 20 seconds after a remote speaker calls the `muteLocalAudioStream` method, the remote speakers' callback excludes information of this user; 20 seconds after all remote users call the `muteLocalAudioStream` method, the SDK stops triggering the remote speakers' callback.

 @param engine      CloudHubRtcEngineKit object.
 @param speakers    CloudHubRtcAudioVolumeInfo array.

 - In the local user’s callback, this array contains the following members:
  - `uid` = 0,
  - `volume` = `totalVolume`, which reports the sum of the voice volume and audio-mixing volume of the local user, and
  - `vad`, which reports the voice activity status of the local user.

 - In the remote speakers' callback, this array contains the following members:
  - `uid` of each remote speaker,
  - `volume`, which reports the sum of the voice volume and audio-mixing volume of each remote speaker, and
  - `vad` = 0.
  An empty speakers array in the callback indicates that no remote user is speaking at the moment.

 @param totalVolume Total volume after audio mixing. The value range is [0,255].

 - In the local user’s callback, `totalVolume` is the sum of the voice volume and audio-mixing volume of the local user.
 - In the remote speakers' callback, `totalVolume` is the sum of the voice volume and audio-mixing volume of all the remote speakers.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine reportAudioVolumeIndicationOfUid:(NSString * _Nonnull)uid volume:(NSInteger)volume;

/** Occurs when the engine sends the first local audio frame.

 @param engine  CloudHubRtcEngineKit object.
 @param elapsed Time elapsed (ms) from the local user calling the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method until the SDK triggers this callback.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine firstLocalAudioFrame:(NSInteger)elapsed;

/** Occurs when the engine decodes the first remote audio frame.

@param engine  CloudHubRtcEngineKit object.
@param uid    ID of the user or host whoes audio frame is decoded.
@param elapsed Time elapsed (ms) from the local user calling the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method until the SDK triggers this callback.
*/
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine firstRemoteAudioDecodedOfUid:(NSString * _Nonnull)uid elapsed:(NSInteger)elapsed;

 /** Occurs when the first local video frame is displayed/rendered on the local video view.

 @param engine  CloudHubRtcEngineKit object.
 @param size    Size of the first local video frame (width and height).
 @param elapsed Time elapsed (ms) from the local user calling the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method until the SDK calls this callback.

 If the [startPreview]([CloudHubRtcEngineKit startPreview]) method is called before the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method, then `elapsed` is the time elapsed from calling the [startPreview]([CloudHubRtcEngineKit startPreview]) method until the SDK triggers this callback.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed;

/** Occurs when the first remote video frame is displayed/rendered on the local video view.

@param engine  CloudHubRtcEngineKit object.
@param uid      ID of the user or host whoes audio frame is decoded.
@param sourceID      ID of the video device.
@param size    Size of the first local video frame (width and height).
@param elapsed Time elapsed (ms) from the local user calling the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method until the SDK calls this callback.
*/
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine firstRemoteVideoDecodedOfUid:(NSString * _Nonnull)uid sourceID:(NSString * _Nullable)sourceID Size:(CGSize)size elapsed:(NSInteger)elapsed;

/** Occurs when a remote user's video stream playback pauses/resumes.

 You can also use the [remoteVideoStateChangedOfUid]([CloudHubRtcEngineDelegate rtcEngine:remoteVideoStateChangedOfUid:state:reason:elapsed:]) callback with the following parameters:

 - CloudHubVideoRemoteStateStopped(0) and CloudHubVideoRemoteStateReasonRemoteMuted(5).
 - CloudHubVideoRemoteStateDecoding(2) and CloudHubVideoRemoteStateReasonRemoteUnmuted(6).
 
 Same as [userMuteVideoBlock]([CloudHubRtcEngineKit userMuteVideoBlock:]).

 The SDK triggers this callback when the remote user stops or resumes sending the video stream by calling the [muteLocalVideoStream]([CloudHubRtcEngineKit muteLocalVideoStream:]) method.

 **Note:**

 This callback is invalid when the number of users or broadcasters in a channel exceeds 20.

 @param engine CloudHubRtcEngineKit object.
 @param muted  A remote user's video stream playback pauses/resumes:

 * YES: Pause.
 * NO: Resume.

 @param uid    User ID of the remote user.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onVideoMuted:(BOOL)muted withUid:(NSString * _Nonnull)uid sourceID:(NSString * _Nonnull)sourceID;


/** Occurs when a remote user's audio stream playback pauses/resumes.

You can also use the [remoteAudioStateChangedOfUid]([CloudHubRtcEngineDelegate rtcEngine:remoteAudioStateChangedOfUid:state:reason:elapsed:]) callback with the following parameters:

- CloudHubAudioRemoteStateStopped(0) and CloudHubAudioRemoteStateReasonRemoteMuted(5).
- CloudHubAudioRemoteStateDecoding(2) and CloudHubAudioRemoteStateReasonRemoteUnmuted(6).

The SDK triggers this callback when the remote user stops or resumes sending the video stream by calling the [muteLocalAudioStream]([CloudHubRtcEngineKit muteLocalAudioStream:]) method.


@param engine CloudHubRtcEngineKit object.
@param muted  A remote user's audio stream playback pauses/resumes:

* YES: Pause.
* NO: Resume.

@param uid    User ID of the remote user.
*/
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onAudioMuted:(BOOL)muted withUid:(NSString * _Nonnull)uid;


/** Occurs when the video size or rotation of a specific remote user changes.

 @param engine   CloudHubRtcEngineKit object.
 @param uid      User ID of the remote user or local user (0) whose video size or rotation changes.
 @param size     New video size.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine videoSizeChangedOfUid:(NSString * _Nonnull)uid sourceID:(NSString * _Nullable)sourceID size:(CGSize)size;

/** Occurs when the remote video state changes.
 
 @param engine CloudHubRtcEngineKit object.
 @param uid ID of the remote user whose video state changes.
 @param state The state of the remote video. See [CloudHubVideoRemoteState](CloudHubVideoRemoteState).
 @param reason The reason of the remote video state change. See [CloudHubVideoRemoteStateReason](CloudHubVideoRemoteStateReason).
 @param elapsed The time elapsed (ms) from the local user calling the [joinChannel]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method until the SDK triggers this callback.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine remoteVideoStateChangedOfUid:(NSString * _Nonnull)uid sourceID:(NSString * _Nonnull)sourceID state:(CloudHubVideoRemoteState)state reason:(CloudHubVideoRemoteStateReason)reason;

/** Occurs when the local video stream state changes.

The SDK reports the current video state in this callback.

 @param engine CloudHubRtcEngineKit object.
 @param state The local video state, see CloudHubLocalVideoStreamState. When the state is CloudHubLocalVideoStreamStateFailed(3), see the `error` parameter for details.
 @param error The detailed error information of the local video, see CloudHubLocalVideoStreamError.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine localVideoStateChangeWithState:(CloudHubLocalVideoStreamState)state error:(CloudHubLocalVideoStreamError)error;

/** Occurs when the local audio state changes.

 This callback indicates the state change of the local audio stream, including the state of the audio recording and encoding, and allows you to troubleshoot issues when exceptions occur.
 
 @param engine See CloudHubRtcEngineKit.
 @param uid ID of the remote user whose audio state changes.
 @param state  State of the remote audio. See [CloudHubAudioRemoteState](CloudHubAudioRemoteState).
 @param reason The reason of the remote audio state change. See [CloudHubAudioRemoteStateReason](CloudHubAudioRemoteStateReason).
 @param elapsed Time elapsed (ms) from the local user calling the [joinChannel]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method until the SDK triggers this callback.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine remoteAudioStateChangedOfUid:(NSString * _Nonnull)uid state:(CloudHubAudioRemoteState)state reason:(CloudHubAudioRemoteStateReason)reason elapsed:(NSInteger)elapsed;

/** Occurs when the local audio state changes.

 This callback indicates the state change of the local audio stream, including the state of the audio recording and encoding, and allows you to troubleshoot issues when exceptions occur.

 @param engine See CloudHubRtcEngineKit.
 @param state The state of the local audio. See [CloudHubAudioLocalState](CloudHubAudioLocalState).
 @param error The error information of the local audio. See [CloudHubAudioLocalError](CloudHubAudioLocalError).

 @note When the state is CloudHubAudioLocalStateFailed(3), see the `error` parameter for details.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine localAudioStateChange:(CloudHubAudioLocalState)state error:(CloudHubAudioLocalError)error;


- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine onStreamInjectedStatus:(NSString * _Nonnull)url uid:(NSString * _Nonnull)uid sourceID:(NSString * _Nonnull)sourceID attributes:(NSString * _Nonnull)attributes status:(CloudHubStreamInjectStatus)status pos:(NSUInteger)pos;//cyjtodo comment

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine remoteScreenStartOfUid:(NSString * _Nonnull)uid sourceID:(NSString * _Nonnull)sourceID;//cyjtodo comment

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine remoteScreenStopOfUid:(NSString * _Nonnull)uid sourceID:(NSString * _Nonnull)sourceID;//cyjtodo comment

#pragma mark Device Delegate Methods

/**-----------------------------------------------------------------------------
 * @name Device Delegate Methods
 * -----------------------------------------------------------------------------
 */

/** Occurs when the local audio route changes.

The SDK triggers this callback when the local audio route switches to an earpiece, speakerphone, headset, or Bluetooth device.

 @param engine  CloudHubRtcEngineKit object.
 @param routing Audio route: CloudHubAudioOutputRouting.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine didAudioRouteChanged:(CloudHubAudioOutputRouting)routing;//cyjtodo

#if TARGET_OS_IPHONE

/** Occurs when a camera focus area changes. (iOS only.)

The SDK triggers this callback when the local user changes the camera focus position by calling the [setCameraFocusPositionInPreview](setCameraFocusPositionInPreview:) method.

 @param engine CloudHubRtcEngineKit object.
 @param rect   Rectangular area in the camera zoom specifying the focus area.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine cameraFocusDidChangedToRect:(CGRect)rect;
#endif


#pragma mark Statistics Delegate Methods

/**-----------------------------------------------------------------------------
 * @name Statistics Delegate Methods
 * -----------------------------------------------------------------------------
 */

/** Reports the statistics of the current call. The SDK triggers this callback once every two seconds after the user joins the channel.

 @param engine CloudHubRtcEngineKit object.
 @param stats  Statistics of the CloudHubRtcEngineKit: [CloudHubChannelStats](CloudHubChannelStats).
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine reportRtcStats:(CloudHubChannelStats * _Nonnull)stats;

/** Reports the last mile network quality of the local user once every two seconds before the user joins a channel.

Last mile refers to the connection between the local device and CloudHub's edge server. After the app calls the [enableLastmileTest]([CloudHubRtcEngineKit enableLastmileTest]) method, the SDK triggers this callback once every two seconds to report the uplink and downlink last mile network conditions of the local user before the user joins the channel.

 @param engine  CloudHubRtcEngineKit object.
 @param quality The last mile network quality based on the uplink and dowlink packet loss rate and jitter. See CloudHubNetworkQuality.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine lastmileQuality:(CloudHubNetworkQuality)quality;

/** Reports the last mile network quality of each user in the channel once every two seconds.

 Last mile refers to the connection between the local device and CloudHub's edge server. The SDK triggers this callback once every two seconds to report the last mile network conditions of each user in the channel. If a channel includes multiple users, the SDK triggers this callback as many times.

 @param engine    CloudHubRtcEngineKit object.
 @param uid       User ID. The network quality of the user with this `uid` is reported. If `uid` is 0, the local network quality is reported.
 @param txQuality Uplink transmission quality of the user in terms of the transmission bitrate, packet loss rate, average RTT (Round-Trip Time), and jitter of the uplink network. `txQuality` is a quality rating helping you understand how well the current uplink network conditions can support the selected CloudHubVideoEncoderConfiguration. For example, a 1000-Kbps uplink network may be adequate for video frames with a resolution of 640 &times; 480 and a frame rate of 15 fps in the Live-broadcast profile, but may be inadequate for resolutions higher than 1280 &times; 720. See  CloudHubNetworkQuality.
 @param rxQuality Downlink network quality rating of the user in terms of packet loss rate, average RTT, and jitter of the downlink network.  See CloudHubNetworkQuality.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine networkQuality:(NSUInteger)uid txQuality:(CloudHubNetworkQuality)txQuality rxQuality:(CloudHubNetworkQuality)rxQuality;

/** Reports the statistics of the uploading local video streams once every two seconds. Same as [localVideoStatBlock]([CloudHubRtcEngineKit localVideoStatBlock:]).

 @param engine CloudHubRtcEngineKit object.
 @param stats Statistics of the uploading local video streams. See [CloudHubRtcLocalVideoStats](CloudHubRtcLocalVideoStats).
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine localVideoStats:(CloudHubRtcLocalVideoStats * _Nonnull)stats;

/** Reports the statistics of the local audio stream.
 
 The SDK triggers this callback once every two seconds.
 
 @param engine See CloudHubRtcEngineKit.
 @param stats The statistics of the local audio stream. See [CloudHubRtcLocalAudioStats](CloudHubRtcLocalAudioStats).
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine localAudioStats:(CloudHubRtcLocalAudioStats * _Nonnull)stats;

/** Reports the statistics of the video stream from each remote user/host.

The SDK triggers this callback once every two seconds for each remote user/host. If a channel includes multiple remote users, the SDK triggers this callback as many times.

 This callback reports the statistics more closely linked to the real-user experience of the video transmission quality than the statistics that the [videoTransportStatsOfUid]([CloudHubRtcEngineDelegate rtcEngine:videoTransportStatsOfUid:delay:lost:rxKBitRate:]) callback reports. This callback reports more about media layer statistics such as the frame loss rate, while the [videoTransportStatsOfUid]([CloudHubRtcEngineDelegate rtcEngine:videoTransportStatsOfUid:delay:lost:rxKBitRate:]) callback reports more about the transport layer statistics such as the packet loss rate.

Schemes such as FEC (Forward Error Correction) or retransmission counter the frame loss rate. Hence, users may find the overall video quality acceptable even when the packet loss rate is high.


 @param engine CloudHubRtcEngineKit object.
 @param stats  Statistics of the received remote video streams. See [CloudHubRtcRemoteVideoStats](CloudHubRtcRemoteVideoStats).
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine remoteVideoStats:(CloudHubRtcRemoteVideoStats * _Nonnull)stats;

/** Reports the statistics of the audio stream from each remote user/host.

 This callback replaces the [audioQualityOfUid]([CloudHubRtcEngineDelegate rtcEngine:audioQualityOfUid:quality:delay:lost:]) callback.

 The SDK triggers this callback once every two seconds for each remote user/host. If a channel includes multiple remote users, the SDK triggers this callback as many times.

 This callback reports the statistics more closely linked to the real-user experience of the audio transmission quality than the statistics that the [audioTransportStatsOfUid]([CloudHubRtcEngineDelegate rtcEngine:audioTransportStatsOfUid:delay:lost:rxKBitRate:]) callback reports. This callback reports more about media layer statistics such as the frame loss rate, while the [audioTransportStatsOfUid]([CloudHubRtcEngineDelegate rtcEngine:audioTransportStatsOfUid:delay:lost:rxKBitRate:]) callback reports more about the transport layer statistics such as the packet loss rate.

Schemes such as FEC (Forward Error Correction) or retransmission counter the frame loss rate. Hence, users may find the overall audio quality acceptable even when the packet loss rate is high.

 @param engine CloudHubRtcEngineKit object.
 @param stats  Statistics of the received remote audio streams. See CloudHubRtcRemoteAudioStats.
 */
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine remoteAudioStats:(CloudHubRtcRemoteAudioStats * _Nonnull)stats;



#pragma mark Audio Player Delegate Methods

/**-----------------------------------------------------------------------------
 * @name Audio Player Delegate Methods
 * -----------------------------------------------------------------------------
 */

/** Occurs when the audio mixing file playback finishes.

You can start an audio mixing file playback by calling the [startAudioMixing]([CloudHubRtcEngineKit startAudioMixing:loopback:replace:cycle:]) method. The SDK triggers this callback when the audio mixing file playback finishes.

 If the [startAudioMixing]([CloudHubRtcEngineKit startAudioMixing:loopback:replace:cycle:]) method call fails, a warning code, CloudHubWarningCodeAudioMixingOpenError, returns in the [didOccurWarning]([CloudHubRtcEngineDelegate rtcEngine:didOccurWarning:]) callback.

 @param engine CloudHubRtcEngineKit object.
 */
- (void)rtcEngineLocalAudioMixingDidFinish:(CloudHubRtcEngineKit * _Nonnull)engine;

/** Occurs when the state of the local user's audio mixing file changes.

- When the audio mixing file plays, pauses playing, or stops playing, this callback returns 710, 711, or 713  in state, and 0 in `errorCode`.
- When exceptions occur during playback, this callback returns 714 in `state` and an error in `errorCode`.
- If the local audio mixing file does not exist, or if the SDK does not support the file format or cannot access the music file URL, the SDK returns `CloudHubWarningCodeAudioMixingOpenError = 701`.

@param engine CloudHubRtcEngineKit object.
@param state The state code, see CloudHubAudioMixingStateCode.
@param errorCode The error code, see CloudHubAudioMixingErrorCode.
*/
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine localAudioMixingStateDidChanged:(CloudHubAudioMixingStateCode)state errorCode:(CloudHubAudioMixingErrorCode)errorCode;

/** Occurs when a remote user starts audio mixing.

 The SDK triggers this callback when a remote user calls the [startAudioMixing]([CloudHubRtcEngineKit startAudioMixing:loopback:replace:cycle:]) method.

 @param engine CloudHubRtcEngineKit object.
 */
- (void)rtcEngineRemoteAudioMixingDidStart:(CloudHubRtcEngineKit * _Nonnull)engine;

/** Occurs when a remote user finishes audio mixing.

 @param engine CloudHubRtcEngineKit object.
 */
- (void)rtcEngineRemoteAudioMixingDidFinish:(CloudHubRtcEngineKit * _Nonnull)engine;

/** Occurs when the local audio effect playback finishes.

 You can start a local audio effect playback by calling the [playEffect]([CloudHubRtcEngineKit playEffect:filePath:loopCount:pitch:pan:gain:publish:]) method. The SDK triggers this callback when the local audio effect file playback finishes.

 @param engine  CloudHubRtcEngineKit object.
 @param soundId ID of the local audio effect. Each local audio effect has a unique ID.
 */
- (void)rtcEngineDidAudioEffectFinish:(CloudHubRtcEngineKit * _Nonnull)engine soundId:(NSInteger)soundId;

#pragma mark Conrolling Message Delegate Methods
- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine
onSetPropertyOfUid:(NSString * _Nonnull)uid
             from:(NSString * _Nullable)fromuid
       properties:(NSString * _Nonnull)prop;//cyjtodo comments

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine
onChatMessageArrival:(NSString * _Nonnull)message
             from:(NSString * _Nullable)fromuid
    withExtraData:(NSString * _Nullable)extraData;//cyjtodo comments

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine
         onPubMsg:(NSString * _Nonnull)msgName
            msgId:(NSString * _Nonnull)msgId
             from:(NSString * _Nullable)fromuid
         withData:(NSString * _Nullable)data
associatedWithUser:(NSString * _Nullable)uid
associatedWithMsg:(NSString * _Nullable)assMsgID
               ts:(NSUInteger)ts
    withExtraData:(NSString * _Nullable)extraData
        isHistory:(BOOL)isHistory;//cyjtodo comments

- (void)rtcEngine:(CloudHubRtcEngineKit * _Nonnull)engine
         onDelMsg:(NSString * _Nonnull)msgName
            msgId:(NSString * _Nonnull)msgId
             from:(NSString * _Nullable)fromuid
         withData:(NSString * _Nullable)data;//cyjtodo comments
@end

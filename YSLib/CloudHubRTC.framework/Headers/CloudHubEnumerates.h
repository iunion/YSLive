//
// CloudHubEnumerates.h
// CloudHubRtcEngineKit
//
//  Copyright (c) 2020 CloudHub. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Error code.

Error codes occur when the SDK encounters an error that cannot be recovered automatically without any app intervention. For example, the SDK reports the CloudHubErrorCodeStartCall = 1002 error if it fails to start a call, and reminds the user to call the [leaveChannel]([CloudHubRtcEngineKit leaveChannel:]) method.
*/
typedef NS_ENUM(NSInteger, CloudHubErrorCode) {
    /** 0: No error occurs. */
    CloudHubErrorCodeNoError = 0,
    /** 1: A general error occurs (no specified reason). */
    CloudHubErrorCodeFailed = 1,
    /** 2: An invalid parameter is used. For example, the specific channel name includes illegal characters. */
    CloudHubErrorCodeInvalidArgument = 2,
    /** 3: The SDK module is not ready.
     <p>Possible solutions：
     <ul><li>Check the audio device.</li>
     <li>Check the completeness of the app.</li>
     <li>Re-initialize the SDK.</li></ul></p>
    */
    CloudHubErrorCodeNotReady = 3,
    /** 4: The current state of the SDK does not support this function. */
    CloudHubErrorCodeNotSupported = 4,
    /** 5: The request is rejected. This is for internal SDK use only, and is not returned to the app through any method or callback. */
    CloudHubErrorCodeRefused = 5,
    /** 6: The buffer size is not big enough to store the returned data. */
    CloudHubErrorCodeBufferTooSmall = 6,
    /** 7: The SDK is not initialized before calling this method. */
    CloudHubErrorCodeNotInitialized = 7,
    /** 17: The request to join the channel is rejected.
     <p>Possible reasons are:
     <ul><li>The user is already in the channel, and still calls the API method to join the channel, for example, [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]).</li>
     <li>The user tries joining the channel during the echo test. Please join the channel after the echo test ends.</li></ul></p>
    */
    CloudHubErrorCodeJoinChannelRejected = 17,
    /** 18: The request to leave the channel is rejected.
     <p>Possible reasons are:
     <ul><li>The user left the channel and still calls the API method to leave the channel, for example, [leaveChannel]([CloudHubRtcEngineKit leaveChannel:]).</li>
     <li>The user has not joined the channel and calls the API method to leave the channel.</li></ul></p>
    */
    CloudHubErrorCodeLeaveChannelRejected = 18,
    /** 22: The app uses too much of the system resources and the SDK fails to allocate the resources. */
    CloudHubErrorCodeResourceLimited = 22,
    /** 101: The specified App ID is invalid. Please try to rejoin the channel with a valid App ID.*/
    CloudHubErrorCodeInvalidAppId = 101,
    /** 102: The specified channel name is invalid. Please try to rejoin the channel with a valid channel name. */
    CloudHubErrorCodeInvalidChannelId = 102,
    /** 107: The amount of concurrent points has exceeded your enterpirse account's limitation . */
    CloudHubErrorCodeConcurrentPintsExceedLimit = 107,
    /** 109: The token expired.
      CloudHubConnectionChangedTokenExpired(9) in the `reason` parameter of [connectionChangedToState]([CloudHubRtcEngineDelegate rtcEngine:connectionChangedToState:reason:]).
     */
    CloudHubErrorCodeTokenExpired = 109,
    /** 110: The token is invalid.
     Possible reasons are:
     The App Certificate for the project is enabled in Console, but the user is using the App ID. Once the App Certificate is enabled, the user must use a token.
     The uid is mandatory, and users must set the same uid as the one set in the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method.
     */
    CloudHubErrorCodeInvalidToken = 110,
    /** 113: Not in channel. */
    CloudHubErrorCodeNotInChannel = 113,
    
    /** 501: The local user is currently not authorized to publish steam. */
    CloudHubErrorCodePublishNotAuthorized = 501,
    /** 502: Internal server error occured when trying to publish stream. */
    CloudHubErrorCodePublishInternalServerError = 502,
    
    /** 601: The local user is currently not authorized to subscribe steam. */
    CloudHubErrorCodeSubscribeNotAuthorized = 601,
    /** 602: Internal server error occured when trying to subscribe stream. */
    CloudHubErrorCodeSubscribeInternalServerError = 602,
    
    /** 701: The movie file is already being played. */
    CloudHubErrorCodeMovieAlreadyPlaying = 701,
    /** 702: Only one movie file can be published at the same time. */
    CloudHubErrorCodeMovieAlreadyPublishing = 702,
    
    /** 1003: Fails to start the camera. */
    CloudHubErrorCodeStartCamera = 1003,
    /** 1027: Audio Device Module: An error occurs in no recording Permission. */
    CloudHubErrorCodeAdmNoPermission = 1027,

    /** 1501: Video Device Module: The camera is unauthorized. */
    CloudHubErrorCodeVdmCameraNotAuthorized = 1501,
    
    /** -1: Other errors*/
    CloudHubErrorCodeUnknwon = -1
};

/** The state of the audio mixing file. */
typedef NS_ENUM(NSInteger, CloudHubMovieStateCode){
    /** The movie file is playing. */
    CloudHubMovieStatePlaying = 710,
    /** The movie file pauses playing. */
    CloudHubMovieStatePaused = 711,
    /** The movie file stops playing. */
    CloudHubMovieStateStopped = 713,
    /** An exception occurs when playing the movie file. */
    CloudHubMovieStateFailed = 714,
    /** The movie file completes playing. */
    CloudHubMovieStatePlayCompleted = 715,
};

/**  The error code of the audio mixing file. */
typedef NS_ENUM(NSInteger, CloudHubMovieErrorCode){
    /** The SDK cannot open the movie file. */
   CloudHubMovieErrorCanNotOpen = 701,
   /** The SDK opens the movie file too frequently. */
   CloudHubMovieErrorTooFrequentCall = 702,
   /** The opening of the movie file is interrupted. */
   CloudHubMovieErrorInterruptedEOF = 703,
   /** No error. */
   CloudHubMovieErrorOK = 0,
};

/** Video frame rate */
typedef NS_ENUM(NSInteger, CloudHubVideoFrameRate) {
    /** 1 fps. */
    CloudHubVideoFrameRateFps1 = 1,
    /** 7 fps. */
    CloudHubVideoFrameRateFps7 = 7,
    /** 10 fps. */
    CloudHubVideoFrameRateFps10 = 10,
    /** 15 fps. */
    CloudHubVideoFrameRateFps15 = 15,
    /** 24 fps. */
    CloudHubVideoFrameRateFps24 = 24,
    /** 30 fps. */
    CloudHubVideoFrameRateFps30 = 30,
};

/** Video frame rotation */
typedef NS_ENUM(NSInteger, CloudHubVideoRotation) {
    /** Sdk will make your video always seem with a correct rotation, but the resolution may change (like 320x240 to 240x320)*/
    CloudHubVideoRotationAuto = 0,
    /** When your home button is on the right side, your video seems correct.*/
    CloudHubHomeButtonOnRight = 1,
    /** When your home button is on bottom, your video seems correct.*/
    CloudHubHomeButtonOnBottom = 2,
    /** When your home button is on the left side, your video seems correct.*/
    CloudHubHomeButtonOnLeft = 3,
    /** When your home button is on top, your video seems correct.*/
    CloudHubHomeButtonOnTop = 4,
};

/** Channel profile. */
typedef NS_ENUM(NSInteger, CloudHubChannelProfile) {
    /** 0: (Default) The Communication profile. 
     <p>Use this profile in one-on-one calls or group calls, where all users can talk freely.</p>
     */
    CloudHubChannelProfileCommunication = 0,
    /** 1: The Live-Broadcast profile. 
     <p>Users in a live-broadcast channel have a role as either broadcaster or audience. A broadcaster can both send and receive streams; an audience can only receive streams.</p>
     */
    CloudHubChannelProfileLiveBroadcasting = 1,
};

/** Client role in a live broadcast. */
typedef NS_ENUM(NSInteger, CloudHubClientRole) {
    /** Host. */
    CloudHubClientRoleBroadcaster = 1,
    /** Audience. */
    CloudHubClientRoleAudience = 2,
};

/** Output log filter level. */
typedef NS_ENUM(NSUInteger, CloudHubLogFilter) {
    CloudHubLogFilterAll = 0,
    CloudHubLogFilterDebug = 1,
    CloudHubLogFilterInfo = 2,
    CloudHubLogFilterWarning = 3,
    CloudHubLogFilterError = 4,
    CloudHubLogFilterAlarm = 5,
    CloudHubLogFilterFatal = 6,
};

/** Video display mode. */
typedef NS_ENUM(NSUInteger, CloudHubVideoRenderMode) {
    /** Hidden(1): Uniformly scale the video until it fills the visible boundaries (cropped). One dimension of the video may have clipped contents. */
    CloudHubVideoRenderModeHidden = 1,

    /** Fit(2): Uniformly scale the video until one of its dimension fits the boundary (zoomed to fit). Areas that are not filled due to the disparity in the aspect ratio are filled with black. */
    CloudHubVideoRenderModeFit = 2,
};

/** Video codec types. */
typedef NS_ENUM(NSInteger, CloudHubVideoCodecType) {
    /** 1: Standard VP8. */
    CloudHubVideoCodecTypeVP8 = 1,
    /** 2: Standard H264. */
    CloudHubVideoCodecTypeH264 = 2,
};

/** Video mirror mode. */
typedef NS_ENUM(NSUInteger, CloudHubVideoMirrorMode) {
    /** 0: (Default) The SDK determines the mirror mode.
     */
    CloudHubVideoMirrorModeAuto = 0,
    /** 1: Enables mirror mode. */
    CloudHubVideoMirrorModeEnabled = 1,
    /** 2: Disables mirror mode. */
    CloudHubVideoMirrorModeDisabled = 2,
};

/** The state of the remote video. */
typedef NS_ENUM(NSUInteger, CloudHubVideoRemoteState) {
    /** 0: The remote video is in the default state, probably due to CloudHubVideoRemoteStateReasonLocalMuted(3), CloudHubVideoRemoteStateReasonRemoteMuted(5), or CloudHubVideoRemoteStateReasonRemoteOffline(7).
     */
    CloudHubVideoRemoteStateStopped = 0,
    /** 1: The first remote video packet is received.
     */
    CloudHubVideoRemoteStateStarting = 1,
    /** 2: The remote video stream is decoded and plays normally, probably due to CloudHubVideoRemoteStateReasonNetworkRecovery(2), CloudHubVideoRemoteStateReasonLocalUnmuted(4), CloudHubVideoRemoteStateReasonRemoteUnmuted(6), or CloudHubVideoRemoteStateReasonAudioFallbackRecovery(9).
     */
    CloudHubVideoRemoteStateFrozen = 2,
    /** 4: The remote video fails to start, probably due to CloudHubVideoRemoteStateReasonInternal(0).
     */
    CloudHubVideoRemoteStateFailed = 3,
};

/** The reason of the remote video state change. */
typedef NS_ENUM(NSUInteger, CloudHubVideoRemoteStateReason) {
    /** 0: Internal reasons. */
    CloudHubVideoRemoteStateReasonInternal = 0,
    /** 1: Network congestion. */
    CloudHubVideoRemoteStateReasonNetworkCongestion = 1,
    /** 2: Network recovery. */
    CloudHubVideoRemoteStateReasonNetworkRecovery = 2,
    /** 3: The local user stops receiving the remote video stream or disables the video module. */
    CloudHubVideoRemoteStateReasonLocalMuted = 3,
    /** 4: The local user resumes receiving the remote video stream or enables the video module. */
    CloudHubVideoRemoteStateReasonLocalUnmuted = 4,
    /** 5: The remote user stops sending the video stream or disables the video module. */
    CloudHubVideoRemoteStateReasonRemoteMuted = 5,
    /** 6: The remote user resumes sending the video stream or enables the video module. */
    CloudHubVideoRemoteStateReasonRemoteUnmuted = 6,
    /** 7: The remote user leaves the channel. */
    CloudHubVideoRemoteStateReasonRemoteOffline = 7,
    /** 8: The remote media stream falls back to the audio-only stream due to poor network conditions. */
    CloudHubVideoRemoteStateReasonAudioFallback = 8,
    /** 9: The remote media stream switches back to the video stream after the network conditions improve. */
    CloudHubVideoRemoteStateReasonAudioFallbackRecovery = 9,
    /** 10: The remote media stream is added. */
    CloudHubVideoRemoteStateReasonAddRemoteStream = 10,
    /** 11: The remote media stream is removed. */
    CloudHubVideoRemoteStateReasonRemoveRemoteStream = 11,
};

/** The state of the remote audio. */
typedef NS_ENUM(NSUInteger, CloudHubAudioRemoteState) {
    /** 0: The remote audio is in the default state, probably due to CloudHubAudioRemoteReasonLocalMuted(3), CloudHubAudioRemoteReasonRemoteMuted(5), or CloudHubAudioRemoteReasonRemoteOffline(7). */
    CloudHubAudioRemoteStateStopped = 0,
    /** 1: The first remote audio packet is received. */
    CloudHubAudioRemoteStateStarting = 1,
    /** 2: The remote audio stream is decoded and plays normally, probably due to CloudHubAudioRemoteReasonNetworkRecovery(2), CloudHubAudioRemoteReasonLocalUnmuted(4), or CloudHubAudioRemoteReasonRemoteUnmuted(6). */
    CloudHubAudioRemoteStateDecoding = 2,
    /** 3: The remote audio is frozen, probably due to CloudHubAudioRemoteReasonNetworkCongestion(1). */
    CloudHubAudioRemoteStateFrozen = 3,
    /** 4: The remote audio fails to start, probably due to CloudHubAudioRemoteReasonInternal(0). */
    CloudHubAudioRemoteStateFailed = 4,
};

/** The reason of the remote audio state change. */
typedef NS_ENUM(NSUInteger, CloudHubAudioRemoteStateReason) {
    /** 0: Internal reasons. */
    CloudHubAudioRemoteReasonInternal = 0,
    /** 1: Network congestion. */
    CloudHubAudioRemoteReasonNetworkCongestion = 1,
    /** 2: Network recovery. */
    CloudHubAudioRemoteReasonNetworkRecovery = 2,
    /** 3: The local user stops receiving the remote audio stream or disables the audio module. */
    CloudHubAudioRemoteReasonLocalMuted = 3,
    /** 4: The local user resumes receiving the remote audio stream or enables the audio module. */
    CloudHubAudioRemoteReasonLocalUnmuted = 4,
    /** 5: The remote user stops sending the audio stream or disables the audio module. */
    CloudHubAudioRemoteReasonRemoteMuted = 5,
    /** 6: The remote user resumes sending the audio stream or enables the audio module. */
    CloudHubAudioRemoteReasonRemoteUnmuted = 6,
    /** 7: The remote user leaves the channel. */
    CloudHubAudioRemoteReasonRemoteOffline = 7,
};

/** The state of the local audio. */
typedef NS_ENUM(NSUInteger, CloudHubAudioLocalState) {
    /** 0: The local audio is in the initial state. */
    CloudHubAudioLocalStateStopped = 0,
    /** 1: The recording device starts successfully.  */
    CloudHubAudioLocalStateRecording = 1,
    /** 2: The first audio frame encodes successfully. */
    CloudHubAudioLocalStateEncoding = 2,
    /** 3: The local audio fails to start. */
    CloudHubAudioLocalStateFailed = 3,
};

/** The error information of the local audio. */
typedef NS_ENUM(NSUInteger, CloudHubAudioLocalError) {
    /** 0: The local audio is normal. */
    CloudHubAudioLocalErrorOk = 0,
    /** 1: No specified reason for the local audio failure. */
    CloudHubAudioLocalErrorFailure = 1,
    /** 2: No permission to use the local audio device. */
    CloudHubAudioLocalErrorDeviceNoPermission = 2,
    /** 3: The microphone is in use. */
    CloudHubAudioLocalErrorDeviceBusy = 3,
    /** 4: The local audio recording fails. Check whether the recording device is working properly. */
    CloudHubAudioLocalErrorRecordFailure = 4,
    /** 5: The local audio encoding fails. */
    CloudHubAudioLocalErrorEncodeFailure = 5,
};

/** Media device type. */
typedef NS_ENUM(NSInteger, CloudHubMediaDeviceType) {
    /** Unknown device. */
    CloudHubMediaDeviceTypeAudioUnknown = -1,
    /** Audio playback device. */
    CloudHubMediaDeviceTypeAudioPlayout = 0,
    /** Audio recording device. */
    CloudHubMediaDeviceTypeAudioRecording = 1,
    /** Video render device. */
    CloudHubMediaDeviceTypeVideoRender = 2,
    /** Video capture device. */
    CloudHubMediaDeviceTypeVideoCapture = 3,
};

/** Connection states. */
typedef NS_ENUM(NSInteger, CloudHubConnectionStateType) {
    /** <p>1: The SDK is disconnected from CloudHub's edge server.</p>
This is the initial state before [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]).<br>
The SDK also enters this state when the app calls [leaveChannel]([CloudHubRtcEngineKit leaveChannel:]).
    */
    CloudHubConnectionStateDisconnected = 1,
    /** <p>2: The SDK is connecting to CloudHub's edge server.</p>
When the app calls [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]), the SDK starts to establish a connection to the specified channel, triggers the [connectionChangedToState]([CloudHubRtcEngineDelegate rtcEngine:connectionChangedToState:reason:]) callback, and switches to the `CloudHubConnectionStateConnecting` state.<br>
<br>
When the SDK successfully joins the channel, the SDK triggers the [connectionChangedToState]([CloudHubRtcEngineDelegate rtcEngine:connectionChangedToState:reason:]) callback and switches to the `CloudHubConnectionStateConnected` state.<br>
<br>
After the SDK joins the channel and when it finishes initializing the media engine, the SDK triggers the [didJoinChannel]([CloudHubRtcEngineDelegate rtcEngine:didJoinChannel:withUid:elapsed:]) callback.
*/
    CloudHubConnectionStateConnecting = 2,
    /** <p>3: The SDK is connected to CloudHub's edge server and joins a channel. You can now publish or subscribe to a media stream in the channel.</p>
If the connection to the channel is lost because, for example, the network is down or switched, the SDK automatically tries to reconnect and triggers:
<li> The [rtcEngineConnectionDidInterrupted]([CloudHubRtcEngineDelegate rtcEngineConnectionDidInterrupted:])(deprecated) callback
<li> The [connectionChangedToState]([CloudHubRtcEngineDelegate rtcEngine:connectionChangedToState:reason:]) callback, and switches to the `CloudHubConnectionStateReconnecting` state.
    */
    CloudHubConnectionStateConnected = 3,
    /** <p>4: The SDK keeps rejoining the channel after being disconnected from a joined channel because of network issues.</p>
<li>If the SDK cannot rejoin the channel within 10 seconds after being disconnected from CloudHub's edge server, the SDK triggers the [rtcEngineConnectionDidLost]([CloudHubRtcEngineDelegate rtcEngineConnectionDidLost:]) callback, stays in the `CloudHubConnectionStateReconnecting` state, and keeps rejoining the channel.
<li>If the SDK fails to rejoin the channel 20 minutes after being disconnected from CloudHub's edge server, the SDK triggers the [connectionChangedToState]([CloudHubRtcEngineDelegate rtcEngine:connectionChangedToState:reason:]) callback, switches to the `CloudHubConnectionStateFailed` state, and stops rejoining the channel.
    */
    CloudHubConnectionStateReconnecting = 4,
    /** <p>5: The SDK fails to connect to CloudHub's edge server or join the channel.</p>
You must call [leaveChannel]([CloudHubRtcEngineKit leaveChannel:]) to leave this state, and call [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) again to rejoin the channel.<br>
<br>
If the SDK is banned from joining the channel by CloudHub's edge server (through the RESTful API), the SDK triggers the [rtcEngineConnectionDidBanned]([CloudHubRtcEngineDelegate rtcEngineConnectionDidBanned:])(deprecated) and [connectionChangedToState]([CloudHubRtcEngineDelegate rtcEngine:connectionChangedToState:reason:]) callbacks.
    */
    CloudHubConnectionStateFailed = 5,
};

/** Reasons for the connection state change. */
typedef NS_ENUM(NSUInteger, CloudHubConnectionChangedReason) {
    /** 0: The SDK is connecting to CloudHub's edge server. */
    CloudHubConnectionChangedConnecting = 0,
    /** 1: The SDK has joined the channel successfully. */
    CloudHubConnectionChangedJoinSuccess = 1,
    /** 2: The connection between the SDK and CloudHub's edge server is interrupted.  */
    CloudHubConnectionChangedInterrupted = 2,
    /** 3: The connection between the SDK and CloudHub's edge server is banned by CloudHub's edge server. */
    CloudHubConnectionChangedBannedByServer = 3,
    /** 4: The SDK fails to join the channel for more than 20 minutes and stops reconnecting to the channel. */
    CloudHubConnectionChangedJoinFailed = 4,
    /** 5: The SDK has left the channel. */
    CloudHubConnectionChangedLeaveChannel = 5,
    /** 6: The specified App ID is invalid. Try to rejoin the channel with a valid App ID. */
    CloudHubConnectionChangedInvalidAppId = 6,
    /** 7: The specified channel name is invalid. Try to rejoin the channel with a valid channel name. */
    CloudHubConnectionChangedInvalidChannelName = 7,
    /** 8: The generated token is invalid probably due to the following reasons:
<li>The App Certificate for the project is enabled in Console, but you do not use Token when joining the channel. If you enable the App Certificate, you must use a token to join the channel.
<li>The uid that you specify in the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method is different from the uid that you pass for generating the token. */
    CloudHubConnectionChangedInvalidToken = 8,
    /** 9: The token has expired. Generate a new token from your server. */
    CloudHubConnectionChangedTokenExpired = 9,
    /** 10: The user is banned by the server. */
    CloudHubConnectionChangedRejectedByServer = 10,
    /** 11: The SDK tries to reconnect after setting a proxy server. */
    CloudHubConnectionChangedSettingProxyServer = 11,
    /** 12: The token renews. */
    CloudHubConnectionChangedRenewToken = 12,
    /** 13: The client IP address has changed, probably due to a change of the network type, IP address, or network port. */
    CloudHubConnectionChangedClientIpAddressChanged = 13,
    /** 14: Timeout for the keep-alive of the connection between the SDK and CloudHub's edge server. The connection state changes to CloudHubConnectionStateReconnecting(4). */
    CloudHubConnectionChangedKeepAliveTimeout = 14,
};

/** The state of the local video stream. */
typedef NS_ENUM(NSInteger, CloudHubLocalVideoStreamState) {
  /** 0: the local video is in the initial state. */
  CloudHubLocalVideoStreamStateStopped = 0,
  /** 1: the local video capturer starts successfully. */
  CloudHubLocalVideoStreamStateCapturing = 1,
  /** 2: the first local video frame encodes successfully. */
  CloudHubLocalVideoStreamStateEncoding = 2,
  /** 3: the local video fails to start. */
  CloudHubLocalVideoStreamStateFailed = 3,
};

/** The detailed error information of the local video. */
typedef NS_ENUM(NSInteger, CloudHubLocalVideoStreamError) {
  /** 0: the local video is normal. */
  CloudHubLocalVideoStreamErrorOK = 0,
  /** 1: no specified reason for the local video failure. */
  CloudHubLocalVideoStreamErrorFailure = 1,
  /** 2: no permission to use the local video device. */
  CloudHubLocalVideoStreamErrorDeviceNoPermission = 2,
  /** 3: the local video capturer is in use. */
  CloudHubLocalVideoStreamErrorDeviceBusy = 3,
  /** 4: the local video capture fails. Check whether the capturer is working properly. */
  CloudHubLocalVideoStreamErrorCaptureFailure = 4,
  /** 5: the local video encoding fails. */
  CloudHubLocalVideoStreamErrorEncodeFailure = 5,
};

typedef NS_ENUM(NSInteger, CloudHubStreamInjectStatus) {
    /** 0: The external video stream imported successfully. */
    CloudHub_INJECT_STREAM_STATUS_START_SUCCESS = 0,
    /** 1: The external video stream already exists. */
    CloudHub_INJECT_STREAM_STATUS_START_ALREADY_EXISTS = 1,
    /** 2: Import external video stream timeout. */
    CloudHub_INJECT_STREAM_STATUS_START_TIMEDOUT = 2,
    /** 3: Import external video stream failed. */
    CloudHub_INJECT_STREAM_STATUS_START_FAILED = 3,
    /** 4: The external video stream stopped importing successfully. */
    CloudHub_INJECT_STREAM_STATUS_STOP_SUCCESS = 4,
    /** 5: No external video stream is found. */
    CloudHub_INJECT_STREAM_STATUS_STOP_NOT_FOUND = 5,
    /** 6: Stop importing external video stream timeout. */
    CloudHub_INJECT_STREAM_STATUS_STOP_TIMEDOUT = 6,
    /** 7: Stop importing external video stream failed. */
    CloudHub_INJECT_STREAM_STATUS_STOP_FAILED = 7,
    /** 8: The external video stream is corrupted. */
    CloudHub_INJECT_STREAM_STATUS_BROKEN = 8,
    /** 9: The external video stream is paused. */
    CloudHub_INJECT_STREAM_STATUS_PAUSE = 9,
    /** 10: The external video stream is resumed. */
    CloudHub_INJECT_STREAM_STATUS_RESUME = 10
};

typedef NS_ENUM(NSInteger, CloudHubMediaType) {
    CloudHub_MEDIA_TYPE_AUDIO_ONLY = 1,
    CloudHub_MEDIA_TYPE_AUDIO_AND_VIDEO = 3,
    CloudHub_MEDIA_TYPE_ONLINE_MOVIE_VIDEO = 4,
    CloudHub_MEDIA_TYPE_OFFLINE_MOVIE_VIDEO = 5,
    CloudHub_MEDIA_TYPE_SCREEN_VIDEO = 6,
};

typedef NS_ENUM(NSInteger, CloudHubNetworkQuality) {
     /** 0: The network quality is unknown. */
     CloudHub_QUALITY_UNKNOWN = 0,
     /**  1: The network quality is excellent. */
     CloudHub_QUALITY_EXCELLENT = 1,
     /** 2: The network quality is quite good, but the bitrate may be slightly
        lower than excellent. */
     CloudHub_QUALITY_GOOD = 2,
     /** 3: Users can feel the communication slightly impaired. */
     CloudHub_QUALITY_POOR = 3,
     /** 4: Users cannot communicate smoothly. */
     CloudHub_QUALITY_BAD = 4,
     /** 5: The network is so bad that users can barely communicate. */
     CloudHub_QUALITY_VBAD = 5,
     /** 6: The network is down and users cannot communicate at all. */
     CloudHub_QUALITY_DOWN = 6,
     /** 7: Users cannot detect the network quality. (Not in use.) */
     CloudHub_QUALITY_UNSUPPORTED = 7,
     /** 8: Detecting the network quality. */
     CloudHub_QUALITY_DETECTING = 8,
};

typedef NS_ENUM(NSInteger, CloudHubRecordingState) {
    /** 0: Not recording. */
    CloudHub_RECORDING_STATE_NONE = 0,
    /** 1: Recording. */
    CloudHub_RECORDING_STATE_STARTED = 1,
    /** 2: Paused. */
    CloudHub_RECORDING_STATE_PAUSED = 2,
};

/** Video codec profile types. */
typedef NS_ENUM(NSInteger, CloudHubVideoCodecProfile) {
  /** 66: Baseline video codec profile. Generally used in video calls on mobile
     phones. */
  CloudHub_VIDEO_CODEC_PROFILE_BASELINE = 66,
  /** 77: Main video codec profile. Generally used in mainstream electronics
     such as MP4 players, portable video players, PSP, and iPads. */
  CloudHub_VIDEO_CODEC_PROFILE_MAIN = 77,
  /** 100: (Default) High video codec profile. Generally used in high-resolution
     broadcasts or television. */
  CloudHub_VIDEO_CODEC_PROFILE_HIGH = 100,
};

typedef NS_ENUM(NSInteger, CloudHubAudioSampleRate) {
    /** 32000: 32 kHz */
    CloudHub_AUDIO_SAMPLE_RATE_32000 = 32000,
    /** 44100: 44.1 kHz */
    CloudHub_AUDIO_SAMPLE_RATE_44100 = 44100,
    /** 48000: 48 kHz */
    CloudHub_AUDIO_SAMPLE_RATE_48000 = 48000,
};

typedef NS_ENUM(NSInteger, CloudHubLastmileProbeResultState) {
    /** 1: The last-mile network probe test is complete. */
    CloudHub_LASTMILE_PROBE_RESULT_COMPLETE = 1,
    /** 2: The last-mile network probe test is incomplete and the bandwidth
       estimation is not available, probably due to limited test resources. */
    CloudHub_LASTMILE_PROBE_RESULT_INCOMPLETE_NO_BWE = 2,
    /** 3: The last-mile network probe test is not carried out, probably due to
       poor network conditions. */
    CloudHub_LASTMILE_PROBE_RESULT_UNAVAILABLE = 3
};

/**
  Permission Types.
 */
typedef NS_ENUM(NSInteger, CloudHubPermissionType) {
  /** The user's publish permission. This determins whether the user can publish
   * his/her own audio/video stream to others or not.
   */
  CloudHub_PERMISSION_TYPE_PUBLISH = 1,
  /** The user's subscribe permission. This determins whether the user can see/hear
   * other user's audio/video or not.
   */
  CloudHub_PERMISSION_TYPE_SUBSCRIBE = 2,
};

/** The state code in channel media relay. */
typedef NS_ENUM(NSInteger, CloudHubMediaRelayState) {
  /** 0: The SDK is initializing.
   */
  CloudHub_RELAY_STATE_IDLE = 0,
  /** 1: The SDK tries to relay the media stream to the destination channel.
   */
  CloudHub_RELAY_STATE_CONNECTING = 1,
  /** 2: The SDK successfully relays the media stream to the destination
   * channel.
   */
  CloudHub_RELAY_STATE_RUNNING = 2,
  /** 3: A failure occurs. See the details in code.
   */
  CloudHub_RELAY_STATE_FAILURE = 3,
};

/** The error code in channel media relay. */
typedef NS_ENUM(NSInteger, CloudHubMediaRelayError) {
  /** 0: The state is normal.
   */
  CloudHub_RELAY_OK = 0,
  /** 1: An error occurs in the server response.
   */
  CloudHub_RELAY_ERROR_SERVER_ERROR_RESPONSE = 1,
  /** 2: No server response. You can call "leaveChannel" method to leave the channel.
   */
  CloudHub_RELAY_ERROR_SERVER_NO_RESPONSE = 2,
  /** 3: The SDK fails to access the service, probably due to limited
   * resources of the server.
   */
  CloudHub_RELAY_ERROR_NO_RESOURCE_AVAILABLE = 3,
  /** 4: Fails to send the relay request.
   */
  CloudHub_RELAY_ERROR_FAILED_JOIN_SRC = 4,
  /** 5: Fails to accept the relay request.
   */
  CloudHub_RELAY_ERROR_FAILED_JOIN_DEST = 5,
  /** 6: The server fails to receive the media stream.
   */
  CloudHub_RELAY_ERROR_FAILED_PACKET_RECEIVED_FROM_SRC = 6,
  /** 7: The server fails to send the media stream.
   */
  CloudHub_RELAY_ERROR_FAILED_PACKET_SENT_TO_DEST = 7,
  /** 8: The SDK disconnects from the server due to poor network
   * connections. You can call "leaveChannel" method to leave the channel.
   */
  CloudHub_RELAY_ERROR_SERVER_CONNECTION_LOST = 8,
  /** 9: An internal error occurs in the server.
   */
  CloudHub_RELAY_ERROR_INTERNAL_ERROR = 9,
  /** 10: The token of the source channel has expired.
   */
  CloudHub_RELAY_ERROR_SRC_TOKEN_EXPIRED = 10,
  /** 11: The token of the destination channel has expired.
   */
  CloudHub_RELAY_ERROR_DEST_TOKEN_EXPIRED = 11,
};

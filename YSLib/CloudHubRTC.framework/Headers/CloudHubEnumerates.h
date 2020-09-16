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
    /** 9: No permission exists. Check if the user has granted access to the audio or video device. */
    CloudHubErrorCodeNoPermission = 9,
    /** 10: An API method timeout occurs. Some API methods require the SDK to return the execution result, and this error occurs if the request takes too long (over 10 seconds) for the SDK to process. */
    CloudHubErrorCodeTimedOut = 10,
    /** 11: The request is canceled. This is for internal SDK use only, and is not returned to the app through any method or callback. */
    CloudHubErrorCodeCanceled = 11,
    /** 12: The method is called too often. This is for internal SDK use only, and is not returned to the app through any method or callback. */
    CloudHubErrorCodeTooOften = 12,
    /** 13: The SDK fails to bind to the network socket. This is for internal SDK use only, and is not returned to the app through any method or callback. */
    CloudHubErrorCodeBindSocket = 13,
    /** 14: The network is unavailable. This is for internal SDK use only, and is not returned to the app through any method or callback. */
    CloudHubErrorCodeNetDown = 14,
    /** 15: No network buffers are available. This is for internal SDK use only, and is not returned to the app through any method or callback. */
    CloudHubErrorCodeNoBufs = 15,
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
    /** 19: The resources are occupied and cannot be used. */
    CloudHubErrorCodeAlreadyInUse = 19,
    /** 20: The SDK gave up the request due to too many requests.  */
    CloudHubErrorCodeAbort = 20,
    /** 21: In Windows, specific firewall settings cause the SDK to fail to initialize and crash. */
    CloudHubErrorCodeInitNetEngine = 21,
    /** 22: The app uses too much of the system resources and the SDK fails to allocate the resources. */
    CloudHubErrorCodeResourceLimited = 22,
    /** 101: The specified App ID is invalid. Please try to rejoin the channel with a valid App ID.*/
    CloudHubErrorCodeInvalidAppId = 101,
    /** 102: The specified channel name is invalid. Please try to rejoin the channel with a valid channel name. */
    CloudHubErrorCodeInvalidChannelId = 102,
    /** 109: The token expired.
     <br></br><b>DEPRECATED</b> as of v2.4.1. Use CloudHubConnectionChangedTokenExpired(9) in the `reason` parameter of [connectionChangedToState]([CloudHubRtcEngineDelegate rtcEngine:connectionChangedToState:reason:]).
     <p>Possible reasons are:
     <ul><li>Authorized Timestamp expired: The timestamp is represented by the number of seconds elapsed since 1/1/1970. The user can use the token to access the CloudHub service within five minutes after the token is generated. If the user does not access the CloudHub service after five minutes, this token is no longer valid.</li>
     <li>Call Expiration Timestamp expired: The timestamp is the exact time when a user can no longer use the CloudHub service (for example, when a user is forced to leave an ongoing call). When a value is set for the Call Expiration Timestamp, it does not mean that the token will expire, but that the user will be banned from the channel.</li></ul></p>
     */
    CloudHubErrorCodeTokenExpired = 109,
    /** 110: The token is invalid.
<br></br><b>DEPRECATED</b> as of v2.4.1. Use CloudHubConnectionChangedInvalidToken(8) in the `reason` parameter of [connectionChangedToState]([CloudHubRtcEngineDelegate rtcEngine:connectionChangedToState:reason:]).
     <p>Possible reasons are:
     <ul><li>The App Certificate for the project is enabled in Console, but the user is using the App ID. Once the App Certificate is enabled, the user must use a token.</li>
     <li>The uid is mandatory, and users must set the same uid as the one set in the [joinChannelByToken]([CloudHubRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) method.</li></ul></p>
     */
    CloudHubErrorCodeInvalidToken = 110,
    /** 111: The Internet connection is interrupted. This applies to the CloudHub Web SDK only. */
    CloudHubErrorCodeConnectionInterrupted = 111,
    /** 112: The Internet connection is lost. This applies to the CloudHub Web SDK only. */
    CloudHubErrorCodeConnectionLost = 112,
    /** 113: The user is not in the channel when calling the [sendStreamMessage]([CloudHubRtcEngineKit sendStreamMessage:data:]) or [getUserInfoByUserAccount]([CloudHubRtcEngineKit getUserInfoByUserAccount:withError:]) method. */
    CloudHubErrorCodeNotInChannel = 113,
    /** 114: The size of the sent data is over 1024 bytes when the user calls the [sendStreamMessage]([CloudHubRtcEngineKit sendStreamMessage:data:]) method. */
    CloudHubErrorCodeSizeTooLarge = 114,
    /** 115: The bitrate of the sent data exceeds the limit of 6 Kbps when the user calls the [sendStreamMessage]([CloudHubRtcEngineKit sendStreamMessage:data:]) method. */
    CloudHubErrorCodeBitrateLimit = 115,
    /** 116: Too many data streams (over five streams) are created when the user calls the [createDataStream]([CloudHubRtcEngineKit createDataStream:reliable:ordered:]) method. */
    CloudHubErrorCodeTooManyDataStreams = 116,
    /** 120: Decryption fails. The user may have used a different encryption password to join the channel. Check your settings or try rejoining the channel. */
    CloudHubErrorCodeDecryptionFailed = 120,
    /** 124: Incorrect watermark file parameter. */
    CloudHubErrorCodeWatermarkParam = 124,
    /** 125: Incorrect watermark file path. */
    CloudHubErrorCodeWatermarkPath = 125,
    /** 126: Incorrect watermark file format. */
    CloudHubErrorCodeWatermarkPng = 126,
    /** 127: Incorrect watermark file information. */
    CloudHubErrorCodeWatermarkInfo = 127,
    /** 128: Incorrect watermark file data format. */
    CloudHubErrorCodeWatermarkAGRB = 128,
    /** 129: An error occurs in reading the watermark file. */
    CloudHubErrorCodeWatermarkRead = 129,
    /** 130: The encrypted stream is not allowed to publish. */
    CloudHubErrorCodeEncryptedStreamNotAllowedPublish = 130,
    /** 134: The user account is invalid. */
    CloudHubErrorCodeInvalidUserAccount = 134,

    /** 151: CDN related errors. Remove the original URL address and add a new one by calling the [removePublishStreamUrl]([CloudHubRtcEngineKit removePublishStreamUrl:]) and [addPublishStreamUrl]([CloudHubRtcEngineKit addPublishStreamUrl:transcodingEnabled:]) methods. */
    CloudHubErrorCodePublishStreamCDNError = 151,
    /** 152: The host publishes more than 10 URLs. Delete the unnecessary URLs before adding new ones. */
    CloudHubErrorCodePublishStreamNumReachLimit = 152,
    /** 153: The host manipulates other hosts' URLs. Check your app logic. */
    CloudHubErrorCodePublishStreamNotAuthorized = 153,
    /** 154: An error occurs in CloudHub's streaming server. Call the [addPublishStreamUrl]([CloudHubRtcEngineKit addPublishStreamUrl:transcodingEnabled:]) method to publish the stream again. */
    CloudHubErrorCodePublishStreamInternalServerError = 154,
    /** 155: The server fails to find the stream. */
    CloudHubErrorCodePublishStreamNotFound = 155,
    /** 156: The format of the RTMP stream URL is not supported. Check whether the URL format is correct. */
    CloudHubErrorCodePublishStreamFormatNotSuppported = 156,

    /** 1001: Fails to load the media engine. */
    CloudHubErrorCodeLoadMediaEngine = 1001,
    /** 1002: Fails to start the call after enabling the media engine. */
    CloudHubErrorCodeStartCall = 1002,
    /** 1003: Fails to start the camera.
     <br></br><b>DEPRECATED</b> as of v2.4.1. Use CloudHubLocalVideoStreamErrorCaptureFailure(4) in the `error` parameter of [connectionChangedToState]([CloudHubRtcEngineDelegate rtcEngine:connectionChangedToState:reason:]).
     */
    CloudHubErrorCodeStartCamera = 1003,
    /** 1004: Fails to start the video rendering module. */
    CloudHubErrorCodeStartVideoRender = 1004,
    /** 1005: A general error occurs in the Audio Device Module (the reason is not classified specifically). Check if the audio device is used by another app, or try rejoining the channel. */
    CloudHubErrorCodeAdmGeneralError = 1005,
    /** 1006: Audio Device Module: An error occurs in using the Java resources. */
    CloudHubErrorCodeAdmJavaResource = 1006,
    /** 1007: Audio Device Module: An error occurs in setting the sampling frequency. */
    CloudHubErrorCodeAdmSampleRate = 1007,
    /** 1008: Audio Device Module: An error occurs in initializing the playback device. */
    CloudHubErrorCodeAdmInitPlayout = 1008,
    /** 1009: Audio Device Module: An error occurs in starting the playback device. */
    CloudHubErrorCodeAdmStartPlayout = 1009,
    /** 1010: Audio Device Module: An error occurs in stopping the playback device. */
    CloudHubErrorCodeAdmStopPlayout = 1010,
    /** 1011: Audio Device Module: An error occurs in initializing the recording device. */
    CloudHubErrorCodeAdmInitRecording = 1011,
    /** 1012: Audio Device Module: An error occurs in starting the recording device. */
    CloudHubErrorCodeAdmStartRecording = 1012,
    /** 1013: Audio Device Module: An error occurs in stopping the recording device. */
    CloudHubErrorCodeAdmStopRecording = 1013,
    /** 1015: Audio Device Module: A playback error occurs. Check your playback device, or try rejoining the channel. */
    CloudHubErrorCodeAdmRuntimePlayoutError = 1015,
    /** 1017: Audio Device Module: A recording error occurs. */
    CloudHubErrorCodeAdmRuntimeRecordingError = 1017,
    /** 1018: Audio Device Module: Fails to record. */
    CloudHubErrorCodeAdmRecordAudioFailed = 1018,
    /** 1020: Audio Device Module: Abnormal audio playback frequency. */
    CloudHubErrorCodeAdmPlayAbnormalFrequency = 1020,
    /** 1021: Audio Device Module: Abnormal audio recording frequency. */
    CloudHubErrorCodeAdmRecordAbnormalFrequency = 1021,
    /** 1022: Audio Device Module: An error occurs in initializing the loopback device. */
    CloudHubErrorCodeAdmInitLoopback  = 1022,
    /** 1023: Audio Device Module: An error occurs in starting the loopback device. */
    CloudHubErrorCodeAdmStartLoopback = 1023,
    /** 1027: Audio Device Module: An error occurs in no recording Permission. */
    CloudHubErrorCodeAdmNoPermission = 1027,
    /** 1359: No recording device exists. */
    CloudHubErrorCodeAdmNoRecordingDevice = 1359,
    /** 1360: No playback device exists. */
    CloudHubErrorCodeAdmNoPlayoutDevice = 1360,
    /** 1501: Video Device Module: The camera is unauthorized. */
    CloudHubErrorCodeVdmCameraNotAuthorized = 1501,
    /** 1600: Video Device Module: An unknown error occurs. */
    CloudHubErrorCodeVcmUnknownError = 1600,
    /** 1601: Video Device Module: An error occurs in initializing the video encoder. */
    CloudHubErrorCodeVcmEncoderInitError = 1601,
    /** 1602: Video Device Module: An error occurs in video encoding. */
    CloudHubErrorCodeVcmEncoderEncodeError = 1602,
    /** 1603: Video Device Module: An error occurs in setting the video encoder.
    <p><b>DEPRECATED</b></p>
    */
    CloudHubErrorCodeVcmEncoderSetError = 1603,
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

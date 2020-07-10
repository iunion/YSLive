//
// CloudHubEnumerates.h
// CloudHubRtcEngineKit
//
//  Copyright (c) 2020 CloudHub. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Warning code.

Warning codes occur when the SDK encounters an error that may be recovered automatically. These are only notifications, and can generally be ignored. For example, when the SDK loses connection to the server, the SDK reports the CloudHubWarningCodeOpenChannelTimeout(106) warning and tries to reconnect automatically.
*/
typedef NS_ENUM(NSInteger, CloudHubWarningCode) {
    /** 8: The specified view is invalid. Specify a view when using the video call function. */
    CloudHubWarningCodeInvalidView = 8,
    /** 16: Failed to initialize the video function, possibly caused by a lack of resources. The users cannot see the video while the voice communication is not affected. */
    CloudHubWarningCodeInitVideo = 16,
     /** 20: The request is pending, usually due to some module not being ready, and the SDK postpones processing the request. */
    CloudHubWarningCodePending = 20,
    /** 103: No channel resources are available. Maybe because the server cannot allocate any channel resource. */
    CloudHubWarningCodeNoAvailableChannel = 103,
    /** 104: A timeout occurs when looking up the channel. When joining a channel, the SDK looks up the specified channel. The warning usually occurs when the network condition is too poor for the SDK to connect to the server. */
    CloudHubWarningCodeLookupChannelTimeout = 104,
    /** 105: The server rejects the request to look up the channel. The server cannot process this request or the request is illegal.
     <br></br><b>DEPRECATED</b> as of v2.4.1. Use CloudHubConnectionChangedRejectedByServer(10) in the `reason` parameter of [connectionChangedToState]([CloudHubRtcEngineDelegate rtcEngine:connectionChangedToState:reason:]).
     */
    CloudHubWarningCodeLookupChannelRejected = 105,
    /** 106: The server rejects the request to look up the channel. The server cannot process this request or the request is illegal. */
    CloudHubWarningCodeOpenChannelTimeout = 106,
    /** 107: The server rejects the request to open the channel. The server cannot process this request or the request is illegal. */
    CloudHubWarningCodeOpenChannelRejected = 107,
    /** 111: A timeout occurs when switching to the live video. */
    CloudHubWarningCodeSwitchLiveVideoTimeout = 111,
    /** 118: A timeout occurs when setting the client role in the live broadcast profile. */
    CloudHubWarningCodeSetClientRoleTimeout = 118,
    /** 119: The client role is unauthorized. */
    CloudHubWarningCodeSetClientRoleNotAuthorized = 119,
    /** 121: The ticket to open the channel is invalid. */
    CloudHubWarningCodeOpenChannelInvalidTicket = 121,
    /** 122: Try connecting to another server. */
    CloudHubWarningCodeOpenChannelTryNextVos = 122,
    /** 701: An error occurs in opening the audio mixing file. */
    CloudHubWarningCodeAudioMixingOpenError = 701,
    /** 1014: Audio Device Module: a warning occurs in the playback device. */
    CloudHubWarningCodeAdmRuntimePlayoutWarning = 1014,
    /** 1016: Audio Device Module: a warning occurs in the recording device. */
    CloudHubWarningCodeAdmRuntimeRecordingWarning = 1016,
    /** 1019: Audio Device Module: no valid audio data is collected. */
    CloudHubWarningCodeAdmRecordAudioSilence = 1019,
    /** 1020: Audio Device Module: a playback device fails. */
    CloudHubWarningCodeAdmPlaybackMalfunction = 1020,
    /** 1021: Audio Device Module: a recording device fails. */
    CloudHubWarningCodeAdmRecordMalfunction = 1021,
    /** 1025: Call is interrupted by system events such as phone call or siri etc. */
    CloudHubWarningCodeAdmInterruption = 1025,
    /** 1031: Audio Device Module: the recorded audio is too low. */
    CloudHubWarningCodeAdmRecordAudioLowlevel = 1031,
    /** 1032: Audio Device Module: the playback audio is too low. */
    CloudHubWarningCodeAdmPlayoutAudioLowlevel = 1032,
    /** 1051: Audio Device Module: howling is detected. */
    CloudHubWarningCodeApmHowling = 1051,
    /** 1052: Audio Device Module: the device is in the glitch state. */
    CloudHubWarningCodeAdmGlitchState = 1052,
    /** 1053: Audio Device Module: the underlying audio settings have changed. */
    CloudHubWarningCodeAdmImproperSettings = 1053,
};

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

/** Video profile.

**DEPRECATED**

Please use CloudHubVideoEncoderConfiguration.

iPhones do not support resolutions above 720p.
*/
typedef NS_ENUM(NSInteger, CloudHubVideoProfile) {
    /** Invalid profile. */
    CloudHubVideoProfileInvalid = -1,
    /** Resolution 160 &times; 120, frame rate 15 fps, bitrate 65 Kbps. */
    CloudHubVideoProfileLandscape120P = 0,
    /** (iOS only) Resolution 120 &times; 120, frame rate 15 fps, bitrate 50 Kbps. */
    CloudHubVideoProfileLandscape120P_3 = 2,
    /** (iOS only) Resolution 320 &times; 180, frame rate 15 fps, bitrate 140 Kbps. */
    CloudHubVideoProfileLandscape180P = 10,
    /** (iOS only) Resolution 180 &times; 180, frame rate 15 fps, bitrate 100 Kbps. */
    CloudHubVideoProfileLandscape180P_3 = 12,
    /** Resolution 240 &times; 180, frame rate 15 fps, bitrate 120 Kbps. */
    CloudHubVideoProfileLandscape180P_4 = 13,
    /** Resolution 320 &times; 240, frame rate 15 fps, bitrate 200 Kbps. */
    CloudHubVideoProfileLandscape240P = 20,
    /** (iOS only) Resolution 240 &times; 240, frame rate 15 fps, bitrate 140 Kbps. */
    CloudHubVideoProfileLandscape240P_3 = 22,
    /** Resolution 424 &times; 240, frame rate 15 fps, bitrate 220 Kbps. */
    CloudHubVideoProfileLandscape240P_4 = 23,
    /** Resolution 640 &times; 360, frame rate 15 fps, bitrate 400 Kbps. */
    CloudHubVideoProfileLandscape360P = 30,
    /** (iOS only) Resolution 360 &times; 360, frame rate 15 fps, bitrate 260 Kbps. */
    CloudHubVideoProfileLandscape360P_3 = 32,
    /** Resolution 640 &times; 360, frame rate 30 fps, bitrate 600 Kbps. */
    CloudHubVideoProfileLandscape360P_4 = 33,
    /** Resolution 360 &times; 360, frame rate 30 fps, bitrate 400 Kbps. */
    CloudHubVideoProfileLandscape360P_6 = 35,
    /** Resolution 480 &times; 360, frame rate 15 fps, bitrate 320 Kbps. */
    CloudHubVideoProfileLandscape360P_7 = 36,
    /** Resolution 480 &times; 360, frame rate 30 fps, bitrate 490 Kbps. */
    CloudHubVideoProfileLandscape360P_8 = 37,
    /** Resolution 640 &times; 360, frame rate 15 fps, bitrate 800 Kbps.
    <br>
     <b>Note:</b> This profile applies to the live broadcast channel profile only.
     */
    CloudHubVideoProfileLandscape360P_9 = 38,
    /** Resolution 640 &times; 360, frame rate 24 fps, bitrate 800 Kbps.
    <br>
     <b>Note:</b> This profile applies to the live broadcast channel profile only.
     */
    CloudHubVideoProfileLandscape360P_10 = 39,
    /** Resolution 640 &times; 360, frame rate 24 fps, bitrate 1000 Kbps.
    <br>
     <b>Note:</b> This profile applies to the live broadcast channel profile only.
     */
    CloudHubVideoProfileLandscape360P_11 = 100,
    /** Resolution 640 &times; 480, frame rate 15 fps, bitrate 500 Kbps. */
    CloudHubVideoProfileLandscape480P = 40,
    /** (iOS only) Resolution 480 &times; 480, frame rate 15 fps, bitrate 400 Kbps. */
    CloudHubVideoProfileLandscape480P_3 = 42,
    /** Resolution 640 &times; 480, frame rate 30 fps, bitrate 750 Kbps. */
    CloudHubVideoProfileLandscape480P_4 = 43,
    /** Resolution 480 &times; 480, frame rate 30 fps, bitrate 600 Kbps. */
    CloudHubVideoProfileLandscape480P_6 = 45,
    /** Resolution 848 &times; 480, frame rate 15 fps, bitrate 610 Kbps. */
    CloudHubVideoProfileLandscape480P_8 = 47,
    /** Resolution 848 &times; 480, frame rate 30 fps, bitrate 930 Kbps. */
    CloudHubVideoProfileLandscape480P_9 = 48,
    /** Resolution 640 &times; 480, frame rate 10 fps, bitrate 400 Kbps. */
    CloudHubVideoProfileLandscape480P_10 = 49,
    /** Resolution 1280 &times; 720, frame rate 15 fps, bitrate 1130 Kbps. */
    CloudHubVideoProfileLandscape720P = 50,
    /** Resolution 1280 &times; 720, frame rate 30 fps, bitrate 1710 Kbps. */
    CloudHubVideoProfileLandscape720P_3 = 52,
    /** Resolution 960 &times; 720, frame rate 15 fps, bitrate 910 Kbps. */
    CloudHubVideoProfileLandscape720P_5 = 54,
    /** Resolution 960 &times; 720, frame rate 30 fps, bitrate 1380 Kbps. */
    CloudHubVideoProfileLandscape720P_6 = 55,
    /** (macOS only) Resolution 1920 &times; 1080, frame rate 15 fps, bitrate 2080 Kbps. */
    CloudHubVideoProfileLandscape1080P = 60,
    /** (macOS only) Resolution 1920 &times; 1080, frame rate 30 fps, bitrate 3150 Kbps. */
    CloudHubVideoProfileLandscape1080P_3 = 62,
    /** (macOS only) Resolution 1920 &times; 1080, frame rate 60 fps, bitrate 4780 Kbps. */
    CloudHubVideoProfileLandscape1080P_5 = 64,
    /** (macOS only) Resolution 2560 &times; 1440, frame rate 30 fps, bitrate 4850 Kbps. */
    CloudHubVideoProfileLandscape1440P = 66,
    /** (macOS only) Resolution 2560 &times; 1440, frame rate 60 fps, bitrate 6500 Kbps. */
    CloudHubVideoProfileLandscape1440P_2 = 67,
    /** (macOS only) Resolution 3840 &times; 2160, frame rate 30 fps, bitrate 6500 Kbps. */
    CloudHubVideoProfileLandscape4K = 70,
    /** (macOS only) Resolution 3840 &times; 2160, frame rate 60 fps, bitrate 6500 Kbps. */
    CloudHubVideoProfileLandscape4K_3 = 72,

    /** Resolution 120 &times; 160, frame rate 15 fps, bitrate 65 Kbps. */
    CloudHubVideoProfilePortrait120P = 1000,
    /** (iOS only) Resolution 120 &times; 120, frame rate 15 fps, bitrate 50 Kbps. */
    CloudHubVideoProfilePortrait120P_3 = 1002,
    /** (iOS only) Resolution 180 &times; 320, frame rate 15 fps, bitrate 140 Kbps. */
    CloudHubVideoProfilePortrait180P = 1010,
    /** (iOS only) Resolution 180 &times; 180, frame rate 15 fps, bitrate 100 Kbps. */
    CloudHubVideoProfilePortrait180P_3 = 1012,
    /** Resolution 180 &times; 240, frame rate 15 fps, bitrate 120 Kbps. */
    CloudHubVideoProfilePortrait180P_4 = 1013,
    /** Resolution 240 &times; 320, frame rate 15 fps, bitrate 200 Kbps. */
    CloudHubVideoProfilePortrait240P = 1020,
    /** (iOS only) Resolution 240 &times; 240, frame rate 15 fps, bitrate 140 Kbps. */
    CloudHubVideoProfilePortrait240P_3 = 1022,
    /** Resolution 240 &times; 424, frame rate 15 fps, bitrate 220 Kbps. */
    CloudHubVideoProfilePortrait240P_4 = 1023,
    /** Resolution 360 &times; 640, frame rate 15 fps, bitrate 400 Kbps. */
    CloudHubVideoProfilePortrait360P = 1030,
    /** (iOS only) Resolution 360 &times; 360, frame rate 15 fps, bitrate 260 Kbps. */
    CloudHubVideoProfilePortrait360P_3 = 1032,
    /** Resolution 360 &times; 640, frame rate 30 fps, bitrate 600 Kbps. */
    CloudHubVideoProfilePortrait360P_4 = 1033,
    /** Resolution 360 &times; 360, frame rate 30 fps, bitrate 400 Kbps. */
    CloudHubVideoProfilePortrait360P_6 = 1035,
    /** Resolution 360 &times; 480, frame rate 15 fps, bitrate 320 Kbps. */
    CloudHubVideoProfilePortrait360P_7 = 1036,
    /** Resolution 360 &times; 480, frame rate 30 fps, bitrate 490 Kbps. */
    CloudHubVideoProfilePortrait360P_8 = 1037,
    /** Resolution 360 &times; 640, frame rate 15 fps, bitrate 600 Kbps. */
    CloudHubVideoProfilePortrait360P_9 = 1038,
    /** Resolution 360 &times; 640, frame rate 24 fps, bitrate 800 Kbps. */
    CloudHubVideoProfilePortrait360P_10 = 1039,
    /** Resolution 360 &times; 640, frame rate 24 fps, bitrate 800 Kbps. */
    CloudHubVideoProfilePortrait360P_11 = 1100,
    /** Resolution 480 &times; 640, frame rate 15 fps, bitrate 500 Kbps. */
    CloudHubVideoProfilePortrait480P = 1040,
    /** (iOS only) Resolution 480 &times; 480, frame rate 15 fps, bitrate 400 Kbps. */
    CloudHubVideoProfilePortrait480P_3 = 1042,
    /** Resolution 480 &times; 640, frame rate 30 fps, bitrate 750 Kbps. */
    CloudHubVideoProfilePortrait480P_4 = 1043,
    /** Resolution 480 &times; 480, frame rate 30 fps, bitrate 600 Kbps. */
    CloudHubVideoProfilePortrait480P_6 = 1045,
    /** Resolution 480 &times; 848, frame rate 15 fps, bitrate 610 Kbps. */
    CloudHubVideoProfilePortrait480P_8 = 1047,
    /** Resolution 480 &times; 848, frame rate 30 fps, bitrate 930 Kbps. */
    CloudHubVideoProfilePortrait480P_9 = 1048,
    /** Resolution 480 &times; 640, frame rate 10 fps, bitrate 400 Kbps. */
    CloudHubVideoProfilePortrait480P_10 = 1049,
    /** Resolution 720 &times; 1280, frame rate 15 fps, bitrate 1130 Kbps. */
    CloudHubVideoProfilePortrait720P = 1050,
    /** Resolution 720 &times; 1280, frame rate 30 fps, bitrate 1710 Kbps. */
    CloudHubVideoProfilePortrait720P_3 = 1052,
    /** Resolution 720 &times; 960, frame rate 15 fps, bitrate 910 Kbps. */
    CloudHubVideoProfilePortrait720P_5 = 1054,
    /** Resolution 720 &times; 960, frame rate 30 fps, bitrate 1380 Kbps. */
    CloudHubVideoProfilePortrait720P_6 = 1055,
    /** (macOS only) Resolution 1080 &times; 1920, frame rate 15 fps, bitrate 2080 Kbps. */
    CloudHubVideoProfilePortrait1080P = 1060,
    /** (macOS only) Resolution 1080 &times; 1920, frame rate 30 fps, bitrate 3150 Kbps. */
    CloudHubVideoProfilePortrait1080P_3 = 1062,
    /** (macOS only) Resolution 1080 &times; 1920, frame rate 60 fps, bitrate 4780 Kbps. */
    CloudHubVideoProfilePortrait1080P_5 = 1064,
    /** (macOS only) Resolution 1440 &times; 2560, frame rate 30 fps, bitrate 4850 Kbps. */
    CloudHubVideoProfilePortrait1440P = 1066,
    /** (macOS only) Resolution 1440 &times; 2560, frame rate 60 fps, bitrate 6500 Kbps. */
    CloudHubVideoProfilePortrait1440P_2 = 1067,
    /** (macOS only) Resolution 2160 &times; 3840, frame rate 30 fps, bitrate 6500 Kbps. */
    CloudHubVideoProfilePortrait4K = 1070,
    /** (macOS only) Resolution 2160 &times; 3840, frame rate 60 fps, bitrate 6500 Kbps. */
    CloudHubVideoProfilePortrait4K_3 = 1072,
    /** (Default) Resolution 640 &times; 360, frame rate 15 fps, bitrate 400 Kbps. */
    CloudHubVideoProfileDEFAULT = CloudHubVideoProfileLandscape360P,
};

/** The camera capturer configuration. */
typedef NS_ENUM(NSInteger, CloudHubCameraCaptureOutputPreference) {
    /** (default) Self-adapts the camera output parameters to the system performance and network conditions to balance CPU consumption and video preview quality. */
    CloudHubCameraCaptureOutputPreferenceAuto = 0,
    /** Prioritizes the system performance. The SDK chooses the dimension and frame rate of the local camera capture closest to those set by [setVideoEncoderConfiguration]([CloudHubRtcEngineKit setVideoEncoderConfiguration:]). */
    CloudHubCameraCaptureOutputPreferencePerformance = 1,
    /** Prioritizes the local preview quality. The SDK chooses higher camera output parameters to improve the local video preview quality. This option requires extra CPU and RAM usage for video pre-processing. */
    CloudHubCameraCaptureOutputPreferencePreview = 2,
    /** Internal use only */
    CloudHubCameraCaptureOutputPreferenceUnkown = 3
};

#if TARGET_OS_IOS
/** The camera direction. */
typedef NS_ENUM(NSInteger, CloudHubCameraDirection) {
        /** The rear camera. */
        CloudHubCameraDirectionRear = 0,
        /** The front camera. */
        CloudHubCameraDirectionFront = 1,
    };
#endif

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
    /** 60 fps (macOS only). */
    CloudHubVideoFrameRateFps60 = 60,
};

/** Video output orientation mode.

  **Note:** When a custom video source is used, if you set CloudHubVideoOutputOrientationMode as CloudHubVideoOutputOrientationModeFixedLandscape(1) or CloudHubVideoOutputOrientationModeFixedPortrait(2), when the rotated video image has a different orientation than the specified output orientation, the video encoder first crops it and then encodes it.
 */
typedef NS_ENUM(NSInteger, CloudHubVideoOutputOrientationMode) {
    /** Adaptive mode (Default).
     <p>The video encoder adapts to the orientation mode of the video input device. When you use a custom video source, the output video from the encoder inherits the orientation of the original video.
     <ul><li>If the width of the captured video from the SDK is greater than the height, the encoder sends the video in landscape mode. The encoder also sends the rotational information of the video, and the receiver uses the rotational information to rotate the received video.</li>
     <li>If the original video is in portrait mode, the output video from the encoder is also in portrait mode. The encoder also sends the rotational information of the video to the receiver.</li></ul></p>
     */
    CloudHubVideoOutputOrientationModeAdaptative = 0,
    /** Landscape mode.
     <p>The video encoder always sends the video in landscape mode. The video encoder rotates the original video before sending it and the rotational information is 0. This mode applies to scenarios involving CDN live streaming.</p>
     */
    CloudHubVideoOutputOrientationModeFixedLandscape = 1,
     /** Portrait mode.
      <p>The video encoder always sends the video in portrait mode. The video encoder rotates the original video before sending it and the rotational information is 0. This mode applies to scenarios involving CDN live streaming.</p>
      */
    CloudHubVideoOutputOrientationModeFixedPortrait = 2,
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
    /** 2: The Gaming profile. 
     <p>This profile uses a codec with a lower bitrate and consumes less power. Applies to the gaming scenario, where all game players can talk freely.</p>
     */
    CloudHubChannelProfileGame = 2,
};

/** Client role in a live broadcast. */
typedef NS_ENUM(NSInteger, CloudHubClientRole) {
    /** Host. */
    CloudHubClientRoleBroadcaster = 1,
    /** Audience. */
    CloudHubClientRoleAudience = 2,
};

/** Encryption mode */
typedef NS_ENUM(NSInteger, CloudHubEncryptionMode) {
    /** When encryptionMode is set as NULL, the encryption mode is set as "aes-128-xts" by default. */
    CloudHubEncryptionModeNone = 0,
    /** (Default) 128-bit AES encryption, XTS mode. */
    CloudHubEncryptionModeAES128XTS = 1,
    /** 256-bit AES encryption, XTS mode. */
    CloudHubEncryptionModeAES256XTS = 2,
    /** 128-bit AES encryption, ECB mode. */
    CloudHubEncryptionModeAES128ECB = 3,
};

/** Reason for the user being offline. */
typedef NS_ENUM(NSUInteger, CloudHubUserOfflineReason) {
    /** The user left the current channel. */
    CloudHubUserOfflineReasonQuit = 0,
    /** The SDK timed out and the user dropped offline because no data packet is received within a certain period of time. If a user quits the call and the message is not passed to the SDK (due to an unreliable channel), the SDK assumes the user dropped offline. */
    CloudHubUserOfflineReasonDropped = 1,
    /** (Live broadcast only.) The client role switched from the host to the audience. */
    CloudHubUserOfflineReasonBecomeAudience = 2,
};

/** The RTMP streaming state. */
typedef NS_ENUM(NSUInteger, CloudHubRtmpStreamingState) {
  /** The RTMP streaming has not started or has ended. This state is also triggered after you remove an RTMP address from the CDN by calling removePublishStreamUrl.*/
  CloudHubRtmpStreamingStateIdle = 0,
  /** The SDK is connecting to CloudHub's streaming server and the RTMP server. This state is triggered after you call the [addPublishStreamUrl]([CloudHubRtcEngineKit addPublishStreamUrl:transcodingEnabled:]) method. */
  CloudHubRtmpStreamingStateConnecting = 1,
  /** The RTMP streaming is being published. The SDK successfully publishes the RTMP streaming and returns this state. */
  CloudHubRtmpStreamingStateRunning = 2,
  /** The RTMP streaming is recovering. When exceptions occur to the CDN, or the streaming is interrupted, the SDK attempts to resume RTMP streaming and returns this state.
<li> If the SDK successfully resumes the streaming, CloudHubRtmpStreamingStateRunning(2) returns.
<li> If the streaming does not resume within 60 seconds or server errors occur, CloudHubRtmpStreamingStateFailure(4) returns. You can also reconnect to the server by calling the [removePublishStreamUrl]([CloudHubRtcEngineKit removePublishStreamUrl:]) and [addPublishStreamUrl]([CloudHubRtcEngineKit addPublishStreamUrl:transcodingEnabled:]) methods. */
  CloudHubRtmpStreamingStateRecovering = 3,
  /** The RTMP streaming fails. See the errorCode parameter for the detailed error information. You can also call the [addPublishStreamUrl]([CloudHubRtcEngineKit addPublishStreamUrl:transcodingEnabled:]) method to publish the RTMP streaming again. */
  CloudHubRtmpStreamingStateFailure = 4,
};


enum RTMP_STREAM_PUBLISH_ERROR
{
  RTMP_STREAM_PUBLISH_ERROR_OK = 0,
  RTMP_STREAM_PUBLISH_ERROR_INVALID_ARGUMENT = 1,
  RTMP_STREAM_PUBLISH_ERROR_ENCRYPTED_STREAM_NOT_ALLOWED = 2,
  RTMP_STREAM_PUBLISH_ERROR_CONNECTION_TIMEOUT = 3,
  RTMP_STREAM_PUBLISH_ERROR_INTERNAL_SERVER_ERROR = 4,
  RTMP_STREAM_PUBLISH_ERROR_RTMP_SERVER_ERROR = 5,
  RTMP_STREAM_PUBLISH_ERROR_TOO_OFTEN = 6,
  RTMP_STREAM_PUBLISH_ERROR_REACH_LIMIT = 7,
  RTMP_STREAM_PUBLISH_ERROR_NOT_AUTHORIZED = 8,
  RTMP_STREAM_PUBLISH_ERROR_STREAM_NOT_FOUND = 9,
  RTMP_STREAM_PUBLISH_ERROR_FORMAT_NOT_SUPPORTED = 10,
};

/** The detailed error information for streaming. */
typedef NS_ENUM(NSUInteger, CloudHubRtmpStreamingErrorCode) {
  /** The RTMP streaming publishes successfully. */
  CloudHubRtmpStreamingErrorCodeOK = 0,
  /** Invalid argument used. If, for example, you do not call the [setLiveTranscoding]([CloudHubRtcEngineKit setLiveTranscoding:]) method to configure the LiveTranscoding parameters before calling the [addPublishStreamUrl]([CloudHubRtcEngineKit addPublishStreamUrl:transcodingEnabled:]) method, the SDK returns this error. Check whether you set the parameters in the setLiveTranscoding method properly. */
  CloudHubRtmpStreamingErrorCodeInvalidParameters = 1,
  /** The RTMP streaming is encrypted and cannot be published. */
  CloudHubRtmpStreamingErrorCodeEncryptedStreamNotAllowed = 2,
  /** Timeout for the RTMP streaming. Call the [addPublishStreamUrl]([CloudHubRtcEngineKit addPublishStreamUrl:transcodingEnabled:]) method to publish the streaming again. */
  CloudHubRtmpStreamingErrorCodeConnectionTimeout = 3,
  /** An error occurs in CloudHub's streaming server. Call the [addPublishStreamUrl]([CloudHubRtcEngineKit addPublishStreamUrl:transcodingEnabled:]) method to publish the streaming again. */
  CloudHubRtmpStreamingErrorCodeInternalServerError = 4,
  /** An error occurs in the RTMP server. */
  CloudHubRtmpStreamingErrorCodeRtmpServerError = 5,
  /** The RTMP streaming publishes too frequently. */
  CloudHubRtmpStreamingErrorCodeTooOften = 6,
  /** The host publishes more than 10 URLs. Delete the unnecessary URLs before adding new ones. */
  CloudHubRtmpStreamingErrorCodeReachLimit = 7,
  /** The host manipulates other hosts' URLs. Check your app logic. */
  CloudHubRtmpStreamingErrorCodeNotAuthorized = 8,
  /** CloudHub's server fails to find the RTMP streaming. */
  CloudHubRtmpStreamingErrorCodeStreamNotFound = 9,
  /** The format of the RTMP streaming URL is not supported. Check whether the URL format is correct. */
  CloudHubRtmpStreamingErrorCodeFormatNotSupported = 10,
};

/** State of importing an external video stream in a live broadcast. */
typedef NS_ENUM(NSUInteger, CloudHubInjectStreamStatus) {
    /** The external video stream imported successfully. */
    CloudHubInjectStreamStatusStartSuccess = 0,
    /** The external video stream already exists. */
    CloudHubInjectStreamStatusStartAlreadyExists = 1,
    /** The external video stream import is unauthorized. */
    CloudHubInjectStreamStatusStartUnauthorized = 2,
    /** Import external video stream timeout. */
    CloudHubInjectStreamStatusStartTimedout = 3,
    /** The external video stream failed to import. */
    CloudHubInjectStreamStatusStartFailed = 4,
    /** The external video stream imports successfully. */
    CloudHubInjectStreamStatusStopSuccess = 5,
    /** No external video stream is found. */
    CloudHubInjectStreamStatusStopNotFound = 6,
    /** The external video stream is stopped from being unauthorized. */
    CloudHubInjectStreamStatusStopUnauthorized = 7,
    /** Importing the external video stream timeout. */
    CloudHubInjectStreamStatusStopTimedout = 8,
    /** Importing the external video stream failed. */
    CloudHubInjectStreamStatusStopFailed = 9,
    /** The external video stream import is interrupted. */
    CloudHubInjectStreamStatusBroken = 10,
};

/** Output log filter level. */
typedef NS_ENUM(NSUInteger, CloudHubLogFilter) {
    /** Do not output any log information. */
    CloudHubLogFilterOff = 0,
    /** Output all log information. Set your log filter as debug if you want to get the most complete log file. */
    CloudHubLogFilterDebug = 0x080f,
    /** Output CRITICAL, ERROR, WARNING, and INFO level log information. We recommend setting your log filter as this level. */
    CloudHubLogFilterInfo = 0x000f,
    /** Outputs CRITICAL, ERROR, and WARNING level log information. */
    CloudHubLogFilterWarning = 0x000e,
    /** Outputs CRITICAL and ERROR level log information. */
    CloudHubLogFilterError = 0x000c,
    /** Outputs CRITICAL level log information. */
    CloudHubLogFilterCritical = 0x0008,
};

/** Audio recording quality. */
typedef NS_ENUM(NSInteger, CloudHubAudioRecordingQuality) {
   /** Low quality: The sample rate is 32 KHz, and the file size is around 1.2 MB after 10 minutes of recording. */
    CloudHubAudioRecordingQualityLow = 0,
    /** Medium quality: The sample rate is 32 KHz, and the file size is around 2 MB after 10 minutes of recording. */
    CloudHubAudioRecordingQualityMedium = 1,
    /** High quality: The sample rate is 32 KHz, and the file size is around 3.75 MB after 10 minutes of recording. */
    CloudHubAudioRecordingQualityHigh = 2
};

/** Lifecycle of the CDN live video stream.

**DEPRECATED**
*/
typedef NS_ENUM(NSInteger, CloudHubRtmpStreamLifeCycle) {
    /** Bound to the channel lifecycle. If all hosts leave the channel, the CDN live streaming stops after 30 seconds. */
    CloudHubRtmpStreamLifeCycleBindToChannel = 1,
    /** Bound to the owner of the RTMP stream. If the owner leaves the channel, the CDN live streaming stops immediately. */
    CloudHubRtmpStreamLifeCycleBindToOwnner = 2,
};

/** Network quality. */
typedef NS_ENUM(NSUInteger, CloudHubNetworkQuality) {
    /** The network quality is unknown. */
    CloudHubNetworkQualityUnknown = 0,
    /**  The network quality is excellent. */
    CloudHubNetworkQualityExcellent = 1,
    /** The network quality is quite good, but the bitrate may be slightly lower than excellent. */
    CloudHubNetworkQualityGood = 2,
    /** Users can feel the communication slightly impaired. */
    CloudHubNetworkQualityPoor = 3,
    /** Users can communicate only not very smoothly. */
    CloudHubNetworkQualityBad = 4,
     /** The network quality is so bad that users can hardly communicate. */
    CloudHubNetworkQualityVBad = 5,
     /** The network is disconnected and users cannot communicate at all. */
    CloudHubNetworkQualityDown = 6,
     /** Users cannot detect the network quality. (Not in use.) */
    CloudHubNetworkQualityUnsupported = 7,
     /** Detecting the network quality. */
    CloudHubNetworkQualityDetecting = 8,
};

/** Video stream type. */
typedef NS_ENUM(NSInteger, CloudHubVideoStreamType) {
    /** High-bitrate, high-resolution video stream. */
    CloudHubVideoStreamTypeHigh = 0,
    /** Low-bitrate, low-resolution video stream. */
    CloudHubVideoStreamTypeLow = 1,
};

/** The priority of the remote user. */
typedef NS_ENUM(NSInteger, CloudHubUserPriority) {
  /** The user's priority is high. */
  CloudHubUserPriorityHigh = 50,
  /** (Default) The user's priority is normal. */
  CloudHubUserPriorityNormal = 100,
};

/**  Quality change of the local video in terms of target frame rate and target bit rate since last count. */
typedef NS_ENUM(NSInteger, CloudHubVideoQualityAdaptIndication) {
  /** The quality of the local video stays the same. */
  CloudHubVideoQualityAdaptNone = 0,
  /** The quality improves because the network bandwidth increases. */
  CloudHubVideoQualityAdaptUpBandwidth = 1,
  /** The quality worsens because the network bandwidth decreases. */
  CloudHubVideoQualityAdaptDownBandwidth = 2,
};

/** Video display mode. */
typedef NS_ENUM(NSUInteger, CloudHubVideoRenderMode) {
    /** Hidden(1): Uniformly scale the video until it fills the visible boundaries (cropped). One dimension of the video may have clipped contents. */
    CloudHubVideoRenderModeHidden = 1,

    /** Fit(2): Uniformly scale the video until one of its dimension fits the boundary (zoomed to fit). Areas that are not filled due to the disparity in the aspect ratio are filled with black. */
    CloudHubVideoRenderModeFit = 2,
};

/** Self-defined video codec profile. */
typedef NS_ENUM(NSInteger, CloudHubVideoCodecProfileType) {
    /** 66: Baseline video codec profile. Generally used in video calls on mobile phones. */
    CloudHubVideoCodecProfileTypeBaseLine = 66,
    /** 77: Main video codec profile. Generally used in mainstream electronics, such as MP4 players, portable video players, PSP, and iPads. */
    CloudHubVideoCodecProfileTypeMain = 77,
    /** 100: (Default) High video codec profile. Generally used in high-resolution broadcasts or television. */
    CloudHubVideoCodecProfileTypeHigh = 100
};

/** Video codec types. */
typedef NS_ENUM(NSInteger, CloudHubVideoCodecType) {
    /** 1: Standard VP8. */
    CloudHubVideoCodecTypeVP8 = 1,
    /** 2: Standard H264. */
    CloudHubVideoCodecTypeH264 = 2,
    /** 3: Enhanced VP8. */
    CloudHubVideoCodecTypeEVP = 3,
    /** 4: Enhanced H264. */
    CloudHubVideoCodecTypeE264 = 4,
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

/** The content hint for screen sharing. */
typedef NS_ENUM(NSUInteger, CloudHubVideoContentHint) {
    /** 0: (Default) No content hint. */
    CloudHubVideoContentHintNone = 0,
    /** 1: Motion-intensive content. Choose this option if you prefer smoothness or when you are sharing a video clip, movie, or video game. */
    CloudHubVideoContentHintMotion = 1,
    /** 2: Motionless content. Choose this option if you prefer sharpness or when you are sharing a picture, PowerPoint slide, or text. */
    CloudHubVideoContentHintDetails = 2,
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
    CloudHubVideoRemoteStateDecoding = 2,
    /** 3: The remote video is frozen, probably due to CloudHubVideoRemoteStateReasonNetworkCongestion(1) or CloudHubVideoRemoteStateReasonAudioFallback(8).
     */
    CloudHubVideoRemoteStateFrozen = 3,
    /** 4: The remote video fails to start, probably due to CloudHubVideoRemoteStateReasonInternal(0).
     */
    CloudHubVideoRemoteStateFailed = 4,
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
};

/** Stream fallback option. */
typedef NS_ENUM(NSInteger, CloudHubStreamFallbackOptions) {
    /** No fallback behavior for the local/remote video stream when the uplink/downlink network condition is unreliable. The quality of the stream is not guaranteed. */
    CloudHubStreamFallbackOptionDisabled = 0,
    /** Under unreliable downlink network conditions, the remote video stream falls back to the low-stream (low resolution and low bitrate) video. You can only set this option in the [setRemoteSubscribeFallbackOption]([CloudHubRtcEngineKit setRemoteSubscribeFallbackOption:]) method. Nothing happens when you set this in the [setLocalPublishFallbackOption]([CloudHubRtcEngineKit setLocalPublishFallbackOption:]) method. */
    CloudHubStreamFallbackOptionVideoStreamLow = 1,
    /** Under unreliable uplink network conditions, the published video stream falls back to audio only. Under unreliable downlink network conditions, the remote video stream first falls back to the low-stream (low resolution and low bitrate) video; and then to an audio-only stream if the network condition deteriorates. */
    CloudHubStreamFallbackOptionAudioOnly = 2,
};

/** Audio sample rate. */
typedef NS_ENUM(NSInteger, CloudHubAudioSampleRateType) {
    /** 32 kHz. */
    CloudHubAudioSampleRateType32000 = 32000,
    /** 44.1 kHz. */
    CloudHubAudioSampleRateType44100 = 44100,
    /** 48 kHz. */
    CloudHubAudioSampleRateType48000 = 48000,
};

/** Audio profile. */
typedef NS_ENUM(NSInteger, CloudHubAudioProfile) {
    /** Default audio profile. In the communication profile, the default value is CloudHubAudioProfileSpeechStandard; in the live-broadcast profile, the default value is CloudHubAudioProfileMusicStandard. */
    CloudHubAudioProfileDefault = 0,
    /** A sample rate of 32 KHz, audio encoding, mono, and a bitrate of up to 18 Kbps. */
    CloudHubAudioProfileSpeechStandard = 1,
    /** A sample rate of 48 KHz, music encoding, mono, and a bitrate of up to 48 Kbps. */
    CloudHubAudioProfileMusicStandard = 2,
    /** A sample rate of 48 KHz, music encoding, stereo, and a bitrate of up to 56 Kbps. */
    CloudHubAudioProfileMusicStandardStereo = 3,
    /** A sample rate of 48 KHz, music encoding, mono, and a bitrate of up to 128 Kbps. */
    CloudHubAudioProfileMusicHighQuality = 4,
    /** A sample rate of 48 KHz, music encoding, stereo, and a bitrate of up to 192 Kbps. */
    CloudHubAudioProfileMusicHighQualityStereo = 5,
};

/** Audio scenario. */
typedef NS_ENUM(NSInteger, CloudHubAudioScenario) {
    /** Default. */
    CloudHubAudioScenarioDefault = 0,
    /** Entertainment scenario, supporting voice during gameplay. */
    CloudHubAudioScenarioChatRoomEntertainment = 1,
    /** Education scenario, prioritizing fluency and stability. */
    CloudHubAudioScenarioEducation = 2,
    /** Live gaming scenario, enabling the gaming audio effects in the speaker mode in a live broadcast scenario. Choose this scenario for high-fidelity music playback.*/
    CloudHubAudioScenarioGameStreaming = 3,
    /** Showroom scenario, optimizing the audio quality with external professional equipment. */
    CloudHubAudioScenarioShowRoom = 4,
    /** Gaming scenario. */
    CloudHubAudioScenarioChatRoomGaming = 5
};

/** Audio output routing. */
typedef NS_ENUM(NSInteger, CloudHubAudioOutputRouting) {
    /** Default. */
    CloudHubAudioOutputRoutingDefault = -1,
    /** Headset.*/
    CloudHubAudioOutputRoutingHeadset = 0,
    /** Earpiece. */
    CloudHubAudioOutputRoutingEarpiece = 1,
    /** Headset with no microphone. */
    CloudHubAudioOutputRoutingHeadsetNoMic = 2,
    /** Speakerphone. */
    CloudHubAudioOutputRoutingSpeakerphone = 3,
    /** Loudspeaker. */
    CloudHubAudioOutputRoutingLoudspeaker = 4,
    /** Bluetooth headset. */
    CloudHubAudioOutputRoutingHeadsetBluetooth = 5
};

/** Use mode of the onRecordAudioFrame callback. */
typedef NS_ENUM(NSInteger, CloudHubAudioRawFrameOperationMode) {
    /** Read-only mode: Users only read the AudioFrame data without modifying anything. For example, when users acquire data with the CloudHub SDK then push the RTMP streams. */
    CloudHubAudioRawFrameOperationModeReadOnly = 0,
    /** Write-only mode: Users replace the AudioFrame data with their own data and pass them to the SDK for encoding. For example, when users acquire data. */
    CloudHubAudioRawFrameOperationModeWriteOnly = 1,
    /** Read and write mode: Users read the data from AudioFrame, modify it, and then play it. For example, when users have their own sound-effect processing module and perform some voice pre-processing such as a voice change. */
    CloudHubAudioRawFrameOperationModeReadWrite = 2,
};

/** Audio equalization band frequency. */
typedef NS_ENUM(NSInteger, CloudHubAudioEqualizationBandFrequency) {
    /** 31 Hz. */
    CloudHubAudioEqualizationBand31 = 0,
    /** 62 Hz. */
    CloudHubAudioEqualizationBand62 = 1,
    /** 125 Hz. */
    CloudHubAudioEqualizationBand125 = 2,
    /** 250 Hz. */
    CloudHubAudioEqualizationBand250 = 3,
    /** 500 Hz */
    CloudHubAudioEqualizationBand500 = 4,
    /** 1 kHz. */
    CloudHubAudioEqualizationBand1K = 5,
    /** 2 kHz. */
    CloudHubAudioEqualizationBand2K = 6,
    /** 4 kHz. */
    CloudHubAudioEqualizationBand4K = 7,
    /** 8 kHz. */
    CloudHubAudioEqualizationBand8K = 8,
    /** 16 kHz. */
    CloudHubAudioEqualizationBand16K = 9,
};

/** Audio reverberation type. */
typedef NS_ENUM(NSInteger, CloudHubAudioReverbType) {
    /** The level of the dry signal (dB). The value ranges between -20 and 10. */
    CloudHubAudioReverbDryLevel = 0,
    /** The level of the early reflection signal (wet signal) in dB. The value ranges between -20 and 10. */
    CloudHubAudioReverbWetLevel = 1,
    /** The room size of the reverberation. A larger room size means a stronger reverberation. The value ranges between 0 and 100. */
    CloudHubAudioReverbRoomSize = 2,
    /** The length of the initial delay of the wet signal (ms). The value ranges between 0 and 200. */
    CloudHubAudioReverbWetDelay = 3,
     /** The reverberation strength. The value ranges between 0 and 100. */
    CloudHubAudioReverbStrength = 4,
};


/** The preset local voice reverberation option. */
typedef NS_ENUM(NSInteger, CloudHubAudioReverbPreset) {
    /** The original voice (no local voice reverberation). */
    CloudHubAudioReverbPresetOff = 0,
    /** Pop music */
    CloudHubAudioReverbPresetPopular = 1,
    /** R&B */
    CloudHubAudioReverbPresetRnB = 2,
    /** Rock music */
    CloudHubAudioReverbPresetRock = 3,
    /** Hip-hop music */
    CloudHubAudioReverbPresetHipHop = 4,
    /** Pop concert */
    CloudHubAudioReverbPresetVocalConcert = 5,
    /** Karaoke */
    CloudHubAudioReverbPresetKTV = 6,
    /** Recording studio */
    CloudHubAudioReverbPresetStudio = 7
};

/** Audio session restriction. */
typedef NS_OPTIONS(NSUInteger, CloudHubAudioSessionOperationRestriction) {
    /** No restriction, the SDK has full control of the audio session operations. */
    CloudHubAudioSessionOperationRestrictionNone              = 0,
    /** The SDK does not change the audio session category. */
    CloudHubAudioSessionOperationRestrictionSetCategory       = 1,
    /** The SDK does not change any setting of the audio session (category, mode, categoryOptions). */
    CloudHubAudioSessionOperationRestrictionConfigureSession  = 1 << 1,
    /** The SDK keeps the audio session active when leaving a channel. */
    CloudHubAudioSessionOperationRestrictionDeactivateSession = 1 << 2,
    /** The SDK does not configure the audio session anymore. */
    CloudHubAudioSessionOperationRestrictionAll               = 1 << 7
};

/** Audio codec profile. */
typedef NS_ENUM(NSInteger, CloudHubAudioCodecProfileType) {
    /** (Default) LC-AAC, the low-complexity audio codec profile. */
  CloudHubAudioCodecProfileLCAAC = 0,
  /** HE-AAC, the high-efficiency audio codec profile. */
  CloudHubAudioCodecProfileHEAAC = 1
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

/** The state code in CloudHubChannelMediaRelayState.
 */
typedef NS_ENUM(NSInteger, CloudHubChannelMediaRelayState) {
    /** 0: The SDK is initializing.
     */
    CloudHubChannelMediaRelayStateIdle = 0,
    /** 1: The SDK tries to relay the media stream to the destination channel.
     */
    CloudHubChannelMediaRelayStateConnecting = 1,
    /** 2: The SDK successfully relays the media stream to the destination channel.
     */
    CloudHubChannelMediaRelayStateRunning = 2,
    /** 3: A failure occurs. See the details in `error`.
     */
    CloudHubChannelMediaRelayStateFailure = 3,
};

/** The event code in CloudHubChannelMediaRelayEvent.
 */
typedef NS_ENUM(NSInteger, CloudHubChannelMediaRelayEvent) {
    /** 0: The user disconnects from the server due to poor network connections.
     */
    CloudHubChannelMediaRelayEventDisconnect = 0,
    /** 1: The network reconnects.
     */
    CloudHubChannelMediaRelayEventConnected = 1,
    /** 2: The user joins the source channel.
     */
    CloudHubChannelMediaRelayEventJoinedSourceChannel = 2,
    /** 3: The user joins the destination channel.
     */
    CloudHubChannelMediaRelayEventJoinedDestinationChannel = 3,
    /** 4: The SDK starts relaying the media stream to the destination channel.
     */
    CloudHubChannelMediaRelayEventSentToDestinationChannel = 4,
    /** 5: The server receives the video stream from the source channel.
     */
    CloudHubChannelMediaRelayEventReceivedVideoPacketFromSource = 5,
    /** 6: The server receives the audio stream from the source channel.
     */
    CloudHubChannelMediaRelayEventReceivedAudioPacketFromSource = 6,
    /** 7: The destination channel is updated.
     */
    CloudHubChannelMediaRelayEventUpdateDestinationChannel = 7,
    /** 8: The destination channel update fails due to internal reasons.
     */
    CloudHubChannelMediaRelayEventUpdateDestinationChannelRefused = 8,
    /** 9: The destination channel does not change, which means that the destination channel fails to be updated.
     */
    CloudHubChannelMediaRelayEventUpdateDestinationChannelNotChange = 9,
    /** 10: The destination channel name is NULL.
     */
    CloudHubChannelMediaRelayEventUpdateDestinationChannelIsNil = 10,
    /** 11: The video profile is sent to the server.
     */
    CloudHubChannelMediaRelayEventVideoProfileUpdate = 11,
};

/** The error code in CloudHubChannelMediaRelayError.
 */
typedef NS_ENUM(NSInteger, CloudHubChannelMediaRelayError) {
    /** 0: The state is normal.
     */
    CloudHubChannelMediaRelayErrorNone = 0,
    /** 1: An error occurs in the server response.
     */
    CloudHubChannelMediaRelayErrorServerErrorResponse = 1,
    /** 2: No server response. You can call the [leaveChannel]([CloudHubRtcEngineKit leaveChannel:]) method to leave the channel.
     */
    CloudHubChannelMediaRelayErrorServerNoResponse = 2,
    /** 3: The SDK fails to access the service, probably due to limited resources of the server.
     */
    CloudHubChannelMediaRelayErrorNoResourceAvailable = 3,
    /** 4: Fails to send the relay request.
     */
    CloudHubChannelMediaRelayErrorFailedJoinSourceChannel = 4,
    /** 5: Fails to accept the relay request.
     */
    CloudHubChannelMediaRelayErrorFailedJoinDestinationChannel = 5,
    /** 6: The server fails to receive the media stream.
     */
    CloudHubChannelMediaRelayErrorFailedPacketReceivedFromSource = 6,
    /** 7: The server fails to send the media stream.
     */
    CloudHubChannelMediaRelayErrorFailedPacketSentToDestination = 7,
    /** 8: The SDK disconnects from the server due to poor network connections. You can call the [leaveChannel]([CloudHubRtcEngineKit leaveChannel:]) method to leave the channel.
     */
    CloudHubChannelMediaRelayErrorServerConnectionLost = 8,
    /** 9: An internal error occurs in the server.
     */
    CloudHubChannelMediaRelayErrorInternalError = 9,
    /** 10: The token of the source channel has expired.    
     */
    CloudHubChannelMediaRelayErrorSourceTokenExpired = 10,
    /** 11: The token of the destination channel has expired.
     */
    CloudHubChannelMediaRelayErrorDestinationTokenExpired = 11,
};

/** Network type. */
typedef NS_ENUM(NSInteger, CloudHubNetworkType) {
  /** -1: The network type is unknown. */
  CloudHubNetworkTypeUnknown = -1,
  /** 0: The SDK disconnects from the network. */
  CloudHubNetworkTypeDisconnected = 0,
  /** 1: The network type is LAN. */
  CloudHubNetworkTypeLAN = 1,
  /** 2: The network type is Wi-Fi (including hotspots). */
  CloudHubNetworkTypeWIFI = 2,
  /** 3: The network type is mobile 2G. */
  CloudHubNetworkTypeMobile2G = 3,
  /** 4: The network type is mobile 3G. */
  CloudHubNetworkTypeMobile3G = 4,
  /** 5: The network type is mobile 4G. */
  CloudHubNetworkTypeMobile4G = 5,
};

/** The video encoding degradation preference under limited bandwidth. */
typedef NS_ENUM(NSInteger, CloudHubDegradationPreference) {
    /** (Default) Degrades the frame rate to guarantee the video quality. */
    CloudHubDegradationMaintainQuality = 0,
    /** Degrades the video quality to guarantee the frame rate. */
    CloudHubDegradationMaintainFramerate = 1,
    /** Reserved for future use. */
    CloudHubDegradationBalanced = 2,
};
/** The lightening contrast level. */
typedef NS_ENUM(NSUInteger, CloudHubLighteningContrastLevel) {
    /** Low contrast level. */
    CloudHubLighteningContrastLow = 0,
    /** (Default) Normal contrast level. */
    CloudHubLighteningContrastNormal = 1,
    /** High contrast level. */
    CloudHubLighteningContrastHigh = 2,
};

/** The state of the probe test result. */
typedef NS_ENUM(NSUInteger, CloudHubLastmileProbeResultState) {
  /** 1: the last-mile network probe test is complete. */
  CloudHubLastmileProbeResultComplete = 1,
  /** 2: the last-mile network probe test is incomplete and the bandwidth estimation is not available, probably due to limited test resources. */
  CloudHubLastmileProbeResultIncompleteNoBwe = 2,
  /** 3: the last-mile network probe test is not carried out, probably due to poor network conditions. */
  CloudHubLastmileProbeResultUnavailable = 3,
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

typedef NS_ENUM(NSUInteger, CloudHubIpAreaCode) {
    CloudHubIpAreaCode_CN = (1 << 0),
    CloudHubIpAreaCode_NA = (1 << 1),
    CloudHubIpAreaCode_EUR = (1 << 2),
    CloudHubIpAreaCode_AS = (1 << 3),
    CloudHubIpAreaCode_GLOBAL = (0xFFFFFFFF)
};

typedef NS_ENUM(NSInteger, CloudHubStreamInjectStatus) {
    /** 0: The external video stream imported successfully. */
    CloudHub_INJECT_STREAM_STATUS_START_SUCCESS = 0,
    /** 1: The external video stream already exists. */
    CloudHub_INJECT_STREAM_STATUS_START_ALREADY_EXISTS = 1,
    /** 3: Import external video stream timeout. */
    CloudHub_INJECT_STREAM_STATUS_START_TIMEDOUT = 2,
    /** 4: Import external video stream failed. */
    CloudHub_INJECT_STREAM_STATUS_START_FAILED = 3,
    /** 5: The external video stream stopped importing successfully. */
    CloudHub_INJECT_STREAM_STATUS_STOP_SUCCESS = 4,
    /** 6: No external video stream is found. */
    CloudHub_INJECT_STREAM_STATUS_STOP_NOT_FOUND = 5,
    /** 8: Stop importing external video stream timeout. */
    CloudHub_INJECT_STREAM_STATUS_STOP_TIMEDOUT = 6,
    /** 9: Stop importing external video stream failed. */
    CloudHub_INJECT_STREAM_STATUS_STOP_FAILED = 7,
    /** 10: The external video stream is corrupted. */
    CloudHub_INJECT_STREAM_STATUS_BROKEN = 8,
    /** 10: The external video stream is corrupted. */
    CloudHub_INJECT_STREAM_STATUS_PAUSE = 9,
    CloudHub_INJECT_STREAM_STATUS_RESUME = 10
};

typedef NS_ENUM(NSInteger, CloudHubMediaType) {
    CloudHub_MEDIA_TYPE_AUDIO_ONLY = 1,
    CloudHub_MEDIA_TYPE_AUDIO_AND_VIDEO = 2,
    CloudHub_MEDIA_TYPE_ONLINE_MOVIE_VIDEO = 4,
    CloudHub_MEDIA_TYPE_OFFLINE_MOVIE_VIDEO = 5,
    CloudHub_MEDIA_TYPE_SCREEN_VIDEO = 6,
};

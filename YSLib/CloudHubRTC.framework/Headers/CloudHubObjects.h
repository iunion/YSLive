//
//  CloudHubObjects.h
//  CloudHubRtcEngineKit
//
//  Copyright (c) 2020 CloudHub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "CloudHubEnumerates.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
typedef UIView VIEW_CLASS;
typedef UIColor COLOR_CLASS;
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
typedef NSView VIEW_CLASS;
typedef NSColor COLOR_CLASS;
#endif

/** Statistics of the local video stream.
 */
__attribute__((visibility("default"))) @interface CloudHubRtcLocalVideoStats : NSObject
/** Bitrate (Kbps) sent in the reported interval, which does not include the bitrate of the retransmission video after packet loss. */
@property (assign, nonatomic) NSUInteger sentBitrate;
/** Frame rate (fps) sent in the reported interval, which does not include the frame rate of the retransmission video after packet loss. */
@property (assign, nonatomic) NSUInteger sentFrameRate;
/** The encoder output frame rate (fps) of the local video. */
@property (assign, nonatomic) NSUInteger encoderOutputFrameRate;
/** The renderer output frame rate (fps) of the local video. */
@property (assign, nonatomic) NSUInteger rendererOutputFrameRate;
/** The target bitrate (Kbps) of the current encoder. This value is estimated by the SDK based on the current network conditions. */
@property (assign, nonatomic) NSUInteger targetBitrate;
/** The target frame rate (fps) of the current encoder. */
@property (assign, nonatomic) NSUInteger targetFrameRate;
/** The encoding bitrate (Kbps), which does not include the bitrate of the re-transmission video after packet loss.
 */
@property (assign, nonatomic) NSUInteger encodedBitrate;
/** The width of the encoding frame (px).
 */
@property (assign, nonatomic) NSUInteger encodedFrameWidth;
/** The height of the encoding frame (px).
 */
@property (assign, nonatomic) NSUInteger encodedFrameHeight;
/** The value of the sent frames, represented by an aggregate value.
 */
@property (assign, nonatomic) NSUInteger encodedFrameCount;
/** The codec type of the local video：

 - CloudHubVideoCodecTypeVP8 = 1: VP8.
 - CloudHubVideoCodecTypeH264 = 2: (Default) H.264.
 */
@property (assign, nonatomic) CloudHubVideoCodecType codecType;
@end

/** Statistics of the remote video stream.
 */
__attribute__((visibility("default"))) @interface CloudHubRtcRemoteVideoStats : NSObject
/** User ID of the user sending the video streams.
 */
@property (copy, nonatomic) NSString*  _Nullable uid;

/** Device ID of the video stream.
 */
@property (copy, nonatomic) NSString*  _Nullable sourceId;

/** Width (pixels) of the video stream.
 */
@property (assign, nonatomic) NSUInteger width;
/** Height (pixels) of the video stream.
 */
@property (assign, nonatomic) NSUInteger height;
/** The average bitrate (Kbps) of the received video stream.
 */
@property (assign, nonatomic) NSUInteger receivedBitrate;
/** The decoder output frame rate (fps) of the remote video.
 */
@property (assign, nonatomic) NSUInteger decoderOutputFrameRate;
/** The renderer output frame rate (fps) of the remote video.
 */
@property (assign, nonatomic) NSUInteger rendererOutputFrameRate;
/** Packet loss rate (%) of the remote video stream after using the anti-packet-loss method.
 */
@property (assign, nonatomic) NSUInteger packetLossRate;

/** The total freeze time (ms) of the remote video stream after the remote user joins the channel. In a video session where the frame rate is set to no less than 5 fps, video freeze occurs when the time interval between two adjacent renderable video frames is more than 500 ms.
 */
@property (assign, nonatomic) NSUInteger totalFrozenTime;
/** The total video freeze time as a percentage (%) of the total time when the video is available.
 */
@property (assign, nonatomic) NSUInteger frozenRate;
@end

/** The statistics of the local audio stream.
 */
__attribute__((visibility("default"))) @interface CloudHubRtcLocalAudioStats : NSObject
/** The number of channels.
 */
@property (assign, nonatomic) NSUInteger numChannels;
/** The sample rate (Hz).
 */
@property (assign, nonatomic) NSUInteger sentSampleRate;
/** The average sending bitrate (Kbps).
 */
@property (assign, nonatomic) NSUInteger sentBitrate;
@end

/** The statistics of the remote audio stream.
 */
__attribute__((visibility("default"))) @interface CloudHubRtcRemoteAudioStats : NSObject
/** User ID of the user sending the audio stream.
 */
@property (copy, nonatomic) NSString* _Nullable uid;
/** Audio quality received by the user.
 */
@property (assign, nonatomic) NSUInteger quality;
/** Network delay (ms) from the sender to the receiver.
 */
@property (assign, nonatomic) NSUInteger networkTransportDelay;
/** Network delay (ms) from the receiver to the jitter buffer.
 */
@property (assign, nonatomic) NSUInteger jitterBufferDelay;
/** The audio frame loss rate in the reported interval.
 */
@property (assign, nonatomic) NSUInteger audioLossRate;
/** The number of channels.
 */
@property (assign, nonatomic) NSUInteger numChannels;
/** The sample rate (Hz) of the received audio stream in the reported interval.
 */
@property (assign, nonatomic) NSUInteger receivedSampleRate;
/** The average bitrate (Kbps) of the received audio stream in the reported interval.
 */
@property (assign, nonatomic) NSUInteger receivedBitrate;
/** The total freeze time (ms) of the remote audio stream after the remote user joins the channel. 
 *
 * In every two seconds, the audio frame loss rate reaching 4% is counted as one audio freeze. The total audio freeze time = The audio freeze number &times; 2000 ms.
 */
@property (assign, nonatomic) NSUInteger totalFrozenTime;
/** The total audio freeze time as a percentage (%) of the total time when the audio is available.
 */
@property (assign, nonatomic) NSUInteger frozenRate;
@end

/** Properties of the audio volume information.
 */
__attribute__((visibility("default"))) @interface CloudHubRtcAudioVolumeInfo : NSObject
/** User ID of the speaker. The `uid` of the local user is 0.
 */
@property (copy, nonatomic) NSString* _Nullable uid;
/** The sum of the voice volume and audio-mixing volume of the speaker. The value ranges between 0 (lowest volume) and 255 (highest volume).
 */
@property (assign, nonatomic) NSUInteger volume;
/** Voice activity status of the local user.

 - 0: The local user is not speaking.
 - 1: The local user is speaking.

 **Note**

 - The `vad` parameter cannot report the voice activity status of the remote users. In the remote users' callback, `vad` = 0.
 - Ensure that you set `report_vad(YES)` in the `enableAudioVolumeIndication` method to enable the voice activity detection of the local user.
 */
@property (assign, nonatomic) NSUInteger vad;
/** The channel ID, which indicates which channel the speaker is in.
 */
@property (copy, nonatomic) NSString * _Nonnull channelId;
@end

/** Statistics of the channel
 */
__attribute__((visibility("default"))) @interface CloudHubChannelStats: NSObject
/** Call duration (s), represented by an aggregate value.
 */
@property (assign, nonatomic) NSInteger duration;
/** Total number of bytes transmitted, represented by an aggregate value.
 */
@property (assign, nonatomic) NSInteger txBytes;
/** Total number of bytes received, represented by an aggregate value.
 */
@property (assign, nonatomic) NSInteger rxBytes;
/** Total number of audio bytes sent (bytes), represented by an aggregate value.
 */
@property (assign, nonatomic) NSInteger txAudioBytes;
/** Total number of video bytes sent (bytes), represented by an aggregate value.
 */
@property (assign, nonatomic) NSInteger txVideoBytes;
/** Total number of audio bytes received (bytes), represented by an aggregate value.
 */
@property (assign, nonatomic) NSInteger rxAudioBytes;
/** Total number of video bytes received (bytes), represented by an aggregate value.
 */
@property (assign, nonatomic) NSInteger rxVideoBytes;
/** Total packet transmission bitrate (Kbps), represented by an instantaneous value.
 */
@property (assign, nonatomic) NSInteger txKBitrate;
/** Total receive bitrate (Kbps), represented by an instantaneous value.
 */
@property (assign, nonatomic) NSInteger rxKBitrate;
/** Audio packet transmission bitrate (Kbps), represented by an instantaneous value.
 */
@property (assign, nonatomic) NSInteger txAudioKBitrate;
/** Audio receive bitrate (Kbps), represented by an instantaneous value.
 */
@property (assign, nonatomic) NSInteger rxAudioKBitrate;
/** Video transmission bitrate (Kbps), represented by an instantaneous value.
 */
@property (assign, nonatomic) NSInteger txVideoKBitrate;
/** Video receive bitrate (Kbps), represented by an instantaneous value.
 */
@property (assign, nonatomic) NSInteger rxVideoKBitrate;
/** Client-server latency (ms)
 */
@property (assign, nonatomic) NSInteger lastmileDelay;
/** The packet loss rate (%) from the local client to CloudHub's edge server, before using the anti-packet-loss method.
 */
@property (assign, nonatomic) NSInteger txPacketLossRate;
/** The packet loss rate (%) from CloudHub's edge server to the local client, before using the anti-packet-loss method.
 */
@property (assign, nonatomic) NSInteger rxPacketLossRate;
/** Number of users in the channel.

- Communication profile: The number of users in the channel.
- Live broadcast profile:

  - If the local user is an audience: The number of users in the channel = The number of hosts in the channel + 1.
  - If the user is a host: The number of users in the channel = The number of hosts in the channel.
 */
@property (assign, nonatomic) NSInteger userCount;
/** Application CPU usage (%).
 */
@property (assign, nonatomic) double cpuAppUsage;
/** System CPU usage (%).
 */
@property (assign, nonatomic) double cpuTotalUsage;
/** The round-trip time delay from the client to the local router.
 */
@property (assign, nonatomic) NSInteger gatewayRtt;
/** The memory usage ratio of the app (%).
 **Note** This value is for reference only. Due to system limitations, you may not get the value of this member.
 */
@property (assign, nonatomic) double memoryAppUsageRatio;
/** The memory usage ratio of the system (%). 
 **Note** This value is for reference only. Due to system limitations, you may not get the value of this member.
 */
@property (assign, nonatomic) double memoryTotalUsageRatio;
/** The memory usage of the app (KB). 
 **Note** This value is for reference only. Due to system limitations, you may not get the value of this member.
 */
@property (assign, nonatomic) NSInteger memoryAppUsageInKbytes;
@end

/** Properties of the video encoder configuration.
 */
__attribute__((visibility("default"))) @interface CloudHubVideoEncoderConfiguration: NSObject
/** The video frame dimension (px) used to specify the video quality in the total number of pixels along a frame's width and height. The default value is 640 x 360.

You can customize the dimension, or select from the following list:

 - CloudHubVideoDimension120x120
 - CloudHubVideoDimension160x120
 - CloudHubVideoDimension180x180
 - CloudHubVideoDimension240x180
 - CloudHubVideoDimension320x180
 - CloudHubVideoDimension240x240
 - CloudHubVideoDimension320x240
 - CloudHubVideoDimension424x240
 - CloudHubVideoDimension360x360
 - CloudHubVideoDimension480x360
 - CloudHubVideoDimension640x360
 - CloudHubVideoDimension480x480
 - CloudHubVideoDimension640x480
 - CloudHubVideoDimension840x480
 - CloudHubVideoDimension960x720
 - CloudHubVideoDimension1280x720
 - CloudHubVideoDimension1920x1080 (macOS only)
 - CloudHubVideoDimension2540x1440 (macOS only)
 - CloudHubVideoDimension3840x2160 (macOS only)

 Note:

 - The dimension does not specify the orientation mode of the output ratio. For how to set the video orientation, see [CloudHubVideoOutputOrientationMode](CloudHubVideoOutputOrientationMode).
 - Whether 720p can be supported depends on the device. If the device cannot support 720p, the frame rate will be lower than the one listed in the table. CloudHub optimizes the video in lower-end devices.
 - iPhones do not support video frame dimensions above 720p.
 */
@property (assign, nonatomic) CGSize dimensions;

/** The frame rate of the video (fps). 

 You can either set the frame rate manually or choose from the following options. The default value is 15. We do not recommend setting this to a value greater than 30.

  *  CloudHubVideoFrameRateFps1(1): 1 fps
  *  CloudHubVideoFrameRateFps7(7): 7 fps
  *  CloudHubVideoFrameRateFps10(10): 10 fps
  *  CloudHubVideoFrameRateFps15(15): 15 fps
  *  CloudHubVideoFrameRateFps24(24): 24 fps
  *  CloudHubVideoFrameRateFps30(30): 30 fps
  *  CloudHubVideoFrameRateFps60(30): 60 fps (macOS only)
 */
@property (assign, nonatomic) CloudHubVideoFrameRate frameRate;

/** Initializes and returns a newly allocated CloudHubVideoEncoderConfiguration object with the specified video resolution.

 @param size Video resolution.
 @param frameRate Video frame rate.
 @param bitrate Video bitrate.
 @param orientationMode CloudHubVideoOutputOrientationMode.
 @return An initialized CloudHubVideoEncoderConfiguration object.
 */
- (instancetype _Nonnull)initWithSize:(CGSize)size
                            frameRate:(CloudHubVideoFrameRate)frameRate;

/** Initializes and returns a newly allocated CloudHubVideoEncoderConfiguration object with the specified video width and height.

 @param width Width of the video.
 @param height Height of the video.
 @param frameRate Video frame rate.
 @param bitrate Video bitrate.
 @param orientationMode CloudHubVideoOutputOrientationMode.
 @return An initialized CloudHubVideoEncoderConfiguration object.
 */
- (instancetype _Nonnull)initWithWidth:(NSInteger)width
                                height:(NSInteger)height
                             frameRate:(CloudHubVideoFrameRate)frameRate;
@end

/** The channel media options.
 */ 
__attribute__((visibility("default"))) @interface CloudHubRtcChannelMediaOptions : NSObject
/** Determines whether to subscribe to audio streams when the user joins the channel:

 - true: (Default) Subscribe.
 - false: Do not subscribe.
 
 This member serves a similar function to the [muteAllRemoteAudioStreams]([CloudHubRtcChannel muteAllRemoteAudioStreams:]) method. After joining the channel, you can call the `muteAllRemoteAudioStreams` method to set whether to subscribe to audio streams in the channel.
 */ 
@property (nonatomic, assign) BOOL autoSubscribeAudio;
/** Determines whether to subscribe to video streams when the user joins the channel:

 - true: (Default) Subscribe.
 - false: Do not subscribe.

 This member serves a similar function to the [muteAllRemoteVideoStreams]([CloudHubRtcChannel muteAllRemoteVideoStreams:]) method. After joining the channel, you can call the `muteAllRemoteVideoStreams` method to set whether to subscribe to audio streams in the channel.
 */ 
@property (nonatomic, assign) BOOL autoSubscribeVideo;

@end

__attribute__((visibility("default"))) @interface CloudHubLocalMovieInfo: NSObject
@property (nonatomic, assign) BOOL hasAudio;
@property (nonatomic, assign) BOOL hasVideo;
@property (nonatomic, assign) NSUInteger duration;
@end

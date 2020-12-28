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

/** Device ID of the video stream. */
@property (copy, nonatomic) NSString*  _Nullable sourceID;
/** Bitrate (Kbps) sent in the reported interval, which does not include the bitrate of the retransmission video after packet loss. */
@property (assign, nonatomic) NSUInteger sentBitrate;
/** Frame rate (fps) sent in the reported interval, which does not include the frame rate of the retransmission video after packet loss. */
@property (assign, nonatomic) NSUInteger sentFrameRate;
/** The encoder output frame rate (fps) of the local video. */
@property (assign, nonatomic) NSUInteger encoderOutputFrameRate;
/** The renderer output frame rate (fps) of the local video. */
@property (assign, nonatomic) NSUInteger rendererOutputFrameRate;
/** The target bitrate (bps) of the current encoder. This value is estimated by the SDK based on the current network conditions. */
@property (assign, nonatomic) NSUInteger targetBitrate;
/** The target frame rate (fps) of the current encoder. */
@property (assign, nonatomic) NSUInteger targetFrameRate;
/** The encoding bitrate (bps), which does not include the bitrate of the re-transmission video after packet loss.
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

/** ID of the video stream.
 */
@property (copy, nonatomic) NSString*  _Nullable sourceID;

/** Type of the video stream.
*/
@property (assign, nonatomic) CloudHubMediaType type;

/** Width (pixels) of the video stream.
 */
@property (assign, nonatomic) NSUInteger width;
/** Height (pixels) of the video stream.
 */
@property (assign, nonatomic) NSUInteger height;
/** The average bitrate (bps) of the received video stream.
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
/** The average bitrate (bps) of the received audio stream in the reported interval.
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
/** The packet loss rate (%) from the local client to Cloudhub's edge server, before using the anti-packet-loss method.
 */
@property (assign, nonatomic) NSInteger txPacketLossRate;
/** The packet loss rate (%) from Cloudhub's edge server to the local client, before using the anti-packet-loss method.
 */
@property (assign, nonatomic) NSInteger rxPacketLossRate;
/** System CPU usage (%).
 */
@property (assign, nonatomic) double cpuTotalUsage;
@end

/** Properties of the video encoder configuration.
 */
__attribute__((visibility("default"))) @interface CloudHubVideoEncoderConfiguration: NSObject
/** The video frame dimension (px) used to specify the video quality in the total number of pixels along a frame's width and height. The default value is 320 x 240.

You can customize the dimension, or select from the following list:

 200x150
 320x180
 320x240
 640x360
 640x480
 1280x720
 
 Note:

 - The dimension does not specify the orientation mode of the output ratio. For how to set the video orientation, see [CloudHubVideoOutputOrientationMode](CloudHubVideoOutputOrientationMode).
 - Whether 720p can be supported depends on the device. If the device cannot support 720p, the frame rate will be lower than the one listed in the table. CloudHub optimizes the video in lower-end devices.
 - iPhones do not support video frame dimensions above 720p.
 */
@property (assign, nonatomic) CGSize dimensions;

/** The frame rate of the video (fps).
 */
@property (assign, nonatomic) CloudHubVideoFrameRate frameRate;

- (instancetype _Nonnull)initWithSize:(CGSize)size
                            frameRate:(CloudHubVideoFrameRate)frameRate;

- (instancetype _Nonnull)initWithWidth:(NSInteger)width
                                height:(NSInteger)height
                             frameRate:(CloudHubVideoFrameRate)frameRate;
@end

__attribute__((visibility("default"))) @interface CloudHubLocalMovieInfo: NSObject
@property (nonatomic, assign) BOOL hasAudio;//not used currently
@property (nonatomic, assign) BOOL hasVideo;//not used currently
@property (nonatomic, assign) NSUInteger duration;
@end

/** Properties of the audio volume information.

 An array containing the user ID and volume information for each speaker.
 */
__attribute__((visibility("default"))) @interface CloudHubAudioVolumeInfo: NSObject
/**
User ID of the speaker.
*/
@property (copy, nonatomic) NSString* _Nonnull uid;
/** The volume of the speaker. The volume ranges between 0 (lowest volume) and
  * 255 (highest volume).
  */
@property (assign, nonatomic) NSUInteger volume;
/** Voice activity status of the local user.
 * - 0: The local user is not speaking.
 * - 1: The local user is speaking.
 *
 * @note
 * - The `vad` parameter cannot report the voice activity status of the remote
 * users. In the remote users' callback, `vad` = 0.
 * - Ensure that you set `reportVad`(YES) in the
 * "enableAudioVolumeIndication" method to enable the voice activity detection
 * of the local user.
 */
@property (nonatomic, assign) NSUInteger vad;
@end

/** The video properties of the stream displaying the video in the CDN live. CloudHub
* supports a maximum of 24 transcoding streams in a CDN streaming channel.
*/
__attribute__((visibility("default"))) @interface CloudHubTranscodingStream : NSObject

@property (nonatomic, copy) NSString * _Nonnull uid;

@property (nonatomic, assign) CloudHubMediaType type;

@property (nonatomic, copy) NSString * _Nonnull sourceID;

/** Horizontal position (pixel) of the video frame relative to the top left
* corner.
*/
@property (nonatomic, assign) int x;

/** Vertical position (pixel) of the video frame relative to the top left
* corner.
*/
@property (nonatomic, assign) int y;

  /** Width (pixel) of the video frame. The default value is 360.
   */
@property (nonatomic, assign) int width;

  /** Height (pixel) of the video frame. The default value is 640.
   */
@property (nonatomic, assign) int height;

  /** Layer position of the video frame. The value ranges between 0 and 100.
   - 0: (Default) Lowest
   - 100: Highest
   - If zOrder is beyond this range, the SDK reports #ERR_INVALID_ARGUMENT.
   */
@property (nonatomic, assign)int zOrder;
@end

/** A struct for managing CDN live audio/video transcoding settings.
 */
__attribute__((visibility("default"))) @interface CloudHubLiveTranscoding : NSObject
@property (nonatomic, assign) int            width;
@property (nonatomic, assign) int            height;
@property (nonatomic, assign) int            videoBitrate;
@property (nonatomic, assign) int            videoFramerate;
@property (nonatomic, assign) int            videoGop;
@property (nonatomic, assign) CloudHubVideoCodecProfile            videoCodecProfile;
@property (nonatomic, assign) unsigned int   backgroundColor;
/** array of CloudHubTranscodingStream */
@property (nonatomic, copy) NSArray *  _Nonnull transcodingStreams;
@property (nonatomic, copy) NSString * _Nullable transcodingExtraInfo;
@property (nonatomic, assign) CloudHubAudioSampleRate audioSampleRate;
@property (nonatomic, assign) int                     audioBitrate;
@property (nonatomic, assign) int                     audioChannels;
@end

/** Configurations of the last-mile network probe test.
 */
__attribute__((visibility("default"))) @interface CloudHubLastmileProbeConfig : NSObject

/** Sets whether or not to test the uplink network. Some users, for example,
the audience in a Live-broadcast channel, do not need such a test:
- YES: test.
- NO: do not test. */
@property (nonatomic, assign) BOOL probeUplink;
/** Sets whether or not to test the downlink network:
- YES: test.
- NO: do not test. */
@property (nonatomic, assign) BOOL probeDownlink;
/** The expected maximum sending bitrate (bps) of the local user. The value
 * ranges between 100000 and 2000000. We recommend setting this parameter
 * according to the bitrate value set by \ref
 * IRtcEngine::setVideoEncoderConfiguration "setVideoEncoderConfiguration". */
@property (nonatomic, assign) unsigned int expectedUplinkBitrate;
/** The expected maximum receiving bitrate (bps) of the local user. The value
 * ranges between 100000 and 5000000. */
@property (nonatomic, assign) unsigned int expectedDownlinkBitrate;

@end

/** The uplink and downlink last-mile network probe test result.
 */
__attribute__((visibility("default"))) @interface CloudHubLastmileProbeResult : NSObject
/** The state of the probe test. */
@property (nonatomic, assign) CloudHubLastmileProbeResultState state;
/** The uplink last-mile packet loss rate (%). */
@property (nonatomic, assign) unsigned int uplinkPacketLossRate;
/** The uplink last-mile estimated available bandwidth (bps). */
@property (nonatomic, assign) unsigned int uplinkAvailableBandwidth;
/** The downlink last-mile packet loss rate (%). */
@property (nonatomic, assign) unsigned int downlinkPacketLossRate;
/** The downlink last-mile estimated available bandwidth (bps). */
@property (nonatomic, assign) unsigned int downlinkAvailableBandwidth;
/** The round-trip delay time (ms). */
@property (nonatomic, assign) unsigned int rtt;
@end


__attribute__((visibility("default"))) @interface CloudHubChannelMediaRelayInfo : NSObject
/** For sourceInfo: The user ID to be relayed.
    For destinationInfos: the user ID in the destination channel.
 . */
@property (nonatomic, strong) NSString * _Nullable uid;

/** The source/destination channel id. */
@property (nonatomic, strong) NSString * _Nullable channelID;

/** The token to join destination channel. */
@property (nonatomic, strong) NSString * _Nullable token;
@end

__attribute__((visibility("default"))) @interface CloudHubChannelMediaRelayConfig : NSObject

/** Pointer to the information of the destination channel: ChannelMediaInfo.
 * It contains the following members:
 * - `channelID`: The name of the destination channel.
 * - `uid`: ID of the broadcaster in the destination channel. The value ranges
 * from 0 to (2<sup>32</sup>-1). To avoid UID conflicts, this `uid` must be
 * different from any other UIDs in the destination channel. The default value
 * is nil. which means the SDK generates a random UID.
 * - `token`: The token for joining the destination channel. It is generated
 * with the `channelName` and `uid` you set in `destInfos`.
 *   - If you have not enabled the App Certificate, set this parameter as the
 * default value `nil`, which means the SDK applies the App ID.
 *   - If you have enabled the App Certificate, you must use the `token`
 * generated with the `channelID` and `uid`.
 */
@property (nonatomic, strong) NSDictionary<NSString*, CloudHubChannelMediaRelayInfo*>* _Nonnull destinationInfos;

@end

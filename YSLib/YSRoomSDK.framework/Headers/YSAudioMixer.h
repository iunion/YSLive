//
//  YSAudioMixer.h
//  YSRoomSDK
//
//  Created by MAC-MiNi on 2018/10/22.
//  Copyright © 2018年 MAC-MiNi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSAudioInfo : NSObject
@property (nonatomic) int fromat;
@property (nonatomic) int number_of_channels;
@property (nonatomic) int number_of_frames;
@property (nonatomic) int bytes_per_sample;
@property (nonatomic) int sample_rate;
@end

@class YSAudioMixer;
@protocol YSAudioMixerOuputDelegate<NSObject>
-(void)mixedAudioOutput:(YSAudioMixer *)mixer ouput_data:(const void *)data audioInfo:(YSAudioInfo *)audioInfo;

@end

@interface YSAudioMixer : NSObject
- (instancetype)initWithDelegate:(id<YSAudioMixerOuputDelegate>)delegate audioInfo:(YSAudioInfo *)audioInfo;
- (int)addSource:(NSString *)sid;
- (int)removeSource:(NSString *)sid;
- (int)receiveData:(NSString *)sid audio_data:(void *)audio_data audioInfo:(YSAudioInfo *)audioInfo;
@end

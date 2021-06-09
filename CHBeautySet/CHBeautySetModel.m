//
//  CHBeautySetModel.m
//  YSLive
//
//  Created by jiang deng on 2021/3/30.
//  Copyright © 2021 CH. All rights reserved.
//

#import "CHBeautySetModel.h"

@implementation CHBeautySetModel

#pragma mark 查看麦克风权限

- (BOOL)microphonePermissions
{
    // AVMediaTypeAudio
    return [BMCloudHubUtil checkAuthorizationStatus:AVMediaTypeAudio];

//    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
//    return permissionStatus == AVAudioSessionRecordPermissionGranted;
}

#pragma mark 查看摄像头权限

- (BOOL)cameraPermissions
{
    // AVMediaTypeVideo
    return [BMCloudHubUtil checkAuthorizationStatus:AVMediaTypeVideo];
}

- (void)setSwitchCam:(BOOL)switchCam
{
    if (_switchCam == switchCam)
    {
        return;
    }
    
    _switchCam = switchCam;
    
    [self.liveManager useFrontCamera:!switchCam];
}

- (void)setFliph:(BOOL)fliph
{
    if (_fliph == fliph)
    {
        return;
    }
    
    _fliph = fliph;
    
    [self.liveManager setCameraFlipMode:fliph Vertivcal:self.flipv];
}

- (void)setFlipv:(BOOL)flipv
{
    if (_flipv == flipv)
    {
        return;
    }
    
    _flipv = flipv;
    
    [self.liveManager setCameraFlipMode:self.fliph Vertivcal:flipv];
}

#pragma - setValue

- (void)setBeautySwitch:(BOOL)beautySwitch
{
    if (beautySwitch == _beautySwitch)
    {
        return;
    }
    _beautySwitch = beautySwitch;
    [self setCloudHubBeauty];
}

- (void)setWhitenValue:(CGFloat)whitenValue
{
    _whitenValue = whitenValue;
    
    [self setCloudHubBeauty];
}

- (void)setExfoliatingValue:(CGFloat)exfoliatingValue
{
    _exfoliatingValue = exfoliatingValue;
    
    [self setCloudHubBeauty];
}

- (void)setRuddyValue:(CGFloat)ruddyValue
{
    _ruddyValue = ruddyValue;
    
    [self setCloudHubBeauty];
}

- (void)setCloudHubBeauty
{
    if (!self.beautySwitch)
    {
        [self.liveManager.cloudHubRtcEngineKit setBeautyEffectOptions:NO options:nil];
    }
    else
    {
        CloudHubBeautyOptions * beautyOptions = [[CloudHubBeautyOptions alloc]init];
        
        if (!self.whitenValue && !self.exfoliatingValue && !self.ruddyValue)
        {
            [self.liveManager.cloudHubRtcEngineKit setBeautyEffectOptions:NO options:nil];
        }
        else
        {
            beautyOptions.lighteningLevel = self.whitenValue;
            beautyOptions.smoothnessLevel = self.exfoliatingValue;
            beautyOptions.rednessLevel = self.ruddyValue;
            
            [self.liveManager.cloudHubRtcEngineKit setBeautyEffectOptions:YES options:beautyOptions];
        }
    }
}


@end

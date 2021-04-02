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

@end

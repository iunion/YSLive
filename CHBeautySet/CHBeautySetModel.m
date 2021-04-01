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

- (void)setHMirror:(BOOL)hMirror
{
    if (_hMirror == hMirror)
    {
        return;
    }
    
    _hMirror = hMirror;
    
    [self.liveManager setCameraFlipMode:hMirror Vertivcal:self.vMirror];
}

- (void)setVMirror:(BOOL)vMirror
{
    if (_vMirror == vMirror)
    {
        return;
    }
    
    _vMirror = vMirror;
    
    [self.liveManager setCameraFlipMode:self.hMirror Vertivcal:vMirror];
}

@end

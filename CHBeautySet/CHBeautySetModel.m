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

#if 0
请求设备权限授权

@param mediaType 设备类型
@param successBlock 成功回调
@param failtureBlock 失败回调
*/
- (void)requestCaptureAuthorizationByMediaType:(AVMediaType)mediaType successBlock:(void(^)(void))successBlock failture:(void(^)(void))failtureBlock
{
   AVAuthorizationStatus authorStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
   
   // 检测授权
   switch (authorStatus)
   {
       // 已授权，可使用
       // The client is authorized to access the hardware supporting a media type.
       case AVAuthorizationStatusAuthorized:
       {
           if (successBlock)
           {
               successBlock();
           }
           break;
       }
       // 未进行授权选择
       // Indicates that the user has not yet made a choice regarding whether the client can access the hardware.
       case AVAuthorizationStatusNotDetermined:
       {
           // 再次请求授权
           [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
               // 用户授权成功
               if (granted)
               {
                   if (successBlock)
                   {
                       successBlock();
                   }
               }
               else
               {
                   // 用户拒绝授权
                   if (failtureBlock)
                   {
                       failtureBlock();
                   }
               }
           }];
           break;
       }
           
       // 用户拒绝授权/未授权
       default:
       {
           if (failtureBlock)
           {
               failtureBlock();
           }
           break;
       }
   }
}

#endif


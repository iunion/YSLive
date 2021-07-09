//
//  BMAuthorizetionMicrophone.m
//  BMKit
//
//  Created by jiang deng on 2021/7/9.
//  Copyright © 2021 DennisDeng. All rights reserved.
//

#import "BMAuthorizetionMicrophone.h"
#import <AVFoundation/AVFoundation.h>

@implementation BMAuthorizetionMicrophone

/// Determine whether authorization is currently available.
+ (BOOL)isAuthorized
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    return status == AVAuthorizationStatusAuthorized;
}

/// Request microphone authorizetion.
+ (void)requestAuthorizetionWithCompletion:(void (^)(BOOL, BOOL))completion
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status)
    {
        case AVAuthorizationStatusAuthorized:
        {
            if (completion)
            {
                completion(YES, NO);
            }
        }
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
        {
            if (completion)
            {
                completion(NO, NO);
            }
        }
            break;
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion)
                    {
                        completion(granted, YES);
                    }
                });
            }];
        }
            break;
        default:
            break;
    }
}

@end

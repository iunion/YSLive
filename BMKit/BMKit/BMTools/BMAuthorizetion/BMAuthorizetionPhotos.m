//
//  BMAuthorizetionPhotos.m
//  BMKit
//
//  Created by jiang deng on 2021/7/9.
//  Copyright © 2021 DennisDeng. All rights reserved.
//

#import "BMAuthorizetionPhotos.h"
#import <Photos/Photos.h>

@implementation BMAuthorizetionPhotos

/// Determine whether authorization is currently available.
+ (BOOL)isAuthorized
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    return status == PHAuthorizationStatusAuthorized;
}

/// Request photo authorizetion.
+ (void)requestAuthorizetionWithCompletion:(void (^)(BOOL, BOOL))completion
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status)
    {
        case PHAuthorizationStatusAuthorized:
        {
            if (completion)
            {
                completion(YES, NO);
            }
        }
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
        {
            if (completion)
            {
                completion(NO, NO);
            }
        }
            break;
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion)
                    {
                        completion(status == PHAuthorizationStatusAuthorized, YES);
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

//
//  BMAuthorizetionReminder.m
//  BMKit
//
//  Created by jiang deng on 2021/7/9.
//  Copyright © 2021 DennisDeng. All rights reserved.
//

#import "BMAuthorizetionReminder.h"
#import <EventKit/EventKit.h>

@implementation BMAuthorizetionReminder

/// Determine whether authorization is currently available.
+ (BOOL)isAuthorized
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    return status == EKAuthorizationStatusAuthorized;
}

/// Request reminder authorizetion.
+ (void)requestAuthorizetionWithCompletion:(void (^)(BOOL, BOOL))completion
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    switch (status)
    {
        case EKAuthorizationStatusAuthorized:
        {
            if (completion)
            {
                completion(YES, NO);
            }
        }
            break;
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            if (completion)
            {
                completion(NO, NO);
            }
        }
            break;
        case EKAuthorizationStatusNotDetermined:
        {
            [[[EKEventStore alloc] init] requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
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

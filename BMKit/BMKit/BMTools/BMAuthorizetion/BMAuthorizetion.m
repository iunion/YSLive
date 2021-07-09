//
//  BMAuthorizetion.m
//  BMKit
//
//  Created by jiang deng on 2021/7/9.
//  Copyright © 2021 DennisDeng. All rights reserved.
//

#import "BMAuthorizetion.h"
#import <UserNotifications/UserNotifications.h>

#import "BMAuthorizetionCalendar.h"
#import "BMAuthorizetionCamera.h"
#import "BMAuthorizetionContacts.h"
#import "BMAuthorizetionMicrophone.h"
#import "BMAuthorizetionPhotos.h"
#import "BMAuthorizetionReminder.h"

@implementation BMAuthorizetion

/// Determine whether authorization is currently available.
+ (BOOL)isAuthorizedWithType:(BMAuthorizetionType)type
{
    switch (type)
    {
        case BMAuthorizetionType_Camera:
        {
            return [BMAuthorizetionCamera isAuthorized];
        }
            break;
        case BMAuthorizetionType_Photos:
        {
            return [BMAuthorizetionPhotos isAuthorized];
        }
            break;
        case BMAuthorizetionType_Contacts:
        {
            return [BMAuthorizetionContacts isAuthorized];
        }
            break;
        case BMAuthorizetionType_Microphone:
        {
            return [BMAuthorizetionMicrophone isAuthorized];
        }
            break;
        case BMAuthorizetionType_Calendar:
        {
            return [BMAuthorizetionCalendar isAuthorized];
        }
            break;
        case BMAuthorizetionType_Reminder:
        {
            return [BMAuthorizetionReminder isAuthorized];
        }
            break;
        default:
        {
            return NO;
        }
            break;
    }
}

/// Request authorization.
+ (void)requestAuthorizetionWithType:(BMAuthorizetionType)type completion:(void (^)(BOOL, BOOL))completion
{
    switch (type)
    {
        case BMAuthorizetionType_Camera:
        {
            [BMAuthorizetionCamera requestAuthorizetionWithCompletion:completion];
        }
            break;
        case BMAuthorizetionType_Photos:
        {
            [BMAuthorizetionPhotos requestAuthorizetionWithCompletion:completion];
        }
            break;
        case BMAuthorizetionType_Contacts:
        {
            [BMAuthorizetionContacts requestAuthorizetionWithCompletion:completion];
        }
            break;
        case BMAuthorizetionType_Microphone:
        {
            [BMAuthorizetionMicrophone requestAuthorizetionWithCompletion:completion];
        }
            break;
        case BMAuthorizetionType_Calendar:
        {
            [BMAuthorizetionCalendar requestAuthorizetionWithCompletion:completion];
        }
            break;
        case BMAuthorizetionType_Reminder:
        {
            [BMAuthorizetionReminder requestAuthorizetionWithCompletion:completion];
        }
            break;
        default:
            break;
    }
}

// Check whether turned on push permission.
+ (void)checkNotificationAuthorizationWithResultBlock:(void (^)(BMNotificationAuthorizationType))resultBlock
{
    if (@available(iOS 10.0, *))
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            switch (settings.authorizationStatus)
            {
                case UNAuthorizationStatusAuthorized:
                {
                    if (resultBlock)
                    {
                        resultBlock(BMNotificationAuthorizationType_Authorization);
                    }
                }
                    break;
                case UNAuthorizationStatusDenied:
                {
                    if (resultBlock)
                    {
                        resultBlock(BMNotificationAuthorizationType_Denied);
                    }
                }
                    break;
                case UNAuthorizationStatusNotDetermined:
                {
                    if (resultBlock)
                    {
                        resultBlock(BMNotificationAuthorizationType_NotDetermined);
                    }
                }
                    break;
                default:
                    break;
            }
        }];
    }
    else
    {
        UIUserNotificationSettings *settings = [UIApplication sharedApplication].currentUserNotificationSettings;
        if (settings.types == UIUserNotificationTypeNone)
        {
            if (resultBlock)
            {
                resultBlock(BMNotificationAuthorizationType_Denied);
            }
        }
        else
        {
            if (resultBlock)
            {
                resultBlock(BMNotificationAuthorizationType_Authorization);
            }
        }
    }
}

@end

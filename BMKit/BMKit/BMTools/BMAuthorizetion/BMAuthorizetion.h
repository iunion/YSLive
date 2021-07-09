//
//  BMAuthorizetion.h
//  BMKit
//
//  Created by jiang deng on 2021/7/9.
//  Copyright © 2021 DennisDeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BMAuthorizetionType) {
    BMAuthorizetionType_Camera,                // Camera            NSCameraUsageDescription
    BMAuthorizetionType_Photos,                // Photos            NSPhotoLibraryUsageDescription     NSPhotoLibraryAddUsageDescription
    BMAuthorizetionType_Contacts,              // Contacts          NSContactsUsageDescription
    BMAuthorizetionType_Microphone,            // Microphone        NSMicrophoneUsageDescription
    BMAuthorizetionType_Calendar,              // Calendar          NSCalendarsUsageDescription
    BMAuthorizetionType_Reminder,              // Reminder          NSRemindersUsageDescription
};


typedef NS_ENUM(NSUInteger, BMNotificationAuthorizationType) {
    BMNotificationAuthorizationType_Authorization,         // 允许通知
    BMNotificationAuthorizationType_Denied,                // 拒绝通知
    BMNotificationAuthorizationType_NotDetermined,         // 还没有做决定(iOS 10之后才有)
};


NS_CLASS_AVAILABLE_IOS(8_0) @interface BMAuthorizetion : NSObject

/// Determine whether authorization is currently available.
+ (BOOL)isAuthorizedWithType:(BMAuthorizetionType)type;

/// Request authorization.
+ (void)requestAuthorizetionWithType:(BMAuthorizetionType)type completion:(void(^_Nullable)(BOOL granted, BOOL isFirst))completion;


 /// Check whether turned on push permission.
 /// 有些app对于没有打开通知，会有一个弹出框提示，提示去打开通知。调用此方法，就会获取当前应用的通知打开状态。不过，这儿有一点需要注意，一般第一次安装app时，都会弹出是否允许通知的弹出框，这是一个延迟事件，而这个方法是一个即时事件，因此，就会有个现象，调用此方法会返回denied或者NotDetermined状态，然而此时却正好是用户选择的时候。因此有种做法就是,可以在沙盒里面设置一个key，用于记录用户打开app(完全杀死进程，再打开)的次数，当打开次数为1的时候，不调用此方法；当大于1的时候，再调用此方法
+ (void)checkNotificationAuthorizationWithResultBlock:(void(^_Nullable)(BMNotificationAuthorizationType authorizationType))resultBlock NS_CLASS_AVAILABLE_IOS(8_0);

@end

NS_ASSUME_NONNULL_END

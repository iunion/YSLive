//
//  BMAuthorizetionCalendar.h
//  BMKit
//
//  Created by jiang deng on 2021/7/9.
//  Copyright © 2021 DennisDeng. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * the calendar authorizetion.
 */

NS_ASSUME_NONNULL_BEGIN

@interface BMAuthorizetionCalendar : NSObject

/// Determine whether authorization is currently available.
+ (BOOL)isAuthorized;

/// Request calendar authorizetion.
+ (void)requestAuthorizetionWithCompletion:(void(^_Nullable)(BOOL granted, BOOL isFirst))completion;

@end

NS_ASSUME_NONNULL_END

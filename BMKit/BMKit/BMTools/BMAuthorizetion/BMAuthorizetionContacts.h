//
//  BMAuthorizetionContacts.h
//  BMKit
//
//  Created by jiang deng on 2021/7/9.
//  Copyright © 2021 DennisDeng. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * the contacts authorizetion.
 */

NS_ASSUME_NONNULL_BEGIN

NS_CLASS_AVAILABLE_IOS(8_0) @interface BMAuthorizetionContacts : NSObject

/// Determine whether authorization is currently available.
+ (BOOL)isAuthorized;

/// Request contacts authorizetion.
+ (void)requestAuthorizetionWithCompletion:(void(^_Nullable)(BOOL granted, BOOL isFirst))completion;

@end

NS_ASSUME_NONNULL_END

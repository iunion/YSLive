//
//  BMAuthorizetionContacts.m
//  BMKit
//
//  Created by jiang deng on 2021/7/9.
//  Copyright © 2021 DennisDeng. All rights reserved.
//

#import "BMAuthorizetionContacts.h"
#import <Contacts/Contacts.h>
#import <AddressBook/AddressBook.h>

@implementation BMAuthorizetionContacts

/// Determine whether authorization is currently available.
+ (BOOL)isAuthorized
{
    BOOL res = NO;
    
    if (@available(iOS 9.0, *))
    {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        res = status == CNAuthorizationStatusAuthorized;
    }
    else
    {
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        res = status == kABAuthorizationStatusAuthorized;
    }
    
    return res;
}

/// Request contacts authorizetion.
+ (void)requestAuthorizetionWithCompletion:(void (^)(BOOL, BOOL))completion
{
    if (@available(iOS 9.0, *))
    {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        switch (status) {
            case CNAuthorizationStatusAuthorized:
            {
                if (completion)
                {
                    completion(YES, NO);
                }
            }
                break;
            case CNAuthorizationStatusDenied:
            case CNAuthorizationStatusRestricted:
            {
                if (completion)
                {
                    completion(NO, NO);
                }
            }
                break;
            case CNAuthorizationStatusNotDetermined:
            {
                [[[CNContactStore alloc] init] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
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
    else
    {
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        switch (status) {
            case kABAuthorizationStatusAuthorized:
            {
                if (completion)
                {
                    completion(YES, NO);
                }
            }
                break;
            case kABAuthorizationStatusDenied:
            case kABAuthorizationStatusRestricted:
            {
                if (completion)
                {
                    completion(NO, NO);
                }
            }
                break;
            case kABAuthorizationStatusNotDetermined:
            {
                ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
                ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion)
                        {
                            completion(granted, YES);
                        }
                    });
                });
            }
                break;
            default:
                break;
        }
    }
}

@end

//
//  BMApp.m
//  BMBaseKit
//
//  Created by jiang deng on 2018/6/14.
//  Copyright © 2018年 BM. All rights reserved.
//

#import "BMApp.h"

static NSString * const BMAppHasBeenOpenedKey       = @"BMApp.hasBeenOpened";

static NSString * const BMAppLastVersionKey         = @"BMApp.lastVersion";
static NSString * const BMAppLastBuildVersionKey    = @"BMApp.lastBuildVersion";

@implementation BMApp

+ (void)onFirstStartApp:(firstStartAppHandler)block
{
    [BMApp onFirstStartApp:block withKey:BMAPP_NAME];
}

+ (void)onFirstStartApp:(firstStartAppHandler)block withKey:(NSString *)key;
{
    NSString *appkey = BMAppHasBeenOpenedKey;
    if ([appkey bm_isNotEmpty])
    {
        appkey = [NSString stringWithFormat:@"%@_%@", BMAppHasBeenOpenedKey, key];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasBeenOpened = [defaults boolForKey:appkey];
    if (hasBeenOpened != true)
    {
        [defaults setBool:YES forKey:appkey];
        [defaults synchronize];
    }
    
    block(BMAPP_VERSION, BMAPP_BUILD, hasBeenOpened);
}

+ (void)onFirstStartForVersion:(NSString *)version
                         block:(firstStartHandler)block
{
    [BMApp onFirstStartForVersion:version block:block withKey:BMAPP_NAME];
}

+ (void)onFirstStartForVersion:(NSString *)version
                         block:(firstStartHandler)block
                       withKey:(NSString *)key
{
    // version > lastVersion && version <= appVersion
    if ([version compare:[BMApp lastVersionWithKey:key] options:NSNumericSearch] == NSOrderedDescending &&
        [version compare:BMAPP_VERSION options:NSNumericSearch] != NSOrderedDescending)
    {
        block(YES);
        
#ifdef DEBUG
        BMLog(@"BMApp: Running migration for version %@", version);
#endif
        
        [BMApp setLastVersion:version withKey:key];
    }
    else
    {
        block(NO);
    }
}

+ (void)onFirstStartForBuildVersion:(NSString *)buildVersion
                              block:(firstStartHandler)block
{
    [BMApp onFirstStartForBuildVersion:buildVersion block:block withKey:BMAPP_NAME];
}

+ (void)onFirstStartForBuildVersion:(NSString *)buildVersion
                              block:(firstStartHandler)block
                            withKey:(NSString *)key
{
    // buildVersion > lastBuildVersion && buildVersion <= appBuildVersion
    if ([buildVersion compare:[BMApp lastBuildVersionWithKey:key] options:NSNumericSearch] == NSOrderedDescending &&
        [buildVersion compare:BMAPP_BUILD options:NSNumericSearch] != NSOrderedDescending)
    {
        block(YES);
        
#ifdef DEBUG
        BMLog(@"BMApp: Running migration for buildVersion %@", buildVersion);
#endif
        
        [BMApp setLastBuildVersion:buildVersion withKey:key];
    }
    else
    {
        block(NO);
    }
}

+ (void)onFirstStartForCurrentVersion:(firstStartHandler)block
{
    [BMApp onFirstStartForCurrentVersion:block withKey:BMAPP_NAME];
}

+ (void)onFirstStartForCurrentVersion:(firstStartHandler)block withKey:(NSString *)key
{
    if (![[BMApp lastVersionWithKey:key] isEqualToString:BMAPP_VERSION])
    {
        block(YES);

#ifdef DEBUG
        BMLog(@"BMApp: Running update Block for version %@", BMAPP_VERSION);
#endif
        
        [BMApp setLastVersion:BMAPP_VERSION withKey:key];
    }
}

+ (void)onFirstStartForCurrentBuildVersion:(firstStartHandler)block
{
    [BMApp onFirstStartForCurrentBuildVersion:block withKey:BMAPP_NAME];
}

+ (void)onFirstStartForCurrentBuildVersion:(nonnull firstStartHandler)block withKey:(nullable NSString *)key
{
    if (![[BMApp lastBuildVersionWithKey:key] isEqualToString:BMAPP_BUILD])
    {
        block(YES);
        
#ifdef DEBUG
        BMLog(@"BMApp: Running update Block for buildVersion %@", BMAPP_BUILD);
#endif
        
        [BMApp setLastBuildVersion:BMAPP_BUILD withKey:key];
    }
}


#pragma mark - UserDefaults

+ (void)reset
{
    [BMApp resetWithKey:BMAPP_NAME];
}

+ (void)resetWithKey:(NSString *)key
{
    NSString *appkey = BMAppHasBeenOpenedKey;
    if ([appkey bm_isNotEmpty])
    {
        appkey = [NSString stringWithFormat:@"%@_%@", BMAppHasBeenOpenedKey, key];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:appkey];
    
    [BMApp setLastVersion:nil withKey:key];
    [BMApp setLastBuildVersion:nil withKey:key];
}

+ (NSString *)lastVersionWithKey:(NSString *)key
{
    NSString *appkey = BMAppLastVersionKey;
    if ([appkey bm_isNotEmpty])
    {
        appkey = [NSString stringWithFormat:@"%@_%@", BMAppLastVersionKey, key];
    }
    
    NSString *res = [[NSUserDefaults standardUserDefaults] valueForKey:appkey];
    return (res ? res : @"");
}

+ (void)setLastVersion:(NSString *)version withKey:(NSString *)key
{
    NSString *appkey = BMAppLastVersionKey;
    if ([appkey bm_isNotEmpty])
    {
        appkey = [NSString stringWithFormat:@"%@_%@", BMAppLastVersionKey, key];
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:version forKey:appkey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)lastBuildVersionWithKey:(NSString *)key
{
    NSString *appkey = BMAppLastBuildVersionKey;
    if ([appkey bm_isNotEmpty])
    {
        appkey = [NSString stringWithFormat:@"%@_%@", BMAppLastBuildVersionKey, key];
    }
    
    NSString *res = [[NSUserDefaults standardUserDefaults] valueForKey:appkey];
    return (res ? res : @"");
}

+ (void)setLastBuildVersion:(NSString *)version withKey:(NSString *)key
{
    NSString *appkey = BMAppLastBuildVersionKey;
    if ([appkey bm_isNotEmpty])
    {
        appkey = [NSString stringWithFormat:@"%@_%@", BMAppLastBuildVersionKey, key];
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:version forKey:appkey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/// make call.
+ (void)makeCallWithPhoneNum:(NSString *)phoneNum
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![phoneNum bm_isNotEmpty])
        {
            return;
        }
        
        NSString *string = [NSString stringWithFormat:@"tel://%@", phoneNum];
        NSURL *url = [NSURL URLWithString:string];
        
        if (@available(iOS 10.0, *))
        {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
        else
        {
            [[UIApplication sharedApplication] openURL:url];
        }
    });
}

/// open app settings.
+ (void)openAppSettings
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 10.0, *))
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }
        else
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    });
}

/// Open App Store Review.
+ (void)openAppStoreReviewWithAppId:(NSString *)appId
{
    NSString *appURL = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@?action=write-review", appId];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (@available(iOS 10.0, *))
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURL] options:@{} completionHandler:nil];
        }
        else
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURL]];
        }
    });
}

/// Open App Store.
+ (void)openAppStoreWithAppId:(NSString *)appId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", appId];
        NSURL *url = [NSURL URLWithString:urlString];
        if (@available(iOS 10.0, *))
        {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
        else
        {
            [[UIApplication sharedApplication] openURL:url];
        }
    });
}

/// Open Safari.
+ (void)openSafariWithURL:(NSString *)url
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *tmpURL = url;
        NSURL *URL = [NSURL URLWithString:tmpURL];
        
        if (@available(iOS 10.0, *))
        {
            [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:^(BOOL success) {
                if (!success)
                {
                    if (![tmpURL hasPrefix:@"http://"])
                    {
                        // 先判断 http:// 能不能打开
                        NSString *modifyURL = [NSString stringWithFormat:@"http://%@", tmpURL];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:modifyURL] options:@{} completionHandler:^(BOOL success) {
                            if (!success)
                            {
                                if (![tmpURL hasPrefix:@"https://"])
                                {
                                    // 再判断 https:// 能不能打开
                                    NSString *modifyURL = [NSString stringWithFormat:@"https://%@", tmpURL];
                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:modifyURL] options:@{} completionHandler:nil];
                                }
                            }
                        }];
                    }
                }
            }];
        } else {
            BOOL res1 = [[UIApplication sharedApplication] openURL:URL];
            if (!res1)
            {
                if (![tmpURL hasPrefix:@"http://"])
                {
                    // 先判断 http:// 能不能打开
                    NSString *modifyURL = [NSString stringWithFormat:@"http://%@", tmpURL];
                    BOOL res2 = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:modifyURL]];
                    if (!res2)
                    {
                        if (![tmpURL hasPrefix:@"https://"])
                        {
                            // 再判断 https:// 能不能打开
                            NSString *modifyURL = [NSString stringWithFormat:@"https://%@", tmpURL];
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:modifyURL]];
                        }
                    }
                }
            }
        }
    });
}

@end

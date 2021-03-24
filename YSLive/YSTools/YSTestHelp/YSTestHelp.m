//
//  YSTestHelp.m
//  YSLive
//
//  Created by jiang deng on 2019/10/12.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSTestHelp.h"
#include <asl.h>

#import "YSLiveMacros.h"

#import "YSAPIMacros.h"
#import "AppDelegate.h"
#import <BMKit/BMAlertView.h>

#import "YSLiveManager.h"

@implementation YSTestHelp

- (void)dealloc
{
}

// 获取一个sharedInstance实例，如果有必要的话，实例化一个
+ (YSTestHelp *)sharedInstance
{
    static YSTestHelp *sharedTestHelper = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedTestHelper = [[[self class] alloc] init];
    });
    
    return sharedTestHelper;
}

+ (NSArray *)roomIdArray
{
    static NSArray <NSDictionary *> *roomIds = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //#define YSLive_RoomId @"1195050735"  //小班课 IOS_1V多_  16：9
        //#define YSLive_RoomId @"922739244"  //小班课 IOS_1V多_  4：3
        //#define YSLive_RoomId       @"1164674398" //小班课IOS_1V1_ 16:9
        //#define YSLive_RoomId       @"1672617739" //小班课IOS_1V1_  4:3
        //#define YSLive_RoomId       @"1011757934"  //直播
        
        NSDictionary *roomDic1 = @{@"roomid" : @"1195050735", @"explanation" : @"小班课 iOS_1VN 16：9"};
        NSDictionary *roomDic2 = @{@"roomid" : @"922739244", @"explanation" : @"小班课 iOS_1VN 4：3"};
        NSDictionary *roomDic3 = @{@"roomid" : @"1164674398", @"explanation" : @"小班课 iOS_1V1 16：9"};
        NSDictionary *roomDic4 = @{@"roomid" : @"1672617739", @"explanation" : @"小班课 iOS_1V1 4：3"};
        NSDictionary *roomDic5 = @{@"roomid" : @"1011757934", @"explanation" : @"直播iOS"};

        roomIds = [NSArray arrayWithObjects:roomDic1, roomDic2, roomDic3, roomDic4, roomDic5, nil];
    });
    
    return roomIds;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        // BMConsole初始化，deviceShakeToShow(摇动开启)默认设为NO，开启请设为YES
        [BMConsole sharedConsole].delegate = self;
        [BMConsole sharedConsole].deviceShakeToShow = YES;
        
        [self setDebugServer];
    }
    
    return self;
}

- (void)setDebugServer
{
    // 初始化配置
    NSString *serverUrl = [[NSUserDefaults standardUserDefaults] objectForKey:YSLIVE_HOST_KEY];
    if (!serverUrl)
    {
        [[NSUserDefaults standardUserDefaults] setObject:YSLIVE_HOST_INIT forKey:YSLIVE_HOST_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
//        [YSLiveManager shareInstance].liveHost = YSLIVE_HOST;
    }
    
    NSString *signinAdressUrl = [[NSUserDefaults standardUserDefaults] objectForKey:YS_SIGNINADDRESS_KEY];
    if (!signinAdressUrl)
    {
        [[NSUserDefaults standardUserDefaults] setObject:YS_SIGNINADDRESS_INIT forKey:YS_SIGNINADDRESS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString *flowerAdressUrl = [[NSUserDefaults standardUserDefaults] objectForKey:YS_FLOWERADDRESS_KEY];
    if (!flowerAdressUrl)
    {
        [[NSUserDefaults standardUserDefaults] setObject:YS_FLOWERADDRESS_INIT forKey:YS_FLOWERADDRESS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString *roomIdIndex = [[NSUserDefaults standardUserDefaults] objectForKey:YSLIVE_ROOMIDINDEX_KEY];
    if (!roomIdIndex)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:YSLIVE_ROOMIDINDEX_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - BMConsole Delegate

// 按键事件
- (void)handleConsoleButton:(UIButton *)sender
{
    
}

- (BOOL)handleConsoleCommand:(NSString *)command
{
    return [self handleConsoleCommand:command withParameter:nil];
}

- (BOOL)handleConsoleCommand:(NSString *)command withParameter:(id)parameter
{
    if (![command bm_isNotEmpty])
    {
        return YES;
    }
    
    BOOL ret = NO;
    [BMConsole log:@"\n==========================================="];

    if ([command isEqualToString:@"api"])  // 查看API路径情况
    {
        ret = YES;
        [BMConsole log:@"当前API运行环境是'%@'", YSLIVE_HOST];
        //[BMConsole log:@"当前H5运行环境是'%@'", YS_H5_SERVER];
        
        NSNumber *roomIndex = [[NSUserDefaults standardUserDefaults] objectForKey:YSLIVE_ROOMIDINDEX_KEY];
        NSDictionary *roomIdDic = [YSTestHelp roomIdArray][roomIndex.integerValue];
        [BMConsole log:@"当前房间为%@: %@", roomIdDic[@"roomid"], roomIdDic[@"explanation"]];
    }
    else if ([command isEqualToString:@"www"] || [command isEqualToString:@"on"])
    {
        ret = YES;
        NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:YSLIVE_HOST_KEY];
        if (![server isEqualToString:YSLIVE_HOST_ONLINE])
        {
            [[NSUserDefaults standardUserDefaults] setObject:YSLIVE_HOST_ONLINE forKey:YSLIVE_HOST_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:YS_SIGNINADDRESS_ONLINE forKey:YS_SIGNINADDRESS_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:YS_FLOWERADDRESS_ONLINE forKey:YS_FLOWERADDRESS_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [YSLiveManager sharedInstance].apiHost = YSLIVE_HOST;
            
            [BMConsole log:@"当前api已经变更为'线上'"];
            
        }
        else
        {
            [BMConsole log:@"当前api运行环境为'线上'"];
        }
    }
    else if ([command isEqualToString:@"dev"])
    {
        ret = YES;
        NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:YSLIVE_HOST_KEY];
        if (![server isEqualToString:YSLIVE_HOST_DEV])
        {
            [[NSUserDefaults standardUserDefaults] setObject:YSLIVE_HOST_DEV forKey:YSLIVE_HOST_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:YS_SIGNINADDRESS_DEV forKey:YS_SIGNINADDRESS_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:YS_FLOWERADDRESS_DEV forKey:YS_FLOWERADDRESS_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [YSLiveManager sharedInstance].apiHost = YSLIVE_HOST;
            
            [BMConsole log:@"当前api已经变更为'开发'"];
        }
        else
        {
            [BMConsole log:@"当前api运行环境为'开发'"];
        }
    }
    else if ([command isEqualToString:@"test"])
    {
        ret = YES;
        NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:YSLIVE_HOST_KEY];
        if (![server isEqualToString:YSLIVE_HOST_TEST])
        {
            [[NSUserDefaults standardUserDefaults] setObject:YSLIVE_HOST_TEST forKey:YSLIVE_HOST_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:YS_SIGNINADDRESS_TEST forKey:YS_SIGNINADDRESS_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:YS_FLOWERADDRESS_TEST forKey:YS_FLOWERADDRESS_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [YSLiveManager sharedInstance].apiHost = YSLIVE_HOST;
            
            [BMConsole log:@"当前api已经变更为'测试'"];
        }
        else
        {
            [BMConsole log:@"当前api运行环境为'测试'"];
        }
    }
    else if ([command isEqualToString:@"room"])
    {
        ret = YES;
        
        NSString *string = [NSString stringWithFormat:@"%@", [YSTestHelp roomIdArray]];
        string = [string bm_convertUnicode];
        [BMConsole log:@"%@：%@",YSLocalized(@"Label.Room"), string];
        
        NSNumber *roomIndex = [[NSUserDefaults standardUserDefaults] objectForKey:YSLIVE_ROOMIDINDEX_KEY];
        NSDictionary *roomIdDic = [YSTestHelp roomIdArray][roomIndex.integerValue];
        [BMConsole log:@"当前房间为%@: %@", roomIdDic[@"roomid"], roomIdDic[@"explanation"]];
    }
    else if ([command isEqualToString:@"room1"] ||
             [command isEqualToString:@"room2"] ||
             [command isEqualToString:@"room3"] ||
             [command isEqualToString:@"room4"] ||
             [command isEqualToString:@"room5"] ||
             [command isEqualToString:@"r1"] ||
             [command isEqualToString:@"r2"] ||
             [command isEqualToString:@"r3"] ||
             [command isEqualToString:@"r4"] ||
             [command isEqualToString:@"r5"]
             )
    {
        ret = YES;
        
        unichar c = [command characterAtIndex:command.length-1];
        NSUInteger index = (c-'1');
        
        NSNumber *roomIndex = [[NSUserDefaults standardUserDefaults] objectForKey:YSLIVE_ROOMIDINDEX_KEY];
        if (index != roomIndex.integerValue)
        {
            [[NSUserDefaults standardUserDefaults] setObject:@(index) forKey:YSLIVE_ROOMIDINDEX_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        NSDictionary *roomIdDic = [YSTestHelp roomIdArray][index];
        [BMConsole log:@"当前房间变更为%@: %@", roomIdDic[@"roomid"], roomIdDic[@"explanation"]];
    }
    /*else if ([command isEqualToString:@"w"] || [command isEqualToString:@"web"])
    {
        ret = YES;
        
        if ([FSTestHelper usingUIWebView])
        {
            [BMConsole log:@"WebView控件 UIWebView"];
        }
        else
        {
            [BMConsole log:@"WebView控件 WKWebView"];
        }
    }
    else if ([command isEqualToString:@"w ui"] || [command isEqualToString:@"web ui"])
    {
        ret = YES;
        
        [FSTestHelper setUsingUIWebView:YES];
        [BMConsole log:@"WebView控件切换为UIWebView"];
    }
    else if ([command isEqualToString:@"w wk"] || [command isEqualToString:@"web wk"])
    {
        ret = YES;
        
        [FSTestHelper setUsingUIWebView:NO];
        [BMConsole log:@"WebView控件切换为WKWebView"];
    }
    else */ if ([command isEqualToString:@"h"] || [command isEqualToString:@"help"]) // help命令
    {
        ret = YES;
        NSMutableString *helpStr = [[NSMutableString alloc] init];
        [helpStr appendString:@"\n(01) 'help' 显示命令帮助文档\n"];
        [helpStr appendString:@"(02) 'version' 显示app版本\n"];
        [helpStr appendString:@"(03) 'clear' 清除控制台信息\n"];
        [helpStr appendString:@"(04) 'log' 打印所有NSLog\n"];
        [helpStr appendString:@"(05) 'app' 显示APP基本信息\n"];
        [helpStr appendString:@"(06) 'api' 显示当前所处API环境信息\n"];
        [helpStr appendString:@"(07) 'on' or 'www' 切换API环境到线上\n"];
        [helpStr appendString:@"(08) 'dev' 切换API环境到开发\n"];
        [helpStr appendString:@"(09) 'test' 切换API环境到测试\n"];
        [helpStr appendString:@"(10) 'fps' 显示隐藏FPS监测\n"];
        [helpStr appendString:@"(11) 'al' 显示隐藏标尺\n"];
        [helpStr appendString:@"(12) 'cp' 显示隐藏颜色提取\n"];
        [helpStr appendString:@"(13) 'gps' 模拟GPS定位数据\n"];
        [helpStr appendString:@"(14) 'mn' 网络监控开关\n"];
        [helpStr appendString:@"(15) 'nf' 网络监控表\n"];
        [helpStr appendString:@"(16) 'web' WebView控件切换 ui wk\n"];
        [helpStr appendString:@"(17) 'r 1-5' 切换房间\n"];
        [helpStr appendString:@"(18) 'room 1-5' 切换房间\n"];
        [helpStr appendString:@"(18) 'room' 显示房间\n"];
        [BMConsole log:@"%@", helpStr];
    }
    /*else if ([command containsString:@"://"])
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:command]])
        {
            ret = YES;
            [BMConsole hide];
            
            FSWebViewController *vc = [[FSWebViewController alloc] initWithTitle:nil url:command];
            [[GetAppDelegate.m_TabBarController getCurrentViewController].navigationController pushViewController:vc animated:YES];
            
            [BMConsole log:@"浏览 %@", command];
        }
    }*/
    
    self.preCommand = command;
    
    return ret;
}

- (void)exitApplication
{
    UIWindow *window = GetAppDelegate.window;
    
    [UIView animateWithDuration:1.0f animations:^{
        window.alpha = 0;
        window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
    } completion:^(BOOL finished) {
        exit(0);
    }];
}


@end

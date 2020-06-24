//
//  YSAppConfig.h
//  YSLive
//
//  Created by fzxm on 2019/10/11.
//  Copyright © 2019 FS. All rights reserved.
//

#ifndef YSAppConfig_h
#define YSAppConfig_h

// 测试
#ifdef __OPTIMIZE__
#define USE_TEST_HELP           0
#else
#if YSSDK
#define USE_TEST_HELP           0
#else
#define USE_TEST_HELP           1
#endif
#endif

#if USE_TEST_HELP
#define FLEX_BM                 1
#endif

#import "YSAppMacros.h"
#import "YSAppUIDef.h"

#import <BMKit/BMKitThird.h>

#import <YSSession/YSSession.h>
#import <YSWhiteBoard/YSWhiteBoard.h>
#import <YSWhiteBoard/YSWhiteBoardManager.h>

#import "YSLiveMacros.h"
#import "YSAppMacros.h"

#import "YSLiveManager.h"

#import "YSUserDefault.h"
#import "YSLiveSkinManager.h"

#if YSSDK
#else
#import "YSSchoolUser.h"
#endif

#define YSKeyWindow [UIApplication sharedApplication].keyWindow


#endif /* YSAppConfig_h */

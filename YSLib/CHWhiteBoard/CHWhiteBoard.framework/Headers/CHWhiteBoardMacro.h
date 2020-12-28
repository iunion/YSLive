//
//  CHWhiteBoardMacro.h
//  CHWhiteBoard
//
//

#ifndef CHWhiteBoardMacro_h
#define CHWhiteBoardMacro_h

//#ifndef __OPTIMIZE__
//#define NSLog(...) NSLog(__VA_ARGS__)
//#else
//#define NSLog(...)
//#endif

#if CHSingle_WhiteBoard

/// 小黑板功能
#define WBHaveSmallBalckBoard                          0
#define WBLocalUser                             [CloudHubWhiteBoardKit sharedInstance]
#define WBManager                               [CloudHubWhiteBoardKit sharedInstance]

#else

/// 小黑板功能
#define WBHaveSmallBalckBoard                          1
#define WBLocalUser                             [CHSessionManager sharedInstance].localUser
#define WBManager                               [CHSessionManager sharedInstance]

#endif


#define CHWBBUNDLE_NAME     @"CHWhiteBoardResources.bundle"
#define CHWBBUNDLE          [NSBundle bundleWithPath: [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:CHWBBUNDLE_NAME]]
#define CHWBLocalized(s)    [CHWBBUNDLE localizedStringForKey:s value:@"" table:nil]

/// 文本框输入工具的text控件tag
#define CHWHITEBOARD_TEXTVIEWTAG    20190109

/// 课件缩放范围
#define CHWHITEBOARD_MAXZOOMSCALE   (3.0f)
#define CHWHITEBOARD_MINZOOMSCALE   (1.0f)

#define CHTopBarHeight 30.0

#pragma mark - 1.读取本地index  0.读取指定   ssssssssss
#define IS_LOAD_LOCAL_INDEX 1

#if IS_LOAD_LOCAL_INDEX
// 读取本地时通常为发布版本需要设置成https端口443
    #define CHWBHTTPS       @"https"
    #define CHWBPort        @"443"

#else

    #define CHWBHTTPS       @"http"
    #define CHWBPort        @"80"
    #define PointToHost     @"192.168.1.118:9251"

#endif


#endif /* CHWhiteBoardMacro_h */

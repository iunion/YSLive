//
//  YSWhiteBoardConfiguration.h
//  YSWhiteBoard
//
//  Created by MAC-MiNi on 2018/4/12.
//  Copyright © 2018年 MAC-MiNi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define YSWHITEBOARD_TEXTVIEWTAG    20190109

#define YSWHITEBOARD_MAXZOOMSCALE   (3.0f)
#define YSWHITEBOARD_MINZOOMSCALE   (1.0f)


extern NSString *const YSWhiteBoardWebProtocolKey;
extern NSString *const YSWhiteBoardWebHostKey;
extern NSString *const YSWhiteBoardWebPortKey;
extern NSString *const YSWhiteBoardPlayBackKey;// 是否是回放
extern NSString *const YSWBMainContentComponent;// 主白板程序


// 通知
extern NSNotificationName const YSWhiteBoardRemoteSelectTool;// 是否选择画笔工具 鼠标
extern NSString *const YSWhiteBoardPreloadExit;// 预加载过程退出教室


#define YSWhiteBoard_HttpDnsService_AccountID   131798

/// 网宿host头
static NSString *const YSWhiteBoard_domain_ws_header = @"rddoccdnws.roadofcloud";
static NSString *const YSWhiteBoard_domain_demows_header = @"rddoccdndemows.roadofcloud";
/// 网宿host
static NSString *const YSWhiteBoard_domain_ws = @"rddoccdnws.roadofcloud.com";
static NSString *const YSWhiteBoard_domain_demows = @"rddoccdndemows.roadofcloud.com";

/// 网宿dns解析
static NSString *const YSWhiteBoard_wshttpdnsurl = @"http://edge.wshttpdns.com/v1/httpdns/clouddns";

#define YSWHITEBOARD_USEHTTPDNS 1
//#if YSSDK
#define YSWHITEBOARD_USEHTTPDNS_ADDALI 0
//#else
//#define YSWHITEBOARD_USEHTTPDNS_ADDALI 1
//#endif

#if YSWHITEBOARD_USEHTTPDNS_ADDALI
/// 阿里host头
static NSString *const YSWhiteBoard_domain_ali_header = @"rddoccdn.roadofcloud";
static NSString *const YSWhiteBoard_domain_demoali_header = @"rddocdemo.roadofcloud";
/// 阿里host
static NSString *const YSWhiteBoard_domain_ali = @"rddoccdn.roadofcloud.com";
static NSString *const YSWhiteBoard_domain_demoali = @"rddocdemo.roadofcloud.com";
#endif

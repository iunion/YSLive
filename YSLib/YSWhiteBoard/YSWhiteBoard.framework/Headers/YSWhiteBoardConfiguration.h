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


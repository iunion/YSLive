//
//  YSWhiteBroadDelegate.h
//  YSWhiteBroad
//
//  Created by MAC-MiNi on 2018/4/9.
//  Copyright © 2018年 MAC-MiNi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YSWhiteBoardManagerDelegate <NSObject>

@required

/**
 文件列表回调
 @param fileList 文件列表 是一个NSArray类型的数据
 */
- (void)onWhiteBroadFileList:(NSArray *)fileList;

/**
PubMsg消息
 */
- (void)onWhiteBroadPubMsgWithMsgID:(NSString *)msgID
                            msgName:(NSString *)msgName
                               data:(NSObject *)data
                             fromID:(NSString *)fromID
                             inList:(BOOL)inlist
                                 ts:(long)ts;

/**
 msglist消息

 @param msgList 消息
 */
- (void)onWhiteBoardOnRoomConnectedMsglist:(NSDictionary *)msgList;

/**
 界面更新
 */
- (void)onWhiteBoardViewStateUpdate:(NSDictionary *)message;

/**
 教室加载状态
 
 */
- (void)onWhiteBoardLoadedState:(NSDictionary *)message;


/// 本地操作，缩放课件比例变化
/// 动态ppt，H5课件，GIF动图，SVG图不支持放大缩小
- (void)onWhiteBoardFileViewZoomScaleChanged:(CGFloat)zoomScale;


@end


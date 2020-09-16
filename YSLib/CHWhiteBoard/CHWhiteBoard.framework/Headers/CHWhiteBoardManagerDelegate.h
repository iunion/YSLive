//
//  CHWhiteBoardManagerDelegate.h
//  CHWhiteBoard
//
//

#ifndef CHWhiteBoardManagerDelegate_h
#define CHWhiteBoardManagerDelegate_h

#import <Foundation/Foundation.h>
#import "CHWhiteBoardEnum.h"

@protocol CHWhiteBoardManagerDelegate <NSObject>

@required

/// 白板准备完毕
- (void)onWhiteBroadCheckRoomFinish:(BOOL)finished;

/**
 文件列表回调
 @param fileList 文件NSDictionary列表
 */
- (void)onWhiteBroadFileList:(NSArray *)fileList;

/// H5脚本文件加载初始化完成
- (void)onWhiteBoardPageFinshed:(NSString *)fileId;

/// 切换Web课件加载状态
- (void)onWhiteBoardLoadedState:(NSString *)fileId withState:(NSDictionary *)dic;

/// Web课件翻页结果
- (void)onWhiteBoardStateUpdate:(NSString *)fileId withState:(NSDictionary *)dic;
/// 翻页超时
- (void)onWhiteBoardSlideLoadTimeout:(NSString *)fileId withState:(NSDictionary *)dic;
/// 课件缩放
- (void)onWhiteBoardZoomScaleChanged:(NSString *)fileId zoomScale:(CGFloat)zoomScale;


#pragma mark - 课件事件

/// 课件全屏
- (void)onWhiteBoardFullScreen:(BOOL)isAllScreen;

/// 切换课件
- (void)onWhiteBoardChangedFileWithFileList:(NSArray *)fileList;
/// 媒体播放状态
- (void)onWhiteBoardChangedMediaFileStateWithFileId:(NSString *)fileId state:(CHMediaState)state;

/// 课件窗口最大化事件
- (void)onWhiteBoardMaximizeView;


#if WBHaveSmallBalckBoard
/// 小黑板状态变化（更改画笔）
- (void)onSetSmallBoardStageState:(CHSmallBoardStageState)smallBoardStageState;

/// 小黑板bottomBar的代理
- (void)onSmallBoardBottomBarClick:(UIButton *)sender;

/// 小黑板答题阶段私聊
- (void)handleSignalingReceivePrivateChatWithPrivateIdArray:(NSArray *)privateIdArray;
- (void)handleSignalingDeletePrivateChat;

#endif


@end

#endif /* CHWhiteBoardManagerDelegate_h */

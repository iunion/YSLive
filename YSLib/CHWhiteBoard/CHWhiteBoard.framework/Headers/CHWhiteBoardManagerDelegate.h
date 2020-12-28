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

@optional

/// 白板管理准备完毕
- (void)onWhiteBroadCheckRoomFinish:(BOOL)finished;

/// 白板管理初始化失败
- (void)onWhiteBroadCreateFail;


#pragma mark - 以下是在 onWhiteBroadCheckRoomFinish: 回调之后触发

/// 文件列表回调
/// @param fileList 文件NSDictionary列表
- (void)onWhiteBroadFileList:(NSArray <NSDictionary *> *)fileList;

#pragma mark - 交互课件加载事件

/// H5脚本文件加载初始化完成
- (void)onWhiteBoardPageFinshed:(NSString *)fileId;

/// 切换交互课件加载状态
- (void)onWhiteBoardLoadedState:(NSString *)fileId withState:(NSDictionary *)dic DEPRECATED_MSG_ATTRIBUTE("use onWhiteBoardLoadInterCourse:isSuccess: instead");
- (void)onWhiteBoardLoadInterCourse:(NSString *)fileId isSuccess:(BOOL)isSuccess;

/// Web课件翻页结果
- (void)onWhiteBoardStateUpdate:(NSString *)fileId withState:(NSDictionary *)dic DEPRECATED_MSG_ATTRIBUTE("use onWhiteBoardSlideCourse:currentPage:isSuccess: instead");
/// 翻页超时
- (void)onWhiteBoardSlideLoadTimeout:(NSString *)fileId withState:(NSDictionary *)dic DEPRECATED_MSG_ATTRIBUTE("use onWhiteBoardSlideCourse:currentPage:isSuccess: instead");

#pragma mark - 普通课件加载事件

/// 普通课件加载完成状态
- (void)onWhiteBoardPageLoadFinshed:(NSString *)fileId isSuccess:(BOOL)isSuccess DEPRECATED_MSG_ATTRIBUTE("use onWhiteBoardSlideCourse:currentPage:isSuccess: instead");

#pragma mark - 课件翻页加载事件

/// 课件翻页显示结果
- (void)onWhiteBoardSlideCourse:(NSString *)fileId currentPage:(NSUInteger)currentPage isSuccess:(BOOL)isSuccess;

#pragma mark - 课件操作事件

/// 课件缩放
- (void)onWhiteBoardZoomScaleChanged:(NSString *)fileId zoomScale:(CGFloat)zoomScale;

/// 课件全屏
- (void)onWhiteBoardFullScreen:(BOOL)isAllScreen;

/// 当前打开的课件列表
- (void)onWhiteBoardChangedFileWithFileList:(NSArray *)fileList;
/// 媒体课件播放状态
- (void)onWhiteBoardChangedMediaFileStateWithFileId:(NSString *)fileId state:(CHMediaState)state;

/// 课件窗口最大化事件
- (void)onWhiteBoardMaximizeView;

#if CHSingle_WhiteBoard
/// 关闭课件窗口
- (void)onWhiteBoardCloseFileWithFileId:(NSString *)fileId;
#endif

#if WBHaveSmallBalckBoard
/// 小黑板状态变化（更改画笔）
- (void)onSetSmallBoardStageState:(CHSmallBoardStageState)smallBoardStageState;

/// 小黑板bottomBar的代理
- (void)onSmallBoardBottomBarClick:(UIButton *)sender;

/// 小黑板答题阶段私聊
- (void)handleSignalingReceivePrivateChatWithPrivateIdArray:(NSArray *)privateIdArray;
- (void)handleSignalingDeletePrivateChat;

#endif

/// 画笔相关undo，redo，clear，eraser工具的可用状态
- (void)changeUndoRedoState:(NSString *)fileid currentpage:(NSUInteger)currentPage canUndo:(BOOL)canUndo canRedo:(BOOL)canRedo canErase:(BOOL)canErase canClean:(BOOL)canClean;

@end

#endif /* CHWhiteBoardManagerDelegate_h */

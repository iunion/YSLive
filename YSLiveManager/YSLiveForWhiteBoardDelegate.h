//
//  YSLiveForWhiteBoardDelegate.h
//  YSLive
//
//  Created by jiang deng on 2020/6/25.
//  Copyright © 2020 YS. All rights reserved.
//

#ifndef YSLiveForWhiteBoardDelegate_h
#define YSLiveForWhiteBoardDelegate_h

@protocol YSLiveForWhiteBoardDelegate <NSObject>

@optional

/// 当前展示的课件列表（fileid）
- (void)handleonWhiteBoardChangedFileWithFileList:(NSArray *)fileList;
/// 删除课件
- (void)handleonWhiteBoardDeleteFile;

/// 关闭课件窗口
- (void)handleonWhiteBoardDeleteWhiteBoardWindow:(CHWhiteBoardWindow *)whiteBoardWindow;
/// 课件全屏
- (void)handleonWhiteBoardFullScreen:(BOOL)isAllScreen;
/// 课件最大化
- (void)handleonWhiteBoardMaximizeView;
/// 课件打开失败
- (void)handleonWhiteBoardOpenFailedIsUpload:(BOOL)isUpload;
/// 媒体课件状态
- (void)handleonWhiteBoardMediaFileStateWithFileId:(NSString *)fileId state:(CHWhiteBoardShareMediaState)state;
/// 共享媒体播放回调
- (void)handleWhiteBoardShareMediaStartPlay:(NSString *)uid
                                   streamId:(NSString *)streamId
                                 attributes:(NSDictionary *)attributesDic
                                 shareMedia:(CHWhiteBoardShareMediaModel *)shareMedia;
/// 共享媒体停止回调
- (void)handleWhiteBoardShareMediaStopPlay:(NSString *)uid
                                  streamId:(NSString *)streamId
                                shareMedia:(CHWhiteBoardShareMediaModel *)shareMedia;

/// 共享媒体暂停回调
- (void)handleWhiteBoardShareMediaPause:(NSString *)uid
                               streamId:(NSString *)streamId
                             shareMedia:(CHWhiteBoardShareMediaModel *)shareMedia;
/// 共享媒体继续回调
- (void)handleWhiteBoardShareMediaResume:(NSString *)uid
                                streamId:(NSString *)streamId
                              shareMedia:(CHWhiteBoardShareMediaModel *)shareMedia;

/// 共享媒体进度回调(毫秒)
- (void)handleWhiteBoardShareMediaChangePosition:(NSString *)uid
                                        streamId:(NSString *)streamId
                                             pos:(NSUInteger)pos
                                      shareMedia:(CHWhiteBoardShareMediaModel *)shareMedia;

//小黑板状态变化（更改画笔）
- (void)handleSignalingSetSmallBoardStageState:(CHSmallBoardStageState)smallBoardStageState;

//小黑板bottomBar的代理
///上传图片
- (void)handleSignalingSmallBoardBottomBarClickToUploadImage;
///删除图片
- (void)handleSignalingSmallBoardBottomBarClickToDeleteImage;
/// 小黑板答题阶段私聊
- (void)handleSignalingReceivePrivateChatWithPrivateIdArray:(NSArray *)privateIdArray;
- (void)handleSignalingDeletePrivateChat;

- (void)handleSignalingChangeUndoRedoStateCanErase:(BOOL)canErase canClean:(BOOL)canClean;


@end

#endif /* YSLiveForWhiteBoardDelegate_h */

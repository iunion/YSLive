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
/// 课件全屏
- (void)handleonWhiteBoardFullScreen:(BOOL)isAllScreen;
/// 课件最大化
- (void)handleonWhiteBoardMaximizeView;
/// 媒体课件状态
- (void)handleonWhiteBoardMediaFileStateWithFileId:(NSString *)fileId state:(YSMediaState)state;

@end

#endif /* YSLiveForWhiteBoardDelegate_h */

//
//  CloudHubManager.h
//  YSLiveSample
//
//  Created by jiang deng on 2020/9/6.
//  Copyright © 2020 yunshuxunlian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudHubManagerDelegate.h"
#import "CloudHubManagerDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface CloudHubManager : NSObject

/// 外部传入host地址
@property (nonatomic, strong) NSString *apiHost;
/// 外部传入port
@property (nonatomic, assign) NSUInteger apiPort;


/// 音视频SDK干管理
@property (nonatomic, strong, readonly) CloudHubRtcEngineKit *cloudHubRtcEngineKit;

/// 房间相关消息回调
@property (nonatomic, weak, readonly) id <CloudHubManagerDelegate> delegate;

/// 当前用户数据
@property (nonatomic, strong, readonly) CHRoomUser *localUser;

#pragma mark - 白板

@property (nonatomic, weak, readonly) id <CHWhiteBoardManagerDelegate> whiteBoardDelegate;
/// 白板管理
@property (nonatomic, strong, readonly) CHWhiteBoardSDKManager *whiteBoardManager;
/// 白板视图whiteBord
@property (nonatomic, weak, readonly) UIView *whiteBordView;

/// 课件列表
@property (nonatomic, strong, readonly) NSArray <CHFileModel *> *fileList;
/// 当前课件数据
@property (nonatomic, strong, readonly) CHFileModel *currentFile;

@end

NS_ASSUME_NONNULL_END

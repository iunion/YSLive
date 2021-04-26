//
//  CHBeautySetModel.h
//  YSLive
//
//  Created by jiang deng on 2021/3/30.
//  Copyright © 2021 CH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YSLiveManager;
@interface CHBeautySetModel : NSObject

/// 音视频SDK管理
@property (nonatomic, weak) YSLiveManager *liveManager;

/// 摄像头权限
@property (nonatomic, assign, readonly) BOOL cameraPermissions;
/// 权限麦克风
@property (nonatomic, assign, readonly) BOOL microphonePermissions;

/// 切换摄像头
@property (nonatomic, assign) BOOL switchCam;
/// 水平镜像
@property (nonatomic, assign) BOOL fliph;
/// 垂直镜像
@property (nonatomic, assign) BOOL flipv;

/// 美白值
@property (nonatomic, assign) CGFloat whitenValue;
/// 瘦脸值
@property (nonatomic, assign) CGFloat thinFaceValue;
/// 大眼值
@property (nonatomic, assign) CGFloat bigEyeValue;
/// 磨皮值
@property (nonatomic, assign) CGFloat exfoliatingValue;
/// 红润值
@property (nonatomic, assign) CGFloat ruddyValue;

/// 贴画图片地址列表
@property (nonatomic, strong) NSMutableArray *propUrlArray;

/// 贴画索引
@property (nonatomic, assign) NSUInteger propIndex;

@end

NS_ASSUME_NONNULL_END

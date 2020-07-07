//
//  YSLiveManager.h
//  YSLive
//
//  Created by jiang deng on 2020/6/24.
//  Copyright © 2020 YS. All rights reserved.
//

#import <YSSession/YSSession.h>
#import "YSLiveForWhiteBoardDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSLiveManager : YSSessionManager

/// 网校api请求host
@property (nonatomic, strong) NSString *schoolApiHost;




#pragma mark - 白板

@property (nonatomic, weak) id <YSLiveForWhiteBoardDelegate> whiteBoardDelegate;
/// 白板管理
@property (nonatomic, strong, readonly) YSWhiteBoardManager *whiteBoardManager;
/// 白板视图whiteBord
@property (nonatomic, weak, readonly) UIView *whiteBordView;

/// 课件列表
@property (nonatomic, strong, readonly) NSArray <YSFileModel *> *fileList;
/// 当前课件数据
@property (nonatomic, strong, readonly) YSFileModel *currentFile;


+ (void)destroy;


- (BOOL)joinRoomWithHost:(NSString *)host port:(int)port nickName:(NSString *)nickName roomId:(NSString *)roomId roomPassword:(nullable NSString *)roomPassword userRole:(YSUserRoleType)userRole userId:(nullable NSString *)userId userParams:(nullable NSDictionary *)userParams needCheckPermissions:(BOOL)needCheckPermissions;

- (BOOL)joinRoomWithHost:(NSString *)host port:(int)port nickName:(NSString *)nickname roomParams:(NSDictionary *)roomParams userParams:(nullable NSDictionary *)userParams needCheckPermissions:(BOOL)needCheckPermissions;


/// 改变小班课白板背景颜色和水印底图
- (void)setWhiteBoardBackGroundColor:(nullable UIColor *)color maskImage:(nullable UIImage *)image;
- (void)setWhiteBoardBackGroundColor:(nullable UIColor *)color drawBackGroundColor:(nullable UIColor *)drawBgColor maskImage:(nullable UIImage *)image;

/// 改变直播白板背景颜色
- (void)setWhiteBoardLivrBackGroundColor:(nullable UIColor *)color drawBackGroundColor:(nullable UIColor *)drawBgColor;

/// 变更H5课件地址参数，此方法会刷新当前H5课件以变更新参数
- (void)changeConnectH5CoursewareUrlParameters:(NSDictionary *)parameters;

/// 设置H5课件Cookies
- (void)setConnectH5CoursewareUrlCookies:(nullable NSArray <NSDictionary *> *)cookies;

/// 获取课件数据
- (YSFileModel *)getFileWithFileID:(NSString *)fileId;

@end

NS_ASSUME_NONNULL_END

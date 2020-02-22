//
//  YSWhiteBroadManager.h
//  YSWhiteBroad
//
//  Created by MAC-MiNi on 2018/4/9.
//  Copyright © 2018年 MAC-MiNi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YSWhiteBoardManagerDelegate.h"
#import "YSFileModel.h"
#import "YSWBRoomJson.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^loadFinishedBlock) (void);
typedef void(^pageControlMarkBlock)(NSDictionary *);

typedef NSArray* _Nullable (^WebContentTerminateBlock)(void);

@interface YSWhiteBoardManager : NSObject

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) BOOL isBeginClass;// 是否已上课
@property (nonatomic, assign) BOOL preloadingFished;//预加载文档标识
@property (nonatomic, assign) BOOL isShowOnWeb;  // 是否web加载;
@property (nonatomic, assign) BOOL isSelectMouse;// 画笔工具是否选择了鼠标;
@property (nonatomic, assign) BOOL isUpdateWebAddressInfo;//文档服务器地址，web地址，备份地址 上传

@property (nonatomic, strong) YSWBRoomJson * ysRoomProperty;// 房间属性
@property (nonatomic, copy) WebContentTerminateBlock _Nullable webContentTerminateBlock;//webview内存过高白屏回调
@property (nonatomic, copy) pageControlMarkBlock pageControlMarkBlock;// 课件备注

@property (nonatomic, strong, readonly) NSMutableArray *docmentList;// 课件列表
@property (nonatomic, copy) NSString *currentFileId;//当前文档id
@property (nonatomic, copy) NSString *address; // 文档服务器地址

@property (nonatomic, strong) NSMutableArray *cacheMsgPool;//缓存数据
@property (nonatomic, strong) NSMutableArray *preLoadingFileCacheMsgPool;//预加载文档缓存数据
@property (nonatomic, strong) NSDictionary *configration;//配置项

@property (nonatomic, strong) UIColor * whiteBoardBgColor;//白板背景色
@property (nonatomic, weak)   id<YSWhiteBoardManagerDelegate> wbDelegate;
@property (nonatomic, assign, readonly) CGRect drawRect;
@property (nonatomic, assign) BOOL playingMedia;// 记录UI层是否正在播放媒体

/**
 单例
 */
+ (instancetype)shareInstance;
/**
 销毁白板
 */
+ (void)destroy;

/**
 注册白板
 */
- (void)registerDelegate:(id<YSWhiteBoardManagerDelegate>)delegate configration:(NSDictionary *)config;


//创建白板组件
- (UIView *)createWhiteBoardWithFrame:(CGRect)frame
                    loadComponentName:(NSString *)loadComponentName
                    loadFinishedBlock:(loadFinishedBlock)loadFinishedBlock;


//发送缓存的消息
- (void)sendCacheInformation:(NSMutableArray *)array;

/**
 创建白板
 @param companyid 公司id
 @return 返回白板数据
 */
- (NSDictionary *)createWhiteBoard:(NSNumber *)companyid;

/// 变更白板content背景色
- (void)changeWhiteBoardBackgroudColor:(UIColor *)color;
/// 变更白板画板背景色
- (void)changeFileViewBackgroudColor:(UIColor *)color;
/// 变更白板背景图
- (void)changeWhiteBoardBackImage:(nullable UIImage *)image;


/**
 添加文档
 
 @param file 文档
 */
- (void)addDocumentWithFile:(NSDictionary *)file;
/**
 删除文档
 
 @param file 文档
 */
- (void)delDocumentFile:(NSDictionary *)file;

- (YSFileModel *)currentFile;
- (YSFileModel *)getDocumentWithFileID:(NSString *)fileId;

/**
 设置默认文档ID
 */
- (void)setTheCurrentDocumentFileID:(NSString *)fileId;

//切换文档
- (int)changeDocumentWithFileID:(NSString *)fileId isBeginClass:(BOOL)isBeginClass isPubMsg:(BOOL)isPubMsg;

/**
 重置白板所有的数据
 */
- (void)resetWhiteBoardAllData;

// 刷新白板
- (void)refreshWhiteBoard;

// 刷新 webview scrollview offset (键盘消失 webview 不弹回)
- (void)refreshWBWebViewOffset:(CGPoint) point;

//关闭动态ppt视频播放
- (void)unpublishNetworkMedia:(id _Nullable)data;

//断开连接
- (void)disconnect:(NSString *_Nullable)reason;

/**
 房间失去连接
 
 @param reason 原因
 */
- (void)roomWhiteBoardOnDisconnect:(NSString * _Nullable)reason;

/**
 清空所有数据
 */
- (void)clearAllData;

/**
 重新加载白板  @此方法仅供白板测试使用
 */
- (void)webViewreload;
// ???: 删除?
- (void)playbackPlayAndPauseController:(BOOL)play;
// ???: 删除?
- (void)playbackSeekCleanup;

#pragma mark - 画笔控制
- (void)brushToolsDidSelect:(YSBrushToolType)BrushToolType;
- (void)didSelectDrawType:(YSDrawType)type color:(NSString *)hexColor widthProgress:(float)progress;
// 恢复默认工具配置设置
- (void)freshBrushToolConfig;
// 获取当前工具配置设置
- (NSDictionary *)getBrushToolConfigWithToolType:(YSBrushToolType)BrushToolType;
// 改变默认画笔颜色
- (void)changeDefaultPrimaryColor:(NSString *)colorHex;


/**
 课件备注回调

 @param block block
 */
- (void)setPageControlMarkBlock:(pageControlMarkBlock)block;

/**
 课件 上一页
 */
- (void)whiteBoardPrePage;

/**
 课件 下一页
 */
- (void)whiteBoardNextPage;

/**
 课件 跳转页

 @param pageNum 页码
 */
- (void)whiteBoardTurnToPage:(int)pageNum;

/**
 白板 放大
 */
- (void)whiteBoardEnlarge;

/**
 白板 缩小
 */
- (void)whiteBoardNarrow;

/**
 白板 放大重置
 */
- (void)whiteBoardResetEnlarge;

@end

NS_ASSUME_NONNULL_END

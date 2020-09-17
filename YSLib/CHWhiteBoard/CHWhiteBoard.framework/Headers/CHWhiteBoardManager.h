//
//  CHWhiteBoardManager.h
//  CHWhiteBoard
//
//

#import <Foundation/Foundation.h>
#import "CHWhiteBoardManagerDelegate.h"

#import "CHWhiteBoardView.h"
#import "CHFileModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CHWhiteBoardManager : NSObject
<
    CHSessionForWhiteBoardDelegate
>

/// 音视频SDK管理
@property (nonatomic, weak, readonly) CloudHubRtcEngineKit *cloudHubRtcEngineKit;

@property (nonatomic, weak, readonly) id <CHWhiteBoardManagerDelegate> wbDelegate;
/// 配置项
@property (nonatomic, strong, readonly) NSDictionary *configration;


// 关于获取白板 服务器地址、备份地址、web地址相关通知
/// 文档服务器地址
@property (nonatomic, strong, readonly) NSString *serverDocAddrKey;
@property (nonatomic, strong, readonly) NSDictionary *serverAddressInfoDic;

/// 课件列表
@property (nonatomic, strong, readonly) NSMutableArray <CHFileModel *> *docmentList;
/// 当前激活文档id
@property (nonatomic, strong, readonly) NSString *currentFileId;

/// 主白板
@property (nonatomic, strong, readonly) CHWhiteBoardView *mainWhiteBoardView;

/// 记录UI层是否开始上课
@property (nonatomic, assign, readonly) BOOL isBeginClass;

/// 更新服务器地址
@property (nonatomic, assign, readonly) BOOL isUpdateWebAddressInfo;

/// 白板背景色
@property (nonatomic, strong, readonly) UIColor *whiteBordBgColor;

/// 课件窗口列表
@property (nullable, nonatomic, strong) NSMutableArray <CHWhiteBoardView *> *coursewareViewList;

/// 16：9的背景view尺寸
@property (nonatomic, assign, readonly) CGSize contentSize;

/// pdf课件清晰度 大于1
@property (nonatomic, assign, readonly) NSUInteger pdfLevelsOfDetail;

/// 小黑板
@property (nonatomic, strong, readonly) CHWhiteBoardView *smallBoardView;

/// 小黑板阶段状态
@property (nonatomic, assign )CHSmallBoardStageState smallBoardStageState;

// UI
@property (nonatomic, assign) CGSize whiteBoardViewDefaultSize;


+ (void)destroy;

+ (instancetype)sharedInstance;
+ (NSString *)whiteBoardVersion;

- (void)registerRtcEngineKit:(CloudHubRtcEngineKit *)rtcEngineKit delegate:(id <CHWhiteBoardManagerDelegate>)delegate configration:(NSDictionary *)config;
- (void)registerRtcEngineKit:(CloudHubRtcEngineKit *)rtcEngineKit delegate:(id<CHWhiteBoardManagerDelegate>)delegate configration:(NSDictionary *)config useHttpDNS:(BOOL)useHttpDNS;

- (void)registerDelegate:(id <CHWhiteBoardManagerDelegate>)delegate configration:(NSDictionary *)config;
- (void)registerDelegate:(id<CHWhiteBoardManagerDelegate>)delegate configration:(NSDictionary *)config useHttpDNS:(BOOL)useHttpDNS;

- (void)serverLog:(NSString *)log;

- (CHWhiteBoardView *)createMainWhiteBoardWithFrame:(CGRect)frame
                        loadFinishedBlock:(wbLoadFinishedBlock)loadFinishedBlock;


#if WBHaveSmallBalckBoard
- (CHWhiteBoardView *)createSmallWhiteBoardWithFileId:(NSString *)fileId withData:(NSDictionary *)data isFromLocalUser:(BOOL)isFromMe;
#endif

//- (void)updateWebAddressInfo;

/// 清理白板数据
- (void)clearGroupData;


#pragma -
#pragma mark 课件操作

/// 变更白板窗口背景色
- (void)changeMainWhiteBoardBackgroudColor:(UIColor *)color;
/// 变更白板画板背景色
- (void)changeMainCourseViewBackgroudColor:(UIColor *)color;
/// 变更白板背景图
- (void)changeMainWhiteBoardBackImage:(nullable UIImage *)image;

/// 变更白板窗口背景色
- (void)changeAllWhiteBoardBackgroudColor:(UIColor *)color;


/// 变更H5课件地址参数，此方法会刷新当前H5课件以变更新参数
- (void)changeConnectH5CoursewareUrlParameters:(nullable NSDictionary *)parameters;

/// 设置H5课件Cookies
- (void)setConnectH5CoursewareUrlCookies:(nullable NSArray <NSDictionary *> *)cookies;


/// 刷新白板
- (void)refreshWhiteBoard;

/// 刷新当前白板课件数据
- (void)freshCurrentCourse;

/// 设置当前课件Id
- (void)setTheCurrentDocumentFileID:(NSString *)fileId;

- (CHFileModel *)currentFile;
- (CHFileModel *)getDocumentWithFileID:(NSString *)fileId;

/// 刷新白板课件
- (void)freshCurrentCourseWithFileId:(NSString *)fileId;

/// 切换课件
- (void)changeCourseWithFileId:(NSString *)fileId;
/// 添加图片课件
- (void)addWhiteBordImageCourseWithDic:(NSDictionary *)uplaodDic;

/// 删除小白板图片
- (void)deleteSmallBoardImage;
/// 删除课件
- (void)deleteCourseWithFileId:(NSString *)fileId;
- (void)deleteCourseWithFile:(CHFileModel *)fileModel;

/// 课件 上一页
- (void)whiteBoardPrePage;
- (void)whiteBoardPrePageWithFileId:(NSString *)fileId;
/// 课件 下一页
- (void)whiteBoardNextPage;
- (void)whiteBoardNextPageWithFileId:(NSString *)fileId;

/// 课件 跳转页
- (void)whiteBoardTurnToPage:(NSUInteger)pageNum;
- (void)whiteBoardTurnToPage:(NSUInteger)pageNum withFileId:(NSString *)fileId;

/// 主白板 全屏
- (void)mainWhiteBoardAllScreen:(BOOL)isAllScreen;

/// 白板 放大
- (void)whiteBoardEnlarge;
- (void)whiteBoardEnlargeWithFileId:(NSString *)fileId;
/// 白板 缩小
- (void)whiteBoardNarrow;
- (void)whiteBoardNarrowWithFileId:(NSString *)fileId;
/// 白板 放大重置
- (void)whiteBoardResetEnlarge;
- (void)whiteBoardResetEnlargeWithFileId:(NSString *)fileId;

///删除课件窗口
- (void)removeWhiteBoardViewWithFileId:(NSString *)fileId;
- (void)removeWhiteBoardViewWithWhiteBoardView:(CHWhiteBoardView *)whiteBoardView;

- (CGFloat)currentDocumentZoomScale;
- (CGFloat)documentZoomScaleWithFileId:(NSString *)fileId;

///多窗口排序后的窗口列表
- (NSArray *)getWhiteBoardViewArrangeList;

#pragma -
#pragma mark 是否多课件窗口

- (BOOL)isOneWhiteBoardView;

#pragma -
#pragma mark 课件窗口控制权限

- (BOOL)isCanControlWhiteBoardView;

#pragma -
#pragma mark 画笔权限

- (BOOL)isUserCanDraw;


#pragma -
#pragma mark 画笔控制

/// 更换画笔工具
- (void)brushToolsDidSelect:(CHBrushToolType)BrushToolType;
- (void)didSelectDrawType:(CHDrawType)type color:(NSString *)hexColor widthProgress:(CGFloat)progress;
// 恢复默认工具配置设置
- (void)freshBrushToolConfig;
// 获取当前工具配置设置 drawType: CHBrushToolType类型  colorHex: RGB颜色  progress: 值
- (CHBrushToolsConfigs *)getCurrentBrushToolConfig;
// 画笔颜色
- (NSString *)getPrimaryColorHex;
// 改变默认画笔颜色
- (void)changePrimaryColorHex:(NSString *)colorHex;


/// 发送信令清除白板视频标注
- (void)clearVideoMark;


#pragma -
#pragma mark 小黑板

#if WBHaveSmallBalckBoard
///小黑板时的画笔权限
- (BOOL)isSmallBoardCanDraw;
#endif

@end

NS_ASSUME_NONNULL_END
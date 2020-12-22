//
//  CHWhiteBoardView.h
//  CHWhiteBoard
//
//

#import <UIKit/UIKit.h>

#import "CHCoursewareControlView.h"

NS_ASSUME_NONNULL_BEGIN

@class CHWBDrawViewManager, CHWBWebViewManager, CHWhiteBoardTopBar, CHSmallBoardTopBar, CHSmallBoardBottomBar;

@protocol CHWhiteBoardViewDelegate;

@interface CHWhiteBoardView : UIView

@property (nonatomic, weak) id <CHWhiteBoardViewDelegate> delegate;

@property (nonatomic, strong, readonly) NSString *whiteBoardId;
@property (nonatomic, strong, readonly) NSString *fileId;

/// 媒体课件窗口
@property (nonatomic, assign, readonly) BOOL isMediaView;

#if !CHSingle_WhiteBoard
/// 媒体数据
@property (nonatomic, strong) CHSharedMediaFileModel *mediaFileModel;

@property (nonatomic, assign, readonly) CHWhiteBordMediaType mediaType;
/// H5脚本加载视频
@property (nonatomic, assign) BOOL isH5LoadMedia;
#endif

/// 当前页码
@property (nonatomic, assign, readonly) NSUInteger currentPage;
/// 总页码
@property (nonatomic, assign, readonly) NSUInteger totalPage;

/// 课件加载成功
@property (nonatomic, assign, readonly) BOOL isLoadingFinish;

/// 白板背景容器
@property (nonatomic, strong, readonly) UIView *whiteBoardContentView;

/// web文档
@property (nonatomic, strong, readonly) CHWBWebViewManager *webViewManager;
/// 普通文档
@property (nonatomic, strong, readonly) CHWBDrawViewManager *drawViewManager;

/// 小白板的topBar
@property (nonatomic, strong, readonly) CHWhiteBoardTopBar *topBar;

/// 翻页工具条
@property (nonatomic, strong, readonly) CHCoursewareControlView *pageControlView;

/// 主白板的
@property (nonatomic, strong) CHWhiteBoardView *mainWhiteBoard;

/// 最小化时的收藏夹按钮
@property (nonatomic, strong) UIButton *collectBtn;

/// 当前的位置信令的值
@property (nonatomic, strong, readonly) NSMutableDictionary *positionData;

/// 是否属于当前激活课件
@property (nonatomic, assign) BOOL isCurrent;

#if WBHaveSmallBalckBoard
#pragma mark - 小黑板

/// 是否是小黑板
@property (nonatomic, assign, readonly) BOOL isSmallBoard;

/// 小黑板的bottomBar
@property (nonatomic, strong, readonly) CHSmallBoardBottomBar *bottomBar;

/// 小黑板的topBar
@property (nonatomic, strong, readonly) CHSmallBoardTopBar *smallTopBar;

/// 上传图片后返回的数据
@property (nonatomic, strong) NSDictionary *imageDict;
#endif


- (void)destroy;

#if WBHaveSmallBalckBoard
- (instancetype)initBoardWithFrame:(CGRect)frame smallBoardFileId:(NSString *)fileId loadFinishedBlock:(nullable wbLoadFinishedBlock)loadFinishedBlock;
#endif

- (instancetype)initBoardWithFrame:(CGRect)frame fileId:(NSString *)fileId loadFinishedBlock:(nullable wbLoadFinishedBlock)loadFinishedBlock;
- (instancetype)initBoardWithFrame:(CGRect)frame fileId:(NSString *)fileId isMedia:(BOOL)isMedia mediaType:(CHWhiteBordMediaType)mediaType isSmallBoard:(BOOL)isSmallBoard loadFinishedBlock:(nullable  wbLoadFinishedBlock)loadFinishedBlock;

/// 更新服务器地址
- (void)updateWebAddressInfo:(NSDictionary *)message;
/// 断开连接
- (void)disconnect:(NSDictionary *)message;
/// 用户属性改变通知
- (void)userPropertyChanged:(NSDictionary *)properties;

/// 收到远端pubMsg消息通知
- (void)remotePubMsg:(NSDictionary *)message;
/// 收到远端delMsg消息的通知
- (void)remoteDelMsg:(NSDictionary *)message;


/// 变更白板窗口背景色
- (void)changeWhiteBoardBackgroudColor:(UIColor *)color;
/// 变更白板画板背景色
- (void)changeCourseViewBackgroudColor:(UIColor *)color;
/// 变更白板背景图
- (void)changeMainWhiteBoardBackImage:(UIImage *)image;

/// 页面刷新尺寸
- (void)refreshWhiteBoard;
- (void)refreshWhiteBoardWithFrame:(CGRect)frame;

- (CGFloat)documentZoomScale;

/// 窗口位置尺寸数据
- (void)changePositionData:(NSDictionary *)positionData;
- (void)changePositionData:(NSDictionary *)positionData type:(NSString *)type isSmall:(BOOL)isSmall isFull:(BOOL)isFull;

#pragma -
#pragma mark 课件操作

/// 刷新当前白板课件
- (void)freshCurrentCourse;

/// 课件 上一页
- (void)whiteBoardPrePage;
/// 课件 下一页
- (void)whiteBoardNextPage;
/// 课件 跳转页
- (void)whiteBoardTurnToPage:(NSUInteger)pageNum;

/// 主白板 全屏
- (void)changeWhiteBoardIsAllScreen:(BOOL)isAllScreen;

/// 白板 放大
- (void)whiteBoardEnlarge;
/// 白板 缩小
- (void)whiteBoardNarrow;
/// 白板 放大重置
- (void)whiteBoardResetEnlarge;

- (void)changeFileId:(NSString *)fileId;
/// 当前页码
- (void)changeCurrentPage:(NSUInteger)currentPage;
/// 总页码
- (void)changeTotalPage:(NSUInteger)pagecount;

/// 缩放变更回调
- (void)onWhiteBoardFileViewZoomScaleChanged:(CGFloat)zoomScale;

- (void)sendUndoRedoState;


#pragma -
#pragma mark 画笔控制

- (void)brushToolsDidSelect:(CHBrushToolType)brushToolType;
- (void)didSelectDrawType:(CHDrawType)type color:(NSString *)hexColor widthProgress:(CGFloat)progress;
- (void)freshBrushToolConfigs;


#if !CHSingle_WhiteBoard
#pragma -
#pragma mark 音视频控制

- (void)setMediaStream:(NSTimeInterval)duration pos:(NSTimeInterval)pos isPlay:(BOOL)isPlay fileName:(nonnull NSString *)fileName;


#pragma -
#pragma mark 白板视频标注

/// 显示白板视频标注
- (void)showVideoWhiteboardWithData:(NSDictionary *)data videoRatio:(CGFloat)videoRatio;
/// 绘制白板视频标注
- (void)drawVideoWhiteboardWithData:(NSDictionary *)data inList:(BOOL)inlist;
/// 隐藏白板视频标注
- (void)hideVideoWhiteboard;
/// 清除白板视频标注
- (void)clearDrawVideoMark;

#endif

#pragma -
#pragma mark 白板H5课件参数设置

/// 变更H5课件地址参数，此方法会刷新当前H5课件以变更新参数
- (void)changeConnectH5CoursewareUrlParameters:(nullable NSDictionary *)parameters;

/// 设置H5课件Cookies
- (void)setConnectH5CoursewareUrlCookies:(nullable NSArray <NSDictionary *> *)cookies;

@end


@protocol CHWhiteBoardViewDelegate <NSObject>

@required

/// H5脚本文件加载初始化完成
- (void)onWBViewWebViewManagerPageFinshed:(CHWhiteBoardView *)whiteBoardView;

/// 切换Web课件加载状态
- (void)onWBViewWebViewManagerLoadedState:(CHWhiteBoardView *)whiteBoardView withState:(NSDictionary *)dic;

/// Web课件翻页结果
- (void)onWBViewWebViewManagerStateUpdate:(CHWhiteBoardView *)whiteBoardView withState:(NSDictionary *)dic;
/// 翻页超时
- (void)onWBViewWebViewManagerSlideLoadTimeout:(CHWhiteBoardView *)whiteBoardView withState:(NSDictionary *)dic;

/// 普通课件加载完成状态
- (void)onWWBViewDrawViewManagerLoadFinshed:(CHWhiteBoardView *)whiteBoardView isSuccess:(BOOL)isSuccess;

/// 课件缩放
- (void)onWWBViewDrawViewManagerZoomScaleChanged:(CHWhiteBoardView *)whiteBoardView zoomScale:(CGFloat)zoomScale;
/// 课件全屏
- (void)onWBViewFullScreen:(BOOL)isAllScreen wbView:(CHWhiteBoardView *)whiteBoardView;
/// 拖拽手势事件  拖拽右下角缩放View
- (void)panToZoomWhiteBoardView:(CHWhiteBoardView *)whiteBoard withGestureRecognizer:(UIPanGestureRecognizer *)pan;

#if !CHSingle_WhiteBoard
/// 拖拽Mp3手势事件
- (void)moveMp3ViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGesture;
#endif

@end

NS_ASSUME_NONNULL_END

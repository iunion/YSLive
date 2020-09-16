//
//  CHCoursewareControlView.h
//  CHWhiteBoard
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define CHCoursewareControlView_Height  (28.0f)

#define CHCoursewareControlView_Width  (232.0f)
#define CHCoursewareControlView_NoScaleWidth        (168.0f)
#define CHCoursewareControlView_FullWidth           (296.0f)
#define CHCoursewareControlView_FullNoScaleWidth    (232.0f)


typedef NS_ENUM(NSInteger, CHCoursewareControlViewTag)
{
    /// 刷新
    CHCoursewareControlViewTag_Fresh = 100,
    
    /// 全屏
    CHCoursewareControlViewTag_AllScreen = 200,
    /// 由全屏还原
    CHCoursewareControlViewTag_Return,
    
    /// 左翻页
    CHCoursewareControlViewTag_LeftTurn = 300,
    /// 右翻页
    CHCoursewareControlViewTag_RightTurn,
    
    /// 放大
    CHCoursewareControlViewTag_Augment = 400,
    /// 缩小
    CHCoursewareControlViewTag_Reduce,
    
    /// 关闭
    CHCoursewareControlViewTag_Close = 500,
    
    /// 页码
    CHCoursewareControlViewTag_Page = 600
};

@protocol CHCoursewareControlViewDelegate <NSObject>

/// 刷新课件
- (void)coursewareFrashBtnClick;
/// 全屏 复原 回调
- (void)coursewarefullScreen:(BOOL)isAllScreen;
/// 上一页
- (void)coursewareTurnToPreviousPage;
/// 下一页
- (void)coursewareTurnToNextPage;
/// 放大
- (void)coursewareToEnlarge;
/// 缩小
- (void)coursewareToNarrow;
/// 由全屏还原的按钮
- (void)whiteBoardfullScreenReturn;
/// 删除按钮
- (void)deleteWhiteBoardView;

@end


@interface CHCoursewareControlView : UIView

@property (nonatomic, weak, readonly) id <CHCoursewareControlViewDelegate> delegate;

/// 自身所属的课件的id
@property (nonatomic, strong) NSString *fileId;

/// 是否全屏
@property (nonatomic, assign) BOOL isAllScreen;

/// 是否最大化
@property (nonatomic, assign) BOOL isBoardMax;

/// 是否可以翻页  (未开课前通过权限判断是否可以翻页  上课后永久不可以翻页)
@property (nonatomic, assign) BOOL allowTurnPage;

/// 是否可以缩放
@property (nonatomic, assign) BOOL allowScaling;

/// 缩放比例
@property (nonatomic, assign, readonly) CGFloat zoomScale;

- (instancetype)initWithFrame:(CGRect)frame delegate:(id <CHCoursewareControlViewDelegate>)delegate;

/// 绘制界面
- (void)setupUI;

/// 重置缩放按钮 将缩放比例还原为 WHITEBOARD_MINZOOMSCALE
- (void)resetBtnStates;
/// 根据缩放比例改变缩放按键可用状态
- (void)changeZoomScale:(CGFloat)zoomScale;

/// 初始化 当前页以及总页数
- (void)sc_setTotalPage:(NSInteger)total currentPage:(NSInteger)currentPage isWhiteBoard:(BOOL)isWhiteBoard;
/// 网页课件 当前页以及总页数
- (void)sc_setTotalPage:(NSInteger)total currentPage:(NSInteger)currentPage canPrevPage:(BOOL)canPrevPage canNextPage:(BOOL)canNextPage isWhiteBoard:(BOOL)isWhiteBoard;

/// 刷新按钮
@property (nonatomic, weak, readonly) UIButton *frashBtn;

/// 全屏按钮
@property (nonatomic, weak, readonly) UIButton *allScreenBtn;
/// 左翻页按钮
@property (nonatomic, weak, readonly) UIButton *leftTurnBtn;
/// 页码
@property (nonatomic, weak, readonly) UILabel *pageLabel;
/// 右翻页按钮
@property (nonatomic, weak, readonly) UIButton *rightTurnBtn;
/// 放大按钮
@property (nonatomic, weak, readonly) UIButton *augmentBtn;
/// 缩小按钮
@property (nonatomic, weak, readonly) UIButton *reduceBtn;
/// 由全屏还原的按钮
@property (nonatomic, weak, readonly) UIButton *returnBtn;
/// 关闭按钮
@property (nonatomic, weak, readonly) UIButton *closeBtn;

/// 点击事件
- (void)buttonsClick:(UIButton *)sender;

/// 计算工具条的宽度 最后会调用getViewWidth获取当前控制条宽度
- (void)freshViewWith;
/// 返回不同状态时的控制条宽度
/// 四种状态的尺寸变化 isBoardMax allowScaling
- (CGFloat)getViewWidth;

@end

NS_ASSUME_NONNULL_END

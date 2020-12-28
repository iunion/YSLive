//
//  CHDrawView.h
//  CHWhiteBoard
//
//

#import <UIKit/UIKit.h>
#import "CHWhiteBoardEnum.h"

NS_ASSUME_NONNULL_BEGIN

@class WBDrawView;

@protocol CHDrawViewDelegate <NSObject>

/**
 涂鸦数据回调
 
 @param fileid 所属文件id
 @param shapeID 涂鸦id
 @param shapeDic 涂鸦数据
 */
- (void)addSharpWithFileID:(NSString *)fileid shapeID:(NSString *)shapeID shapeDic:(NSDictionary *)shapeDic;
- (void)deleteSharpWithFileID:(NSString *)fileid shapeID:(NSString *)shapeID shapeDic:(NSDictionary *)shapeDic;

/// 清除，clear发送信令
- (void)clearSharpWithFileID:(NSString *)fileid shapeID:(NSString *)shapeID shapeDic:(NSDictionary *)shapeDic;

- (void)changeUndoRedoState:(NSString *)fileid currentpage:(NSUInteger)currentPage canUndo:(BOOL)canUndo canRedo:(BOOL)canRedo canErase:(BOOL)canErase canClean:(BOOL)canClean;

@end

@interface CHDrawView : UIView

@property (nonatomic, weak) id <CHDrawViewDelegate> delegate;

@property (nonatomic, strong) WBDrawView *drawView;                       //涂鸦显示层
@property (nonatomic, strong) WBDrawView *rtDrawView;                     //实时绘制层
@property (nonatomic, strong, readonly) NSString *fileid;               //涂鸦所属文件id rtDrawView的fileId
@property (nonatomic, assign, readonly) NSUInteger pageid;              //涂鸦所属文件页码
//@property (nonatomic, assign) float iFontScale;                         //涂鸦比例，当前涂鸦frame.width / 960

- (instancetype)initWithDelegate:(nullable id<CHDrawViewDelegate>)delegate;

/**
 是否已经设置了画笔
 
 @return 画笔状态
 */
- (BOOL)hasDraw;

/**
 设置画笔
 
 @param drawType 画笔类型
 @param hexColor 16进制画笔颜色
 @param progress 画笔粗细，0.05f~1.0f
 */
- (void)changeDrawType:(CHDrawType)drawType
           hexColor:(NSString *)hexColor
           progress:(CGFloat)progress;
- (void)changeDrawHexColor:(NSString *)hexColor progress:(CGFloat)progress;


/**
 翻到涂鸦所属文件及页码
 
 @param fileID 文件id
 @param pageID 页码数
 @param refresh 是否立即刷新
 */
- (void)switchToFileID:(NSString *)fileID
                pageID:(NSUInteger)pageID
    refreshImmediately:(BOOL)refresh;


/**
 添加一笔涂鸦
 
 @param data 涂鸦数据字典
 @param refresh 是否立即刷新
 */
- (void)addDrawData:(NSDictionary *)data authorUserId:(NSString *)userId seq:(NSUInteger)seq isRedo:(BOOL)isRedo isFromMyself:(BOOL)isFromMyself refreshImmediately:(BOOL)refresh;


- (void)sendUndoRedoState;

/**
 收到撤销一笔涂鸦
 */
- (void)handleUndoDrawWithShapeId:(NSString *)shapeId;
- (void)handleUndoDrawWithClearId:(NSString *)clearId;

/**
 收到清空涂鸦
 
 @param clearID 清空id
 */
- (void)handleClearDrawWithClearID:(NSString *)clearID authorUserId:(NSString *)userId seq:(NSUInteger)seq toAuthorUserId:(NSString *)toAuthorUserId isRedo:(BOOL)isRedo isFromMyself:(BOOL)isFromMyself;

/// 发送清除视频标注数据
- (void)clearDrawVideoMarkWithMsg;


/**
 清理一页数据
 
 @param fileID 文件id
 @param pageNum 页码
 */
- (void)clearOnePageWithFileID:(NSString *)fileID pageNum:(int)pageNum;

/**
 设置画布工作模式
 
 @param mode 模式枚举：工作模式or观察模式
 */
- (void)setWorkMode:(CHWorkMode)mode;


/**
 下课清理数据
 */
- (void)clearDataAfterClass;

@end

NS_ASSUME_NONNULL_END

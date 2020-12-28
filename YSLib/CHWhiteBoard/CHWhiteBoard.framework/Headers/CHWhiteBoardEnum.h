//
//  CHWhiteBoardEnum.h
//  CHWhiteBoard
//
//

#ifndef CHWhiteBoardEnum_h
#define CHWhiteBoardEnum_h


/// 白板文档媒体类型
typedef NS_ENUM(NSUInteger, CHWhiteBordMediaType)
{
    /// 视频
    CHWhiteBordMediaType_Video = 0,
    /// 音频
    CHWhiteBordMediaType_Audio
};

#if CHSingle_WhiteBoard
/// 白板课件类型
typedef NS_ENUM(NSUInteger, CHWhiteBordFileProp)
{
    /// 普通
    CHWhiteBordFileProp_GeneralFile = 0,
    /// 动态Ppt
    CHWhiteBordFileProp_DynamicPPT,
    CHWhiteBordFileProp_NewDynamicPPT,
    /// H5
    CHWhiteBordFileProp_H5Document = 3
};
#endif

/// 操作模式
typedef NS_ENUM(NSUInteger, CHWorkMode)
{
    CHWorkModeViewer        = 0,    // 只能观看 不能标记 隐藏工具条
    CHWorkModeControllor    = 1,    // 操作状态
};

/// 信令事件
typedef NS_ENUM(NSInteger, CHDrawEvent)
{
    CHDrawEventUnknown          = 0,    // 切换文档
    CHDrawEventShowPage         = 1,    // 切换文档
    CHDrawEventShapeAdd         = 2,    // 增加画笔
    CHDrawEventShapeClean       = 5,    // 清屏
    CHDrawEventShapeUndo        = 6,    // 撤回
    CHDrawEventShapeRedo        = 7,    // 重做
    CHDrawEventShowUserPage     = 10    // 切换小黑板数据
};

/// 画笔工具类型
typedef NS_ENUM(NSInteger, CHBrushToolType)
{
    CHBrushToolTypeMouse    = 100,  // 箭头
    CHBrushToolTypeLine     = 10,   // 划线类型
    CHBrushToolTypeText     = 20,   // 文字类型
    CHBrushToolTypeShape    = 30,   // 框类型
    CHBrushToolTypeEraser   = 50,   // 橡皮擦
    CHBrushToolTypeClear    = 60,   // 删除
    CHBrushToolTypeUndo     = 70,   // 撤退
    CHBrushToolTypeRedo     = 80    // 前进
};

/// 画笔绘图类型
typedef NS_ENUM(NSInteger, CHDrawType)
{
    CHDrawTypePen               = 10,   // 钢笔
    CHDrawTypeMarkPen           = 11,   // 记号笔
    CHDrawTypeLine              = 12,   // 直线
    CHDrawTypeArrowLine         = 13,   // 带箭头直线
    
    CHDrawTypeText              = 20,   // 文本
    
    CHDrawTypeEmptyRectangle    = 30,   // 空心矩形
    CHDrawTypeFilledRectangle   = 31,   // 实心矩形
    CHDrawTypeEmptyEllipse      = 32,   // 空心圆
    CHDrawTypeFilledEllipse     = 33,   // 实心圆
    
    CHDrawTypeEraser            = 50,   // 橡皮擦
    
    CHDrawTypeClear             = 60,   // 清除画板内容
    
    CHDrawTypeUndo              = 70,   // 撤退
    CHDrawTypeRedo              = 80,   // 重做
};

typedef NS_ENUM(NSUInteger, CHWhiteBoardErrorCode)
{
    CHError_OK,
    CHError_Bad_Parameters,
};

typedef NS_ENUM(NSUInteger, CHSmallBoardStageState)
{
    CHSmallBoardStage_none = 0, // 非小黑板状态
    CHSmallBoardStage_prepare,  // 准备阶段 (老师创建了白板还没有分发的时候)
    CHSmallBoardStage_answer,   // 答题阶段 （老师点了分发，学生在答题阶段）
    CHSmallBoardStage_comment   // 讲评阶段 （老师回收了画板，学生同步观看老师的状态）
    
    // 再次分发又回到2 状态 ，关闭回到 0状态
};


#endif /* CHWhiteBoardEnum_h */

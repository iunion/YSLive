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

typedef NS_ENUM(NSInteger, CHEvent)
{
    CHEventShowPage        = 0,    //切换文档
    CHEventShapeAdd        = 2,    //增加画笔
    CHEventShapeClean      = 5,    //清屏
    CHEventShapeUndo       = 6,    //撤回
    CHEventShapeRedo       = 7,    //重做
    CHEventShowUserPage    = 10    //切换小黑板数据
};

typedef NS_ENUM(NSInteger, CHNativeToolType)
{
    CHNativeToolTypeMouse   = 100,
    CHNativeToolTypeLine    = 10,
    CHNativeToolTypeText    = 20,
    CHNativeToolTypeShape   = 30,
    CHNativeToolTypeEraser  = 50,
};

typedef NS_ENUM(NSInteger, CHToolSelectButtonIndex)
{
    Draw_Pen            = 10,       //画笔
    Draw_MarkPen        = 11,       //记号笔
    Draw_Line           = 12,       //直线
    Draw_Arrow          = 13,       //带箭头的直线
    
    Draw_EmptyRect      = 30,       //空心矩形
    Draw_SolidRect      = 31,       //实心矩形
    Draw_EmptyCircle    = 32,       //空心圆
    Draw_SolidCircle    = 33,       //实心圆
    
    Draw_Text_Size      = 20, //文字
    Draw_Text_Color     = 21,
    
    Draw_Edite_Select   = 40,//
    Draw_Edite_Delete   = 41,//
    Draw_Edite_Move     = 42,
    Draw_Edite_Clear    = 43,//
    
    Draw_Eraser         = 50,       //橡皮擦
    
    
    Draw_Undo           = 26,       //撤销
    Draw_Redo           = 27,       //重做
};

typedef NS_ENUM(NSUInteger, CHWorkMode)
{
    CHWorkModeViewer = 0,       //只能观看 不能标记 隐藏工具条
    CHWorkModeControllor = 1,   //操作状态
};

typedef NS_ENUM(NSInteger, CHDrawType)
{
    CHDrawTypePen               = 10,    //钢笔
    CHDrawTypeMarkPen           = 11,    //记号笔
    CHDrawTypeLine              = 12,    //直线
    CHDrawTypeArrowLine         = 13,    //箭头
    
    CHDrawTypeTextMS            = 20,    //微软雅黑字
    CHDrawTypeTextSong          = 21,    //宋体字
    CHDrawTypeTextArial         = 22,    //Arial字
    
    CHDrawTypeEmptyRectangle    = 30,    //空心矩形
    CHDrawTypeFilledRectangle   = 31,    //实心矩形
    CHDrawTypeEmptyEllipse      = 32,    //空心圆
    CHDrawTypeFilledEllipse     = 33,    //实心圆
    
    CHDrawTypeEraser            = 50,    //橡皮擦
    
    CHDrawTypeClear             = 60,    //清除画板内容
};

typedef NS_ENUM(NSInteger, CHBrushToolType)
{
    CHBrushToolTypeMouse   = 100,//箭头
    CHBrushToolTypeLine    = 10, //划线类型
    CHBrushToolTypeText    = 20, //文字类型
    CHBrushToolTypeShape   = 30, //框类型
    CHBrushToolTypeEraser  = 50, //橡皮擦
    CHBrushToolTypeClear  = 60,  //删除
};

typedef NS_ENUM(NSUInteger, CHWhiteBoardErrorCode)
{
    CHError_OK,
    CHError_Bad_Parameters,
};

typedef NS_ENUM(NSUInteger, CHSmallBoardStageState)
{
    CHSmallBoardStage_none = 0,//非小黑板状态
    CHSmallBoardStage_prepare,//准备阶段 (老师创建了白板还没有分发的时候)
    CHSmallBoardStage_answer,//答题阶段 （老师点了分发，学生在答题阶段）
    CHSmallBoardStage_comment//讲评极端 （老师回收了画板，学生同步观看老师的状态）
    
    //再次分发又回到2 状态 ，关闭回到 0状态
};


#endif /* CHWhiteBoardEnum_h */

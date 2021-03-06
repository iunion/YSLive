//
//  SCBrushToolView.m
//  YSLive
//

//

#import "SCBrushToolView.h"

#define BrushToolTopHeight  52.0f
#define BrushToolWidth      48.0f
#define BrushToolBtnGap     6.0f
#define BrushToolBtnWidth   30.0f

/// 工具栏宽度
static const CGFloat kBrushTool_width_iPhone = 36.0f;
static const CGFloat kBrushTool_width_iPad = 50.0f ;
#define BRUSHTOOL_WIDTH        ([CHCommonTools deviceIsIPad] ? kBrushTool_width_iPad : kBrushTool_width_iPhone)
/// 工具栏按钮宽度
static const CGFloat kBrushToolBtn_width_iPhone = 26.0f;
static const CGFloat kBrushToolBtn_width_iPad = 30.0f ;
#define BRUSHTOOL_BTN_WIDTH        ([CHCommonTools deviceIsIPad] ? kBrushToolBtn_width_iPad : kBrushToolBtn_width_iPhone)

@interface SCBrushToolView ()

@property (nonatomic, assign) BOOL isTeacher;

/// 工具按钮view
@property (nonatomic, strong) UIView *toolBacView;
/// 鼠标（光标）
@property (nonatomic, strong) UIButton *mouseBtn;
/// 画笔
@property (nonatomic, strong) UIButton *penBtn;
/// 文本
@property (nonatomic, strong) UIButton *textBtn;
/// 框
@property (nonatomic, strong) UIButton *shapeBtn;
/// 橡皮檫
@property (nonatomic, strong) UIButton *eraserBtn;
/// 撤退
@property (nonatomic, strong) UIButton *undoBtn;
/// 前进
@property (nonatomic, strong) UIButton *redoBtn;
/// 清除
@property (nonatomic, strong) UIButton *clearBtn;

@property (nonatomic, assign) CHBrushToolType type;

@end

@implementation SCBrushToolView

- (instancetype)initWithTeacher:(BOOL)isTeacher
{
    if (self = [super init])
    {
        self.isTeacher = isTeacher;
        [self setup];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    frame.size.width = BRUSHTOOL_WIDTH;
    if (self.isTeacher)
    {
//        frame.size.height = BRUSHTOOL_BTN_WIDTH*6+BrushToolBtnGap*5+10.0f;
        frame.size.height = BRUSHTOOL_BTN_WIDTH*8+BrushToolBtnGap*7+10.0f;
    }
    else
    {
        frame.size.height = BRUSHTOOL_BTN_WIDTH*5+BrushToolBtnGap*4+10.0f;
    }
    
    [super setFrame:frame];
}

- (void)resetTool
{
    [self sc_toolButtonListClicked:self.penBtn];
}

- (void)freshCanUndo:(BOOL)canUndo canRedo:(BOOL)canRedo
{
    self.undoBtn.enabled = canUndo;
    self.redoBtn.enabled = canRedo;
}

- (void)freshClear:(BOOL)canClear
{
    self.clearBtn.enabled = canClear;
}

- (void)freshErase:(BOOL)canErase
{
    self.eraserBtn.enabled = canErase;
}

- (void)setup
{
    [self addSubview:self.toolBacView];

    self.toolBacView.backgroundColor = CHSkinDefineColor(@"ToolBgColor");
    self.toolBacView.layer.cornerRadius = BRUSHTOOL_WIDTH*0.5f;
    self.toolBacView.layer.shadowColor = CHSkinDefineColor(@"ToolBgColor").CGColor;
    self.toolBacView.layer.shadowOffset = CGSizeMake(0,2);
    self.toolBacView.layer.shadowOpacity = 0.5;
    self.toolBacView.layer.shadowRadius = 1;
//    [self.toolBacView bm_addShadow:3.0f Radius:BRUSHTOOL_WIDTH*0.5f BorderColor:YSSkinDefineColor(@"ToolBgColor") ShadowColor:YSSkinDefineColor(@"blackColor")];
    
    [self.toolBacView addSubview:self.mouseBtn];
    [self.toolBacView addSubview:self.penBtn];
    [self.toolBacView addSubview:self.textBtn];
    [self.toolBacView addSubview:self.shapeBtn];
    [self.toolBacView addSubview:self.eraserBtn];
    if (self.isTeacher)
    {
        [self.toolBacView addSubview:self.undoBtn];
        [self.toolBacView addSubview:self.redoBtn];
        [self.toolBacView addSubview:self.clearBtn];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.toolsBtn.frame = CGRectMake(0, 0, BrushToolWidth, BrushToolTopHeight);
    self.toolBacView.frame = CGRectMake(0, 0, self.bm_width, self.bm_height);
    
    CGFloat btnGap = BrushToolBtnGap;
    CHWeakSelf
    [self.mouseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(BRUSHTOOL_BTN_WIDTH);
    }];

    [self.penBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mouseBtn.mas_bottom).mas_offset(btnGap);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(BRUSHTOOL_BTN_WIDTH);
    }];
    
    [self.textBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.penBtn.mas_bottom).mas_offset(btnGap);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(BRUSHTOOL_BTN_WIDTH);
    }];
    
    [self.shapeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.textBtn.mas_bottom).mas_offset(btnGap);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(BRUSHTOOL_BTN_WIDTH);
    }];
    
    [self.eraserBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.shapeBtn.mas_bottom).mas_offset(btnGap);
        make.centerX.mas_equalTo(0);
        make.width.height.mas_equalTo(BRUSHTOOL_BTN_WIDTH);
    }];
    
    if (self.isTeacher)
    {
        [self.undoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.eraserBtn.mas_bottom).mas_offset(btnGap);
            make.centerX.mas_equalTo(0);
            make.width.height.mas_equalTo(BRUSHTOOL_BTN_WIDTH);
        }];
        
        [self.redoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.undoBtn.mas_bottom).mas_offset(btnGap);
            make.centerX.mas_equalTo(0);
            make.width.height.mas_equalTo(BRUSHTOOL_BTN_WIDTH);
        }];
        
        [self.clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.redoBtn.mas_bottom).mas_offset(btnGap);
            make.centerX.mas_equalTo(0);
            make.width.height.mas_equalTo(BRUSHTOOL_BTN_WIDTH);
        }];

    }
}

#pragma mark -
#pragma mark SEL

- (void)sc_toolButtonListClicked:(UIButton *)btn
{
//    if (btn == self.clearBtn)
    if (btn.tag == CHDrawTypeClear || btn.tag == CHBrushToolTypeUndo || btn.tag == CHBrushToolTypeRedo)
    {
        if ([self.delegate respondsToSelector:@selector(brushToolClikWithToolBtn:)])
        {
            [self.delegate brushToolClikWithToolBtn:btn];
        }
        return;
    }
    
    btn.selected = YES;
    for (UIButton *tempBtn in self.toolBacView.subviews)
    {
        if (tempBtn.tag != btn.tag)
        {
            tempBtn.selected = NO;
        }
    }

    if ([self.delegate respondsToSelector:@selector(brushToolViewType:withToolBtn:)])
    {
        [self.delegate brushToolViewType:btn.tag withToolBtn:btn];
    }
}


#pragma mark -
#pragma mark lazy

- (UIView *)toolBacView
{
    if (!_toolBacView)
    {
        _toolBacView = [[UIView alloc] init];
        //[_toolBacView bm_setImageWithStretchableImage:@"sc_brush_tool_bac" atPoint:CGPointMake(24, 50)];
        _toolBacView.userInteractionEnabled = YES;
        _toolBacView.backgroundColor = CHSkinDefineColor(@"PopViewBgColor");
    }
    
    return _toolBacView;
}

- (UIButton *)mouseBtn
{
    if (!_mouseBtn)
    {
        _mouseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mouseBtn setImage:CHSkinElementImage(@"brushTool_mouse", @"iconNor") forState:UIControlStateNormal];
        [_mouseBtn setImage:CHSkinElementImage(@"brushTool_mouse", @"iconSel") forState:UIControlStateSelected];
        [_mouseBtn setAdjustsImageWhenHighlighted:NO];
        [_mouseBtn addTarget:self action:@selector(sc_toolButtonListClicked:) forControlEvents:UIControlEventTouchUpInside];
        _mouseBtn.tag = CHBrushToolTypeMouse;
//        _mouseBtn.selected = YES;
    }
    
    return _mouseBtn;
}

- (UIButton *)penBtn
{
    if (!_penBtn)
    {
        _penBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_penBtn setImage:CHSkinElementImage(@"brushTool_pen", @"iconNor") forState:UIControlStateNormal];
        [_penBtn setImage:CHSkinElementImage(@"brushTool_pen", @"iconSel") forState:UIControlStateSelected];
        [_penBtn setAdjustsImageWhenHighlighted:NO];
        [_penBtn addTarget:self action:@selector(sc_toolButtonListClicked:) forControlEvents:UIControlEventTouchUpInside];
        _penBtn.tag = CHBrushToolTypeLine;
        _penBtn.selected = YES;
    }
    
    return _penBtn;
}

- (UIButton *)textBtn
{
    if (!_textBtn)
    {
        _textBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_textBtn setImage:CHSkinElementImage(@"brushTool_text", @"iconNor") forState:UIControlStateNormal];
        [_textBtn setImage:CHSkinElementImage(@"brushTool_text", @"iconSel") forState:UIControlStateSelected];
        [_textBtn setAdjustsImageWhenHighlighted:NO];
        [_textBtn addTarget:self action:@selector(sc_toolButtonListClicked:) forControlEvents:UIControlEventTouchUpInside];
        _textBtn.tag = CHBrushToolTypeText;
    }
    
    return _textBtn;
}

- (UIButton *)shapeBtn
{
    if (!_shapeBtn)
    {
        _shapeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shapeBtn setImage:CHSkinElementImage(@"brushTool_shape", @"iconNor") forState:UIControlStateNormal];
        [_shapeBtn setImage:CHSkinElementImage(@"brushTool_shape", @"iconSel") forState:UIControlStateSelected];
        [_shapeBtn setAdjustsImageWhenHighlighted:NO];
        [_shapeBtn addTarget:self action:@selector(sc_toolButtonListClicked:) forControlEvents:UIControlEventTouchUpInside];
        _shapeBtn.tag = CHBrushToolTypeShape;
    }
    
    return _shapeBtn;
}

- (UIButton *)eraserBtn
{
    if (!_eraserBtn)
    {
        _eraserBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_eraserBtn setImage:CHSkinElementImage(@"brushTool_eraser", @"iconNor") forState:UIControlStateNormal];
        [_eraserBtn setImage:CHSkinElementImage(@"brushTool_eraser", @"iconSel") forState:UIControlStateSelected];
        [_eraserBtn setAdjustsImageWhenHighlighted:NO];
        [_eraserBtn addTarget:self action:@selector(sc_toolButtonListClicked:) forControlEvents:UIControlEventTouchUpInside];
        _eraserBtn.tag = CHBrushToolTypeEraser;
    }
    
    return _eraserBtn;
}

- (UIButton *)clearBtn
{
    if (!_clearBtn)
    {
        _clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearBtn setImage:CHSkinElementImage(@"brushTool_clear", @"iconNor") forState:UIControlStateNormal];
        [_clearBtn setImage:CHSkinElementImage(@"brushTool_clear", @"iconSel") forState:UIControlStateSelected];
        
        [_clearBtn setAdjustsImageWhenHighlighted:NO];
        [_clearBtn addTarget:self action:@selector(sc_toolButtonListClicked:) forControlEvents:UIControlEventTouchUpInside];
        _clearBtn.tag = CHDrawTypeClear;
    }
    
    return _clearBtn;
}

// 撤退
- (UIButton *)undoBtn
{
    if (!_undoBtn)
    {
        _undoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_undoBtn setImage:CHSkinElementImage(@"brushTool_undo", @"iconNor") forState:UIControlStateNormal];
        [_undoBtn setImage:CHSkinElementImage(@"brushTool_undo", @"iconSel") forState:UIControlStateSelected];
        [_undoBtn setImage:CHSkinElementImage(@"brushTool_undo", @"iconDis") forState:UIControlStateDisabled];
        _undoBtn.enabled = NO;

        [_undoBtn setAdjustsImageWhenHighlighted:NO];
        [_undoBtn addTarget:self action:@selector(sc_toolButtonListClicked:) forControlEvents:UIControlEventTouchUpInside];
        _undoBtn.tag = CHBrushToolTypeUndo;
    }
    
    return _undoBtn;
}

/// 前进
- (UIButton *)redoBtn
{
    if (!_redoBtn)
    {
        _redoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_redoBtn setImage:CHSkinElementImage(@"brushTool_redo", @"iconNor") forState:UIControlStateNormal];
        [_redoBtn setImage:CHSkinElementImage(@"brushTool_redo", @"iconSel") forState:UIControlStateSelected];
        [_redoBtn setImage:CHSkinElementImage(@"brushTool_redo", @"iconDis") forState:UIControlStateDisabled];
        _redoBtn.enabled = NO;

        [_redoBtn setAdjustsImageWhenHighlighted:NO];
        [_redoBtn addTarget:self action:@selector(sc_toolButtonListClicked:) forControlEvents:UIControlEventTouchUpInside];
        _redoBtn.tag = CHBrushToolTypeRedo;
    }
    
    return _redoBtn;
}

@end

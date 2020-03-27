//
//  SCBrushToolView.m
//  YSLive
//
//  Created by fzxm on 2019/11/6.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCBrushToolView.h"

#define BrushToolTopHeight  52.0f
#define BrushToolWidth      48.0f
#define BrushToolBtnGap     4.0f
#define BrushToolBtnWidth   30.0f

@interface SCBrushToolView()

@property (nonatomic, assign) BOOL isTeacher;

/// 工具按钮（控制工具条的展开收起）
@property (nonatomic, strong) UIButton *toolsBtn;
/// 工具按钮view
@property (nonatomic, strong) UIImageView *toolBacView;
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
/// 清除
@property (nonatomic, strong) UIButton *clearBtn;


@property (nonatomic, assign) YSBrushToolType type;

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
    frame.size.width = BrushToolWidth;
    if (self.isTeacher)
    {
        frame.size.height = BrushToolTopHeight+BrushToolBtnWidth*6+BrushToolBtnGap*5+10.0f;
    }
    else
    {
        frame.size.height = BrushToolTopHeight+BrushToolBtnWidth*5+BrushToolBtnGap*4+10.0f;
    }
    
    [super setFrame:frame];
}

- (void)resetTool
{
    [self sc_toolButtonListClicked:self.mouseBtn];
}

- (void)setup
{
    [self addSubview:self.toolsBtn];
    [self addSubview:self.toolBacView];
    
    self.toolBacView.backgroundColor = [UIColor bm_colorWithHex:0x648CD6];
    [self.toolBacView bm_addShadow:3.0f Radius:40*0.5f BorderColor:[UIColor  bm_colorWithHex:0xCCCCFF] ShadowColor:[UIColor  bm_colorWithHex:0x666666]];
    
    [self.toolBacView addSubview:self.mouseBtn];
    [self.toolBacView addSubview:self.penBtn];
    [self.toolBacView addSubview:self.textBtn];
    [self.toolBacView addSubview:self.shapeBtn];
    [self.toolBacView addSubview:self.eraserBtn];
    if (self.isTeacher)
    {
        [self.toolBacView addSubview:self.clearBtn];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.toolsBtn.frame = CGRectMake(0, 0, BrushToolWidth, BrushToolTopHeight);
    
    self.toolBacView.frame = CGRectMake(0, BrushToolTopHeight, 40, self.bm_height-BrushToolTopHeight);
    self.toolBacView.bm_centerX = self.toolsBtn.bm_centerX;
    
    CGFloat btnGap = BrushToolBtnGap;
    BMWeakSelf
    [self.mouseBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.top.bmmas_equalTo(5);
        make.centerX.bmmas_equalTo(0);
        make.width.height.bmmas_equalTo(BrushToolBtnWidth);
    }];

    [self.penBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.top.bmmas_equalTo(weakSelf.mouseBtn.bmmas_bottom).bmmas_offset(btnGap);
        make.centerX.bmmas_equalTo(0);
        make.width.height.bmmas_equalTo(BrushToolBtnWidth);
    }];
    
    [self.textBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.top.bmmas_equalTo(weakSelf.penBtn.bmmas_bottom).bmmas_offset(btnGap);
        make.centerX.bmmas_equalTo(0);
        make.width.height.bmmas_equalTo(BrushToolBtnWidth);
    }];
    
    [self.shapeBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.top.bmmas_equalTo(weakSelf.textBtn.bmmas_bottom).bmmas_offset(btnGap);
        make.centerX.bmmas_equalTo(0);
        make.width.height.bmmas_equalTo(BrushToolBtnWidth);
    }];
    
    [self.eraserBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.top.bmmas_equalTo(weakSelf.shapeBtn.bmmas_bottom).bmmas_offset(btnGap);
        make.centerX.bmmas_equalTo(0);
        make.width.height.bmmas_equalTo(BrushToolBtnWidth);
    }];
    
    if (self.isTeacher)
    {
        [self.clearBtn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
            make.top.bmmas_equalTo(weakSelf.eraserBtn.bmmas_bottom).bmmas_offset(btnGap);
            make.centerX.bmmas_equalTo(0);
            make.width.height.bmmas_equalTo(BrushToolBtnWidth);
        }];
    }
}


#pragma mark -
#pragma mark SEL
- (void)toolBtnClicked:(UIButton *)btn
{
    btn.selected = !btn.selected;
    self.toolBacView.hidden = !btn.selected;
    if ([self.delegate respondsToSelector:@selector(toolBtnClickedSeleted:)])
    {
        //type传-1  只是为了控制显示隐藏
        [self.delegate toolBtnClickedSeleted:btn.selected];
    }
}

- (void)sc_toolButtonListClicked:(UIButton *)btn
{
    if (btn == self.clearBtn)
    {
        if ([self.delegate respondsToSelector:@selector(brushToolDoClean)])
        {
            [self.delegate brushToolDoClean];
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

- (UIButton *)toolsBtn
{
    if (!_toolsBtn)
    {
        _toolsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_toolsBtn setBackgroundImage:[UIImage imageNamed:@"sc_brush_tool_normal"] forState:UIControlStateNormal];
        [_toolsBtn setBackgroundImage:[UIImage imageNamed:@"sc_brush_tool_selected"] forState:UIControlStateSelected];
        [_toolsBtn addTarget:self action:@selector(toolBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _toolsBtn.selected = YES;
        [_toolsBtn setAdjustsImageWhenHighlighted:NO];
    }
    
    return _toolsBtn;
}

- (UIImageView *)toolBacView
{
    if (!_toolBacView)
    {
        _toolBacView = [[UIImageView alloc] init];
        //[_toolBacView bm_setImageWithStretchableImage:@"sc_brush_tool_bac" atPoint:CGPointMake(24, 50)];
        _toolBacView.userInteractionEnabled = YES;
    }
    
    return _toolBacView;
}

- (UIButton *)mouseBtn
{
    if (!_mouseBtn)
    {
        _mouseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mouseBtn setBackgroundImage:[UIImage imageNamed:@"sc_brush_mouse_normal"] forState:UIControlStateNormal];
        [_mouseBtn setBackgroundImage:[UIImage imageNamed:@"sc_brush_mouse_selected"] forState:UIControlStateSelected];
        [_mouseBtn setAdjustsImageWhenHighlighted:NO];
        [_mouseBtn addTarget:self action:@selector(sc_toolButtonListClicked:) forControlEvents:UIControlEventTouchUpInside];
        _mouseBtn.tag = YSBrushToolTypeMouse;
        _mouseBtn.selected = YES;
    }
    
    return _mouseBtn;
}

- (UIButton *)penBtn
{
    if (!_penBtn)
    {
        _penBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_penBtn setBackgroundImage:[UIImage imageNamed:@"sc_brush_pen_normal"] forState:UIControlStateNormal];
        [_penBtn setBackgroundImage:[UIImage imageNamed:@"sc_brush_pen_selected"] forState:UIControlStateSelected];
        [_penBtn setAdjustsImageWhenHighlighted:NO];
        [_penBtn addTarget:self action:@selector(sc_toolButtonListClicked:) forControlEvents:UIControlEventTouchUpInside];
        _penBtn.tag = YSBrushToolTypeLine;
    }
    
    return _penBtn;
}

- (UIButton *)textBtn
{
    if (!_textBtn)
    {
        _textBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_textBtn setBackgroundImage:[UIImage imageNamed:@"sc_brush_text_normal"] forState:UIControlStateNormal];
        [_textBtn setBackgroundImage:[UIImage imageNamed:@"sc_brush_text_selected"] forState:UIControlStateSelected];
        [_textBtn setAdjustsImageWhenHighlighted:NO];
        [_textBtn addTarget:self action:@selector(sc_toolButtonListClicked:) forControlEvents:UIControlEventTouchUpInside];
        _textBtn.tag = YSBrushToolTypeText;
    }
    
    return _textBtn;
}

- (UIButton *)shapeBtn
{
    if (!_shapeBtn)
    {
        _shapeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shapeBtn setBackgroundImage:[UIImage imageNamed:@"sc_brush_shape_normal"] forState:UIControlStateNormal];
        [_shapeBtn setBackgroundImage:[UIImage imageNamed:@"sc_brush_shape_selected"] forState:UIControlStateSelected];
        [_shapeBtn setAdjustsImageWhenHighlighted:NO];
        [_shapeBtn addTarget:self action:@selector(sc_toolButtonListClicked:) forControlEvents:UIControlEventTouchUpInside];
        _shapeBtn.tag = YSBrushToolTypeShape;
    }
    
    return _shapeBtn;
}

- (UIButton *)eraserBtn
{
    if (!_eraserBtn)
    {
        _eraserBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_eraserBtn setBackgroundImage:[UIImage imageNamed:@"sc_brush_eraser_normal"] forState:UIControlStateNormal];
        [_eraserBtn setBackgroundImage:[UIImage imageNamed:@"sc_brush_eraser_selected"] forState:UIControlStateSelected];
        [_eraserBtn setAdjustsImageWhenHighlighted:NO];
        [_eraserBtn addTarget:self action:@selector(sc_toolButtonListClicked:) forControlEvents:UIControlEventTouchUpInside];
        _eraserBtn.tag = YSBrushToolTypeEraser;
    }
    
    return _eraserBtn;
}

- (UIButton *)clearBtn
{
    if (!_clearBtn)
    {
        _clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearBtn setBackgroundImage:[UIImage imageNamed:@"sc_brush_clear_normal"] forState:UIControlStateNormal];
        [_clearBtn setBackgroundImage:[UIImage imageNamed:@"sc_brush_clear_selected"] forState:UIControlStateHighlighted];
        [_clearBtn setAdjustsImageWhenHighlighted:NO];
        [_clearBtn addTarget:self action:@selector(sc_toolButtonListClicked:) forControlEvents:UIControlEventTouchUpInside];
        _clearBtn.tag = YSDrawTypeClear;
    }
    
    return _clearBtn;
}

@end

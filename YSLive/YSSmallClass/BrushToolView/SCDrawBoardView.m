//
//  SCDrawBoardView.m
//  YSLive
//
//  Created by fzxm on 2019/11/7.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCDrawBoardView.h"
#import "SCColorSelectView.h"
#import "YSSliderSuperView.h"

#define WeightViewCoefficient (28.00 - 6.00) / (1.00 - 0.03)
@interface SCDrawBoardView ()
<
    UIGestureRecognizerDelegate
>
/// 背景view
@property (nonatomic, strong) UIView *bacContainerView;

/// 默认笔按钮 或者空心矩形

@property (nonatomic, strong) UIButton *toolOneBtn;
/// 记号笔按钮 或者 实心矩形
@property (nonatomic, strong) UIButton *toolTwoBtn;
/// 线按钮 或者 空心圆形
@property (nonatomic, strong) UIButton *toolThreeBtn;
/// 箭头按钮 或者 实心圆形
@property (nonatomic, strong) UIButton *toolFourBtn;
/// 割线
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) SCColorSelectView *colorSelectView;
@property (nonatomic, strong) UIView *progressSelectView;
@property (nonatomic, strong) UIView *progressView;

@property (nonatomic, strong) YSSliderSuperView *slider;
/// 滑杆 粗细view
@property (nonatomic, strong) UIView *weightView;
/// 存放按钮的数组
@property (nonatomic, strong) NSArray *toolBtnArr;

///// 画笔类型  边框类型
//@property (nonatomic, assign) YSDrawType drawType;
/// 颜色
@property (nonatomic, strong) NSString *selectColor;
/// 线宽
@property (nonatomic, assign) CGFloat progressResult;

@end

@implementation SCDrawBoardView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.drawType = YSDrawTypePen;
    self.selectColor = [[YSLiveManager shareInstance].whiteBoardManager getPrimaryColorHex];
    self.progressResult = 0.5f;
    BMWeakSelf
    self.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureClicked:)];
    tapGesture.delegate =self;
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGesture];
    
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = YSSkinDefineColor(@"ToolBgColor");
    self.backgroundView.layer.masksToBounds = YES;
    self.backgroundView.layer.cornerRadius = 20;
    [self addSubview:self.backgroundView];
    
    self.bacContainerView = [[UIView alloc] init];
    self.bacContainerView.backgroundColor = UIColor.clearColor;
    [self.backgroundView addSubview:self.bacContainerView];
    [self.bacContainerView bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(weakSelf.backgroundView.bmmas_left);
        make.right.bmmas_equalTo(weakSelf.backgroundView.bmmas_right);
        make.bottom.bmmas_equalTo(weakSelf.backgroundView.bmmas_bottom);
    }];
    
    self.toolOneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.toolTwoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.toolThreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.toolFourBtn = [UIButton buttonWithType:UIButtonTypeCustom];

    self.toolBtnArr = @[self.toolOneBtn,self.toolTwoBtn,self.toolThreeBtn,self.toolFourBtn];
    
    UIButton *lastBtn = nil;
    
    for (int i = 0; i < self.toolBtnArr.count; i++) {
        UIButton *btn = self.toolBtnArr[i];
        [self.bacContainerView addSubview:btn];
        [btn addTarget:self action:@selector(toolBtnsSelect:) forControlEvents:UIControlEventTouchUpInside];
        [btn bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
            make.size.bmmas_equalTo([NSValue valueWithCGSize:CGSizeMake(30, 30)]);
            make.left.bmmas_equalTo(lastBtn ? lastBtn.bmmas_right : weakSelf.bacContainerView.bmmas_left).bmmas_offset(lastBtn ? 30  : 19);
            make.top.bmmas_equalTo(weakSelf.bacContainerView.bmmas_top).bmmas_offset(21);
            if (i == self.toolBtnArr.count - 1)
            {
                make.right.bmmas_equalTo(weakSelf.bacContainerView.bmmas_right).bmmas_offset(-19);
            }
        }];
        lastBtn = btn;
    }
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = YSSkinDefineColor(@"lineColor");
    [self.bacContainerView addSubview:self.lineView];
    [self.lineView bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(weakSelf.bacContainerView).bmmas_offset(13);
        make.right.bmmas_equalTo(weakSelf.bacContainerView).bmmas_offset(-13);
        make.top.bmmas_equalTo(weakSelf.toolOneBtn.bmmas_bottom).bmmas_offset(15);
        make.height.bmmas_equalTo(@(1));
    }];
    
    self.colorSelectView = [[SCColorSelectView alloc] init];
    [self.colorSelectView setCurrentSelectColor:self.selectColor];
    [self.bacContainerView addSubview:self.colorSelectView];
    [self.colorSelectView bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(weakSelf.bacContainerView).bmmas_offset(20);
        make.right.bmmas_equalTo(weakSelf.bacContainerView).bmmas_offset(-14);
        make.top.bmmas_equalTo(weakSelf.lineView.bmmas_bottom).bmmas_offset(38);
        make.height.bmmas_equalTo(@(20));
    }];
    self.colorSelectView.chooseBackBlock = ^(NSString * _Nonnull colorStr) {

        if ([weakSelf.delegate respondsToSelector:@selector(brushSelectorViewDidSelectDrawType:color:widthProgress:)])
        {
            [weakSelf.delegate brushSelectorViewDidSelectDrawType:weakSelf.drawType color:colorStr widthProgress:weakSelf.progressResult];
        }
        weakSelf.selectColor = colorStr;
    };
    
    self.progressView = [[UIView alloc] init];
    self.progressView.backgroundColor =YSSkinElementColor(@"brushTool_slider", @"bgColor");
    self.progressView.layer.masksToBounds = YES;
    self.progressView.layer.cornerRadius = 2.5f;
    [self.bacContainerView addSubview:self.progressView];
    [self.progressView bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(weakSelf.bacContainerView.bmmas_left).bmmas_offset(20);
        make.right.bmmas_equalTo(weakSelf.bacContainerView.bmmas_right).bmmas_offset(-44);
        make.height.bmmas_equalTo(@(10));
        make.top.bmmas_equalTo(weakSelf.colorSelectView.bmmas_bottom).bmmas_offset(33);
        make.bottom.bmmas_equalTo(weakSelf.bacContainerView.bmmas_bottom).bmmas_offset(-33);
    }];
    
    self.progressSelectView = [[UIView alloc] init];
    self.progressSelectView.backgroundColor = YSSkinDefineColor(@"defaultSelectedBgColor");
    self.progressSelectView.layer.masksToBounds = YES;
    self.progressSelectView.layer.cornerRadius = 2.5f;
    [self.bacContainerView addSubview:self.progressSelectView];
    [self.progressSelectView bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(weakSelf.bacContainerView.bmmas_left).bmmas_offset(20);
        make.width.bmmas_equalTo(weakSelf.progressView.bmmas_width).multipliedBy(weakSelf.progressResult);
        make.height.bmmas_equalTo(@(10));
        make.top.bmmas_equalTo(weakSelf.colorSelectView.bmmas_bottom).bmmas_offset(33);
    }];
    
    self.slider = [[YSSliderSuperView alloc] init];
    self.slider.minimumTrackTintColor = [UIColor clearColor];
    self.slider.maximumTrackTintColor = [UIColor clearColor];
 [self.slider setThumbImage:YSSkinElementImage(@"brushTool_slider", @"iconNor") forState:UIControlStateNormal];
    self.slider.minimumValue = 0.03f;
    self.slider.maximumValue = 1.0;
    self.slider.value = self.progressResult;
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderViewEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.bacContainerView addSubview:self.slider];
    [self.slider bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        make.height.bmmas_equalTo(@(5));
        make.centerY.bmmas_equalTo(weakSelf.progressView);
        make.left.bmmas_equalTo(weakSelf.progressView.bmmas_left).bmmas_offset(-4);
        make.right.bmmas_equalTo(weakSelf.progressView.bmmas_right).bmmas_offset(4);
    }];
    
    
    self.weightView = [[UIView alloc] init];
    self.weightView.backgroundColor = YSSkinDefineColor(@"defaultSelectedBgColor");
    [self.bacContainerView addSubview:self.weightView];
    [self.weightView bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
        
        make.width.height.bmmas_equalTo(@(weakSelf.slider.value * WeightViewCoefficient + 5 ));
        make.centerY.bmmas_equalTo(weakSelf.progressView);
        make.centerX.bmmas_equalTo(weakSelf.bacContainerView.bmmas_right).bmmas_offset(-24);
        
    }];
    self.weightView.layer.cornerRadius = (weakSelf.slider.value * WeightViewCoefficient + 5 ) / 2;
    self.weightView.layer.masksToBounds = YES;
    
    [self.backgroundView bmmas_remakeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(weakSelf.bacContainerView.bmmas_left);
        make.right.bmmas_equalTo(weakSelf.bacContainerView.bmmas_right);
        make.top.bmmas_equalTo(weakSelf.bacContainerView.bmmas_top);
        make.bottom.bmmas_equalTo(weakSelf.bacContainerView.bmmas_bottom);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.frame = CGRectMake(73, 0, BMUI_SCREEN_WIDTH-73, BMUI_SCREEN_HEIGHT);
}

- (void)tapGestureClicked:(UITapGestureRecognizer *)tap
{
    self.hidden = YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.backgroundView])
    {
        return NO;
    }
    else
    {
        return YES;
    }

}

#pragma mark - SETTER

- (void)changeSelectColor:(NSString *)selectColor
{
    NSArray *colorArray = [SCColorSelectView colorArray];
    
    BOOL found = NO;
    for (NSString *colorStr in colorArray)
    {
        if ([colorStr isEqualToString:selectColor])
        {
            found = YES;
            break;
        }
    }
    
    if (found)
    {
        self.selectColor = selectColor;
        [self.colorSelectView setCurrentSelectColor:self.selectColor];
    }
}

- (void)setBrushToolType:(YSBrushToolType)brushToolType
{
    _brushToolType = brushToolType;
    
    YSLiveManager *liveManager = [YSLiveManager shareInstance];
    YSBrushToolsConfigs *config = [liveManager.whiteBoardManager getCurrentBrushToolConfig];
    
    YSDrawType drawType = config.drawType;
    // 工具颜色各自配置
    //NSString *colorHex = config.colorHex;
    NSString *colorHex = [[YSLiveManager shareInstance].whiteBoardManager getPrimaryColorHex];
    CGFloat progress = config.progress;

    switch (brushToolType)
    {
        case YSBrushToolTypeMouse:
            self.hidden = YES;
            break;
          
        case YSBrushToolTypeLine:
            self.drawType = drawType;
            [self creatToolBtnWithBrushToolType:YSBrushToolTypeLine];
            [self showType:YSSelectorShowType_All];
            
            break;
            
        case YSBrushToolTypeText:
            self.drawType = drawType;
            [self showType:YSSelectorShowType_ColorSize];
            break;
            
        case YSBrushToolTypeShape:
            self.drawType = drawType;
            [self creatToolBtnWithBrushToolType:YSBrushToolTypeShape];
            [self showType:YSSelectorShowType_All];
            break;
            
        case YSBrushToolTypeEraser:
            self.drawType = drawType;
            [self showType:YSSelectorShowType_Size];
        
            break;
            
        default:
            break;
    }
    
    self.slider.value = progress;
    self.progressResult = progress;
    [self changeSelectColor:colorHex];
    [self layoutIfNeeded];
    
    [self.progressSelectView bmmas_remakeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(self.bacContainerView.bmmas_left).bmmas_offset(20);
        make.width.bmmas_equalTo(progress * self.progressView.frame.size.width);
        make.height.bmmas_equalTo(@(10));
        make.top.bmmas_equalTo(self.colorSelectView.bmmas_bottom).bmmas_offset(33);
    }];
//    [self layoutIfNeeded];
    [self.weightView bmmas_updateConstraints:^(BMMASConstraintMaker *make) {
        make.width.height.bmmas_equalTo(@(progress * WeightViewCoefficient + 5));
    }];
    self.weightView.layer.cornerRadius = (progress * WeightViewCoefficient + 5) / 2;
    self.weightView.layer.masksToBounds = YES;
    if (brushToolType != YSBrushToolTypeMouse)
    {
        if ([self.delegate respondsToSelector:@selector(brushSelectorViewDidSelectDrawType:color:widthProgress:)])
        {
            [self.delegate brushSelectorViewDidSelectDrawType:_drawType color:self.selectColor widthProgress:progress];
        }
    }
}

- (void)setDrawType:(YSDrawType)drawType
{
    _drawType = drawType;
    
    for (UIButton *tool in self.toolBtnArr)
    {
        tool.selected = NO;
    }

    switch (drawType) {
        case YSDrawTypePen:
        case YSDrawTypeEmptyRectangle:
            self.toolOneBtn.selected = YES;
            break;
        case YSDrawTypeMarkPen:
        case YSDrawTypeFilledRectangle:
            self.toolTwoBtn.selected = YES;
            break;
        case YSDrawTypeLine:
        case YSDrawTypeEmptyEllipse:
            self.toolThreeBtn.selected = YES;
            break;
        case YSDrawTypeArrowLine:
        case YSDrawTypeFilledEllipse:
            self.toolFourBtn.selected = YES;
            break;
        default:
            break;
    }
}

- (void)creatToolBtnWithBrushToolType:(YSBrushToolType)brushToolType
{
    if (brushToolType == YSBrushToolTypeLine)
    {

        [self.toolOneBtn setImage:YSSkinElementImage(@"brushTool_drawpen", @"iconNor") forState:UIControlStateNormal];
        [self.toolOneBtn setImage:YSSkinElementImage(@"brushTool_drawpen", @"iconSel") forState:UIControlStateSelected];
        
        [self.toolTwoBtn setImage:YSSkinElementImage(@"brushTool_markpen", @"iconNor") forState:UIControlStateNormal];
        [self.toolTwoBtn setImage:YSSkinElementImage(@"brushTool_markpen", @"iconSel") forState:UIControlStateSelected];
        
        [self.toolThreeBtn setImage:YSSkinElementImage(@"brushTool_line", @"iconNor") forState:UIControlStateNormal];
        [self.toolThreeBtn setImage:YSSkinElementImage(@"brushTool_line", @"iconSel") forState:UIControlStateSelected];
        
        [self.toolFourBtn setImage:YSSkinElementImage(@"brushTool_arrowline", @"iconNor") forState:UIControlStateNormal];
        [self.toolFourBtn setImage:YSSkinElementImage(@"brushTool_arrowline", @"iconSel") forState:UIControlStateSelected];
        
    }
    
    if (brushToolType == YSBrushToolTypeShape)
    {

        [self.toolOneBtn setImage:YSSkinElementImage(@"brushTool_emptyrectangle", @"iconNor") forState:UIControlStateNormal];
        [self.toolOneBtn setImage:YSSkinElementImage(@"brushTool_emptyrectangle", @"iconSel") forState:UIControlStateSelected];
        
        [self.toolTwoBtn setImage:YSSkinElementImage(@"brushTool_filledrectangle", @"iconNor") forState:UIControlStateNormal];
        [self.toolTwoBtn setImage:YSSkinElementImage(@"brushTool_filledrectangle", @"iconSel") forState:UIControlStateSelected];
        
        [self.toolThreeBtn setImage:YSSkinElementImage(@"brushTool_emptyellipse", @"iconNor") forState:UIControlStateNormal];
        [self.toolThreeBtn setImage:YSSkinElementImage(@"brushTool_emptyellipse", @"iconSel") forState:UIControlStateSelected];
        
        [self.toolFourBtn setImage:YSSkinElementImage(@"brushTool_filledellipse", @"iconNor") forState:UIControlStateNormal];
        [self.toolFourBtn setImage:YSSkinElementImage(@"brushTool_filledellipse", @"iconSel") forState:UIControlStateSelected];
    }
    
}

- (void)showType:(YSSelectorShowType)type
{
    BMWeakSelf
    switch (type) {
        case YSSelectorShowType_All:
        {
            [self.backgroundView bmmas_remakeConstraints:^(BMMASConstraintMaker *make) {
                make.left.bmmas_equalTo(weakSelf.bacContainerView.bmmas_left);
                make.right.bmmas_equalTo(weakSelf.bacContainerView.bmmas_right);
                make.top.bmmas_equalTo(weakSelf.bacContainerView.bmmas_top);
                make.bottom.bmmas_equalTo(weakSelf.bacContainerView.bmmas_bottom);
            }];
            break;
        }
        case YSSelectorShowType_ColorSize:
        {
            [self.backgroundView bmmas_remakeConstraints:^(BMMASConstraintMaker *make) {
                make.left.bmmas_equalTo(weakSelf.bacContainerView.bmmas_left);
                make.right.bmmas_equalTo(weakSelf.bacContainerView.bmmas_right);
                make.top.bmmas_equalTo(weakSelf.lineView.bmmas_bottom);
                make.bottom.bmmas_equalTo(weakSelf.bacContainerView.bmmas_bottom);
            }];
            break;
        }
        case YSSelectorShowType_Color:
        {
            [self.backgroundView bmmas_remakeConstraints:^(BMMASConstraintMaker *make) {
                make.left.bmmas_equalTo(weakSelf.bacContainerView.bmmas_left);
                make.right.bmmas_equalTo(weakSelf.bacContainerView.bmmas_right);
                make.top.bmmas_equalTo(weakSelf.lineView.bmmas_bottom);
                make.bottom.bmmas_equalTo(weakSelf.progressView.bmmas_top).bmmas_offset(-12 );
            }];
            break;
        }
        case YSSelectorShowType_Size:
        {
            [self.backgroundView bmmas_remakeConstraints:^(BMMASConstraintMaker *make) {
                make.left.bmmas_equalTo(weakSelf.bacContainerView.bmmas_left);
                make.right.bmmas_equalTo(weakSelf.bacContainerView.bmmas_right);
                make.top.bmmas_equalTo(weakSelf.progressView.bmmas_top).bmmas_offset(-33);
                make.bottom.bmmas_equalTo(weakSelf.bacContainerView.bmmas_bottom);
            }];
            
            break;
        }
            
        default:
            break;
    }
}
#pragma mark - SEL
- (void)toolBtnsSelect:(UIButton *)btn
{
    if (self.brushToolType == YSBrushToolTypeLine)
    {
        /**
        YSDrawTypePen               = 10,    //钢笔
        YSDrawTypeMarkPen           = 11,    //记号笔
        YSDrawTypeLine              = 12,    //直线
        YSDrawTypeArrowLine         = 13,    //箭头
        */
        self.drawType = 10 + [self.toolBtnArr indexOfObject:btn];//通过整型得到type
    }
    
    if (self.brushToolType == YSBrushToolTypeShape)
    {
        /**
         YSDrawTypeEmptyRectangle    = 30,    //空心矩形
         YSDrawTypeFilledRectangle   = 31,    //实心矩形
         YSDrawTypeEmptyEllipse      = 32,    //空心圆
         YSDrawTypeFilledEllipse     = 33,    //实心圆
         */
        self.drawType = 30 + [self.toolBtnArr indexOfObject:btn];
    }

    if ([self.delegate respondsToSelector:@selector(brushSelectorViewDidSelectDrawType:color:widthProgress:)]) {
        [self.delegate brushSelectorViewDidSelectDrawType:self.drawType color:self.selectColor widthProgress:self.progressResult];
    }
}
- (void)sliderViewEnd:(UISlider *)sender
{
    self.progressResult = sender.value;
    if ([self.delegate respondsToSelector:@selector(brushSelectorViewDidSelectDrawType:color:widthProgress:)]) {
        [self.delegate brushSelectorViewDidSelectDrawType:_drawType color:self.selectColor widthProgress:self.progressResult];
    }
}

- (void)sliderValueChanged:(UISlider *)sender
{
    BMWeakSelf
    self.progressResult = sender.value;
    [self layoutIfNeeded];
    [self.weightView bmmas_updateConstraints:^(BMMASConstraintMaker *make) {
        
        make.width.height.bmmas_equalTo(@(sender.value * WeightViewCoefficient + 5));

    }];
    self.weightView.layer.cornerRadius = (sender.value * WeightViewCoefficient + 5) / 2;
    self.weightView.layer.masksToBounds = YES;
    
    [self.progressSelectView bmmas_remakeConstraints:^(BMMASConstraintMaker *make) {
        make.left.bmmas_equalTo(weakSelf.bacContainerView.bmmas_left).bmmas_offset(20);
        make.width.bmmas_equalTo(sender.value * weakSelf.progressView.frame.size.width);
        make.height.bmmas_equalTo(@(10));
        make.top.bmmas_equalTo(weakSelf.colorSelectView.bmmas_bottom).bmmas_offset(33);
    }];
    
}

@end

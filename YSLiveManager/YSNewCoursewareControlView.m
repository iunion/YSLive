//
//  YSNewCoursewareControlView.m
//  YSAll
//
//  Created by jiang deng on 2020/8/27.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSNewCoursewareControlView.h"

#if USECUSTOMER_COURSEWARECONTROLVIEW

@implementation YSNewCoursewareControlView

- (void)setupUI
{
    //[super setupUI];
    
    self.backgroundColor = [UIColor redColor];
    
    [self newSetupUI];
}

- (void)newSetupUI
{
    CGFloat btnHeight = 24;
    
    // 刷新按钮
    UIButton *frashBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnHeight, btnHeight)];
    [frashBtn setImage:YSSkinWhiteElementImage(@"controlTool_frash", @"iconNor") forState:UIControlStateNormal];
    [frashBtn setImage:YSSkinWhiteElementImage(@"controlTool_frash", @"iconSel") forState:UIControlStateSelected];
    [frashBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    frashBtn.tag = YSCoursewareControlViewTag_Fresh;
    [self addSubview:frashBtn];
    
    // 全屏按钮
    UIButton *allScreenBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnHeight, btnHeight)];
    [allScreenBtn setImage:YSSkinWhiteElementImage(@"controlTool_allScreen", @"iconNor") forState:UIControlStateNormal];
    [allScreenBtn setImage:YSSkinWhiteElementImage(@"controlTool_allScreen", @"iconHigh") forState:UIControlStateHighlighted];
    [allScreenBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    allScreenBtn.tag = YSCoursewareControlViewTag_AllScreen;
    [self addSubview:allScreenBtn];
    
    // 左翻页按钮
    UIButton *leftTurnBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 17, 25)];
    [leftTurnBtn setImage:YSSkinWhiteElementImage(@"controlTool_leftTurn", @"iconNor") forState:UIControlStateNormal];
    [leftTurnBtn setImage:YSSkinWhiteElementImage(@"controlTool_leftTurn", @"iconHigh") forState:UIControlStateHighlighted];
    [leftTurnBtn setImage:YSSkinWhiteElementImage(@"controlTool_leftTurn", @"iconDis") forState:UIControlStateDisabled];
    leftTurnBtn.enabled = NO;
    [leftTurnBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    leftTurnBtn.tag = YSCoursewareControlViewTag_LeftTurn;
    [self addSubview:leftTurnBtn];
    
    // 页码
    UILabel *pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 28)];
    pageLabel.textColor = YSSkinWhiteDefineColor(@"DefaultTitleColor");
    pageLabel.textAlignment = NSTextAlignmentCenter;
    pageLabel.font = [UIFont systemFontOfSize:16];
    pageLabel.tag = YSCoursewareControlViewTag_Page;
    [self addSubview:pageLabel];
    pageLabel.adjustsFontSizeToFitWidth = YES;
    
    // 右翻页按钮
    UIButton *rightTurnBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 17, 25)];
    [rightTurnBtn setImage:YSSkinWhiteElementImage(@"controlTool_rightTurn", @"iconNor") forState:UIControlStateNormal];
    [rightTurnBtn setImage:YSSkinWhiteElementImage(@"controlTool_rightTurn", @"iconHigh") forState:UIControlStateHighlighted];
    [rightTurnBtn setImage:YSSkinWhiteElementImage(@"controlTool_rightTurn", @"iconDis") forState:UIControlStateDisabled];
    rightTurnBtn.enabled = NO;
    [rightTurnBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    rightTurnBtn.tag = YSCoursewareControlViewTag_RightTurn;
    [self addSubview:rightTurnBtn];
    
    // 放大按钮
    UIButton *augmentBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnHeight, btnHeight)];
    [augmentBtn setImage:YSSkinWhiteElementImage(@"controlTool_enlarge", @"iconNor") forState:UIControlStateNormal];
    [augmentBtn setImage:YSSkinWhiteElementImage(@"controlTool_enlarge", @"iconHigh") forState:UIControlStateHighlighted];
    [augmentBtn setImage:YSSkinWhiteElementImage(@"controlTool_enlarge", @"iconDis") forState:UIControlStateDisabled];
    [augmentBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    augmentBtn.tag = YSCoursewareControlViewTag_Augment;
    [self addSubview:augmentBtn];
    
    // 缩小按钮
    UIButton *reduceBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnHeight, btnHeight)];
    [reduceBtn setImage:YSSkinWhiteElementImage(@"controlTool_minimize", @"iconNor") forState:UIControlStateNormal];
    [reduceBtn setImage:YSSkinWhiteElementImage(@"controlTool_minimize", @"iconHigh") forState:UIControlStateHighlighted];
    [reduceBtn setImage:YSSkinWhiteElementImage(@"controlTool_minimize", @"iconDis") forState:UIControlStateDisabled];
    [reduceBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    reduceBtn.tag = YSCoursewareControlViewTag_Reduce;
    [self addSubview:reduceBtn];
    
    augmentBtn.enabled = YES;
    reduceBtn.enabled  = NO;
    
    if ([YSSessionManager sharedInstance].localUser.role != YSUserType_Teacher)
    {
        return;
    }
    
    // 由全屏还原的按钮
    UIButton *returnBtn = [[UIButton alloc]initWithFrame:CGRectMake(3, 0, btnHeight, btnHeight)];
    [returnBtn setImage:YSSkinWhiteElementImage(@"controlTool_return", @"iconNor") forState:UIControlStateNormal];
    returnBtn.contentMode = UIViewContentModeScaleAspectFill;
    [returnBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    returnBtn.tag = YSCoursewareControlViewTag_Return;
    [self addSubview:returnBtn];
    
    // 删除按钮
    UIButton *cancleBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnHeight, btnHeight)];
    [cancleBtn setImage:YSSkinWhiteElementImage(@"controlTool_close", @"iconNor") forState:UIControlStateNormal];
    cancleBtn.contentMode = UIViewContentModeScaleAspectFill;
    [cancleBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    cancleBtn.tag = YSCoursewareControlViewTag_Close;
    [self addSubview:cancleBtn];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

}

/// 计算工具条的宽度
- (void)freshViewWith
{
    [super freshViewWith];
}

@end

#endif


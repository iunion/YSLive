//
//  YSNewCoursewareControlView.m
//  YSAll
//
//  Created by jiang deng on 2020/8/27.
//  Copyright © 2020 YS. All rights reserved.
//

#import "CHNewCoursewareControlView.h"

@implementation CHNewCoursewareControlView

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
    [frashBtn setImage:[UIImage imageNamed:@"controlTool_frash_normal_skin"] forState:UIControlStateNormal];
    [frashBtn setImage:[UIImage imageNamed:@"controlTool_frash_selected_skin"] forState:UIControlStateSelected];
    [frashBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    frashBtn.tag = CHCoursewareControlViewTag_Fresh;
    [self addSubview:frashBtn];
    
    // 全屏按钮
    UIButton *allScreenBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnHeight, btnHeight)];
    [allScreenBtn setImage:[UIImage imageNamed:@"controlTool_allScreen_normal_skin"] forState:UIControlStateNormal];
    [allScreenBtn setImage:[UIImage imageNamed:@"controlTool_allScreen_highLighted_skin"]  forState:UIControlStateHighlighted];
    [allScreenBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    allScreenBtn.tag = CHCoursewareControlViewTag_AllScreen;
    [self addSubview:allScreenBtn];
    
    // 左翻页按钮
    UIButton *leftTurnBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 17, 25)];
    [leftTurnBtn setImage:[UIImage imageNamed:@"controlTool_leftTurn_normal_skin"] forState:UIControlStateNormal];
    [leftTurnBtn setImage:[UIImage imageNamed:@"controlTool_leftTurn_highLighted_skin"] forState:UIControlStateHighlighted];
    [leftTurnBtn setImage:[UIImage imageNamed:@"controlTool_leftTurn_disable_skin"] forState:UIControlStateDisabled];
    leftTurnBtn.enabled = NO;
    [leftTurnBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    leftTurnBtn.tag = CHCoursewareControlViewTag_LeftTurn;
    [self addSubview:leftTurnBtn];
    
    // 页码
    UILabel *pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 28)];
    pageLabel.textColor = [UIColor whiteColor];
    pageLabel.textAlignment = NSTextAlignmentCenter;
    pageLabel.font = [UIFont systemFontOfSize:16];
    pageLabel.tag = CHCoursewareControlViewTag_Page;
    [self addSubview:pageLabel];
    pageLabel.adjustsFontSizeToFitWidth = YES;
    
    // 右翻页按钮
    UIButton *rightTurnBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 17, 25)];
    [rightTurnBtn setImage:[UIImage imageNamed:@"controlTool_rightTurn_normal_skin"] forState:UIControlStateNormal];
    [rightTurnBtn setImage:[UIImage imageNamed:@"controlTool_rightTurn_highLighted_skin"] forState:UIControlStateHighlighted];
    [rightTurnBtn setImage:[UIImage imageNamed:@"controlTool_rightTurn_disable_skin"] forState:UIControlStateDisabled];
    rightTurnBtn.enabled = NO;
    [rightTurnBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    rightTurnBtn.tag = CHCoursewareControlViewTag_RightTurn;
    [self addSubview:rightTurnBtn];
    
    // 放大按钮
    UIButton *augmentBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnHeight, btnHeight)];
    [augmentBtn setImage:[UIImage imageNamed:@"controlTool_enlarge_normal_skin"] forState:UIControlStateNormal];
    [augmentBtn setImage:[UIImage imageNamed:@"controlTool_enlarge_highLighted_skin"] forState:UIControlStateHighlighted];
    [augmentBtn setImage:[UIImage imageNamed:@"controlTool_enlarge_disable_skin"] forState:UIControlStateDisabled];
    [augmentBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    augmentBtn.tag = CHCoursewareControlViewTag_Augment;
    [self addSubview:augmentBtn];
    
    // 缩小按钮
    UIButton *reduceBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnHeight, btnHeight)];
    [reduceBtn setImage:[UIImage imageNamed:@"controlTool_minimize_normal_skin"] forState:UIControlStateNormal];
    [reduceBtn setImage:[UIImage imageNamed:@"controlTool_minimize_highLighted_skin"] forState:UIControlStateHighlighted];
    [reduceBtn setImage:[UIImage imageNamed:@"controlTool_minimize_disable_skin"] forState:UIControlStateDisabled];
    [reduceBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    reduceBtn.tag = CHCoursewareControlViewTag_Reduce;
    [self addSubview:reduceBtn];
    
    augmentBtn.enabled = YES;
    reduceBtn.enabled  = NO;
    
    // 由全屏还原的按钮
    UIButton *returnBtn = [[UIButton alloc]initWithFrame:CGRectMake(3, 0, btnHeight, btnHeight)];
    [returnBtn setImage:[UIImage imageNamed:@"controlTool_return_normal_skin"] forState:UIControlStateNormal];
    returnBtn.contentMode = UIViewContentModeScaleAspectFill;
    [returnBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    returnBtn.tag = CHCoursewareControlViewTag_Return;
    [self addSubview:returnBtn];
    
    // 删除按钮
    UIButton *cancleBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnHeight, btnHeight)];
    [cancleBtn setImage:[UIImage imageNamed:@"controlTool_close_normal_skin"] forState:UIControlStateNormal];
    cancleBtn.contentMode = UIViewContentModeScaleAspectFill;
    [cancleBtn addTarget:self action:@selector(buttonsClick:) forControlEvents:UIControlEventTouchUpInside];
    cancleBtn.tag = CHCoursewareControlViewTag_Close;
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



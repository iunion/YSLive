//
//  CHFullFloatControlView.m
//  YSAll
//
//  Created by 马迪 on 2021/4/7.
//  Copyright © 2021 CH. All rights reserved.
//

#import "CHFullFloatControlView.h"

#define ButtonNum 3
#define TopMargin 10

@interface CHFullFloatControlView ()

@property (nonatomic, strong) UIButton *hideButton;

@property (nonatomic, strong) UIButton *mineButton;

@property (nonatomic, strong) UIButton *allButton;

@end

@implementation CHFullFloatControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = YSSkinDefineColor(@"Color2");
        
        [self setupUIView];
 
        self.frame = frame;
    }
    
    return self;
}

#pragma mark -
- (void)setupUIView
{
    self.hideButton = [self creatButtonWithImage:@"fullFloat_cancleBtn" withTag:FullFloatControlCancle];
    
    self.mineButton = [self creatButtonWithImage:@"fullFloat_mineBtn" withTag:FullFloatControlMine];
    
    self.allButton = [self creatButtonWithImage:@"fullFloat_allBtn" withTag:FullFloatControlAll];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGFloat buttonH = (frame.size.height - 2*TopMargin)/ButtonNum;
    
    self.hideButton.frame = CGRectMake(0, TopMargin, frame.size.width, buttonH);
    
    self.mineButton.frame = CGRectMake(0, self.hideButton.bm_bottom, frame.size.width, buttonH);
    
    self.allButton.frame = CGRectMake(0, self.mineButton.bm_bottom, frame.size.width, buttonH);
}

- (UIButton *)creatButtonWithImage:(NSString *)imageName withTag:(NSInteger)tag
{
    UIButton *button = [[UIButton alloc]init];
    button.tag = tag;
    [button setImage:YSSkinElementImage(imageName, @"iconNor") forState:UIControlStateNormal];
    [button setImage:YSSkinElementImage(imageName, @"iconSel") forState:UIControlStateSelected];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    return button;
}

- (void)buttonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (sender.tag == FullFloatControlCancle)
    {
        self.allButton.selected = NO;
        self.mineButton.selected = NO;
    }
    else if (sender.tag == FullFloatControlMine)
    {
        self.allButton.selected = NO;
    }
    else if (sender.tag == FullFloatControlAll)
    {
        self.mineButton.selected = NO;
    }
    
    if (_fullFloatControlButtonClick)
    {
        _fullFloatControlButtonClick(sender.tag);
    }
}

@end

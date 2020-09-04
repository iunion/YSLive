//
//  SCColorSelectView.m
//  YSLive
//
//  Created by fzxm on 2019/11/7.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCColorSelectView.h"
#import "SCColorListView.h"
#import "SCColorTipView.h"

#define SCColorViewBaseTag 500

@interface SCColorSelectView ()

@property (nonatomic, strong) NSString        * currentColor;
@property (nonatomic, strong) NSString        * currentChooseColor;
@property (nonatomic, strong) UIView          * currentColorView;
@property (nonatomic, strong) SCColorListView * colorListView;
@property (nonatomic, strong) NSMutableArray  * colorViewMuArray;

@property (nonatomic, strong) SCColorTipView * colorTipView;
@property (nonatomic, strong) UIView * chooseTipView;

@end

@implementation SCColorSelectView

+ (NSArray *)colorArray
{
    static NSArray <NSString *> *colors = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colors = [NSArray arrayWithObjects:
                       @"#000000", @"#9B9B9B", @"#FFFFFF", @"#FF87A3", @"#FF515F", @"#FF0000",
                       @"#E18838", @"#AC6B00", @"#864706", @"#FF7E0B", @"#FFD33B", @"#FFF52B",
                       @"#B3D330", @"#88BA44", @"#56A648", @"#53B1A4", @"#68C1FF", @"#058CE5",
                       @"#0B48FF", @"#C1C7FF", @"#D25FFA", @"#6E3087", @"#3D2484", @"#142473",  nil];
    });
    return colors;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = UIColor.clearColor;
        
        [self addSubview:self.currentColorView];
        [self.currentColorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.mas_equalTo(self);
            make.width.mas_equalTo(self.mas_height);
        }];
        
        [self addSubview:self.colorListView];
        [self.colorListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.mas_equalTo(self);
            make.right.mas_equalTo(self.currentColorView.mas_left).mas_offset(-10);
        }];
        
        [self.colorViewMuArray removeAllObjects];
        __block UIView * lastView = nil;
        for (int i = 0; i < [SCColorSelectView colorArray].count; i ++) {
            
            UIView * colorView = [[UIView alloc] init];
            colorView.backgroundColor = [YSCommonTools colorWithHexString:[[SCColorSelectView colorArray] objectAtIndex:i]];
            colorView.tag = SCColorViewBaseTag + i;
            [self.colorListView addSubview:colorView];
            [self.colorViewMuArray addObject:colorView];
            [colorView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.and.bottom.mas_equalTo(self.colorListView);
                make.width.mas_equalTo(self.colorListView).dividedBy([SCColorSelectView colorArray].count);
                if (lastView == nil) {
                    make.left.mas_offset(0);
                } else {
                    make.left.mas_equalTo(lastView.mas_right);
                }
                lastView = colorView;
            }];
        }
        
        [self.colorListView addSubview:self.chooseTipView];
        self.chooseTipView.hidden = YES;
        [self.chooseTipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.mas_equalTo(lastView).mas_offset(4);
            make.center.mas_equalTo(lastView);
        }];
        
        self.colorTipView.hidden = YES;
        [self.colorListView addSubview:self.colorTipView];
        [self.colorTipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.currentColorView);
            make.height.mas_equalTo(self.colorTipView.mas_width).mas_offset(2);
            make.bottom.mas_equalTo(lastView.mas_top).mas_offset(-4);
            make.centerX.mas_equalTo(lastView);
        }];
    }
    return self;
}

- (UIView *)currentColorView {
    
    if (nil == _currentColorView) {
        _currentColorView = [[UIView alloc] init];
        _currentColorView.layer.borderWidth = 1;
        _currentColorView.layer.borderColor = UIColor.whiteColor.CGColor;
        _currentColorView.layer.cornerRadius = 2;
        _currentColorView.layer.masksToBounds = YES;
    }
    return _currentColorView;
}

- (UIView *)colorListView {
    
    if (nil == _colorListView) {
        _colorListView = [[SCColorListView alloc] init];
        _colorListView.backgroundColor = UIColor.clearColor;
        _colorListView.layer.borderWidth = 1;
        _colorListView.layer.borderColor = UIColor.whiteColor.CGColor;
        _colorListView.userInteractionEnabled = YES;
        
        YSWeakSelf
        _colorListView.BeganBlock = ^(CGPoint point) {
            [weakSelf selectorViewTouchDown:point];
        };
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectorViewTap:)];
        [_colorListView addGestureRecognizer:tap];

        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(selectorViewPan:)];
        [_colorListView addGestureRecognizer:pan];
    }
    return _colorListView;
}

- (void) selectorViewTouchDown:(CGPoint)locat {
    
    NSInteger index = locat.x / (CGRectGetWidth(self.colorListView.frame) / [SCColorSelectView colorArray].count);
    if (index < 0) index = 0;
    if (index >= [SCColorSelectView colorArray].count) index = [SCColorSelectView colorArray].count - 1;
    
    [self showColorTipWithIndex:index];
}

- (void) selectorViewTap:(UITapGestureRecognizer *)tap {
    
     if (tap.state == UIGestureRecognizerStateEnded) {
        
         self.chooseTipView.hidden = YES;
         self.colorTipView.hidden  = YES;
         
         [self changeDrawColor];
    }
}

- (void) selectorViewPan:(UIPanGestureRecognizer *)pan {
    
    if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged) {
  
        CGPoint locat = [pan locationInView:pan.view];
        NSInteger index = locat.x / (CGRectGetWidth(self.colorListView.frame) / [SCColorSelectView colorArray].count);
        if (index < 0) index = 0;
        if (index >= [SCColorSelectView colorArray].count) index = [SCColorSelectView colorArray].count - 1;
        
        [self showColorTipWithIndex:index];
        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        
        self.chooseTipView.hidden = YES;
        self.colorTipView.hidden  = YES;
        
        [self changeDrawColor];
        
    } else {
        
        self.chooseTipView.hidden = YES;
        self.colorTipView.hidden  = YES;
        self.currentColorView.backgroundColor = [YSCommonTools colorWithHexString:self.currentColor];
    }
}

- (void) showColorTipWithIndex:(NSInteger)index {
    
    NSString * chooseColor = [[SCColorSelectView colorArray] objectAtIndex:index];
    self.currentChooseColor = chooseColor;
    
    self.currentColorView.backgroundColor = [YSCommonTools colorWithHexString:chooseColor];
    [self.colorTipView changeColor:chooseColor];
    
    
    UIView * colorView = [self.colorListView viewWithTag:SCColorViewBaseTag + index];
    [self.chooseTipView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.mas_equalTo(colorView).mas_offset(4);
        make.center.mas_equalTo(colorView).priorityLow();
    }];
    self.chooseTipView.hidden = NO;
    
    [self.colorTipView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.currentColorView);
        make.height.mas_equalTo(self.colorTipView.mas_width).mas_offset(2);
        make.bottom.mas_equalTo(colorView.mas_top).mas_offset(-4);
        make.centerX.mas_equalTo(colorView);
    }];
    self.colorTipView.hidden = NO;
}

- (UIView *)chooseTipView {
    if (_chooseTipView == nil) {
        _chooseTipView = [[UIView alloc] init];
        _chooseTipView.backgroundColor = UIColor.clearColor;
        _chooseTipView.layer.borderWidth = 2;
        _chooseTipView.layer.borderColor = UIColor.whiteColor.CGColor;
    }
    return _chooseTipView;
}

- (SCColorTipView *)colorTipView {
    if (nil == _colorTipView) {
        _colorTipView = [[SCColorTipView alloc] init];
        _colorTipView.backgroundColor = UIColor.clearColor;
    }
    return _colorTipView;
}

//- (NSArray *)colorArray {
//    if (_colorArray == nil) {
//        _colorArray = [NSArray arrayWithObjects:
//                       @"#000000", @"#9B9B9B", @"#FFFFFF", @"#FF87A3", @"#FF515F", @"#FF0000",
//                       @"#E18838", @"#AC6B00", @"#864706", @"#FF7E0B", @"#FFD33B", @"#FFF52B",
//                       @"#B3D330", @"#88BA44", @"#56A648", @"#53B1A4", @"#68C1FF", @"#058CE5",
//                       @"#0B48FF", @"#C1C7FF", @"#D25FFA", @"#6E3087", @"#3D2484", @"#142473",  nil];
//    }
//    return _colorArray;
//}

- (void)setCurrentSelectColor:(NSString *)curColor {
    
    self.currentColorView.backgroundColor = [YSCommonTools colorWithHexString:curColor];
    self.currentColor = curColor;
    self.currentChooseColor = curColor;
}

- (void) changeDrawColor {
    
    if (!self.currentChooseColor) {
        return;
    }
    
    self.currentColor = self.currentChooseColor;
    if (self.chooseBackBlock) {
        self.chooseBackBlock(self.currentChooseColor);
    }
}

@end

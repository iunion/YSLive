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
        [self.currentColorView bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
            make.top.right.bottom.bmmas_equalTo(self);
            make.width.bmmas_equalTo(self.bmmas_height);
        }];
        
        [self addSubview:self.colorListView];
        [self.colorListView bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
            make.top.bottom.left.bmmas_equalTo(self);
            make.right.bmmas_equalTo(self.currentColorView.bmmas_left).bmmas_offset(-10);
        }];
        
        [self.colorViewMuArray removeAllObjects];
        __block UIView * lastView = nil;
        for (int i = 0; i < [SCColorSelectView colorArray].count; i ++) {
            
            UIView * colorView = [[UIView alloc] init];
            colorView.backgroundColor = [UIColor bm_colorWithHexString:[[SCColorSelectView colorArray] objectAtIndex:i]];
            colorView.tag = SCColorViewBaseTag + i;
            [self.colorListView addSubview:colorView];
            [self.colorViewMuArray addObject:colorView];
            [colorView bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
                make.top.and.bottom.bmmas_equalTo(self.colorListView);
                make.width.bmmas_equalTo(self.colorListView).dividedBy([SCColorSelectView colorArray].count);
                if (lastView == nil) {
                    make.left.bmmas_offset(0);
                } else {
                    make.left.bmmas_equalTo(lastView.bmmas_right);
                }
                lastView = colorView;
            }];
        }
        
        [self.colorListView addSubview:self.chooseTipView];
        self.chooseTipView.hidden = YES;
        [self.chooseTipView bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
            make.width.and.height.bmmas_equalTo(lastView).bmmas_offset(4);
            make.center.bmmas_equalTo(lastView);
        }];
        
        self.colorTipView.hidden = YES;
        [self.colorListView addSubview:self.colorTipView];
        [self.colorTipView bmmas_makeConstraints:^(BMMASConstraintMaker *make) {
            make.width.bmmas_equalTo(self.currentColorView);
            make.height.bmmas_equalTo(self.colorTipView.bmmas_width).bmmas_offset(2);
            make.bottom.bmmas_equalTo(lastView.bmmas_top).bmmas_offset(-4);
            make.centerX.bmmas_equalTo(lastView);
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
        
        BMWeakSelf
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
        self.currentColorView.backgroundColor = [UIColor bm_colorWithHexString: self.currentColor];
    }
}

- (void) showColorTipWithIndex:(NSInteger)index {
    
    NSString * chooseColor = [[SCColorSelectView colorArray] objectAtIndex:index];
    self.currentChooseColor = chooseColor;
    
    self.currentColorView.backgroundColor = [UIColor bm_colorWithHexString:chooseColor];
    [self.colorTipView changeColor:chooseColor];
    
    
    UIView * colorView = [self.colorListView viewWithTag:SCColorViewBaseTag + index];
    [self.chooseTipView bmmas_remakeConstraints:^(BMMASConstraintMaker *make) {
        make.width.and.height.bmmas_equalTo(colorView).bmmas_offset(4);
        make.center.bmmas_equalTo(colorView).priorityLow();
    }];
    self.chooseTipView.hidden = NO;
    
    [self.colorTipView bmmas_remakeConstraints:^(BMMASConstraintMaker *make) {
        make.width.bmmas_equalTo(self.currentColorView);
        make.height.bmmas_equalTo(self.colorTipView.bmmas_width).bmmas_offset(2);
        make.bottom.bmmas_equalTo(colorView.bmmas_top).bmmas_offset(-4);
        make.centerX.bmmas_equalTo(colorView);
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
    
    self.currentColorView.backgroundColor = [UIColor bm_colorWithHexString:curColor];
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

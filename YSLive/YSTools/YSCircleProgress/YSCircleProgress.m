//
//  YSCircleProgress.m
//  YSAll
//
//  Created by jiang deng on 2020/2/15.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSCircleProgress.h"

@interface YSCircleProgress ()
{
    /** 原点 */
    CGPoint _origin;
    /** 半径 */
    CGFloat _radius;
    /** 起始 */
    CGFloat _startAngle;
    /** 结束 */
    CGFloat _endAngle;
}

/// 进度显示
@property (nonatomic, strong) UILabel *progressLabel;
/// 进度显示层
@property (nonatomic, strong) CAShapeLayer *progressLayer;
/// 进度背景显示层
@property (nonatomic, strong) CAShapeLayer *bgLayer;

@end


@implementation YSCircleProgress

- (instancetype)init
{
    if (self)
    {
        self = [super init];
        
        self.backgroundColor = [UIColor clearColor];
        
        [self setUI];
    }
    
    return self;
}

#pragma mark - 初始化页面

- (void)setUI
{
    CAShapeLayer *bgLayer = [CAShapeLayer layer];
    bgLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:bgLayer];
    self.bgLayer = bgLayer;

    CAShapeLayer *progressLayer = [CAShapeLayer layer];
    progressLayer.lineCap = kCALineCapRound;
    progressLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:progressLayer];
    self.progressLayer = bgLayer;

    UILabel *progressLabel = [[UILabel alloc] init];
    progressLabel.textAlignment = NSTextAlignmentCenter;
    progressLabel.textColor = [UIColor blackColor];
    [self addSubview:progressLabel];
    self.progressLabel = progressLabel;
    
    
//    UIBezierPath *bottomPath = [UIBezierPath bezierPathWithArcCenter:_origin radius:_radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
//    _bottomLayer.path = bottomPath.CGPath;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _origin = CGPointMake(self.bounds.size.width * 0.5f, self.bounds.size.height * 0.5f);
    _radius = self.bounds.size.width * 0.5f;

    //self.progressLabel =
}

@end

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

/// 园显示层
@property (nonatomic, strong) CAShapeLayer *circlrLayer;

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
    _innerColor = [UIColor greenColor];
    _lineBgColor = [UIColor blueColor];
    _lineProgressColor = [UIColor redColor];
    _lineWidth = 8.0f;
    _isClockwise = NO;
    
    CAShapeLayer *circlrLayer = [CAShapeLayer layer];
    circlrLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:circlrLayer];
    self.circlrLayer = circlrLayer;
    
    CAShapeLayer *bgLayer = [CAShapeLayer layer];
    bgLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:bgLayer];
    self.bgLayer = bgLayer;

    CAShapeLayer *progressLayer = [CAShapeLayer layer];
    progressLayer.lineCap = kCALineCapRound;
    progressLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:progressLayer];
    self.progressLayer = progressLayer;

    UILabel *progressLabel = [[UILabel alloc] init];
    progressLabel.textAlignment = NSTextAlignmentCenter;
    progressLabel.textColor = [UIColor blackColor];
    [self addSubview:progressLabel];
    self.progressLabel = progressLabel;
    
    self.progressLabel.hidden = YES;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _origin = CGPointMake(self.bounds.size.width * 0.5f, self.bounds.size.height * 0.5f);
    _radius = self.bounds.size.width * 0.5f;

    self.circlrLayer.frame = self.bounds;
    self.bgLayer.frame = self.bounds;
    self.progressLayer.frame = self.bounds;

    self.progressLabel.bm_size = CGSizeMake(self.bm_width-8.0f, 20.0f);
    self.progressLabel.center = _origin;
}

- (void)setInnerColor:(UIColor *)innerColor
{
    _innerColor = innerColor;
    
    [self drawPath];
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    self.progressLabel.text = [NSString stringWithFormat:@"%.0f%%",progress * 100];
    
    _startAngle = - M_PI_2;
    _endAngle = _startAngle + progress * M_PI * 2;
    
    [self drawPath];
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    
    [self drawPath];
}

- (void)setLineBgColor:(UIColor *)lineBgColor
{
    _lineBgColor = lineBgColor;
    
    [self drawPath];
}

- (void)setLineProgressColor:(UIColor *)lineProgressColor
{
    _lineProgressColor = lineProgressColor;
    
    [self drawPath];
}

- (void)setIsClockwise:(BOOL)isClockwise
{
    _isClockwise = isClockwise;
    
    [self drawPath];
}

- (void)drawPath
{
    self.circlrLayer.fillColor = self.innerColor.CGColor;
    UIBezierPath *circlrPath = [UIBezierPath bezierPathWithArcCenter:_origin radius:_radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    self.circlrLayer.path = circlrPath.CGPath;

    self.bgLayer.strokeColor = self.lineBgColor.CGColor;
    self.bgLayer.lineWidth = self.lineWidth;
    UIBezierPath *bgPath = [UIBezierPath bezierPathWithArcCenter:_origin radius:_radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    self.bgLayer.path = bgPath.CGPath;
    
    self.progressLayer.strokeColor = self.lineProgressColor.CGColor;
    self.progressLayer.lineWidth = self.lineWidth;
    UIBezierPath *progressPath = [UIBezierPath bezierPathWithArcCenter:_origin radius:_radius startAngle:_startAngle endAngle:_endAngle clockwise:self.isClockwise];
    self.progressLayer.path = progressPath.CGPath;
}


@end

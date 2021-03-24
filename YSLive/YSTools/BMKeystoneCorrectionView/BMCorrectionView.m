//
//  BMCorrectionView.m
//  YSLive
//
//  Created by jiang deng on 2021/2/5.
//  Copyright © 2021 YS. All rights reserved.
//

#import "BMCorrectionView.h"

@interface BMCorrectionView ()

@property (nonatomic, assign) CGPoint startPoint;

@end

@implementation BMCorrectionView

#pragma mark 绘制动作

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    self.startPoint = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    [self changeTo:point];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 触控过短会导致系统认为canceltouchues执行本方法而不调用touchesEnded，需要将绘制移交到touchesEnded
    [self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
        
    [self changeTo:point];
}

- (void)changeTo:(CGPoint)point
{
    if (CGPointEqualToPoint(point, self.startPoint))
    {
        return;
    }
    
    CGPoint fromPoint = CGPointMake(self.startPoint.x / self.bm_width, self.startPoint.y / self.bm_height);
    CGPoint toPoint = CGPointMake(point.x / self.bm_width, point.y / self.bm_height);
    
    // 精度 0.001
    if (fabs(fromPoint.x - toPoint.x) >= 0.001 || fabs(fromPoint.y - toPoint.y) >= 0.001)
    {
        if (self.delegate)
        {
            [self.delegate correctionViewFromPoint:fromPoint toPoint:toPoint];
        }
        
        self.startPoint = point;
    }
}

@end

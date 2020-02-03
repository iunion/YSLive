//
//  YSBarrageTextCell.m
//  TestApp
//
//  Created by QMTV on 2017/8/23.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "YSBarrageTextCell.h"

@implementation YSBarrageTextCell

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

- (void)updateSubviewsData {
    if (!_textLabel) {
        [self addSubview:self.textLabel];
    }
//    if (self.textDescriptor.textShadowOpened) {
//        self.textLabel.layer.shadowColor = self.textDescriptor.shadowColor.CGColor;
//        self.textLabel.layer.shadowOffset = self.textDescriptor.shadowOffset;
//        self.textLabel.layer.shadowRadius = self.textDescriptor.shadowRadius;
//        self.textLabel.layer.shadowOpacity = self.textDescriptor.shadowOpacity;
//    }
    
    [self.textLabel setAttributedText:self.textDescriptor.attributedText];
}



//使用该方法不会模糊，根据屏幕密度计算
- (UIImage *)convertViewToImage:(UIView *)view {
    
    UIImage *imageRet;// = [[UIImage alloc] init];
    //UIGraphicsBeginImageContextWithOptions(区域大小, 是否是非透明的, 屏幕密度);
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    imageRet = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageRet;
    
}
- (void)layoutContentSubviews {
//    NSRange range=NSMakeRange(0, self.textDescriptor.attributedText.string.length);
//    NSDictionary *attribute=[self.textDescriptor.attributedText attributesAtIndex:0 effectiveRange:&range];
//    CGRect textFrame = [self.textDescriptor.attributedText.string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil];
    CGSize size = [self.textDescriptor.attributedText bm_sizeToFitWidth:UI_SCREEN_HEIGHT];
    self.textLabel.frame = CGRectMake(0, 0, size.width, size.height);
    //UIImage *contentImage = [self convertViewToImage:self.textLabel];
    
}

- (void)convertContentToImage {
    UIImage *contentImage = [self convertViewToImage:self.textLabel];
    [self.layer setContents:(__bridge id)contentImage.CGImage];
    
/**
     [self.textLabel setAttributedText:[[NSAttributedString alloc] initWithAttributedString:self.textDescriptor.attributedText]];
     NSAttributedString *att = self.textDescriptor.attributedText;
     UILabel *label = [[UILabel alloc] init];
     
     CGSize size = [att bm_sizeToFitWidth:UI_SCREEN_WIDTH];
     label.frame = CGRectMake(0, 0, size.width+10, size.height+10);
     label.attributedText = self.textDescriptor.attributedText;
 //    [self convertViewToImage:label];
     UIImage *contentImage = [self convertViewToImage:label];
     [self.layer setContents:(__bridge id)contentImage.CGImage];
 */
}

- (void)removeSubViewsAndSublayers {
    [super removeSubViewsAndSublayers];
    
    _textLabel = nil;
}

- (void)addBarrageAnimationWithDelegate:(id<CAAnimationDelegate>)animationDelegate {
    if (!self.superview) {
        return;
    }
    
    CGPoint startCenter = CGPointMake(CGRectGetMaxX(self.superview.bounds) + CGRectGetWidth(self.bounds)/2, self.center.y);
    CGPoint endCenter = CGPointMake(-(CGRectGetWidth(self.bounds)/2), self.center.y);
    
    CGFloat animationDuration = self.barrageDescriptor.animationDuration;
    if (self.barrageDescriptor.fixedSpeed > 0.0) {//如果是固定速度那就用固定速度
        if (self.barrageDescriptor.fixedSpeed > 100.0) {
            self.barrageDescriptor.fixedSpeed = 100.0;
        }
        animationDuration = (startCenter.x - endCenter.x)/([UIScreen mainScreen].scale*2)/self.barrageDescriptor.fixedSpeed;
    }
    
    CAKeyframeAnimation *walkAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    walkAnimation.values = @[[NSValue valueWithCGPoint:startCenter], [NSValue valueWithCGPoint:endCenter]];
    walkAnimation.keyTimes = @[@(0.0), @(1.0)];
    walkAnimation.duration = animationDuration;
    walkAnimation.repeatCount = 1;
    walkAnimation.delegate =  animationDelegate;
    walkAnimation.removedOnCompletion = NO;
    walkAnimation.fillMode = kCAFillModeForwards;
    
    [self.layer addAnimation:walkAnimation forKey:kBarrageAnimation];
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _textLabel;
}

- (void)setBarrageDescriptor:(YSBarrageDescriptor *)barrageDescriptor {
    [super setBarrageDescriptor:barrageDescriptor];
    self.textDescriptor = (YSBarrageTextDescriptor *)barrageDescriptor;
}

@end

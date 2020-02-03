//
//  YSSkinCoverWindow.m
//  YSAll
//
//  Created by jiang deng on 2019/12/25.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSSkinCoverWindow.h"
#import "YSSkinCoverLayer.h"
#import "SCEyeCareEmptyVC.h"

@interface YSSkinCoverWindow ()

@property (nonatomic, weak) YSSkinCoverLayer *skinCoverLayer;
@property (nonatomic, weak) SCEyeCareEmptyVC *eyeCareEmptyVC;

@end

@implementation YSSkinCoverWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        // 移除所有的子layer
        [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        
        // 添加layer
        YSSkinCoverLayer *skinCoverLayer = [YSSkinCoverLayer layer];
        skinCoverLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        //skinCoverLayer.backgroundColor = [UIColor blackColor].CGColor;
        skinCoverLayer.backgroundColor = [UIColor bm_colorWithHex:0xFFECB2].CGColor;
        skinCoverLayer.opacity = 0.3f;
        
        [self.layer addSublayer:skinCoverLayer];
        
        self.skinCoverLayer = skinCoverLayer;
    }
    
    return self;
}

- (void)changeSkinCoverColor:(UIColor *)color
{
    self.skinCoverLayer.backgroundColor = color.CGColor;
}

- (void)freshWindowWithShowStatusBar:(BOOL)showStatusBar isRientationPortrait:(BOOL)isRientationPortrait
{
    SCEyeCareEmptyVC *vc = [[SCEyeCareEmptyVC alloc] init];
    vc.showStatusBar = showStatusBar;
    vc.isRientationPortrait = isRientationPortrait;

    self.rootViewController = vc;
    self.eyeCareEmptyVC = vc;
}

@end

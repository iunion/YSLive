//
//  YSBarrageView.m
//  TestApp
//
//  Created by QMTV on 2017/8/22.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "YSBarrageManager.h"

@interface YSBarrageManager ()

@property (nonatomic, strong) YSBarrageRenderView *renderView;

@end

@implementation YSBarrageManager

- (void)dealloc {
    NSLog(@"%s", __func__);
    [_renderView stop];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _renderView = [[YSBarrageRenderView alloc] init];

    }
    
    return self;
}

- (void)start {
    [self.renderView start];
}

- (void)pause {
    [self.renderView pause];
}

- (void)resume {
    [self.renderView resume];
}

- (void)stop {
    [self.renderView stop];
}

- (void)renderBarrageDescriptor:(YSBarrageDescriptor *)barrageDescriptor {
    if (!barrageDescriptor) {
        return;
    }
    if (![barrageDescriptor isKindOfClass:[YSBarrageDescriptor class]]) {
        return;
    }
    
    YSBarrageCell *barrageCell = [self.renderView dequeueReusableCellWithClass:barrageDescriptor.barrageCellClass];
    if (!barrageCell) {
        return;
    }
    barrageCell.barrageDescriptor = barrageDescriptor;
    [self.renderView fireBarrageCell:barrageCell];
}

#pragma mark ------ getter
//- (YSBarrageRenderView *)renderView {
//    return _renderView;
//}

- (YSBarrageRenderStatus)renderStatus
{
    return self.renderView.renderStatus;
}

@end

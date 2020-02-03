//
//  YSBarrageView.h
//  TestApp
//
//  Created by QMTV on 2017/8/22.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSBarrageRenderView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSBarrageManager : NSObject {
    YSBarrageRenderView *_renderView;
}

@property (nonatomic, strong, readonly) YSBarrageRenderView *renderView;
@property (nonatomic, assign, readonly) YSBarrageRenderStatus renderStatus;

- (void)start;
- (void)pause;
- (void)resume;
- (void)stop;

- (void)renderBarrageDescriptor:(YSBarrageDescriptor *)barrageDescriptor;

@end

NS_ASSUME_NONNULL_END

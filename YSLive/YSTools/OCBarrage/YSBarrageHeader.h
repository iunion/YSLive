//
//  YSBarrageHeader.h
//  TestApp
//
//  Created by QMTV on 2017/8/23.
//  Copyright © 2017年 LFC. All rights reserved.
//

#ifndef YSBarrageHeader_h
#define YSBarrageHeader_h

#define kBarrageAnimation @"kBarrageAnimation"
@class YSBarrageDescriptor;
@class YSBarrageCell;

typedef void(^YSBarrageTouchAction)(__weak YSBarrageDescriptor *descriptor);
typedef void(^YSBarrageCellTouchedAction)(__weak YSBarrageDescriptor *descriptor, __weak YSBarrageCell *cell);

typedef NS_ENUM(NSInteger, YSBarragePositionPriority) {
    YSBarragePositionLow = 0,
    YSBarragePositionMiddle,
    YSBarragePositionHigh,
    YSBarragePositionVeryHigh
};

typedef NS_ENUM(NSInteger, YSBarrageRenderPositionStyle) {//新加的cell的y坐标的类型
    YSBarrageRenderPositionRandomTracks = 0, //将YSBarrageRenderView分成几条轨道, 随机选一条展示
    YSBarrageRenderPositionRandom, // y坐标随机
    YSBarrageRenderPositionIncrease, //y坐标递增, 循环
};

#endif /* YSBarrageHeader_h */

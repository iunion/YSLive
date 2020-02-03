//
//  YSBarrageContentView.h
//  TestApp
//
//  Created by QMTV on 2017/8/22.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSBarrageCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YSBarrageRenderStatus) {
	YSBarrageRenderStoped = 0,
	YSBarrageRenderStarted,
	YSBarrageRenderPaused
};

@interface YSBarrageRenderView : UIView <CAAnimationDelegate> {
	NSMutableArray<YSBarrageCell *> *_animatingCells;
	NSMutableArray<YSBarrageCell *> *_idleCells;
	dispatch_semaphore_t _animatingCellsLock;
	dispatch_semaphore_t _idleCellsLock;
	dispatch_semaphore_t _trackInfoLock;
	YSBarrageCell *_lastestCell;
	UIView *_lowPositionView;
	UIView *_middlePositionView;
	UIView *_highPositionView;
	UIView *_veryHighPositionView;
	BOOL _autoClear;
	YSBarrageRenderStatus _renderStatus;
	NSMutableDictionary *_trackNextAvailableTime;
}

@property (nonatomic, strong, readonly) NSMutableArray<YSBarrageCell *> *animatingCells;
@property (nonatomic, strong, readonly) NSMutableArray<YSBarrageCell *> *idleCells;
@property (nonatomic, assign) YSBarrageRenderPositionStyle renderPositionStyle;
@property (nonatomic, assign, readonly) YSBarrageRenderStatus renderStatus;

- (nullable YSBarrageCell *)dequeueReusableCellWithClass:(Class)barrageCellClass;
- (void)fireBarrageCell:(YSBarrageCell *)barrageCell;
- (BOOL)trigerActionWithPoint:(CGPoint)touchPoint;

- (void)start;
- (void)pause;
- (void)resume;
- (void)stop;


@end

NS_ASSUME_NONNULL_END

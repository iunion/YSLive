//
//  SCVideoGridView.h
//  YSLive
//Created by jiang deng on 2019/11/8.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SCVideoView;
@interface SCVideoGridView : UIView

/// 默认尺寸
@property (nonatomic, assign) CGSize defaultSize;
/// 上边偏移
@property (nonatomic, assign) CGFloat topOffset;

@property (nonatomic, strong, readonly) NSMutableArray <SCVideoView *> *videoViewArray;

- (instancetype)initWithWideScreen:(BOOL)isWideScreen;

//- (void)freshViewWithVideoViewArray:(NSMutableArray<SCVideoView *> *)videoViewArray;

- (void)freshViewWithVideoViewArray:(NSMutableArray<SCVideoView *> *)videoViewArray withFouceVideo:(nullable SCVideoView *)fouceVideo withRoomLayout:(YSLiveRoomLayout)roomLayout withAppUseTheType:(YSAppUseTheType)appUseTheType;

- (void)clearView;

@end

NS_ASSUME_NONNULL_END

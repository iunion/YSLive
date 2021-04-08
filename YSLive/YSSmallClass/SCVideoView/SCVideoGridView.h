//
//  SCVideoGridView.h
//  YSLive
//Created by jiang deng on 2019/11/8.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CHVideoView;
@interface SCVideoGridView : UIView

/// 默认尺寸
@property (nonatomic, assign) CGSize defaultSize;
/// 上边偏移
@property (nonatomic, assign) CGFloat topOffset;

@property (nonatomic, strong, readonly) NSMutableArray <CHVideoView *> *videoSequenceArr;
//@property (nonatomic, strong, readonly) NSMutableDictionary *videoViewArrayDic;

- (instancetype)initWithWideScreen:(BOOL)isWideScreen;

//- (void)freshViewWithVideoViewArray:(NSMutableArray<CHVideoView *> *)videoViewArray;

- (void)freshViewWithVideoViewArray:(NSMutableArray<CHVideoView *> *)videoSequenceArr withFouceVideo:(nullable CHVideoView *)fouceVideo withRoomLayout:(CHRoomLayoutType)roomLayout withAppUseTheType:(CHRoomUseType)appUseTheType;

- (void)clearView;

@end

NS_ASSUME_NONNULL_END

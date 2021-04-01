//
//  CHBeautySetView.h
//  YSLive
//
//  Created by jiang deng on 2021/4/1.
//  Copyright © 2021 CH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHBeautySetModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CHBeautySetViewDelegate;
@interface CHBeautySetView : UIView

@property (nonatomic, weak) id <CHBeautySetViewDelegate> delegate;

@property (nonatomic, weak) YSLiveManager *liveManager;

/// 美颜数据
@property (nonatomic, weak) CHBeautySetModel *beautySetModel;

@end

@protocol CHBeautySetViewDelegate <NSObject>

- (void)beautySetFinished:(BOOL)isFinished;

@end

NS_ASSUME_NONNULL_END

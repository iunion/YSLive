//
//  CHBeautySetVC.h
//  YSLive
//
//  Created by jiang deng on 2021/3/29.
//  Copyright © 2021 CH. All rights reserved.
//

#import "YSSuperVC.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CHBeautySetVCDelegate;
@interface CHBeautySetVC : YSSuperVC

@property (nonatomic, weak) id <CHBeautySetVCDelegate> delegate;

@end

@protocol CHBeautySetVCDelegate <NSObject>

- (void)beautySetFinished:(BOOL)isFinished;

@end

NS_ASSUME_NONNULL_END

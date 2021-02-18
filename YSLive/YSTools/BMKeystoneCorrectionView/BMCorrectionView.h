//
//  BMCorrectionView.h
//  YSLive
//
//  Created by jiang deng on 2021/2/5.
//  Copyright © 2021 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BMCorrectionViewDelegate;

@interface BMCorrectionView : UIView

@property (nonatomic, weak) id <BMCorrectionViewDelegate> delegate;

@end

@protocol BMCorrectionViewDelegate <NSObject>

- (void)correctionViewFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;

@end

NS_ASSUME_NONNULL_END

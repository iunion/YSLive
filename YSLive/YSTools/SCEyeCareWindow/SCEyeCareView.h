//
//  SCEyeCareView.h
//  YSAll
//
//  Created by jiang deng on 2019/12/26.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SCEyeCareViewDelegate;

@interface SCEyeCareView : UIView

@property (nonatomic, weak) id <SCEyeCareViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame needRotation:(BOOL)needRotation;

@end

@protocol SCEyeCareViewDelegate <NSObject>

@optional

- (void)eyeCareViewClose;

@end

NS_ASSUME_NONNULL_END

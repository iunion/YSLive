//
//  UIView+BMNibLoading.h
//  BMBasekit
//
//  Created by DennisDeng on 14-5-5.
//  Copyright (c) 2014年 DennisDeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (BMNibLoading)

+ (instancetype)bm_instanceWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)bundleOrNil owner:(nullable id)ownerOrNil;
- (void)bm_loadContentsWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)bundleOrNil;

@end

NS_ASSUME_NONNULL_END

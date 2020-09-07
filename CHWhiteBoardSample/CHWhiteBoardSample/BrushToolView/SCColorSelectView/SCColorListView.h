//
//  SCColorListView.h
//  YSLive
//
//  Created by fzxm on 2019/11/7.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCColorListView : UIView
@property (nonatomic, copy) void(^BeganBlock)(CGPoint point);
@end

NS_ASSUME_NONNULL_END

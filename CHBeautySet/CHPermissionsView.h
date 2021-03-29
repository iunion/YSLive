//
//  CHPermissionsView.h
//  YSLive
//
//  Created by jiang deng on 2021/3/29.
//  Copyright © 2021 CH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CHPermissionsViewDelegate;
@interface CHPermissionsView : UIView

@property (nonatomic, weak) id <CHPermissionsViewDelegate> delegate;

@end

@protocol CHPermissionsViewDelegate <NSObject>

- (void)permissionsViewChanged;

@end

NS_ASSUME_NONNULL_END

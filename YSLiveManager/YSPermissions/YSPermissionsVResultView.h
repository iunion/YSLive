//
//  YSPermissionsVResultView.h
//  YSAll
//
//  Created by fzxm on 2019/12/19.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSPermissionsVResultView : UIView

@property (nonatomic, strong) UIColor *permissionColor;
@property (nonatomic, strong) UIColor *noPermissionColor;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *permissionText;
@property (nonatomic, strong) NSString *noPermissionText;

- (void)freshWithResult:(BOOL)result;

@end

NS_ASSUME_NONNULL_END

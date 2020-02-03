//
//  YSPermissionsVC.h
//  YSLive
//
//  Created by 马迪 on 2019/12/17.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YSSuperVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSPermissionsVC : YSSuperVC

@property (nonatomic, copy) void(^toJoinRoom)(void);

@end

NS_ASSUME_NONNULL_END

//
//  YSLoginViewController.h
//  YSEdu
//
//  Created by fzxm on 2019/10/9.
//  Copyright © 2019 ysxl. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "YSSuperVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSLoginVC : YSSuperVC

- (instancetype)initWithLoginURL:(NSURL *)loginurl;

// URL打开登录
- (void)joinRoomWithRoomId:(NSString *)roomId;

// URL直接进入房间
- (BOOL)joinRoomWithRoomParams:(NSDictionary *)roomParams userParams:(nullable NSDictionary *)userParams;

@end

NS_ASSUME_NONNULL_END

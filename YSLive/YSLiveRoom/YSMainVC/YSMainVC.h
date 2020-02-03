//
//  YSMainVC.h
//  YSLive
//
//  Created by jiang deng on 2019/10/14.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSMainSuperVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSMainVC : YSMainSuperVC

- (instancetype)initWithWideScreen:(BOOL)isWideScreen whiteBordView:(UIView *)whiteBordView userId:(nullable NSString *)userId;

@end

NS_ASSUME_NONNULL_END

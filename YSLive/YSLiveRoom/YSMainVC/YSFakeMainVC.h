//
//  YSFakeMainVC.h
//  YSAll
//
//  Created by 马迪 on 2021/3/18.
//  Copyright © 2021 YS. All rights reserved.
//

#import "YSMainSuperVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSFakeMainVC : YSMainSuperVC

- (instancetype)initWithWideScreen:(BOOL)isWideScreen whiteBordView:(UIView *)whiteBordView userId:(nullable NSString *)userId;

@end

NS_ASSUME_NONNULL_END

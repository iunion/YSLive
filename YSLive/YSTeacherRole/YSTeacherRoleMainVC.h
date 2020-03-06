//
//  YSTeacherRoleMainVC.h
//  YSLive
//
//  Created by 马迪 on 2019/12/23.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSClassMainSuperVC.h"

NS_ASSUME_NONNULL_BEGIN


@interface YSTeacherRoleMainVC : YSClassMainSuperVC

- (instancetype)initWithRoomType:(YSRoomTypes)roomType isWideScreen:(BOOL)isWideScreen maxVideoCount:(NSUInteger)maxCount whiteBordView:(UIView *)whiteBordView userId:(nullable NSString *)userId;


@end

NS_ASSUME_NONNULL_END

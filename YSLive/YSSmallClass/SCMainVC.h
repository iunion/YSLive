//
//  SCMainVC.h
//  YSLive
//
//  Created by fzxm on 2019/11/6.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSClassMainSuperVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCMainVC : YSClassMainSuperVC


- (instancetype)initWithRoomType:(CHRoomUserType)roomType isWideScreen:(BOOL)isWideScreen maxVideoCount:(NSUInteger)maxCount whiteBordView:(UIView *)whiteBordView userId:(nullable NSString *)userId withRoomLayout:(CHRoomLayoutType)roomLayoutType;

// 刷新content视频布局
//- (void)freshContentVideoView;
// 刷新宫格视频布局
//- (void)freshVideoGridView;

@end

NS_ASSUME_NONNULL_END

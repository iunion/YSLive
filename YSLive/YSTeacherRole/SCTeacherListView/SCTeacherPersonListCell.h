//
//  SCTeacherPersonListCell.h
//  YSLive
//
//  Created by fzxm on 2019/12/26.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SCTeacherPersonListCellDelegate <NSObject>

- (void)upPlatformBtnProxyClickWithRoomUser:(YSRoomUser *)roomUser;

- (void)speakBtnProxyClickWithRoomUser:(YSRoomUser *)roomUser;

- (void)outBtnProxyClickWithRoomUser:(YSRoomUser *)roomUser;

@end


@interface SCTeacherPersonListCell : UITableViewCell

@property (nonatomic, strong) YSRoomUser *userModel;
@property(nonatomic,weak) id<SCTeacherPersonListCellDelegate> delegate;

@end


NS_ASSUME_NONNULL_END

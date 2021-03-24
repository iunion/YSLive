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

- (void)upPlatformBtnProxyClickWithRoomUser:(CHRoomUser *)roomUser;

- (void)speakBtnProxyClickWithRoomUser:(CHRoomUser *)roomUser;

- (void)outBtnProxyClickWithRoomUser:(CHRoomUser *)roomUser;

@end


@interface SCTeacherPersonListCell : UITableViewCell

@property (nonatomic, strong) CHRoomUser *userModel;
@property(nonatomic,weak) id<SCTeacherPersonListCellDelegate> delegate;
- (void)setUserRole:(CHUserRoleType)userRoleType;
@end


NS_ASSUME_NONNULL_END

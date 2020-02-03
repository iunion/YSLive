//
//  SCTeacherListView.h
//  YSAll
//
//  Created by fzxm on 2019/12/26.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SCTeacherListViewDelegate <NSObject>
/// 上下台
- (void)upPlatformProxyWithRoomUser:(YSRoomUser *)roomUser;
/// 禁言
- (void)speakProxyWithRoomUser:(YSRoomUser *)roomUser;
/// 踢出房间
- (void)outProxyWithRoomUser:(YSRoomUser *)roomUser;

/// 选择课件
- (void)selectCoursewareProxyWithFileModel:(YSFileModel *)fileModel;
/// 删除课件
- (void)deleteCoursewareProxyWithFileModel:(YSFileModel *)fileModel;

- (void)tapGestureBackListView;
@end


@interface SCTeacherListView : UIView

@property(nonatomic, weak) id<SCTeacherListViewDelegate> delegate;

- (void)setDataSource:(NSArray *)dataSource withType:(SCTeacherTopBarType)type;

@end

NS_ASSUME_NONNULL_END

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

/// 上一页
- (void)leftPageProxyWithPage:(NSInteger)page;
- (void)rightPageProxyWithPage:(NSInteger)page;
- (void)searchProxyWithSearchContent:(NSString *)searchContent;
- (void)cancelProxy;

@end


@interface SCTeacherListView : UIView

@property(nonatomic, weak) id<SCTeacherListViewDelegate> delegate;
@property(nonatomic, assign) CGFloat bottomGap;
@property(nonatomic, assign) CGFloat topGap;
- (void)setDataSource:(NSArray *)dataSource withType:(SCBottomToolBarType)type userNum:(NSInteger)userNum;
/// 主要用于展示 多课件 媒体课件的状态
/// @param dataSource 课件列表
/// @param type 课件列表
/// @param userNum 课件个数
/// @param currentFileList 当前展示的课件数组
/// @param mediaFileID 当前展示的媒体课件
/// @param state 当前媒体课件状态
- (void)setDataSource:(NSArray *)dataSource withType:(SCBottomToolBarType)type userNum:(NSInteger)userNum currentFileList:(NSArray *)currentFileList mediaFileID:(NSString *)mediaFileID mediaState:(YSWhiteBordMediaState)state;
- (void)setPersonListCurrentPage:(NSInteger)currentPage totalPage:(NSInteger)totalPage;
- (void)setUserRole:(YSUserRoleType)userRoleType;
@end

NS_ASSUME_NONNULL_END

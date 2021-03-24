//
//  SCTeacherCoursewareListCell.h
//  YSLive
//
//  Created by fzxm on 2019/12/26.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SCTeacherCoursewareListCellDelegate <NSObject>

- (void)deleteBtnProxyClickWithFileModel:(CHFileModel *)fileModel;


@end

@interface SCTeacherCoursewareListCell : UITableViewCell

@property(nonatomic,weak) id<SCTeacherCoursewareListCellDelegate> delegate;

- (void)setFileModel:(CHFileModel *)fileModel isCurrent:(BOOL)isCurrent mediaFileID:(NSString *)mediaFileID mediaState:(CHMediaState)state;
- (void)setUserRole:(CHUserRoleType)userRoleType;

@end

NS_ASSUME_NONNULL_END

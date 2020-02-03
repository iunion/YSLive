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

- (void)deleteBtnProxyClickWithFileModel:(YSFileModel *)fileModel;


@end

@interface SCTeacherCoursewareListCell : UITableViewCell

@property(nonatomic,weak) id<SCTeacherCoursewareListCellDelegate> delegate;
@property (nonatomic, strong) YSFileModel *fileModel;

@end

NS_ASSUME_NONNULL_END

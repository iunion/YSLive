//
//  FileListTableViewCell.h
//  CHWhiteBoardSample
//
//  Created by fzxm on 2020/9/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CoursewareListCellDelegate <NSObject>

- (void)deleteBtnWithFileModel:(CHFileModel *)fileModel;


@end
@interface FileListTableViewCell : UITableViewCell

@property(nonatomic,weak) id<CoursewareListCellDelegate> delegate;
- (void)setFileModel:(CHFileModel *)fileModel;
@end

NS_ASSUME_NONNULL_END

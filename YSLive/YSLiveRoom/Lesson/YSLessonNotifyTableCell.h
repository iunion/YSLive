//
//  YSLessonNotifyTableCell.h
//  YSLive
//
//  Created by fzxm on 2019/10/17.
//  Copyright © 2019 FS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class YSLessonModel;
@class YSLessonNotifyTableCell;

typedef void (^TranslationBlock)( YSLessonNotifyTableCell *tableCell);
typedef void (^OpenBtnBlock)( YSLessonNotifyTableCell *tableCell);

@interface YSLessonNotifyTableCell : UITableViewCell

@property (nonatomic, strong) YSLessonModel *lessonModel;
@property (nonatomic, copy) TranslationBlock translationBlock;
@property (nonatomic, copy) OpenBtnBlock openBlock;

@end

NS_ASSUME_NONNULL_END

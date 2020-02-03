//
//  SCAnswerTBHeaderView.h
//  YSLive
//
//  Created by fzxm on 2019/11/21.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SCAnswerDetailModel;

@interface SCAnswerTBHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong)SCAnswerDetailModel *detailModel;

@end

NS_ASSUME_NONNULL_END

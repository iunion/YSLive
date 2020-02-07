//
//  YSClassInstructionCell.h
//  YSAll
//
//  Created by jiang deng on 2020/2/6.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSClassModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSClassInstructionCell : UITableViewCell

@property (nonatomic, strong, readonly) YSClassDetailModel *classDetailModel;

@property (nonatomic, assign, readonly) CGFloat cellHeight;

- (void)drawCellWithModel:(YSClassDetailModel *)classDetailModel;

@end

NS_ASSUME_NONNULL_END

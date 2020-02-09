//
//  YSClassMediumCell.h
//  YSAll
//
//  Created by jiang deng on 2020/2/6.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSClassModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol YSClassMediumCellDelegate;
@interface YSClassMediumCell : UITableViewCell

@property (nullable, nonatomic, weak) id <YSClassMediumCellDelegate> delegate;

@property (nonatomic, strong, readonly) YSClassDetailModel *classDetailModel;

- (void)drawCellWithModel:(YSClassDetailModel *)classDetailModel;

@end

@protocol YSClassMediumCellDelegate <NSObject>

@optional

- (void)playReplayClassWithClassDetailModel:(YSClassModel *)classModel index:(NSUInteger)replayIndex;

@end

NS_ASSUME_NONNULL_END

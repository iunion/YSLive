//
//  YSClassCell.h
//  YSAll
//
//  Created by jiang deng on 2020/2/6.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSClassModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol YSClassCellDelegate;
@interface YSClassCell : UITableViewCell

@property (nullable, nonatomic, weak) id <YSClassCellDelegate> delegate;

@property (nonatomic, strong, readonly) YSClassModel *classModel;

+ (CGFloat)cellHeight;

- (void)drawCellWithModel:(YSClassModel *)classModel isDetail:(BOOL)isDetail;

@end

@protocol YSClassCellDelegate <NSObject>

@optional

- (void)enterClassWith:(YSClassModel *)classModel;
- (void)openClassWith:(YSClassModel *)classModel;

@end

NS_ASSUME_NONNULL_END

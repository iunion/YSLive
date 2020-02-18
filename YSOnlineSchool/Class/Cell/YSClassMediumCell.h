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

@property (nonatomic, strong, readonly) YSClassReplayListModel *classReplayListModel;

- (void)drawCellWithModel:(YSClassReplayListModel *)classReplayListModel withClassState:(YSClassState)classState;

@end

@protocol YSClassMediumCellDelegate <NSObject>

@optional

- (void)playReviewClassWithClassReviewModel:(YSClassReviewModel *)classReviewModel index:(NSUInteger)replayIndex;

@end

@interface YSClassReplayView : UIView

@property (nullable, nonatomic, weak) id <YSClassMediumCellDelegate> delegate;

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) YSClassReviewModel *classReviewModel;

@end

NS_ASSUME_NONNULL_END

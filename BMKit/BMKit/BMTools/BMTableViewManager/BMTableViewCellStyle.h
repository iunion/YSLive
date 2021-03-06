//
//  BMTableViewCellStyle.h
//  BMTableViewManagerSample
//
//  Created by DennisDeng on 2017/4/20.
//  Copyright © 2017年 DennisDeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMTableViewManagerDefine.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, UITableViewCellAnimationStyle)
{
    UITableViewCellAnimationStyle_None,
    UITableViewCellAnimationStyle_Rotate,
    UITableViewCellAnimationStyle_Scale,
    // have bug
    UITableViewCellAnimationStyle_ScalePoint,
    UITableViewCellAnimationStyle_Move,
    UITableViewCellAnimationStyle_MoveSpring,
    UITableViewCellAnimationStyle_Alpha,
    UITableViewCellAnimationStyle_Fall,
    UITableViewCellAnimationStyle_LeftRightOverTurn,
    UITableViewCellAnimationStyle_UpDownOverTurn
};

@interface BMTableViewCellStyle : NSObject

@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, assign) UITableViewCellSelectionStyle defaultCellSelectionStyle;
// backgroundImageView/selectedBackgroundImageView边缘间隔(左右)
@property (nonatomic, assign) CGFloat backgroundImageMargin;
// contentView边缘间隔(左右)
@property (nonatomic, assign) CGFloat contentViewMargin;

// 背景图
@property (nullable, nonatomic, strong) NSMutableDictionary *backgroundImages;
@property (nullable, nonatomic, strong) NSMutableDictionary *selectedBackgroundImages;

@property (nonatomic, assign) UITableViewCellAnimationStyle animationStyle;

- (BOOL)hasCustomBackgroundImage;
- (nullable UIImage *)backgroundImageForCellPositionType:(BMTableViewCell_PositionType)cellPositionType;
- (void)setBackgroundImage:(nullable UIImage *)image forCellPositionType:(BMTableViewCell_PositionType)cellPositionType;

- (BOOL)hasCustomSelectedBackgroundImage;
- (nullable UIImage *)selectedBackgroundImageForCellPositionType:(BMTableViewCell_PositionType)cellPositionType;
- (void)setSelectedBackgroundImage:(nullable UIImage *)image forCellPositionType:(BMTableViewCell_PositionType)cellPositionType;

@end

NS_ASSUME_NONNULL_END

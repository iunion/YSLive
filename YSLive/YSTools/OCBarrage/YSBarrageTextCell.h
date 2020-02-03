//
//  YSBarrageTextCell.h
//  TestApp
//
//  Created by QMTV on 2017/8/23.
//  Copyright © 2017年 LFC. All rights reserved.
//

#import "YSBarrageCell.h"
#import "YSBarrageTextDescriptor.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSBarrageTextCell : YSBarrageCell

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong, nullable) YSBarrageTextDescriptor *textDescriptor;

@end

NS_ASSUME_NONNULL_END

//
//  YSClassDetailVC.h
//  YSAll
//
//  Created by jiang deng on 2020/2/6.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSTableViewVC.h"

NS_ASSUME_NONNULL_BEGIN

@class YSClassModel;

@interface YSClassDetailVC : YSTableViewVC

@property (nullable, nonatomic, strong) YSClassModel *linkClassModel;

@end

NS_ASSUME_NONNULL_END

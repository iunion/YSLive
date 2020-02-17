//
//  YSUpHandPopCell.h
//  YSLive
//
//  Created by 迁徙鸟 on 2020/2/17.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSUpHandPopCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property(nonatomic,strong)NSDictionary *dataDict;

@end

NS_ASSUME_NONNULL_END

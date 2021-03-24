//
//  YSSetTableViewCell.h
//  YSAll
//
//  Created by 马迪 on 2020/6/1.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSSetTableViewCell : UITableViewCell

@property(nonatomic,copy) NSString *titleText;

/**
 *  快速创建tableViewCell
 *
 *  @param tableView tableView description
 *
 *  @return <#return value description#>
 */
+ (instancetype)setTableViewCellWithTableView:(UITableView *)tableView;
@end

NS_ASSUME_NONNULL_END

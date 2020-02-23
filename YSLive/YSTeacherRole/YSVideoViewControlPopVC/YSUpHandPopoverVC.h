//
//  YSUpHandPopoverVC.h
//  YSLive
//
//  Created by 迁徙鸟 on 2020/2/17.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSUpHandPopCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSUpHandPopoverVC : UIViewController

@property(nonatomic,strong)NSMutableArray * userArr;

@property(nonatomic,weak)UITableView * tabView;

@property(nonatomic,copy)void(^letStudentUpVideo)(YSUpHandPopCell *cell);

@end

NS_ASSUME_NONNULL_END

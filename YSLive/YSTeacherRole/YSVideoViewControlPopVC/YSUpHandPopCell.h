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

//@property(nonatomic,strong)YSRoomUser *userModel;
@property(nonatomic,strong)NSMutableDictionary * userDict;

///头像按钮
@property (nonatomic, strong) UIButton * headBtn;

@property(nonatomic,copy)void(^headButtonClick)(void);

@end

NS_ASSUME_NONNULL_END

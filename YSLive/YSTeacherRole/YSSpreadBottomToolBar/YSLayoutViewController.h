//
//  YSLayoutViewController.h
//  YSAll
//
//  Created by 马迪 on 2020/12/2.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSLayoutViewController : UIViewController

///综合布局
@property(nonatomic,strong) BMImageTitleButtonView * aroundLayoutBtn;
///平铺布局
@property(nonatomic,strong) BMImageTitleButtonView * videoLayoutBtn;
///双师布局
@property(nonatomic,strong) BMImageTitleButtonView * doubleLayoutBtn;


@end

NS_ASSUME_NONNULL_END

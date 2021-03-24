//
//  YS222ViewController.h
//  YSAll
//
//  Created by 马迪 on 2020/12/2.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//typedef void(^popViewCellClick)(NSIndexPath *index);

@protocol YSLayoutViewControllerDelegate <NSObject>

- (void)layoutCellClick:(NSInteger)rowNum;

@end


@interface YSLayoutViewController : UIViewController

//数据源数组
@property(nonatomic,strong)NSArray *menusArr;
//@property(nonatomic,copy)popViewCellClick popViewCellClick;
@property(nonatomic,weak) id<YSLayoutViewControllerDelegate> delegate;


@end

NS_ASSUME_NONNULL_END

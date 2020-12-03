//
//  YSDefaultLayoutPopView.h
//  YSAll
//
//  Created by 马迪 on 2020/12/2.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YSDefaultLayoutPopViewDelegate <NSObject>

- (void)layoutCellClick:(NSInteger)rowNum;

@end


@interface YSDefaultLayoutPopView : UIViewController


//数据源数组
@property(nonatomic,strong)NSArray *menusArr;
@property(nonatomic,weak) id<YSDefaultLayoutPopViewDelegate> delegate;

@property(nonatomic,assign) CHRoomLayoutType roomLayout;

@end

NS_ASSUME_NONNULL_END

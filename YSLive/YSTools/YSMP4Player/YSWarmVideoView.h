//
//  YSWarmVideoView.h
//  YSAll
//
//  Created by 马迪 on 2020/12/11.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface YSWarmVideoView : UIView

@property (nonatomic, copy) NSString *warmUrl;

/** 全屏按钮 */
@property (nonatomic, strong) UIButton *fullBtn;

@property (nonatomic, copy) void(^warmViewFullBtnClick)(UIButton *sender);


@end

NS_ASSUME_NONNULL_END

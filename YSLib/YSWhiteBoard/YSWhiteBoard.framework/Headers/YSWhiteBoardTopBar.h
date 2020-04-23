//
//  YSWhiteBoardTopBar.h
//  YSWhiteBoard
//
//  Created by 马迪 on 2020/4/9.
//  Copyright © 2020 jiang deng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YSWhiteBoardView;

NS_ASSUME_NONNULL_BEGIN

@protocol YSWhiteBoardTopBarDelegate <NSObject>

///拖拽手势事件
- (void)panToMoveWhiteBoardView:(UIView *)whiteBoard withGestureRecognizer:(UIPanGestureRecognizer *)pan;

- (void)clickToBringVideoToFont:(UIView *)whiteBoard;

@end


@interface YSWhiteBoardTopBar : UIView

@property (nonatomic, weak) id<YSWhiteBoardTopBarDelegate>  delegate;

///按钮点击事件
@property(nonatomic,copy) void(^barButtonsClick)(UIButton *sender);

/// 课件 title
@property (nonatomic, copy) NSString  *titleString;

/// 自身对应的YSWhiteBoardView
//@property (nonatomic, weak) YSWhiteBoardView  *whiteBoardView;

@end

NS_ASSUME_NONNULL_END

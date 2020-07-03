//
//  YSFloatView.h
//  YSLive
//
//  Created by jiang deng on 2019/11/12.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^YSFloatViewClickBlock)(void);

@interface YSFloatView : UIView

@property (nonatomic, strong, readonly) UIScrollView *backScrollView;

@property (nonatomic, weak, readonly) UIView *contentView;

@property (nonatomic, assign) BOOL canGestureRecognizer;

@property (nonatomic, assign) BOOL canZoom;

@property (nonatomic, assign) BOOL showWaiting;
///是否全屏课件
@property (nonatomic, assign) BOOL isFullBackgrond;

// 父视图中可移动范围缩进边距 默认为 0 0 0 0 (气泡默认可活动范围为父视图大小)
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

////刚拖出来的默认值
//@property (nonatomic, assign) CGSize defaultSize;
//可以放大到的最小尺寸
@property (nonatomic, assign) CGSize minSize;
//可以放大到的最大尺寸
@property (nonatomic, assign) CGSize maxSize;

@property (nonatomic, copy) NSString *peerId;

///默认刚拖出来的比例为2
@property (nonatomic , assign) CGFloat endScale;

// 点击Block
@property (nullable, nonatomic, copy) YSFloatViewClickBlock clickBlock;

// 加载内容
- (void)showWithContentView:(UIView *)contentView;
// 坐标调整
- (void)stayMove;

- (void)cleanContent;

@end

NS_ASSUME_NONNULL_END

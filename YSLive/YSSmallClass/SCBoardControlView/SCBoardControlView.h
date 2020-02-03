//
//  SCBoardControlView.h
//  YSLive
//
//  Created by fzxm on 2019/11/11.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SCBoardControlViewDelegate <NSObject>
/// 全屏 复原 回调
/// @param isAllScreen 是否全屏
- (void)boardControlProxyfullScreen:(BOOL)isAllScreen;
/// 上一页
- (void)boardControlProxyPrePage;
/// 下一页
- (void)boardControlProxyNextPage;
/// 放大
- (void)boardControlProxyEnlarge;
/// 缩小
- (void)boardControlProxyNarrow;

@end


@interface SCBoardControlView : UIView

@property (nonatomic, weak) id <SCBoardControlViewDelegate> delegate;

/// 全屏
@property (nonatomic, assign) BOOL isAllScreen;
/// 是否可以缩放
@property (nonatomic, assign) BOOL allowScaling;
/// 是否可以翻页  (未开课前通过权限判断是否可以翻页  上课后永久不可以翻页)
@property (nonatomic, assign) BOOL allowPaging;

/// 缩放比例
@property (nonatomic, assign, readonly) CGFloat zoomScale;


/// 初始化 当前页以及总页数
/// @param total 总页数
/// @param currentPage 当前页
- (void)sc_setTotalPage:(NSInteger)total currentPage:(NSInteger)currentPage isWhiteBoard:(BOOL)isWhiteBoard;
- (void)sc_setTotalPage:(NSInteger)total currentPage:(NSInteger)currentPage canPrevPage:(BOOL)canPrevPage canNextPage:(BOOL)canNextPage isWhiteBoard:(BOOL)isWhiteBoard;

/// 重置缩放按钮
- (void)resetBtnStates;

- (void)changeZoomScale:(CGFloat)zoomScale;

@end

NS_ASSUME_NONNULL_END

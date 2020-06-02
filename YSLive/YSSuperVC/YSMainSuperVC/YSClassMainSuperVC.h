//
//  YSClassMainSuperVC.h
//  YSLive
//
//  Created by jiang deng on 2020/3/6.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSMainSuperVC.h"
#import "SCVideoView.h"
#import "YSSpreadBottomToolBar.h"

/// 顶部状态栏高度
#define STATETOOLBAR_HEIGHT           ([UIDevice bm_isiPad] ? 18 : 12)

typedef NS_ENUM(NSUInteger, SCMain_ArrangeContentBackgroudViewType)
{
    SCMain_ArrangeContentBackgroudViewType_ShareVideoFloatView,
    SCMain_ArrangeContentBackgroudViewType_VideoGridView,
    SCMain_ArrangeContentBackgroudViewType_DragOutFloatViews
};

// 上传图片的用途
typedef NS_ENUM(NSInteger, SCUploadImageUseType)
{
    /// 作为课件
    SCUploadImageUseType_Document = 0,
    /// 聊天用图
    SCUploadImageUseType_Message  = 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface YSClassMainSuperVC : YSMainSuperVC
<
    YSSpreadBottomToolBarDelegate
>

/// 所有内容的背景
@property (nonatomic, strong) UIView *contentBackgroud;

/// 所有内容的背景contentBackgroud的尺寸
@property(nonatomic, assign, readonly) CGFloat contentWidth;
@property(nonatomic, assign, readonly) CGFloat contentHeight;

/// 视频View列表
@property (nonatomic, strong) NSMutableArray <SCVideoView *> *videoViewArray;

/// 房间号
@property(nonatomic, copy) NSString *roomID;
/// 上课时间
@property(nonatomic, copy) NSString *lessonTime;

/// 底部工具栏
@property (nonatomic, strong, readonly) YSSpreadBottomToolBar *spreadBottomToolBar;

- (void)keyboardWillShow:(NSNotification*)notification;
- (void)keyboardWillHide:(NSNotification *)notification;

// 横排视频最大宽度计算
- (CGFloat)getVideoTotalWidth;

- (NSUInteger)getVideoViewCount;

@end

NS_ASSUME_NONNULL_END

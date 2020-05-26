//
//  YSClassMainSuperVC.h
//  YSLive
//
//  Created by jiang deng on 2020/3/6.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSMainSuperVC.h"


#define YSUI_contentWidth self.contentWidth
#define YSUI_contentHeight self.contentHeight

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

/// 所有内容的背景
@property (nonatomic, strong) UIView *contentBackgroud;

/// 所有内容的背景contentBackgroud的尺寸
@property(nonatomic, assign, readonly) CGFloat contentWidth;
@property(nonatomic, assign, readonly) CGFloat contentHeight;


- (void)keyboardWillShow:(NSNotification*)notification;
- (void)keyboardWillHide:(NSNotification *)notification;


@end

NS_ASSUME_NONNULL_END

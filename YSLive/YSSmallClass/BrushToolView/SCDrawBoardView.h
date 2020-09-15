//
//  SCDrawBoardView.h
//  YSLive
//
//  Created by fzxm on 2019/11/7.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YSSelectorShowType)
{
    YSSelectorShowType_All,         //包含类型选择，颜色选择，大小选择
    YSSelectorShowType_ColorSize,       //包含颜色选择，大小选择
    YSSelectorShowType_Size,          //只有大小选择
    YSSelectorShowType_Color,      //只有颜色选择(文字的特殊配置项)
};

@protocol SCDrawBoardViewDelegate <NSObject>

/// 形状 颜色 大小 回调
/// @param drawType 画笔 形状类型
/// @param hexColor 颜色
/// @param progress 大小
- (void)brushSelectorViewDidSelectDrawType:(CHDrawType)drawType
                                     color:(NSString *)hexColor
                             widthProgress:(float)progress;

@end

@interface SCDrawBoardView : UIView

@property (nonatomic, weak) id<SCDrawBoardViewDelegate> delegate;

/// 工具类型 必传  为了判断哪种功能界面
@property(nonatomic, assign) CHBrushToolType brushToolType;
/// 画笔类型  边框类型 （记录上次选中的类型）
@property (nonatomic, assign) CHDrawType drawType;
@property (nonatomic, strong) UIView *backgroundView;
//小三角
//@property (nonatomic, strong) UIImageView *triangleImgView;

- (void)changeSelectColor:(NSString *)selectColor;

@end

NS_ASSUME_NONNULL_END

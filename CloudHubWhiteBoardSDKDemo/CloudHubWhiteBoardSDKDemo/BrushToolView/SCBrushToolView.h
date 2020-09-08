//
//  SCBrushToolView.h
//  YSLive
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SCBrushToolViewDelegate <NSObject>

/// 工具类型回调
/// @param toolViewBtnType 工具类型
- (void)brushToolViewType:(CHBrushToolType)toolViewBtnType withToolBtn:(nonnull UIButton *)toolBtn;


@optional

- (void)brushToolDoClean;

@end


@interface SCBrushToolView : UIView

@property (nonatomic, weak)id <SCBrushToolViewDelegate>delegate;

@property (nonatomic, strong, readonly) UIButton *mouseBtn;

- (instancetype)initWithTeacher:(BOOL)isTeacher;

- (void)resetTool;

@end

NS_ASSUME_NONNULL_END

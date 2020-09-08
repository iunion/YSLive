//
//  SCColorListView.h
//  YSLive
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCColorListView : UIView
@property (nonatomic, copy) void(^BeganBlock)(CGPoint point);
@end

NS_ASSUME_NONNULL_END

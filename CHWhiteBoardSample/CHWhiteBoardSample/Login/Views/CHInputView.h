//
//  CHInputView.h
//  CHEdu
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CHInputViewDelegate;

@interface CHInputView : UIView

@property (nonatomic, weak) id <CHInputViewDelegate> delegate;

@property (nonatomic, strong) UITextField * inputTextField;

- (instancetype)initWithFrame:(CGRect)frame withPlaceholder:(NSString *)placeholder withImageName:(NSString *)imageName;

@end

@protocol CHInputViewDelegate <NSObject>

- (void)inpuTextFieldDidChanged:(UITextField *)textField;

@optional


@end

NS_ASSUME_NONNULL_END

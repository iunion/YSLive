//
//  BMAlertView+YSDefaultAlert.h
//  YSLive
//
//  Created by fzxm on 2019/10/23.
//  Copyright © 2019 FS. All rights reserved.
//

#import <BMKit/BMAlertView.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMAlertView (YSDefaultAlert)

+ (void)ys_showAlertWithTitle:(nullable id)title
                      message:(nullable id)message
                  cancelTitle:(nullable NSString *)cancelTitle
                   completion:(nullable BMAlertViewCompletionBlock)completion;

+ (void)ys_showAlertWithTitle:(nullable id)title
                      message:(nullable id)message
                  cancelTitle:(nullable NSString *)cancelTitle
              orientationMask:(UIInterfaceOrientationMask)orientationMask
                   completion:(nullable BMAlertViewCompletionBlock)completion;


+ (void)ys_showAlertWithTitle:(nullable id)title
                      message:(nullable id)message
                  cancelTitle:(nullable NSString *)cancelTitle
                   otherTitle:(nullable NSString *)otherTitle
                   completion:(nullable BMAlertViewCompletionBlock)completion;

+ (void)ys_showAlertWithTitle:(nullable id)title
                      message:(nullable id)message
                  cancelTitle:(nullable NSString *)cancelTitle
                   otherTitle:(nullable NSString *)otherTitle
              orientationMask:(UIInterfaceOrientationMask)orientationMask
                   completion:(nullable BMAlertViewCompletionBlock)completion;

+ (BMAlertView *)creatAlertWithIcon:(nullable NSString *)iconName
                              title:(nullable id)title
                            message:(nullable id)message
                        contentView:(nullable UIView *)contentView
                        cancelTitle:(nullable NSString *)cancelTitle
                        otherTitles:(nullable NSArray<NSString *> *)otherTitles
                 buttonsShouldStack:(BOOL)shouldStack
                         completion:(nullable BMAlertViewCompletionBlock)completion;


@end

NS_ASSUME_NONNULL_END

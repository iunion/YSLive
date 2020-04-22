//
//  BMAlertView+YSDefaultAlert.m
//  YSLive
//
//  Created by fzxm on 2019/10/23.
//  Copyright © 2019 FS. All rights reserved.
//

#import "BMAlertView+YSDefaultAlert.h"

@implementation BMAlertView (YSDefaultAlert)



+ (BMAlertView *)creatAlertWithIcon:(NSString *)iconName
                              title:(id)title
                            message:(id)message
                        contentView:(UIView *)contentView
                        cancelTitle:(NSString *)cancelTitle
                        otherTitles:(NSArray<NSString *> *)otherTitles
                 buttonsShouldStack:(BOOL)shouldStack
                         completion:(BMAlertViewCompletionBlock)completion
{
    BMAlertView *alert = [[BMAlertView alloc] initWithIcon:iconName title:title message:message contentView:contentView cancelTitle:cancelTitle otherTitles:otherTitles buttonsShouldStack:shouldStack completion:completion];
    alert.alertBgColor       = [UIColor whiteColor];
    alert.alertMaskBgColor   = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
    alert.alertMaskBgEffect  = nil;
    alert.alertTitleFont     = [UIFont systemFontOfSize:18.f];
    alert.alertTitleColor    = [UIColor bm_colorWithHex:0x282828];
    alert.alertMessageFont   = [UIFont systemFontOfSize:14.f];
    alert.alertMessageColor  = [UIColor bm_colorWithHex:0x333333];
    alert.cancleBtnBgColor   = [UIColor whiteColor];
    alert.otherBtnBgColor    = [UIColor whiteColor];
    alert.cancleBtnTextColor = [UIColor bm_colorWithHex:0x999999];
    alert.otherBtnTextColor  = [UIColor bm_colorWithHex:0x577EEE];
    alert.btnFont            = [UIFont systemFontOfSize:16.f];
    alert.alertGapLineColor  = [UIColor bm_colorWithHex:0xD8D8D8];
    alert.showAnimationType  = BMAlertViewShowAnimationNone;
    alert.hideAnimationType  = BMAlertViewHideAnimationNone;
    alert.shouldDismissOnTapOutside = YES;
    alert.showClose = YES;
    
    return alert;
}

+ (void)ys_showAlertWithTitle:(id)title
                      message:(id)message
                  cancelTitle:(NSString *)cancelTitle completion:(BMAlertViewCompletionBlock)completion
{
    
    BMAlertView * alert = [BMAlertView creatAlertWithIcon:nil title:title message:message contentView:nil cancelTitle:cancelTitle otherTitles:nil buttonsShouldStack:NO completion:completion];
    alert.cancleBtnTextColor = [UIColor bm_colorWithHex:0x577EEE];
    [alert showAlertView];
}

+ (void)ys_showAlertWithTitle:(id)title message:(id)message cancelTitle:(NSString *)cancelTitle otherTitle:(NSString *)otherTitle completion:(BMAlertViewCompletionBlock)completion
{
    BMAlertView * alert;
    if ([otherTitle bm_isNotEmpty])
    {
        alert = [BMAlertView creatAlertWithIcon:nil title:title message:message contentView:nil cancelTitle:cancelTitle otherTitles:@[otherTitle] buttonsShouldStack:NO completion:completion];
    }
    else
    {
        alert = [BMAlertView creatAlertWithIcon:nil title:title message:message contentView:nil cancelTitle:cancelTitle otherTitles:nil buttonsShouldStack:NO completion:completion];
    }
    
    [alert showAlertView];
}
@end

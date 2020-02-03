//
//  YSPassWordAlert.h
//  YSLive
//
//  Created by fzxm on 2019/10/23.
//  Copyright © 2019 FS. All rights reserved.
//

#import <BMKit/BMNoticeView.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^NoticeViewSureBtnClicked)(NSString * passWord);

@interface YSPassWordAlert : BMNoticeView

+ (void)showPassWordInputAlerWithTopDistance:(CGFloat)topDistance inView:(UIView *)inView backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets sureBlock:(NoticeViewSureBtnClicked)clicked dismissBlock:(nullable BMNoticeViewDismissBlock)dismissBlock;

@end

NS_ASSUME_NONNULL_END

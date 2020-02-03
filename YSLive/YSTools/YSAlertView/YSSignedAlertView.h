//
//  YSSignedAlertView.h
//  YSLive
//
//  Created by fzxm on 2019/10/22.
//  Copyright © 2019 FS. All rights reserved.
//

#import <BMKit/BMNoticeView.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SignedAlertViewSigned)(void);

@interface YSSignedAlertView : BMNoticeView

+ (YSSignedAlertView *)showWithTime:(NSTimeInterval)timeInterval inView:(UIView *)inView backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets topDistance:(CGFloat)topDistance signedBlock:(nullable SignedAlertViewSigned)signedBlock;

@end

NS_ASSUME_NONNULL_END

//
//  CHMainViewController.h
//  CHLiveSample
//
//  Created by 马迪 on 2020/9/1.
//  Copyright © 2020 yunshuxunlian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudHubManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface CHMainViewController : UIViewController
<
    CloudHubManagerDelegate
>

//- (instancetype)initWithRoomType:(YSRoomUserType)roomType isWideScreen:(BOOL)isWideScreen maxVideoCount:(NSUInteger)maxCount whiteBordView:(UIView *)whiteBordView userId:(nullable NSString *)userId;
- (instancetype)initWithwhiteBordView:(UIView *)whiteBordView userId:(nullable NSString *)userId;

@end

NS_ASSUME_NONNULL_END

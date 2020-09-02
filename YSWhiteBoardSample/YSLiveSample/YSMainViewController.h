//
//  YSMainViewController.h
//  YSLiveSample
//
//  Created by 马迪 on 2020/9/1.
//  Copyright © 2020 yunshuxunlian. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSMainViewController : UIViewController

//- (instancetype)initWithRoomType:(YSRoomUserType)roomType isWideScreen:(BOOL)isWideScreen maxVideoCount:(NSUInteger)maxCount whiteBordView:(UIView *)whiteBordView userId:(nullable NSString *)userId;
- (instancetype)initWithwhiteBordView:(UIView *)whiteBordView userId:(nullable NSString *)userId;

@end

NS_ASSUME_NONNULL_END

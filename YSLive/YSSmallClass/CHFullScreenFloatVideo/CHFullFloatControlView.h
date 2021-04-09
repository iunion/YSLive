//
//  CHFullFloatControlView.h
//  YSAll
//
//  Created by 马迪 on 2021/4/7.
//  Copyright © 2021 CH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CHFullFloatControlView : UIView

@property (nonatomic,copy)void(^fullFloatControlButtonClick)(FullFloatControl fullFloatControl);

@end

NS_ASSUME_NONNULL_END

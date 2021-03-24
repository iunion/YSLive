//
//  CHLiveControl.h
//  YSAll
//
//  Created by 马迪 on 2021/3/22.
//  Copyright © 2021 CH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CHLiveControlView : UIControl

/// 控制自己音视频的按钮的背景View
@property(nonatomic,strong,readonly) UIView * controlBackView;

/// 刷新视频控制按钮状态
- (void)updataVideoPopViewStateWithSourceId:(NSString *)sourceId;

@end

NS_ASSUME_NONNULL_END

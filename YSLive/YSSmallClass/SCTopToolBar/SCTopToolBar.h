//
//  SCTopToolBar.h
//  YSLive
//
//  Created by fzxm on 2019/11/9.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCTopToolBarModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol SCTopToolBarDelegate <NSObject>

/// 麦克风
- (void)microphoneProxyWithBtn:(UIButton *)btn;
/// 照片
- (void)photoProxyWithBtn:(UIButton *)btn;
/// 摄像头
- (void)cameraProxyWithBtn:(UIButton *)btn;
/// 退出
- (void)exitProxyWithBtn:(UIButton *)btn;

@end

@interface SCTopToolBar : UIView

@property (nonatomic, weak) id<SCTopToolBarDelegate> delegate;

@property (nonatomic, strong) SCTopToolBarModel *topToolModel;

@property (nonatomic, strong, readonly) UIButton *microphoneBtn;
@property (nonatomic, strong, readonly) UIButton *photoBtn;
@property (nonatomic, strong, readonly) UIButton *cameraBtn;


- (void)hideMicrophoneBtn:(BOOL)hide;
- (void)hidePhotoBtn:(BOOL)hide;
- (void)hideCameraBtn:(BOOL)hide;

- (void)selectMicrophoneBtn:(BOOL)select;
//- (void)selectCameraBtn:(BOOL)select;

@end

NS_ASSUME_NONNULL_END

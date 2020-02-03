//
//  SCTTopPopverViewController.h
//  YSLive
//
//  Created by fzxm on 2019/12/26.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SCTTopPopverViewControllerDelegate <NSObject>

- (void)toolboxBtnsClick:(UIButton*)sender;

- (void)allControlBtnsClick:(UIButton*)sender;

@end
@interface SCTTopPopverViewController : UIViewController

@property(nonatomic,weak) id<SCTTopPopverViewControllerDelegate> delegate;


- (void)freshUIWithType:(SCTeacherTopBarType)type isMeeting:(BOOL)isMeeting;

@end

NS_ASSUME_NONNULL_END

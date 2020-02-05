//
//  YSSetTableViewVC.h
//  YSAll
//
//  Created by jiang deng on 2020/2/5.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSTableViewVC.h"
#import <BMKit/BMTableViewManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSSetTableViewVC : YSTableViewVC
<
   BMTableViewManagerDelegate
>

@property (nonatomic, strong, readonly) BMTableViewManager *tableManager;

- (BMFreshViewType)getFreshViewType;

// 支持键盘相应
- (BOOL)needKeyboardEvent;

- (void)interfaceSettings;
- (void)freshViews;

// 手机号
- (BOOL)verifyPhoneNum:(NSString *)phoneNum;
- (BOOL)verifyPhoneNum:(NSString *)phoneNum showMessage:(BOOL)showMessage;
// 密码
- (BOOL)verifyPassword:(NSString *)password;
- (BOOL)verifyPassword:(NSString *)password showMessage:(BOOL)showMessage;

// 身份证号
- (BOOL)verifyId:(NSString *)idNum;
- (BOOL)verifyId:(NSString *)idNum showMessage:(BOOL)showMessage;

@end

NS_ASSUME_NONNULL_END

//
//  YSSuperNetVC.h
//  YSLive
//
//  Created by jiang deng on 2019/10/12.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSSuperVC.h"
#import "YSApiRequest.h"
#import "BMProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface YSSuperNetVC : YSSuperVC
<
    YSSuperNetVCProtocol
>

// 网络等待
@property (nonatomic, strong) BMProgressHUD *m_ProgressHUD;

// 显示等待开关
@property (nonatomic, assign) BOOL m_ShowProgressHUD;
// 显示结果消息提示开关
@property (nonatomic, assign) BOOL m_ShowResultHUD;

// 网络请求成功后,data是否可以为空, 默认不为空(NO)
@property (nonatomic, assign) BOOL m_AllowEmptyJson;

@end

NS_ASSUME_NONNULL_END

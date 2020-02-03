//
//  YSEmotionView.h
//  YSLive
//
//  Created by 马迪 on 2019/10/16.
//  Copyright © 2019 FS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSEmotionView : UIView

///把表情添加到输入框
@property(nonatomic,copy)void(^addEmotionToTextView)(NSString *emotionName);
///删除输入框中的表情
@property(nonatomic,copy)void(^deleteEmotionBtnClick)(void);

@end

NS_ASSUME_NONNULL_END

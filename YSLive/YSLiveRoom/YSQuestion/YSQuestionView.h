//
//  YSQuestionView.h
//  YSLive
//
//  Created by 马迪 on 2019/10/21.
//  Copyright © 2019 FS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSQuestionView : UIView

///提问列表数组
@property (nonatomic, strong) NSMutableArray *questionArr;

///不允许课前互动的蒙版
@property (nonatomic, strong) UIView *maskView;



- (void)frashView:(nullable id)message;

@end

NS_ASSUME_NONNULL_END

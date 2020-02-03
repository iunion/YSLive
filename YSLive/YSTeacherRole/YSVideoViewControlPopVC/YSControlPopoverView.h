//
//  YSControlPopoverView.h
//  YSLive
//
//  Created by 马迪 on 2019/12/24.
//  Copyright © 2019 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YSControlPopoverViewDelegate <NSObject>

- (void)teacherControlBtnsClick:(UIButton*)sender;

- (void)studentControlBtnsClick:(UIButton*)sender;

@end


@interface YSControlPopoverView : UIViewController

///app使用场景  3：小班课  4：直播   5：会议
@property (nonatomic, assign) YSAppUseTheType appUseTheType;

@property(nonatomic,weak) id<YSControlPopoverViewDelegate> delegate;

@property(nonatomic,copy)void(^controlPopoverbuttonClick)(NSInteger index);

///音频控制按钮
@property(nonatomic,strong) UIButton * audioBtn;
///视频控制按钮
@property(nonatomic,strong) UIButton * videoBtn;
///画笔权限控制按钮
@property(nonatomic,strong) UIButton * canDrawBtn;
///上下台控制按钮
@property(nonatomic,strong) UIButton * onStageBtn;

/// 是否被拖出
@property (nonatomic, assign) BOOL isDragOut;

@property(nonatomic,strong) YSRoomUser * userModel;
/// 房间类型 0:表示一对一教室  非0:表示一多教室
@property (nonatomic, assign) YSRoomTypes roomtype;



@end

NS_ASSUME_NONNULL_END

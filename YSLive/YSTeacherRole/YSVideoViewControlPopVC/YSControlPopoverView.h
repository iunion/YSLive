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
//成为焦点按钮
@property(nonatomic,strong) UIButton * fouceBtn;

/// 是否被拖出
@property (nonatomic, assign) BOOL isDragOut;

///成为焦点的用户的peerID(必须在userModel前赋值)
@property (nullable,nonatomic, copy) NSString * foucePeerId;

@property(nonatomic,strong) YSRoomUser * userModel;
/// 房间类型 0:表示一对一教室  非0:表示一多教室
@property (nonatomic, assign) YSRoomTypes roomtype;

///标识布局变化的值
@property (nonatomic, assign) YSLiveRoomLayout roomLayout;



@end

NS_ASSUME_NONNULL_END

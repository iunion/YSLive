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

- (void)videoViewControlBtnsClick:(BMImageTitleButtonView*)sender videoViewControlType:(SCVideoViewControlType)videoViewControlType withStreamId:(NSString *)streamId;
@end


@interface YSControlPopoverView : UIViewController

///app使用场景  3：小班课  4：直播   5：会议
@property (nonatomic, assign) YSRoomUseType appUseTheType;

@property(nonatomic,weak) id<YSControlPopoverViewDelegate> delegate;

@property(nonatomic,copy)void(^controlPopoverbuttonClick)(NSInteger index);

///音频控制按钮
@property(nonatomic,strong) BMImageTitleButtonView * audioBtn;
///视频控制按钮
@property(nonatomic,strong) BMImageTitleButtonView * videoBtn;
///镜像控制按钮
@property(nonatomic,strong) BMImageTitleButtonView * mirrorBtn;
///画笔权限控制按钮
@property(nonatomic,strong) BMImageTitleButtonView * canDrawBtn;
///上下台控制按钮
@property(nonatomic,strong) BMImageTitleButtonView * onStageBtn;
//成为焦点按钮
@property(nonatomic,strong) BMImageTitleButtonView * fouceBtn;

/// 是否被拖出
@property (nonatomic, assign) BOOL isDragOut;
/// 是否全体静音
@property (nonatomic, assign) BOOL isAllNoAudio;
/// 是否是画中画的非老师视频
@property (nonatomic, assign) BOOL isNested;
///成为焦点的用户的peerID(必须在userModel前赋值)
@property (nullable,nonatomic, copy) NSString * foucePeerId;
@property (nullable,nonatomic, copy) NSString *fouceStreamId;

@property(nonatomic,strong) YSRoomUser * userModel;

/// 房间类型
@property (nonatomic, assign) YSRoomUserType roomtype;

///标识布局变化的值
@property (nonatomic, assign) YSRoomLayoutType roomLayout;

/// 当前的用户视频的镜像状态
@property(nonatomic, assign) CloudHubVideoMirrorMode videoMirrorMode;

/// 当前视频窗口的sourceId
@property(nonatomic, copy) NSString *sourceId;

/// 当前视频窗口的streamId
@property(nonatomic, copy) NSString *streamId;

@end

NS_ASSUME_NONNULL_END

//
//  CHPermissionsView.h
//  YSLive
//
//  Created by jiang deng on 2021/3/29.
//  Copyright © 2021 CH. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CHPermissionsViewChangeType)
{
    /// 切换摄像头
    CHPermissionsViewChange_Cam ,
    /// 水平镜像
    CHPermissionsViewChange_HMirror,
    /// 垂直镜像
    CHPermissionsViewChange_VMirror,
    /// 播放声音
    CHPermissionsViewChange_Play,
    /// 停止声音
    CHPermissionsViewChange_Pause,
    /// 美颜设置
    CHPermissionsViewChange_BeautySet
};


NS_ASSUME_NONNULL_BEGIN

@protocol CHPermissionsViewDelegate;
@interface CHPermissionsView : UIView

@property (nonatomic, weak) id <CHPermissionsViewDelegate> delegate;

- (void)changeVolumLevel:(CGFloat)volumLevel;

@end

@protocol CHPermissionsViewDelegate <NSObject>

- (void)onPermissionsViewChanged:(CHPermissionsViewChangeType)changeType;

@end

NS_ASSUME_NONNULL_END

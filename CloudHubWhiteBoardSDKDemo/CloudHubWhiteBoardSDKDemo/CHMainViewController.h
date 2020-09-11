//
//  CHMainViewController.h
//  CHLiveSample
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CHMainViewController : UIViewController
<
    CloudHubRtcEngineDelegate,
    CHWhiteBoardManagerDelegate
>

/// 音视频SDK干管理
@property (nonatomic, weak) CloudHubRtcEngineKit *cloudHubRtcEngineKit;

//- (instancetype)initWithRoomType:(YSRoomUserType)roomType isWideScreen:(BOOL)isWideScreen maxVideoCount:(NSUInteger)maxCount whiteBordView:(UIView *)whiteBordView userId:(nullable NSString *)userId;
- (instancetype)initWithwhiteBordView:(UIView *)whiteBordView userId:(nullable NSString *)userId;

@end

NS_ASSUME_NONNULL_END

//
//  YSMp3Controlview.h
//  YSAll
//
//  Created by fzxm on 2020/1/8.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YSMp3ControlviewDelegate <NSObject>

- (void)playMp3ControlViewPlay:(BOOL)isPause withFileModel:(YSSharedMediaFileModel *)mediaFileModel;

- (void)sliderMp3ControlViewPos:(NSTimeInterval)value withFileModel:(YSSharedMediaFileModel *)mediaFileModel;
- (void)closeMp3ControlViewWithFileModel:(YSSharedMediaFileModel *)mediaFileModel;

@end

@interface YSMp3Controlview : UIView

@property(nonatomic,weak) id<YSMp3ControlviewDelegate> delegate;

/// 媒体数据
@property (nonatomic, strong) YSSharedMediaFileModel *mediaFileModel;

@property (nonatomic, strong) UIButton *playBtn;

@property (nonatomic, assign) BOOL isPlay;

- (void)setMediaStream:(NSTimeInterval)duration
                   pos:(NSTimeInterval)pos
                isPlay:(BOOL)isPlay
              fileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END

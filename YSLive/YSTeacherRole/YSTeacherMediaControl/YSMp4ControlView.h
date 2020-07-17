//
//  YSMp4ControlView.h
//  YSAll
//
//  Created by fzxm on 2020/1/7.
//  Copyright © 2020 YS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YSMp4ControlViewDelegate <NSObject>

- (void)playYSMp4ControlViewPlay:(BOOL)isPause withFileModel:(YSSharedMediaFileModel *)mediaFileModel;

- (void)sliderYSMp4ControlViewPos:(NSTimeInterval)value withFileModel:(YSSharedMediaFileModel *)mediaFileModel;

@end


@interface YSMp4ControlView : UIView

@property(nonatomic,weak) id<YSMp4ControlViewDelegate> delegate;

/// 媒体数据
@property (nonatomic, strong) YSSharedMediaFileModel *mediaFileModel;

@property (nonatomic, assign) BOOL isPlay;

- (void)setMediaStream:(NSTimeInterval)duration
                   pos:(NSTimeInterval)pos
                isPlay:(BOOL)isPlay
              fileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END

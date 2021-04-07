//
//  CHFullFloatVideoView.m
//  YSAll
//
//  Created by 马迪 on 2021/4/7.
//  Copyright © 2021 CH. All rights reserved.
//

#import "CHFullFloatVideoView.h"
#import "CHFullFloatControlView.h"


@interface CHFullFloatVideoView ()

@property (nonatomic, weak) UIView *rightVideoBgView;

@end

@implementation CHFullFloatVideoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = UIColor.clearColor;
        [self setupUIView];
 
    }
    return self;
}

#pragma mark -
- (void)setupUIView
{
    CGFloat controlViewW = 30;
    
    CHFullFloatControlView *controlView = [[CHFullFloatControlView alloc]initWithFrame:CGRectMake(self.bm_width - controlViewW, 45, controlViewW, 180)];
    [self addSubview:controlView];
    
    UIView *rightVideoBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
    rightVideoBgView.backgroundColor = UIColor.clearColor;
    [self addSubview:rightVideoBgView];
    self.rightVideoBgView = rightVideoBgView;
}

- (void)freshViewWithVideoViewArray:(NSMutableArray<SCVideoView *> *)videoSequenceArr withFouceVideo:(SCVideoView *)fouceVideo withRoomLayout:(CHRoomLayoutType)roomLayout withAppUseTheType:(CHRoomUseType)appUseTheType
{
//    self.videoSequenceArr = videoSequenceArr;

    [self.rightVideoBgView bm_removeAllSubviews];

//    if (roomLayout == CHRoomLayoutType_FocusLayout)
//    {
        if (appUseTheType == CHRoomUseTypeSmallClass)
        {
//            self.videosBgView.backgroundColor = YSSkinDefineColor(@"Color2");

            [self changeFrameFocus];

            for (SCVideoView *videoView in self.videoSequenceArr)
            {
                videoView.isDragOut = NO;
                videoView.isFullScreen = NO;
                videoView.isFullMedia = YES;
                [self.videosBgView addSubview:videoView];
                videoView.frame = CGRectMake(0, 0, self.videoWidth, self.videoHeight);
            }

            [self freshViewFocusWithFouceVideo:fouceVideo];
        }
//    }
//    else
//    {
////        self.videosBgView.backgroundColor = [UIColor clearColor];
//        [self changeFrame];
//
//        for (SCVideoView *videoView in self.videoSequenceArr)
//        {
//            videoView.isDragOut = NO;
//            videoView.isFullScreen = NO;
//            videoView.isFullMedia = YES;
//            [self.videosBgView addSubview:videoView];
//            videoView.frame = CGRectMake(0, 0, self.videoWidth, self.videoHeight);
//        }
//
//        [self freshView];
//    }
}


@end

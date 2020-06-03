//
//  SCVideoGridView.m
//  YSLive
//
//  Created by jiang deng on 2019/11/8.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCVideoGridView.h"
#import "SCVideoView.h"

/// 视频间距
static const CGFloat kVideoGridView_Gap_iPhone = 4.0f;
static const CGFloat kVideoGridView_Gap_iPad  = 6.0f;
#define VIDEOGRIDVIEW_WIDTH     (80.0f)
#define VIDEOGRIDVIEW_TOP       (64.0f)
#define VIDEOGRIDVIEW_GAP       ([UIDevice bm_isiPad] ? kVideoGridView_Gap_iPad : kVideoGridView_Gap_iPhone)

@interface SCVideoGridView ()

/// 视频ratio 16:9
@property (nonatomic, assign) BOOL isWideScreen;

@property (nonatomic, strong) NSMutableArray <SCVideoView *> *videoViewArray;

@property (nonatomic, strong) UIView *videosBgView;

//焦点视图左侧每个小视频的宽高
@property (nonatomic, assign) CGFloat videoWidth;
@property (nonatomic, assign) CGFloat videoHeight;

//焦点视图右侧的宽高
@property (nonatomic, assign) CGFloat rightBgWidth;
@property (nonatomic, assign) CGFloat rightBgHeight;

@property (nonatomic, strong) UIView *rightVideoBgView;

@end

@implementation SCVideoGridView


- (instancetype)initWithWideScreen:(BOOL)isWideScreen
{
    self = [super init];
    if (self)
    {
        self.isWideScreen = isWideScreen;
        
        self.videosBgView = [[UIView alloc] init];
        self.videosBgView.backgroundColor = YSSkinDefineColor(@"defaultBgColor");
        
        [self addSubview:self.videosBgView];
        self.rightVideoBgView = [[UIView alloc] init];
        self.rightVideoBgView.backgroundColor = YSSkinDefineColor(@"defaultBgColor");
    }
    return self;
}

- (void)changeFrame
{
    CGFloat maxWidth = self.defaultSize.width-VIDEOGRIDVIEW_GAP*2;
    CGFloat maxHeight = self.defaultSize.height-VIDEOGRIDVIEW_GAP*2;
    
    CGFloat videoWidth = VIDEOGRIDVIEW_WIDTH;
    CGFloat videoHeight;
    if (self.isWideScreen)
    {
        videoHeight = ceil(videoWidth / 16) * 9;
    }
    else
    {
        videoHeight = ceil(videoWidth / 4) * 3;
    }
    
    CGFloat bgWidth = videoWidth;
    CGFloat bgHeight = videoHeight;

    CGFloat width = videoWidth;
    CGFloat height = videoHeight;

    CGFloat scale = 1.0f;
    
    switch (self.videoViewArray.count)
    {
        case 1:
        {
            width = videoWidth;
            height = videoHeight;
            
            CGFloat widthScale = maxWidth/width;
            CGFloat heightScale = maxHeight/height;

            scale = MIN(widthScale, heightScale);
            bgWidth = width*scale;
            bgHeight = height*scale;
        }
            break;

        case 2:
        {
            width = videoWidth*2;
            height = videoHeight;
            
            CGFloat widthScale = (maxWidth-VIDEOGRIDVIEW_GAP)/width;
            CGFloat heightScale = maxHeight/height;

            scale = MIN(widthScale, heightScale);
            bgWidth = width*scale+VIDEOGRIDVIEW_GAP;
            bgHeight = height*scale;
        }
            break;
            
        case 3:
        case 4:
        {
            width = videoWidth*2;
            height = videoHeight*2;
            
            CGFloat widthScale = (maxWidth-VIDEOGRIDVIEW_GAP)/width;
            CGFloat heightScale = (maxHeight-VIDEOGRIDVIEW_GAP)/height;

            scale = MIN(widthScale, heightScale);
            bgWidth = width*scale+VIDEOGRIDVIEW_GAP;
            bgHeight = height*scale+VIDEOGRIDVIEW_GAP;
        }
            break;
            
        case 5:
        case 6:
        {
            width = videoWidth*3;
            height = videoHeight*2;
            
            CGFloat widthScale = (maxWidth-VIDEOGRIDVIEW_GAP*2)/width;
            CGFloat heightScale = (maxHeight-VIDEOGRIDVIEW_GAP)/height;

            scale = MIN(widthScale, heightScale);
            bgWidth = width*scale+VIDEOGRIDVIEW_GAP*2;
            bgHeight = height*scale+VIDEOGRIDVIEW_GAP;
        }
            break;

        case 7:
        case 8:
        {
            width = videoWidth*4;
            height = videoHeight*2;
            
            CGFloat widthScale = (maxWidth-VIDEOGRIDVIEW_GAP*2)/width;
            CGFloat heightScale = (maxHeight-VIDEOGRIDVIEW_GAP*2)/height;

            scale = MIN(widthScale, heightScale);
            bgWidth = width*scale+VIDEOGRIDVIEW_GAP*2;
            bgHeight = height*scale+VIDEOGRIDVIEW_GAP*2;
        }
            break;
        case 9:
        {
            width = videoWidth*3;
            height = videoHeight*3;
            
            CGFloat widthScale = (maxWidth-VIDEOGRIDVIEW_GAP*2)/width;
            CGFloat heightScale = (maxHeight-VIDEOGRIDVIEW_GAP*2)/height;
            
            scale = MIN(widthScale, heightScale);
            bgWidth = width*scale+VIDEOGRIDVIEW_GAP*2;
            bgHeight = height*scale+VIDEOGRIDVIEW_GAP*2;
        }
            break;
        case 10:
        case 11:
        case 12:
        {
            width = videoWidth*4;
            height = videoHeight*3;
            
            CGFloat widthScale = (maxWidth-VIDEOGRIDVIEW_GAP*3)/width;
            CGFloat heightScale = (maxHeight-VIDEOGRIDVIEW_GAP*2)/height;

            scale = MIN(widthScale, heightScale);
            bgWidth = width*scale+VIDEOGRIDVIEW_GAP*3;
            bgHeight = height*scale+VIDEOGRIDVIEW_GAP*2;
        }
            break;

        case 13:
        case 14:
        case 15:
        {
            width = videoWidth*4;
            height = videoHeight*4;
            NSInteger widthGapNum = 3;//横排空隙个数
            NSInteger heightGapNum = 3;//竖排空隙个数
            if (![UIDevice bm_isiPad])
            {
                width = videoWidth*5;
                height = videoHeight*3;
                widthGapNum = 4;
                heightGapNum = 2;
            }
            
            CGFloat widthScale = (maxWidth-VIDEOGRIDVIEW_GAP*widthGapNum)/width;
            CGFloat heightScale = (maxHeight-VIDEOGRIDVIEW_GAP*heightGapNum)/height;

            scale = MIN(widthScale, heightScale);
            bgWidth = width*scale+VIDEOGRIDVIEW_GAP*widthGapNum;
            bgHeight = height*scale+VIDEOGRIDVIEW_GAP*heightGapNum;
        }
            break;
        case 16:
        {
            width = videoWidth*4;
            height = videoHeight*4;
            NSInteger widthGapNum = 3;//横排空隙个数
            NSInteger heightGapNum = 3;//竖排空隙个数
            if (![UIDevice bm_isiPad])
            {
                width = videoWidth*6;
                height = videoHeight*3;
                widthGapNum = 5;
                heightGapNum = 2;
            }
            
            CGFloat widthScale = (maxWidth-VIDEOGRIDVIEW_GAP*widthGapNum)/width;
            CGFloat heightScale = (maxHeight-VIDEOGRIDVIEW_GAP*heightGapNum)/height;
            
            scale = MIN(widthScale, heightScale);
            bgWidth = width*scale+VIDEOGRIDVIEW_GAP*widthGapNum;
            bgHeight = height*scale+VIDEOGRIDVIEW_GAP*heightGapNum;
        }
            break;
        case 17:
        {
            width = videoWidth*4;
            height = videoHeight*5;
            NSInteger widthGapNum = 3;//横排空隙个数
            NSInteger heightGapNum = 4;//竖排空隙个数
            if (![UIDevice bm_isiPad])
            {
                width = videoWidth*6;
                height = videoHeight*3;
                widthGapNum = 5;
                heightGapNum = 2;
            }
            
            CGFloat widthScale = (maxWidth-VIDEOGRIDVIEW_GAP*widthGapNum)/width;
            CGFloat heightScale = (maxHeight-VIDEOGRIDVIEW_GAP*heightGapNum)/height;
            
            scale = MIN(widthScale, heightScale);
            bgWidth = width*scale+VIDEOGRIDVIEW_GAP*widthGapNum;
            bgHeight = height*scale+VIDEOGRIDVIEW_GAP*heightGapNum;
        }
            break;

        default:
            break;
    }

    self.videoWidth = videoWidth*scale;
    self.videoHeight = videoHeight*scale;

    self.videosBgView.bm_width = bgWidth;
    self.videosBgView.bm_height = bgHeight;
    
    CGPoint center = CGPointMake(self.bm_width*0.5, maxHeight*0.5 + VIDEOGRIDVIEW_GAP);
    self.videosBgView.center = center;
}

- (void)freshViewWithVideoViewArray:(NSMutableArray<SCVideoView *> *)videoViewArray withFouceVideo:(nullable SCVideoView *)fouceVideo withRoomLayout:(YSLiveRoomLayout)roomLayout withAppUseTheType:(YSAppUseTheType)appUseTheType
{
    self.videoViewArray = videoViewArray;
    
    [self clearView];
    
    if (roomLayout == YSLiveRoomLayout_FocusLayout)
    {
        if (appUseTheType == YSAppUseTheTypeSmallClass)
        {
            self.videosBgView.backgroundColor = YSSkinDefineColor(@"defaultBgColor");
            
            [self changeFrameFocus];
            
            for (SCVideoView *videoView in self.videoViewArray)
            {
                videoView.isDragOut = NO;
                videoView.isFullScreen = NO;
                videoView.isFullMedia = YES;
                [self.videosBgView addSubview:videoView];
                videoView.frame = CGRectMake(0, 0, self.videoWidth, self.videoHeight);
            }
            
            [self freshViewFocusWithFouceVideo:fouceVideo];
        }
    }
    else
    {
        
        self.videosBgView.backgroundColor = [UIColor clearColor];
        [self changeFrame];

           for (SCVideoView *videoView in self.videoViewArray)
           {
               videoView.isDragOut = NO;
               videoView.isFullScreen = NO;
               videoView.isFullMedia = YES;
               [self.videosBgView addSubview:videoView];
               videoView.frame = CGRectMake(0, 0, self.videoWidth, self.videoHeight);
           }
               
           [self freshView];
    }
}

- (void)freshView
{
    CGFloat width = self.videoWidth + VIDEOGRIDVIEW_GAP;
    CGFloat height = self.videoHeight + VIDEOGRIDVIEW_GAP;

    switch (self.videoViewArray.count)
    {
        case 1:
        {
            SCVideoView *videoView = self.videoViewArray[0];
            
            videoView.bm_top = 0;
            videoView.bm_left = 0;
        }
            break;
            
        case 2:
        {
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            
            videoView1.bm_top = 0;
            videoView1.bm_left = 0;
            
            videoView2.bm_top = 0;
            videoView2.bm_left = width;

        }
            break;
            
        case 3:
        {
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            
            videoView1.bm_top = 0;
            videoView1.bm_left = (self.videosBgView.bm_width-self.videoWidth)*0.5f;

            videoView2.bm_top = height;
            videoView2.bm_left = 0;
            
            videoView3.bm_top = height;
            videoView3.bm_left = width;
        }
            break;

        case 4:
        {
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            SCVideoView *videoView4 = self.videoViewArray[3];
            
            videoView1.bm_top = 0;
            videoView1.bm_left = 0;
            
            videoView2.bm_top = 0;
            videoView2.bm_left = width;
            
            videoView3.bm_top = height;
            videoView3.bm_left = 0;
            
            videoView4.bm_top = height;
            videoView4.bm_left = width;
        }
            break;

        case 5:
        {
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            SCVideoView *videoView4 = self.videoViewArray[3];
            SCVideoView *videoView5 = self.videoViewArray[4];

            CGFloat left = (self.videosBgView.bm_width - self.videoWidth*2+VIDEOGRIDVIEW_GAP)*0.5f;
            videoView1.bm_top = 0;
            videoView1.bm_left = left;
            
            videoView2.bm_top = 0;
            videoView2.bm_left = left+width;
            
            videoView3.bm_top = height;
            videoView3.bm_left = 0;
            
            videoView4.bm_top = height;
            videoView4.bm_left = width;
            
            videoView5.bm_top = height;
            videoView5.bm_left = width*2;
        }
            break;

        case 6:
        {
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            SCVideoView *videoView4 = self.videoViewArray[3];
            SCVideoView *videoView5 = self.videoViewArray[4];
            SCVideoView *videoView6 = self.videoViewArray[5];

            videoView1.bm_top = 0;
            videoView1.bm_left = 0;
            
            videoView2.bm_top = 0;
            videoView2.bm_left = width;
            
            videoView3.bm_top = 0;
            videoView3.bm_left = width*2;

            videoView4.bm_top = height;
            videoView4.bm_left = 0;
            
            videoView5.bm_top = height;
            videoView5.bm_left = width;
            
            videoView6.bm_top = height;
            videoView6.bm_left = width*2;
        }
            break;

        case 7:
        {
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            SCVideoView *videoView4 = self.videoViewArray[3];
            SCVideoView *videoView5 = self.videoViewArray[4];
            SCVideoView *videoView6 = self.videoViewArray[5];
            SCVideoView *videoView7 = self.videoViewArray[6];
            
            videoView1.bm_top = 0;
            videoView1.bm_left = 0;
            
            videoView2.bm_top = 0;
            videoView2.bm_left = width;
            
            videoView3.bm_top = 0;
            videoView3.bm_left = width*2;

            videoView4.bm_top = 0;
            videoView4.bm_left = width*3;
            
            videoView5.bm_top = height;
            videoView5.bm_left = 0;
            
            videoView6.bm_top = height;
            videoView6.bm_left = width;
            
            videoView7.bm_top = height;
            videoView7.bm_left = width*2;
        }
            break;

        case 8:
        {
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            SCVideoView *videoView4 = self.videoViewArray[3];
            SCVideoView *videoView5 = self.videoViewArray[4];
            SCVideoView *videoView6 = self.videoViewArray[5];
            SCVideoView *videoView7 = self.videoViewArray[6];
            SCVideoView *videoView8 = self.videoViewArray[7];
            
            videoView1.bm_top = 0;
            videoView1.bm_left = 0;
            
            videoView2.bm_top = 0;
            videoView2.bm_left = width;
            
            videoView3.bm_top = 0;
            videoView3.bm_left = width*2;

            videoView4.bm_top = 0;
            videoView4.bm_left = width*3;
            
            videoView5.bm_top = height;
            videoView5.bm_left = 0;
            
            videoView6.bm_top = height;
            videoView6.bm_left = width;
            
            videoView7.bm_top = height;
            videoView7.bm_left = width*2;
            
            videoView8.bm_top = height;
            videoView8.bm_left = width*3;
        }
            break;

        case 9:
        {
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            SCVideoView *videoView4 = self.videoViewArray[3];
            SCVideoView *videoView5 = self.videoViewArray[4];
            SCVideoView *videoView6 = self.videoViewArray[5];
            SCVideoView *videoView7 = self.videoViewArray[6];
            SCVideoView *videoView8 = self.videoViewArray[7];
            SCVideoView *videoView9 = self.videoViewArray[8];
            
            videoView1.bm_top = 0;
            videoView1.bm_left = 0;
            
            videoView2.bm_top = 0;
            videoView2.bm_left = width;
            
            videoView3.bm_top = 0;
            videoView3.bm_left = width*2;

            videoView4.bm_top = height;
            videoView4.bm_left = 0;
            
            videoView5.bm_top = height;
            videoView5.bm_left = width;
            
            videoView6.bm_top = height;
            videoView6.bm_left = width*2;
            
            videoView7.bm_top = height*2;
            videoView7.bm_left = 0;
            
            videoView8.bm_top = height*2;
            videoView8.bm_left = width;
            
            videoView9.bm_top = height*2;
            videoView9.bm_left = width*2;
        }
            break;

        case 10:
        {
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            SCVideoView *videoView4 = self.videoViewArray[3];
            SCVideoView *videoView5 = self.videoViewArray[4];
            SCVideoView *videoView6 = self.videoViewArray[5];
            SCVideoView *videoView7 = self.videoViewArray[6];
            SCVideoView *videoView8 = self.videoViewArray[7];
            SCVideoView *videoView9 = self.videoViewArray[8];
            SCVideoView *videoView10 = self.videoViewArray[9];

            videoView1.bm_top = 0;
            videoView1.bm_left = 0;
            
            videoView2.bm_top = 0;
            videoView2.bm_left = width;
            
            videoView3.bm_top = 0;
            videoView3.bm_left = width*2;
            
            videoView4.bm_top = 0;
            videoView4.bm_left = width*3;
            
            videoView5.bm_top = height;
            videoView5.bm_left = 0;
            
            videoView6.bm_top = height;
            videoView6.bm_left = width;
            
            videoView7.bm_top = height;
            videoView7.bm_left = width*2;
            
            videoView8.bm_top = height;
            videoView8.bm_left = width*3;
            
            videoView9.bm_top = height*2;
            videoView9.bm_left = 0;
            
            videoView10.bm_top = height*2;
            videoView10.bm_left = width;
        }
            break;

        case 11:
        {
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            SCVideoView *videoView4 = self.videoViewArray[3];
            SCVideoView *videoView5 = self.videoViewArray[4];
            SCVideoView *videoView6 = self.videoViewArray[5];
            SCVideoView *videoView7 = self.videoViewArray[6];
            SCVideoView *videoView8 = self.videoViewArray[7];
            SCVideoView *videoView9 = self.videoViewArray[8];
            SCVideoView *videoView10 = self.videoViewArray[9];
            SCVideoView *videoView11 = self.videoViewArray[10];
            
            videoView1.bm_top = 0;
            videoView1.bm_left = 0;
            
            videoView2.bm_top = 0;
            videoView2.bm_left = width;
            
            videoView3.bm_top = 0;
            videoView3.bm_left = width*2;
            
            videoView4.bm_top = 0;
            videoView4.bm_left = width*3;
            
            videoView5.bm_top = height;
            videoView5.bm_left = 0;
            
            videoView6.bm_top = height;
            videoView6.bm_left = width;
            
            videoView7.bm_top = height;
            videoView7.bm_left = width*2;
            
            videoView8.bm_top = height;
            videoView8.bm_left = width*3;
            
            videoView9.bm_top = height*2;
            videoView9.bm_left = 0;
            
            videoView10.bm_top = height*2;
            videoView10.bm_left = width;
            
            videoView11.bm_top = height*2;
            videoView11.bm_left = width*2;
        }
            break;

        case 12:
        {
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            SCVideoView *videoView4 = self.videoViewArray[3];
            SCVideoView *videoView5 = self.videoViewArray[4];
            SCVideoView *videoView6 = self.videoViewArray[5];
            SCVideoView *videoView7 = self.videoViewArray[6];
            SCVideoView *videoView8 = self.videoViewArray[7];
            SCVideoView *videoView9 = self.videoViewArray[8];
            SCVideoView *videoView10 = self.videoViewArray[9];
            SCVideoView *videoView11 = self.videoViewArray[10];
            SCVideoView *videoView12 = self.videoViewArray[11];
            
            videoView1.bm_top = 0;
            videoView1.bm_left = 0;
            
            videoView2.bm_top = 0;
            videoView2.bm_left = width;
            
            videoView3.bm_top = 0;
            videoView3.bm_left = width*2;
            
            videoView4.bm_top = 0;
            videoView4.bm_left = width*3;
            
            videoView5.bm_top = height;
            videoView5.bm_left = 0;
            
            videoView6.bm_top = height;
            videoView6.bm_left = width;
            
            videoView7.bm_top = height;
            videoView7.bm_left = width*2;
            
            videoView8.bm_top = height;
            videoView8.bm_left = width*3;
            
            videoView9.bm_top = height*2;
            videoView9.bm_left = 0;
            
            videoView10.bm_top = height*2;
            videoView10.bm_left = width;
            
            videoView11.bm_top = height*2;
            videoView11.bm_left = width*2;
            
            videoView12.bm_top = height*2;
            videoView12.bm_left = width*3;
        }
            break;

        case 13:
        {
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            SCVideoView *videoView4 = self.videoViewArray[3];
            SCVideoView *videoView5 = self.videoViewArray[4];
            SCVideoView *videoView6 = self.videoViewArray[5];
            SCVideoView *videoView7 = self.videoViewArray[6];
            SCVideoView *videoView8 = self.videoViewArray[7];
            SCVideoView *videoView9 = self.videoViewArray[8];
            SCVideoView *videoView10 = self.videoViewArray[9];
            SCVideoView *videoView11 = self.videoViewArray[10];
            SCVideoView *videoView12 = self.videoViewArray[11];
            SCVideoView *videoView13 = self.videoViewArray[12];
            
            if ([UIDevice bm_isiPad])
            {
                videoView1.bm_top = 0;
                videoView1.bm_left = 0;
                
                videoView2.bm_top = 0;
                videoView2.bm_left = width;
                
                videoView3.bm_top = 0;
                videoView3.bm_left = width*2;
                
                videoView4.bm_top = 0;
                videoView4.bm_left = width*3;
                
                videoView5.bm_top = height;
                videoView5.bm_left = 0;
                
                videoView6.bm_top = height;
                videoView6.bm_left = width;
                
                videoView7.bm_top = height;
                videoView7.bm_left = width*2;
                
                videoView8.bm_top = height;
                videoView8.bm_left = width*3;
                
                videoView9.bm_top = height*2;
                videoView9.bm_left = 0;
                
                videoView10.bm_top = height*2;
                videoView10.bm_left = width;
                
                videoView11.bm_top = height*2;
                videoView11.bm_left = width*2;
                
                videoView12.bm_top = height*2;
                videoView12.bm_left = width*3;

                videoView13.bm_top = height*3;
                videoView13.bm_left = 0;
            }
            else
            {
                videoView1.bm_top = 0;
                videoView1.bm_left = 0;
                
                videoView2.bm_top = 0;
                videoView2.bm_left = width;
                
                videoView3.bm_top = 0;
                videoView3.bm_left = width*2;
                
                videoView4.bm_top = 0;
                videoView4.bm_left = width*3;
                
                videoView5.bm_top = 0;
                videoView5.bm_left = width*4;
                
                videoView6.bm_top = height;
                videoView6.bm_left = 0;
                
                videoView7.bm_top = height;
                videoView7.bm_left = width;
                
                videoView8.bm_top = height;
                videoView8.bm_left = width*2;
                
                videoView9.bm_top = height;
                videoView9.bm_left = width*3;
                
                videoView10.bm_top = height;
                videoView10.bm_left = width*4;
                
                videoView11.bm_top = height*2;
                videoView11.bm_left = 0;
                
                videoView12.bm_top = height*2;
                videoView12.bm_left = width;

                videoView13.bm_top = height*2;
                videoView13.bm_left = width*2;
            }
        }
            break;
        case 14:
        {
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            SCVideoView *videoView4 = self.videoViewArray[3];
            SCVideoView *videoView5 = self.videoViewArray[4];
            SCVideoView *videoView6 = self.videoViewArray[5];
            SCVideoView *videoView7 = self.videoViewArray[6];
            SCVideoView *videoView8 = self.videoViewArray[7];
            SCVideoView *videoView9 = self.videoViewArray[8];
            SCVideoView *videoView10 = self.videoViewArray[9];
            SCVideoView *videoView11 = self.videoViewArray[10];
            SCVideoView *videoView12 = self.videoViewArray[11];
            SCVideoView *videoView13 = self.videoViewArray[12];
            SCVideoView *videoView14 = self.videoViewArray[13];
            
            if ([UIDevice bm_isiPad])
            {
                videoView1.bm_top = 0;
                videoView1.bm_left = 0;
                
                videoView2.bm_top = 0;
                videoView2.bm_left = width;
                
                videoView3.bm_top = 0;
                videoView3.bm_left = width*2;
                
                videoView4.bm_top = 0;
                videoView4.bm_left = width*3;
                
                videoView5.bm_top = height;
                videoView5.bm_left = 0;
                
                videoView6.bm_top = height;
                videoView6.bm_left = width;
                
                videoView7.bm_top = height;
                videoView7.bm_left = width*2;
                
                videoView8.bm_top = height;
                videoView8.bm_left = width*3;
                
                videoView9.bm_top = height*2;
                videoView9.bm_left = 0;
                
                videoView10.bm_top = height*2;
                videoView10.bm_left = width;
                
                videoView11.bm_top = height*2;
                videoView11.bm_left = width*2;
                
                videoView12.bm_top = height*2;
                videoView12.bm_left = width*3;
                
                videoView13.bm_top = height*3;
                videoView13.bm_left = 0;
                
                videoView14.bm_top = height*3;
                videoView14.bm_left = width;
            }
            else
            {
                videoView1.bm_top = 0;
                videoView1.bm_left = 0;
                
                videoView2.bm_top = 0;
                videoView2.bm_left = width;
                
                videoView3.bm_top = 0;
                videoView3.bm_left = width*2;
                
                videoView4.bm_top = 0;
                videoView4.bm_left = width*3;
                
                videoView5.bm_top = 0;
                videoView5.bm_left = width*4;
                
                videoView6.bm_top = height;
                videoView6.bm_left = 0;
                
                videoView7.bm_top = height;
                videoView7.bm_left = width;
                
                videoView8.bm_top = height;
                videoView8.bm_left = width*2;
                
                videoView9.bm_top = height;
                videoView9.bm_left = width*3;
                
                videoView10.bm_top = height;
                videoView10.bm_left = width*4;
                
                videoView11.bm_top = height*2;
                videoView11.bm_left = 0;
                
                videoView12.bm_top = height*2;
                videoView12.bm_left = width;
                
                videoView13.bm_top = height*2;
                videoView13.bm_left = width*2;
                
                videoView14.bm_top = height*2;;
                videoView14.bm_left = width*3;
            }
        }
            break;
            case 15:
            {
                SCVideoView *videoView1 = self.videoViewArray[0];
                SCVideoView *videoView2 = self.videoViewArray[1];
                SCVideoView *videoView3 = self.videoViewArray[2];
                SCVideoView *videoView4 = self.videoViewArray[3];
                SCVideoView *videoView5 = self.videoViewArray[4];
                SCVideoView *videoView6 = self.videoViewArray[5];
                SCVideoView *videoView7 = self.videoViewArray[6];
                SCVideoView *videoView8 = self.videoViewArray[7];
                SCVideoView *videoView9 = self.videoViewArray[8];
                SCVideoView *videoView10 = self.videoViewArray[9];
                SCVideoView *videoView11 = self.videoViewArray[10];
                SCVideoView *videoView12 = self.videoViewArray[11];
                SCVideoView *videoView13 = self.videoViewArray[12];
                SCVideoView *videoView14 = self.videoViewArray[13];
                SCVideoView *videoView15 = self.videoViewArray[14];
                
                if ([UIDevice bm_isiPad])
                {
                    videoView1.bm_top = 0;
                    videoView1.bm_left = 0;
                    
                    videoView2.bm_top = 0;
                    videoView2.bm_left = width;
                    
                    videoView3.bm_top = 0;
                    videoView3.bm_left = width*2;
                    
                    videoView4.bm_top = 0;
                    videoView4.bm_left = width*3;
                    
                    videoView5.bm_top = height;
                    videoView5.bm_left = 0;
                    
                    videoView6.bm_top = height;
                    videoView6.bm_left = width;
                    
                    videoView7.bm_top = height;
                    videoView7.bm_left = width*2;
                    
                    videoView8.bm_top = height;
                    videoView8.bm_left = width*3;
                    
                    videoView9.bm_top = height*2;
                    videoView9.bm_left = 0;
                    
                    videoView10.bm_top = height*2;
                    videoView10.bm_left = width;
                    
                    videoView11.bm_top = height*2;
                    videoView11.bm_left = width*2;
                    
                    videoView12.bm_top = height*2;
                    videoView12.bm_left = width*3;
                    
                    videoView13.bm_top = height*3;
                    videoView13.bm_left = 0;
                    
                    videoView14.bm_top = height*3;
                    videoView14.bm_left = width;
                    
                    videoView15.bm_top = height*3;
                    videoView15.bm_left = width*2;
                }
                else
                {
                    videoView1.bm_top = 0;
                    videoView1.bm_left = 0;
                    
                    videoView2.bm_top = 0;
                    videoView2.bm_left = width;
                    
                    videoView3.bm_top = 0;
                    videoView3.bm_left = width*2;
                    
                    videoView4.bm_top = 0;
                    videoView4.bm_left = width*3;
                    
                    videoView5.bm_top = 0;
                    videoView5.bm_left = width*4;
                    
                    videoView6.bm_top = height;
                    videoView6.bm_left = 0;
                    
                    videoView7.bm_top = height;
                    videoView7.bm_left = width;
                    
                    videoView8.bm_top = height;
                    videoView8.bm_left = width*2;
                    
                    videoView9.bm_top = height;
                    videoView9.bm_left = width*3;
                    
                    videoView10.bm_top = height;
                    videoView10.bm_left = width*4;
                    
                    videoView11.bm_top = height*2;
                    videoView11.bm_left = 0;
                    
                    videoView12.bm_top = height*2;
                    videoView12.bm_left = width;
                    
                    videoView13.bm_top = height*2;
                    videoView13.bm_left = width*2;
                    
                    videoView14.bm_top = height*2;
                    videoView14.bm_left = width*3;
                    
                    videoView15.bm_top = height*2;
                    videoView15.bm_left = width*4;
                }
            }
                break;
            case 16:
            {
                SCVideoView *videoView1 = self.videoViewArray[0];
                SCVideoView *videoView2 = self.videoViewArray[1];
                SCVideoView *videoView3 = self.videoViewArray[2];
                SCVideoView *videoView4 = self.videoViewArray[3];
                SCVideoView *videoView5 = self.videoViewArray[4];
                SCVideoView *videoView6 = self.videoViewArray[5];
                SCVideoView *videoView7 = self.videoViewArray[6];
                SCVideoView *videoView8 = self.videoViewArray[7];
                SCVideoView *videoView9 = self.videoViewArray[8];
                SCVideoView *videoView10 = self.videoViewArray[9];
                SCVideoView *videoView11 = self.videoViewArray[10];
                SCVideoView *videoView12 = self.videoViewArray[11];
                SCVideoView *videoView13 = self.videoViewArray[12];
                SCVideoView *videoView14 = self.videoViewArray[13];
                SCVideoView *videoView15 = self.videoViewArray[14];
                SCVideoView *videoView16 = self.videoViewArray[15];
                
                if ([UIDevice bm_isiPad])
                {
                    videoView1.bm_top = 0;
                    videoView1.bm_left = 0;
                    
                    videoView2.bm_top = 0;
                    videoView2.bm_left = width;
                    
                    videoView3.bm_top = 0;
                    videoView3.bm_left = width*2;
                    
                    videoView4.bm_top = 0;
                    videoView4.bm_left = width*3;
                    
                    videoView5.bm_top = height;
                    videoView5.bm_left = 0;
                    
                    videoView6.bm_top = height;
                    videoView6.bm_left = width;
                    
                    videoView7.bm_top = height;
                    videoView7.bm_left = width*2;
                    
                    videoView8.bm_top = height;
                    videoView8.bm_left = width*3;
                    
                    videoView9.bm_top = height*2;
                    videoView9.bm_left = 0;
                    
                    videoView10.bm_top = height*2;
                    videoView10.bm_left = width;
                    
                    videoView11.bm_top = height*2;
                    videoView11.bm_left = width*2;
                    
                    videoView12.bm_top = height*2;
                    videoView12.bm_left = width*3;
                    
                    videoView13.bm_top = height*3;
                    videoView13.bm_left = 0;
                    
                    videoView14.bm_top = height*3;
                    videoView14.bm_left = width;
                    
                    videoView15.bm_top = height*3;
                    videoView15.bm_left = width*2;
                    
                    videoView16.bm_top = height*3;
                    videoView16.bm_left = width*3;
                }
                else
                {
                    videoView1.bm_top = 0;
                    videoView1.bm_left = 0;
                    
                    videoView2.bm_top = 0;
                    videoView2.bm_left = width;
                    
                    videoView3.bm_top = 0;
                    videoView3.bm_left = width*2;
                    
                    videoView4.bm_top = 0;
                    videoView4.bm_left = width*3;
                    
                    videoView5.bm_top = 0;
                    videoView5.bm_left = width*4;
                    
                    videoView6.bm_top = 0;
                    videoView6.bm_left = width*5;
                    
                    videoView7.bm_top = height;
                    videoView7.bm_left = 0;
                    
                    videoView8.bm_top = height;
                    videoView8.bm_left = width;
                    
                    videoView9.bm_top = height;
                    videoView9.bm_left = width*2;
                    
                    videoView10.bm_top = height;
                    videoView10.bm_left = width*3;
                    
                    videoView11.bm_top = height;
                    videoView11.bm_left = width*4;
                    
                    videoView12.bm_top = height;
                    videoView12.bm_left = width*5;
                    
                    videoView13.bm_top = height*2;
                    videoView13.bm_left = 0;
                    
                    videoView14.bm_top = height*2;
                    videoView14.bm_left = width;
                    
                    videoView15.bm_top = height*2;
                    videoView15.bm_left = width*2;
                    
                    videoView16.bm_top = height*2;
                    videoView16.bm_left = width*3;
                }
            }
            break;
        case 17:
        {
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            SCVideoView *videoView4 = self.videoViewArray[3];
            SCVideoView *videoView5 = self.videoViewArray[4];
            SCVideoView *videoView6 = self.videoViewArray[5];
            SCVideoView *videoView7 = self.videoViewArray[6];
            SCVideoView *videoView8 = self.videoViewArray[7];
            SCVideoView *videoView9 = self.videoViewArray[8];
            SCVideoView *videoView10 = self.videoViewArray[9];
            SCVideoView *videoView11 = self.videoViewArray[10];
            SCVideoView *videoView12 = self.videoViewArray[11];
            SCVideoView *videoView13 = self.videoViewArray[12];
            SCVideoView *videoView14 = self.videoViewArray[13];
            SCVideoView *videoView15 = self.videoViewArray[14];
            SCVideoView *videoView16 = self.videoViewArray[15];
            SCVideoView *videoView17 = self.videoViewArray[16];
            
            if ([UIDevice bm_isiPad])
            {
                videoView1.bm_top = 0;
                videoView1.bm_left = 0;
                
                videoView2.bm_top = 0;
                videoView2.bm_left = width;
                
                videoView3.bm_top = 0;
                videoView3.bm_left = width*2;
                
                videoView4.bm_top = 0;
                videoView4.bm_left = width*3;
                
                videoView5.bm_top = height;
                videoView5.bm_left = 0;
                
                videoView6.bm_top = height;
                videoView6.bm_left = width;
                
                videoView7.bm_top = height;
                videoView7.bm_left = width*2;
                
                videoView8.bm_top = height;
                videoView8.bm_left = width*3;
                
                videoView9.bm_top = height*2;
                videoView9.bm_left = 0;
                
                videoView10.bm_top = height*2;
                videoView10.bm_left = width;
                
                videoView11.bm_top = height*2;
                videoView11.bm_left = width*2;
                
                videoView12.bm_top = height*2;
                videoView12.bm_left = width*3;
                
                videoView13.bm_top = height*3;
                videoView13.bm_left = 0;
                
                videoView14.bm_top = height*3;
                videoView14.bm_left = width;
                
                videoView15.bm_top = height*3;
                videoView15.bm_left = width*2;
                
                videoView16.bm_top = height*3;
                videoView16.bm_left = width*3;
                
                videoView17.bm_top = height*4;
                videoView17.bm_left = 0;
            }
            else
            {
                videoView1.bm_top = 0;
                videoView1.bm_left = 0;
                
                videoView2.bm_top = 0;
                videoView2.bm_left = width;
                
                videoView3.bm_top = 0;
                videoView3.bm_left = width*2;
                
                videoView4.bm_top = 0;
                videoView4.bm_left = width*3;
                
                videoView5.bm_top = 0;
                videoView5.bm_left = width*4;
                
                videoView6.bm_top = 0;
                videoView6.bm_left = width*5;
                
                videoView7.bm_top = height;
                videoView7.bm_left = 0;
                
                videoView8.bm_top = height;
                videoView8.bm_left = width;
                
                videoView9.bm_top = height;
                videoView9.bm_left = width*2;
                
                videoView10.bm_top = height;
                videoView10.bm_left = width*3;
                
                videoView11.bm_top = height;
                videoView11.bm_left = width*4;
                
                videoView12.bm_top = height;
                videoView12.bm_left = width*5;
                
                videoView13.bm_top = height*2;
                videoView13.bm_left = 0;
                
                videoView14.bm_top = height*2;
                videoView14.bm_left = width;
                
                videoView15.bm_top = height*2;
                videoView15.bm_left = width*2;
                
                videoView16.bm_top = height*2;
                videoView16.bm_left = width*3;
                
                videoView17.bm_top = height*2;
                videoView17.bm_left = width*4;
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 焦点布局（17路视频）

//计算各控件的尺寸
- (void)changeFrameFocus
{
    self.videosBgView.frame = self.bounds;
    
    self.videoHeight = (self.bm_height - 7 * VIDEOGRIDVIEW_GAP)/6;
    
    if (self.isWideScreen)
    {
        self.videoWidth = ceil(self.videoHeight / 9) * 16;
    }
    else
    {
        self.videoWidth = ceil(self.videoHeight / 3) * 4;
    }
    
    self.rightBgHeight = self.bm_height;
    
    if (self.videoViewArray.count < 2)
    {
        self.rightBgWidth = 0.0;
    }
    else if (self.videoViewArray.count < 8)
    {
        self.rightBgWidth = self.videoWidth;
    }
    else if (self.videoViewArray.count < 14)
    {
        self.rightBgWidth = 2 * self.videoWidth + VIDEOGRIDVIEW_GAP;
    }
    else
    {
        self.rightBgWidth = 3 * self.videoWidth + 2 * VIDEOGRIDVIEW_GAP;
    }
        
    [self.videosBgView addSubview:self.rightVideoBgView];
}


//布局
- (void)freshViewFocusWithFouceVideo:(SCVideoView *)fouceVideo
{
    CGFloat width = self.videoWidth + VIDEOGRIDVIEW_GAP;
    CGFloat height = self.videoHeight + VIDEOGRIDVIEW_GAP;

    NSMutableArray * mutArray = [NSMutableArray arrayWithArray:self.videoViewArray];
    
    if (mutArray.count > 0)
    {
        CGFloat maxWidth = self.defaultSize.width-VIDEOGRIDVIEW_GAP*2 - self.rightBgWidth;
        CGFloat maxHeight = self.defaultSize.height-VIDEOGRIDVIEW_GAP*2;
        
        CGFloat videoWidth = VIDEOGRIDVIEW_WIDTH;
        CGFloat videoHeight;
        if (self.isWideScreen)
        {
            videoHeight = ceil(videoWidth / 16) * 9;
        }
        else
        {
            videoHeight = ceil(videoWidth / 4) * 3;
        }
        
        CGFloat widthScale = maxWidth/videoWidth;
        CGFloat heightScale = maxHeight/videoHeight;
        
        CGFloat scale = MIN(widthScale, heightScale);
        CGFloat bgWidth = videoWidth*scale;
        CGFloat bgHeight = videoHeight*scale;
        
        fouceVideo.frame = CGRectMake((self.defaultSize.width - bgWidth - VIDEOGRIDVIEW_GAP - self.rightBgWidth)/2, (maxHeight-bgHeight)/2+VIDEOGRIDVIEW_GAP, bgWidth, bgHeight);
        
        self.rightVideoBgView.frame = CGRectMake(fouceVideo.bm_right + VIDEOGRIDVIEW_GAP, 0, self.rightBgWidth, self.rightBgHeight);

        [mutArray removeObject:fouceVideo];
    }
    
    CGFloat left = self.rightVideoBgView.bm_originX;
        
    for (int i = 0; i< mutArray.count; i++)
    {
        SCVideoView *videoView = mutArray[i];
        if (i < 6)
        {
            videoView.bm_top = i * height + VIDEOGRIDVIEW_GAP;
            videoView.bm_left = left;
        }
        else if (i >= 6 && i<12)
        {
            videoView.bm_top = (i - 6) * height + VIDEOGRIDVIEW_GAP;
            videoView.bm_left = left + width;;
        }
        else
        {
            videoView.bm_top = (i - 12) * height + VIDEOGRIDVIEW_GAP;
            videoView.bm_left = left + 2 * width;;
        }
    }
}

- (void)clearView
{
    [self.videosBgView bm_removeAllSubviews];
}


#pragma mark - 焦点布局（12路视频）
/*
- (void)changeFrameFocus
{
    self.videosBgView.frame = self.bounds;
    
    self.rightBgWidth = 0.0;
    self.rightBgHeight = self.bm_height;
    if (self.videoViewArray.count<= 5)
    {
        self.videoHeight = ceil((self.bm_height - 5 * VIDEOGRIDVIEW_GAP)/4);
        
        if (self.isWideScreen)
           {
               self.videoWidth = ceil(self.videoHeight / 9) * 16;
           }
           else
           {
               self.videoWidth = ceil(self.videoHeight / 3) * 4;
           }
        self.rightBgWidth = self.videoWidth;
    }
    else
    {
        self.videoHeight = (self.bm_height - 7 * VIDEOGRIDVIEW_GAP)/6;
        
        if (self.isWideScreen)
        {
            self.videoWidth = ceil(self.videoHeight / 9) * 16;
        }
        else
        {
            self.videoWidth = ceil(self.videoHeight / 3) * 4;
        }
        self.rightBgWidth = 2 * self.videoWidth + VIDEOGRIDVIEW_GAP;
    }
    
    [self.videosBgView addSubview:self.rightVideoBgView];
}

- (void)freshViewFocusWithFouceVideo:(SCVideoView *)fouceVideo
{
    CGFloat width = self.videoWidth + VIDEOGRIDVIEW_GAP;
    CGFloat height = self.videoHeight + VIDEOGRIDVIEW_GAP;

    NSMutableArray * mutArray = [NSMutableArray arrayWithArray:self.videoViewArray];
    
    if (mutArray.count>0)
    {
//        CGFloat topHeight = VIDEOGRIDVIEW_TOP/2;
        
        CGFloat maxWidth = self.defaultSize.width-VIDEOGRIDVIEW_GAP*2 - self.rightBgWidth;
        CGFloat maxHeight = self.defaultSize.height-VIDEOGRIDVIEW_GAP*2;
        
        CGFloat videoWidth = VIDEOGRIDVIEW_WIDTH;
        CGFloat videoHeight;
        if (self.isWideScreen)
        {
            videoHeight = ceil(videoWidth / 16) * 9;
        }
        else
        {
            videoHeight = ceil(videoWidth / 4) * 3;
        }
        
        CGFloat widthScale = maxWidth/videoWidth;
        CGFloat heightScale = maxHeight/videoHeight;
        
        CGFloat scale = MIN(widthScale, heightScale);
        CGFloat bgWidth = videoWidth*scale;
        CGFloat bgHeight = videoHeight*scale;
        
        fouceVideo.frame = CGRectMake((self.defaultSize.width - bgWidth - VIDEOGRIDVIEW_GAP - self.rightBgWidth)/2, (maxHeight-bgHeight)/2+VIDEOGRIDVIEW_GAP, bgWidth, bgHeight);
        
        self.rightVideoBgView.frame = CGRectMake(fouceVideo.bm_right + VIDEOGRIDVIEW_GAP, 0, self.rightBgWidth, self.rightBgHeight);

        [mutArray removeObject:fouceVideo];
    }
    
    CGFloat left = self.rightVideoBgView.bm_originX;
    
    switch (mutArray.count)
    {
        case 1:
        {
            SCVideoView *videoView = mutArray[0];
            
            videoView.bm_top = VIDEOGRIDVIEW_GAP;
            videoView.bm_left = left;
        }
            break;
            
        case 2:
        {
            SCVideoView *videoView1 = mutArray[0];
            SCVideoView *videoView2 = mutArray[1];
            
            videoView1.bm_top = VIDEOGRIDVIEW_GAP;
            videoView1.bm_left = left;
            
            videoView2.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView2.bm_left = left;

        }
            break;
            
        case 3:
        {
            SCVideoView *videoView1 = mutArray[0];
            SCVideoView *videoView2 = mutArray[1];
            SCVideoView *videoView3 = mutArray[2];
            
            videoView1.bm_top = VIDEOGRIDVIEW_GAP;
            videoView1.bm_left = left;
            
            videoView2.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView2.bm_left = left;
            
            videoView3.bm_top = 2*height + VIDEOGRIDVIEW_GAP;
            videoView3.bm_left = left;
        }
            break;

        case 4:
        {
            SCVideoView *videoView1 = mutArray[0];
            SCVideoView *videoView2 = mutArray[1];
            SCVideoView *videoView3 = mutArray[2];
            SCVideoView *videoView4 = mutArray[3];
            
            videoView1.bm_top = VIDEOGRIDVIEW_GAP;
            videoView1.bm_left = left;
            
            videoView2.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView2.bm_left = left;
            
            videoView3.bm_top = 2*height + VIDEOGRIDVIEW_GAP;
            videoView3.bm_left = left;
            
            videoView4.bm_top = 3*height + VIDEOGRIDVIEW_GAP;
            videoView4.bm_left = left;
        }
            break;

        case 5:
        {
            SCVideoView *videoView1 = mutArray[0];
            SCVideoView *videoView2 = mutArray[1];
            SCVideoView *videoView3 = mutArray[2];
            SCVideoView *videoView4 = mutArray[3];
            SCVideoView *videoView5 = mutArray[4];

            videoView1.bm_top = VIDEOGRIDVIEW_GAP;
            videoView1.bm_left = left;
            
            videoView2.bm_top = VIDEOGRIDVIEW_GAP;
            videoView2.bm_left = left+width;
            
            videoView3.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView3.bm_left = left;
            
            videoView4.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView4.bm_left = left+width;
            
            videoView5.bm_top = 2 * height + VIDEOGRIDVIEW_GAP;
            videoView5.bm_left = left;
        }
            break;

        case 6:
        {
            SCVideoView *videoView1 = mutArray[0];
            SCVideoView *videoView2 = mutArray[1];
            SCVideoView *videoView3 = mutArray[2];
            SCVideoView *videoView4 = mutArray[3];
            SCVideoView *videoView5 = mutArray[4];
            SCVideoView *videoView6 = mutArray[5];

            videoView1.bm_top = VIDEOGRIDVIEW_GAP;
            videoView1.bm_left = left;
            
            videoView2.bm_top = VIDEOGRIDVIEW_GAP;
            videoView2.bm_left = left+width;
            
            videoView3.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView3.bm_left = left;
            
            videoView4.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView4.bm_left = left+width;
            
            videoView5.bm_top = 2 * height + VIDEOGRIDVIEW_GAP;
            videoView5.bm_left = left;
            
            videoView6.bm_top = 2 * height + VIDEOGRIDVIEW_GAP;
            videoView6.bm_left = left+width;
        }
            break;

        case 7:
        {
            SCVideoView *videoView1 = mutArray[0];
            SCVideoView *videoView2 = mutArray[1];
            SCVideoView *videoView3 = mutArray[2];
            SCVideoView *videoView4 = mutArray[3];
            SCVideoView *videoView5 = mutArray[4];
            SCVideoView *videoView6 = mutArray[5];
            SCVideoView *videoView7 = mutArray[6];
            
            videoView1.bm_top = VIDEOGRIDVIEW_GAP;
            videoView1.bm_left = left;
            
            videoView2.bm_top = VIDEOGRIDVIEW_GAP;
            videoView2.bm_left = left+width;
            
            videoView3.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView3.bm_left = left;
            
            videoView4.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView4.bm_left = left+width;
            
            videoView5.bm_top = 2 * height + VIDEOGRIDVIEW_GAP;
            videoView5.bm_left = left;
            
            videoView6.bm_top = 2 * height + VIDEOGRIDVIEW_GAP;
            videoView6.bm_left = left+width;
            
            videoView7.bm_top = 3 * height + VIDEOGRIDVIEW_GAP;
            videoView7.bm_left = left;
        }
            break;

        case 8:
        {
            SCVideoView *videoView1 = mutArray[0];
            SCVideoView *videoView2 = mutArray[1];
            SCVideoView *videoView3 = mutArray[2];
            SCVideoView *videoView4 = mutArray[3];
            SCVideoView *videoView5 = mutArray[4];
            SCVideoView *videoView6 = mutArray[5];
            SCVideoView *videoView7 = mutArray[6];
            SCVideoView *videoView8 = mutArray[7];
            
            videoView1.bm_top = VIDEOGRIDVIEW_GAP;
            videoView1.bm_left = left;
            
            videoView2.bm_top = VIDEOGRIDVIEW_GAP;
            videoView2.bm_left = left+width;
            
            videoView3.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView3.bm_left = left;
            
            videoView4.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView4.bm_left = left+width;
            
            videoView5.bm_top = 2 * height + VIDEOGRIDVIEW_GAP;
            videoView5.bm_left = left;
            
            videoView6.bm_top = 2 * height + VIDEOGRIDVIEW_GAP;
            videoView6.bm_left = left+width;
            
            videoView7.bm_top = 3 * height + VIDEOGRIDVIEW_GAP;
            videoView7.bm_left = left;
            
            videoView8.bm_top = 3 * height + VIDEOGRIDVIEW_GAP;
            videoView8.bm_left = left+width;
        }
            break;

        case 9:
        {
            SCVideoView *videoView1 = mutArray[0];
            SCVideoView *videoView2 = mutArray[1];
            SCVideoView *videoView3 = mutArray[2];
            SCVideoView *videoView4 = mutArray[3];
            SCVideoView *videoView5 = mutArray[4];
            SCVideoView *videoView6 = mutArray[5];
            SCVideoView *videoView7 = mutArray[6];
            SCVideoView *videoView8 = mutArray[7];
            SCVideoView *videoView9 = mutArray[8];
            
            videoView1.bm_top = VIDEOGRIDVIEW_GAP;
            videoView1.bm_left = left;
            
            videoView2.bm_top = VIDEOGRIDVIEW_GAP;
            videoView2.bm_left = left+width;
            
            videoView3.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView3.bm_left = left;
            
            videoView4.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView4.bm_left = left+width;
            
            videoView5.bm_top = 2 * height + VIDEOGRIDVIEW_GAP;
            videoView5.bm_left = left;
            
            videoView6.bm_top = 2 * height + VIDEOGRIDVIEW_GAP;
            videoView6.bm_left = left+width;
            
            videoView7.bm_top = 3 * height + VIDEOGRIDVIEW_GAP;
            videoView7.bm_left = left;
            
            videoView8.bm_top = 3 * height + VIDEOGRIDVIEW_GAP;
            videoView8.bm_left = left+width;
            
            videoView9.bm_top = 4 * height + VIDEOGRIDVIEW_GAP;
            videoView9.bm_left = left;
        }
            break;

        case 10:
        {
            SCVideoView *videoView1 = mutArray[0];
            SCVideoView *videoView2 = mutArray[1];
            SCVideoView *videoView3 = mutArray[2];
            SCVideoView *videoView4 = mutArray[3];
            SCVideoView *videoView5 = mutArray[4];
            SCVideoView *videoView6 = mutArray[5];
            SCVideoView *videoView7 = mutArray[6];
            SCVideoView *videoView8 = mutArray[7];
            SCVideoView *videoView9 = mutArray[8];
            SCVideoView *videoView10 = mutArray[9];

            videoView1.bm_top = VIDEOGRIDVIEW_GAP;
            videoView1.bm_left = left;
            
            videoView2.bm_top = VIDEOGRIDVIEW_GAP;
            videoView2.bm_left = left+width;
            
            videoView3.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView3.bm_left = left;
            
            videoView4.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView4.bm_left = left+width;
            
            videoView5.bm_top = 2 * height + VIDEOGRIDVIEW_GAP;
            videoView5.bm_left = left;
            
            videoView6.bm_top = 2 * height + VIDEOGRIDVIEW_GAP;
            videoView6.bm_left = left+width;
            
            videoView7.bm_top = 3 * height + VIDEOGRIDVIEW_GAP;
            videoView7.bm_left = left;
            
            videoView8.bm_top = 3 * height + VIDEOGRIDVIEW_GAP;
            videoView8.bm_left = left+width;
            
            videoView9.bm_top = 4 * height + VIDEOGRIDVIEW_GAP;
            videoView9.bm_left = left;
            
            videoView10.bm_top = 4 * height + VIDEOGRIDVIEW_GAP;
            videoView10.bm_left = left+width;

        }
            break;

        case 11:
        {
            SCVideoView *videoView1 = mutArray[0];
            SCVideoView *videoView2 = mutArray[1];
            SCVideoView *videoView3 = mutArray[2];
            SCVideoView *videoView4 = mutArray[3];
            SCVideoView *videoView5 = mutArray[4];
            SCVideoView *videoView6 = mutArray[5];
            SCVideoView *videoView7 = mutArray[6];
            SCVideoView *videoView8 = mutArray[7];
            SCVideoView *videoView9 = mutArray[8];
            SCVideoView *videoView10 = mutArray[9];
            SCVideoView *videoView11 = mutArray[10];
            
            videoView1.bm_top = VIDEOGRIDVIEW_GAP;
            videoView1.bm_left = left;
            
            videoView2.bm_top = VIDEOGRIDVIEW_GAP;
            videoView2.bm_left = left+width;
            
            videoView3.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView3.bm_left = left;
            
            videoView4.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView4.bm_left = left+width;
            
            videoView5.bm_top = 2 * height + VIDEOGRIDVIEW_GAP;
            videoView5.bm_left = left;
            
            videoView6.bm_top = 2 * height + VIDEOGRIDVIEW_GAP;
            videoView6.bm_left = left+width;
            
            videoView7.bm_top = 3 * height + VIDEOGRIDVIEW_GAP;
            videoView7.bm_left = left;
            
            videoView8.bm_top = 3 * height + VIDEOGRIDVIEW_GAP;
            videoView8.bm_left = left+width;
            
            videoView9.bm_top = 4 * height + VIDEOGRIDVIEW_GAP;
            videoView9.bm_left = left;
            
            videoView10.bm_top = 4 * height + VIDEOGRIDVIEW_GAP;
            videoView10.bm_left = left+width;
            
            videoView11.bm_top = 5 * height + VIDEOGRIDVIEW_GAP;
            videoView11.bm_left = left;
            
        }
            break;
        case 12:
        {
            SCVideoView *videoView1 = mutArray[0];
            SCVideoView *videoView2 = mutArray[1];
            SCVideoView *videoView3 = mutArray[2];
            SCVideoView *videoView4 = mutArray[3];
            SCVideoView *videoView5 = mutArray[4];
            SCVideoView *videoView6 = mutArray[5];
            SCVideoView *videoView7 = mutArray[6];
            SCVideoView *videoView8 = mutArray[7];
            SCVideoView *videoView9 = mutArray[8];
            SCVideoView *videoView10 = mutArray[9];
            SCVideoView *videoView11 = mutArray[10];
            SCVideoView *videoView12 = mutArray[11];
            
            videoView1.bm_top = VIDEOGRIDVIEW_GAP;
            videoView1.bm_left = left;
            
            videoView2.bm_top = VIDEOGRIDVIEW_GAP;
            videoView2.bm_left = left+width;
            
            videoView3.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView3.bm_left = left;
            
            videoView4.bm_top = height + VIDEOGRIDVIEW_GAP;
            videoView4.bm_left = left+width;
            
            videoView5.bm_top = 2 * height + VIDEOGRIDVIEW_GAP;
            videoView5.bm_left = left;
            
            videoView6.bm_top = 2 * height + VIDEOGRIDVIEW_GAP;
            videoView6.bm_left = left+width;
            
            videoView7.bm_top = 3 * height + VIDEOGRIDVIEW_GAP;
            videoView7.bm_left = left;
            
            videoView8.bm_top = 3 * height + VIDEOGRIDVIEW_GAP;
            videoView8.bm_left = left+width;
            
            videoView9.bm_top = 4 * height + VIDEOGRIDVIEW_GAP;
            videoView9.bm_left = left;
            
            videoView10.bm_top = 4 * height + VIDEOGRIDVIEW_GAP;
            videoView10.bm_left = left+width;
            
            videoView11.bm_top = 5 * height + VIDEOGRIDVIEW_GAP;
            videoView11.bm_left = left;
            
            videoView12.bm_top = 5 * height + VIDEOGRIDVIEW_GAP;
            videoView12.bm_left = left+width;
        }
            break;

        default:
            break;
    }
}
*/

@end

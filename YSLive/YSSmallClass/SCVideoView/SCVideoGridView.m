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

@property (nonatomic, assign) CGFloat videoWidth;
@property (nonatomic, assign) CGFloat videoHeight;

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
        self.videosBgView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.videosBgView];
        self.rightVideoBgView = [[UIView alloc] init];
        self.rightVideoBgView.backgroundColor = [UIColor bm_colorWithHex:0x5A8CDC];
    }
    return self;
}

- (void)changeFrame
{
    CGFloat top = VIDEOGRIDVIEW_TOP;
    CGFloat maxWidth = self.defaultSize.width-VIDEOGRIDVIEW_GAP*2;
    CGFloat maxHeight = self.defaultSize.height-VIDEOGRIDVIEW_GAP*2-top;
    
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
        {
            width = videoWidth*4;
            height = videoHeight*4;
            
            CGFloat widthScale = (maxWidth-VIDEOGRIDVIEW_GAP*3)/width;
            CGFloat heightScale = (maxHeight-VIDEOGRIDVIEW_GAP*3)/height;

            scale = MIN(widthScale, heightScale);
            bgWidth = width*scale+VIDEOGRIDVIEW_GAP*3;
            bgHeight = height*scale+VIDEOGRIDVIEW_GAP*3;
        }
            break;

        default:
            break;
    }

    self.videoWidth = videoWidth*scale;
    self.videoHeight = videoHeight*scale;

    self.videosBgView.bm_width = bgWidth;
    self.videosBgView.bm_height = bgHeight;

    CGFloat checktop = maxHeight+top - bgHeight;
    
    if (checktop >= top)
    {
        CGPoint center = CGPointMake(self.bm_width*0.5, (maxHeight+top)*0.5);
        self.videosBgView.center = center;
    }
    else
    {
        CGPoint center = CGPointMake(self.bm_width*0.5, top+maxHeight*0.5);
        self.videosBgView.center = center;
    }
}

- (void)freshViewWithVideoViewArray:(NSMutableArray<SCVideoView *> *)videoViewArray withFouceVideo:(nullable SCVideoView *)fouceVideo withRoomLayout:(YSLiveRoomLayout)roomLayout withAppUseTheType:(YSAppUseTheType)appUseTheType
{
    self.videoViewArray = videoViewArray;
    
    [self clearView];
    
    if (roomLayout == YSLiveRoomLayout_FocusLayout)
    {
        if (appUseTheType == YSAppUseTheTypeSmallClass)
        {
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

            videoView4.bm_top = height;
            videoView4.bm_left = 0;
            
            videoView5.bm_top = height;
            videoView5.bm_left = width;
            
            videoView6.bm_top = height;
            videoView6.bm_left = width*2;
            
            videoView7.bm_top = height*2;
            videoView7.bm_left = 0;
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
            break;

        default:
            break;
    }
}

- (void)changeFrameFocus
{
    self.videosBgView.frame = self.bounds;
    
    CGFloat rightVideoBgWidth = 0.0;
    CGFloat rightVideoBgHeight = self.bm_height;

    if (self.videoViewArray.count<2)
    {
        CGFloat maxWidth = self.defaultSize.width-VIDEOGRIDVIEW_GAP*2 - self.rightVideoBgView.bm_width;
        //        CGFloat maxHeight = self.defaultSize.height-VIDEOGRIDVIEW_GAP*2-top;
            CGFloat maxHeight = self.defaultSize.height-VIDEOGRIDVIEW_GAP*2;
                
//                CGFloat videoWidth = VIDEOGRIDVIEW_WIDTH;
//                CGFloat videoHeight;
//                if (self.isWideScreen)
//                {
//                    videoHeight = ceil(videoWidth / 16) * 9;
//                }
//                else
//                {
//                    videoHeight = ceil(videoWidth / 4) * 3;
//                }
//
//                CGFloat widthScale = maxWidth/videoWidth;
//                CGFloat heightScale = maxHeight/videoHeight;
//
//                CGFloat scale = MIN(widthScale, heightScale);
//                CGFloat bgWidth = videoWidth*scale;
//                CGFloat bgHeight = videoHeight*scale;
//
//                fouceVideo.frame = CGRectMake((maxWidth-bgWidth)/2+VIDEOGRIDVIEW_GAP, (maxHeight-bgHeight)/2, bgWidth, bgHeight);
        rightVideoBgWidth = 0.0;
    }
    
    else if (self.videoViewArray.count<= 5)
    {
        self.videosBgView.frame = self.bounds;
        
        self.videoHeight = ceil((self.bm_height - 5 * VIDEOGRIDVIEW_GAP)/4);
        
        if (self.isWideScreen)
           {
               self.videoWidth = ceil(self.videoHeight / 9) * 16;
           }
           else
           {
               self.videoWidth = ceil(self.videoHeight / 3) * 4;
           }
        rightVideoBgWidth = self.videoWidth + 2 * VIDEOGRIDVIEW_GAP;
    }
    else
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
        rightVideoBgWidth = 2 * self.videoWidth + 3 * VIDEOGRIDVIEW_GAP;
    }
    
    [self.videosBgView addSubview:self.rightVideoBgView];
    
    self.rightVideoBgView.frame = CGRectMake(self.bm_width - rightVideoBgWidth, 0, rightVideoBgWidth, rightVideoBgHeight);
}

- (void)freshViewFocusWithFouceVideo:(SCVideoView *)fouceVideo
{
    CGFloat width = self.videoWidth + VIDEOGRIDVIEW_GAP;
    CGFloat height = self.videoHeight + VIDEOGRIDVIEW_GAP;
    
    CGFloat left = self.rightVideoBgView.bm_originX + VIDEOGRIDVIEW_GAP;

    NSMutableArray * mutArray = [NSMutableArray arrayWithArray:self.videoViewArray];
    
    if (mutArray.count>0)
    {
//        CGFloat top = VIDEOGRIDVIEW_TOP;
        
        CGFloat maxWidth = self.defaultSize.width-VIDEOGRIDVIEW_GAP*2 - self.rightVideoBgView.bm_width;
//        CGFloat maxHeight = self.defaultSize.height-VIDEOGRIDVIEW_GAP*2-top;
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
        
//        fouceVideo.frame = CGRectMake((maxWidth-bgWidth)/2+VIDEOGRIDVIEW_GAP, (maxHeight-bgHeight)/2+VIDEOGRIDVIEW_GAP+top/2, bgWidth, bgHeight);
        fouceVideo.frame = CGRectMake((maxWidth-bgWidth)/2+VIDEOGRIDVIEW_GAP, (maxHeight-bgHeight)/2+VIDEOGRIDVIEW_GAP, bgWidth, bgHeight);
        
        [mutArray removeObject:fouceVideo];
    }
    
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

- (void)clearView
{
    [self.videosBgView bm_removeAllSubviews];
//    
//    SCVideoView *videoView1 = [self.videoViewArray firstObject];
//    if (videoView1.superview)
//    {
//        for (SCVideoView *videoView in self.videoViewArray)
//        {
//            if (videoView.superview)
//            {
//                [videoView removeFromSuperview];
//            }
//        }
//    }
}

@end

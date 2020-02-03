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
#define VIDEOGRIDVIEW_GAP       ([UIDevice bm_isiPad] ? kVideoGridView_Gap_iPad : kVideoGridView_Gap_iPhone)

@interface SCVideoGridView ()

/// 视频ratio 16:9
@property (nonatomic, assign) BOOL isWideScreen;

@property (nonatomic, strong) NSMutableArray <SCVideoView *> *videoViewArray;

@end

@implementation SCVideoGridView


- (instancetype)initWithWideScreen:(BOOL)isWideScreen
{
    self = [super init];
    if (self)
    {
        self.isWideScreen = isWideScreen;
    }
    return self;
}

- (void)changeFrame
{
    switch (self.videoViewArray.count)
    {
        case 2:
        {
            CGFloat width = self.defaultSize.width*1.42;
            
            if ([UIDevice bm_isiPad]) {
                width = self.defaultSize.width;
            }
            
            self.bm_width = width+VIDEOGRIDVIEW_GAP;
            self.bm_height = [self getHeightWithWidth:width];
        }
            break;

        case 3:
        case 4:
        {
            self.bm_width = self.defaultSize.width+VIDEOGRIDVIEW_GAP;
            self.bm_height = self.defaultSize.height+VIDEOGRIDVIEW_GAP;
        }
            break;
            
        case 5:
        case 6:
        {
            CGFloat width = self.defaultSize.width * 1.42f;
            self.bm_width = width+VIDEOGRIDVIEW_GAP*2;
            self.bm_height = [self getHeightWithWidth:width]+VIDEOGRIDVIEW_GAP;
        }
            break;
            
        case 7:
        case 8:
        case 9:
        {
            self.bm_width = self.defaultSize.width+VIDEOGRIDVIEW_GAP*2;
            self.bm_height = self.defaultSize.height+VIDEOGRIDVIEW_GAP*2;
        }
            break;
            
        case 10:
        case 11:
        case 12:
        {
            CGFloat width = self.defaultSize.width * 1.42f;
            self.bm_width = width+VIDEOGRIDVIEW_GAP*3;
            self.bm_height = [self getHeightWithWidth:width]+VIDEOGRIDVIEW_GAP*2;
        }
            break;
            
        case 13:
        {
            self.bm_width = self.defaultSize.width+VIDEOGRIDVIEW_GAP*3;
            self.bm_height = self.defaultSize.height+VIDEOGRIDVIEW_GAP*3;
        }
            break;
            
        case 1:
        default:
            self.bm_size = self.defaultSize;
            break;
    }
    [self bm_centerInSuperViewWithTopOffset:self.topOffset];
}

- (void)freshViewWithVideoViewArray:(NSMutableArray<SCVideoView *> *)videoViewArray
{
    self.videoViewArray = videoViewArray;
    [self clearView];
    
    for (SCVideoView *videoView in self.videoViewArray)
    {
        videoView.isDragOut = NO;
        videoView.isFullScreen = NO;
        videoView.isFullMedia = YES;
        [self addSubview:videoView];
    }
    
    [self changeFrame];
    
    
    [self freshView];
}

- (CGFloat)getHeightWithWidth:(CGFloat)width
{
    if (self.isWideScreen)
    {
        return width * 9 / 16;
    }
    else
    {
        return width * 3 / 4;
    }
}

- (void)freshView
{
    CGFloat width;
    CGFloat height;
    
    switch (self.videoViewArray.count)
    {
        case 1:
        {
            width = self.bm_width;
            height = self.bm_height;
            SCVideoView *videoView = self.videoViewArray[0];
            videoView.frame = CGRectMake(0, 0, width, height);
        }
            break;
            
        case 2:
        {
            width = (self.bm_width - VIDEOGRIDVIEW_GAP)*0.5;
            height = [self getHeightWithWidth:width];
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            CGFloat startY = (self.bm_height-height)*0.5;
            videoView1.frame = CGRectMake(0, startY, width, height);
            videoView2.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, startY, width, height);
        }
            break;
            
        case 3:
        {
            width = (self.bm_width - VIDEOGRIDVIEW_GAP)*0.5;
            height = [self getHeightWithWidth:width];
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            videoView1.frame = CGRectMake((self.bm_width-width)*0.5, 0, width, height);
            videoView2.frame = CGRectMake(0, height+VIDEOGRIDVIEW_GAP, width, height);
            videoView3.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, height+VIDEOGRIDVIEW_GAP, width, height);
        }
            break;

        case 4:
        {
            width = (self.bm_width - VIDEOGRIDVIEW_GAP)*0.5;
            height = [self getHeightWithWidth:width];
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            SCVideoView *videoView4 = self.videoViewArray[3];
            videoView1.frame = CGRectMake(0, 0, width, height);
            videoView2.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, 0, width, height);
            videoView3.frame = CGRectMake(0, height+VIDEOGRIDVIEW_GAP, width, height);
            videoView4.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, height+VIDEOGRIDVIEW_GAP, width, height);
        }
            break;

        case 5:
        {
            width = (self.bm_width - VIDEOGRIDVIEW_GAP*2)/3;
            height = [self getHeightWithWidth:width];
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            SCVideoView *videoView4 = self.videoViewArray[3];
            SCVideoView *videoView5 = self.videoViewArray[4];
            CGFloat startX = (self.bm_width-width*2-VIDEOGRIDVIEW_GAP)*0.5;
            CGFloat startY = (self.bm_height-height*2-VIDEOGRIDVIEW_GAP)*0.5;
            videoView1.frame = CGRectMake(startX, startY, width, height);
            videoView2.frame = CGRectMake(startX+width+VIDEOGRIDVIEW_GAP, startY, width, height);
            videoView3.frame = CGRectMake(0, startY+height+VIDEOGRIDVIEW_GAP, width, height);
            videoView4.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, startY+height+VIDEOGRIDVIEW_GAP, width, height);
            videoView5.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, startY+height+VIDEOGRIDVIEW_GAP, width, height);
        }
            break;

        case 6:
        {
            width = (self.bm_width - VIDEOGRIDVIEW_GAP*2)/3;
            height = [self getHeightWithWidth:width];
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            SCVideoView *videoView4 = self.videoViewArray[3];
            SCVideoView *videoView5 = self.videoViewArray[4];
            SCVideoView *videoView6 = self.videoViewArray[5];
            CGFloat startY = (self.bm_height-height*2-VIDEOGRIDVIEW_GAP)*0.5;
            videoView1.frame = CGRectMake(0, startY, width, height);
            videoView2.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, startY, width, height);
            videoView3.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, startY, width, height);
            videoView4.frame = CGRectMake(0, startY+height+VIDEOGRIDVIEW_GAP, width, height);
            videoView5.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, startY+height+VIDEOGRIDVIEW_GAP, width, height);
            videoView6.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, startY+height+VIDEOGRIDVIEW_GAP, width, height);
        }
            break;

        case 7:
        {
            width = (self.bm_width - VIDEOGRIDVIEW_GAP*2)/3;
            height = [self getHeightWithWidth:width];
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            SCVideoView *videoView4 = self.videoViewArray[3];
            SCVideoView *videoView5 = self.videoViewArray[4];
            SCVideoView *videoView6 = self.videoViewArray[5];
            SCVideoView *videoView7 = self.videoViewArray[6];
            videoView1.frame = CGRectMake(0, 0, width, height);
            videoView2.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, 0, width, height);
            videoView3.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, 0, width, height);
            videoView4.frame = CGRectMake(0, height+VIDEOGRIDVIEW_GAP, width, height);
            videoView5.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, height+VIDEOGRIDVIEW_GAP, width, height);
            videoView6.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, height+VIDEOGRIDVIEW_GAP, width, height);
            videoView7.frame = CGRectMake(0, (height+VIDEOGRIDVIEW_GAP)*2, width, height);
        }
            break;

        case 8:
        {
            width = (self.bm_width - VIDEOGRIDVIEW_GAP*2)/3;
            height = [self getHeightWithWidth:width];
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            SCVideoView *videoView4 = self.videoViewArray[3];
            SCVideoView *videoView5 = self.videoViewArray[4];
            SCVideoView *videoView6 = self.videoViewArray[5];
            SCVideoView *videoView7 = self.videoViewArray[6];
            SCVideoView *videoView8 = self.videoViewArray[7];
            videoView1.frame = CGRectMake(0, 0, width, height);
            videoView2.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, 0, width, height);
            videoView3.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, 0, width, height);
            videoView4.frame = CGRectMake(0, height+VIDEOGRIDVIEW_GAP, width, height);
            videoView5.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, height+VIDEOGRIDVIEW_GAP, width, height);
            videoView6.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, height+VIDEOGRIDVIEW_GAP, width, height);
            videoView7.frame = CGRectMake(0, (height+VIDEOGRIDVIEW_GAP)*2, width, height);
            videoView8.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, (height+VIDEOGRIDVIEW_GAP)*2, width, height);
        }
            break;

        case 9:
        {
            width = (self.bm_width - VIDEOGRIDVIEW_GAP*2)/3;
            height = [self getHeightWithWidth:width];
            SCVideoView *videoView1 = self.videoViewArray[0];
            SCVideoView *videoView2 = self.videoViewArray[1];
            SCVideoView *videoView3 = self.videoViewArray[2];
            SCVideoView *videoView4 = self.videoViewArray[3];
            SCVideoView *videoView5 = self.videoViewArray[4];
            SCVideoView *videoView6 = self.videoViewArray[5];
            SCVideoView *videoView7 = self.videoViewArray[6];
            SCVideoView *videoView8 = self.videoViewArray[7];
            SCVideoView *videoView9 = self.videoViewArray[8];
            videoView1.frame = CGRectMake(0, 0, width, height);
            videoView2.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, 0, width, height);
            videoView3.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, 0, width, height);
            videoView4.frame = CGRectMake(0, height+VIDEOGRIDVIEW_GAP, width, height);
            videoView5.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, height+VIDEOGRIDVIEW_GAP, width, height);
            videoView6.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, height+VIDEOGRIDVIEW_GAP, width, height);
            videoView7.frame = CGRectMake(0, (height+VIDEOGRIDVIEW_GAP)*2, width, height);
            videoView8.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, (height+VIDEOGRIDVIEW_GAP)*2, width, height);
            videoView9.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, (height+VIDEOGRIDVIEW_GAP)*2, width, height);
        }
            break;

        case 10:
        {
            width = (self.bm_width - VIDEOGRIDVIEW_GAP*3)/4;
            height = [self getHeightWithWidth:width];
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
            CGFloat startY = (self.bm_height-height*3-VIDEOGRIDVIEW_GAP*2)*0.5;
            videoView1.frame = CGRectMake(0, startY, width, height);
            videoView2.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, startY, width, height);
            videoView3.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, startY, width, height);
            videoView4.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*3, startY, width, height);
            videoView5.frame = CGRectMake(0, startY+height+VIDEOGRIDVIEW_GAP, width, height);
            videoView6.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, startY+height+VIDEOGRIDVIEW_GAP, width, height);
            videoView7.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, startY+height+VIDEOGRIDVIEW_GAP, width, height);
            videoView8.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*3, startY+height+VIDEOGRIDVIEW_GAP, width, height);
            videoView9.frame = CGRectMake(0, startY+(height+VIDEOGRIDVIEW_GAP)*2, width, height);
            videoView10.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, startY+(height+VIDEOGRIDVIEW_GAP)*2, width, height);
        }
            break;

        case 11:
        {
            width = (self.bm_width - VIDEOGRIDVIEW_GAP*3)/4;
            height = [self getHeightWithWidth:width];
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
            CGFloat startY = (self.bm_height-height*3-VIDEOGRIDVIEW_GAP*2)*0.5;
            videoView1.frame = CGRectMake(0, startY, width, height);
            videoView2.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, startY, width, height);
            videoView3.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, startY, width, height);
            videoView4.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*3, startY, width, height);
            videoView5.frame = CGRectMake(0, startY+height+VIDEOGRIDVIEW_GAP, width, height);
            videoView6.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, startY+height+VIDEOGRIDVIEW_GAP, width, height);
            videoView7.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, startY+height+VIDEOGRIDVIEW_GAP, width, height);
            videoView8.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*3, startY+height+VIDEOGRIDVIEW_GAP, width, height);
            videoView9.frame = CGRectMake(0, startY+(height+VIDEOGRIDVIEW_GAP)*2, width, height);
            videoView10.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, startY+(height+VIDEOGRIDVIEW_GAP)*2, width, height);
            videoView11.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, startY+(height+VIDEOGRIDVIEW_GAP)*2, width, height);
        }
            break;

        case 12:
        {
            width = (self.bm_width - VIDEOGRIDVIEW_GAP*3)/4;
            height = [self getHeightWithWidth:width];
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
            CGFloat startY = (self.bm_height-height*3-VIDEOGRIDVIEW_GAP*2)*0.5;
            videoView1.frame = CGRectMake(0, startY, width, height);
            videoView2.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, startY, width, height);
            videoView3.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, startY, width, height);
            videoView4.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*3, startY, width, height);
            videoView5.frame = CGRectMake(0, startY+height+VIDEOGRIDVIEW_GAP, width, height);
            videoView6.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, startY+height+VIDEOGRIDVIEW_GAP, width, height);
            videoView7.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, startY+height+VIDEOGRIDVIEW_GAP, width, height);
            videoView8.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*3, startY+height+VIDEOGRIDVIEW_GAP, width, height);
            videoView9.frame = CGRectMake(0, startY+(height+VIDEOGRIDVIEW_GAP)*2, width, height);
            videoView10.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, startY+(height+VIDEOGRIDVIEW_GAP)*2, width, height);
            videoView11.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, startY+(height+VIDEOGRIDVIEW_GAP)*2, width, height);
            videoView12.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*3, startY+(height+VIDEOGRIDVIEW_GAP)*2, width, height);
        }
            break;

        case 13:
        {
            width = (self.bm_width - VIDEOGRIDVIEW_GAP*3)/4;
            height = [self getHeightWithWidth:width];
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
            videoView1.frame = CGRectMake(0, 0, width, height);
            videoView2.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, 0, width, height);
            videoView3.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, 0, width, height);
            videoView4.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*3, 0, width, height);
            videoView5.frame = CGRectMake(0, height+VIDEOGRIDVIEW_GAP, width, height);
            videoView6.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, height+VIDEOGRIDVIEW_GAP, width, height);
            videoView7.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, height+VIDEOGRIDVIEW_GAP, width, height);
            videoView8.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*3, height+VIDEOGRIDVIEW_GAP, width, height);
            videoView9.frame = CGRectMake(0, (height+VIDEOGRIDVIEW_GAP)*2, width, height);
            videoView10.frame = CGRectMake(width+VIDEOGRIDVIEW_GAP, (height+VIDEOGRIDVIEW_GAP)*2, width, height);
            videoView11.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*2, (height+VIDEOGRIDVIEW_GAP)*2, width, height);
            videoView12.frame = CGRectMake((width+VIDEOGRIDVIEW_GAP)*3, (height+VIDEOGRIDVIEW_GAP)*2, width, height);
            videoView13.frame = CGRectMake(0, (height+VIDEOGRIDVIEW_GAP)*3, width, height);
        }
            break;

        default:
            break;
    }
}

- (void)clearView
{
    [self bm_removeAllSubviews];
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

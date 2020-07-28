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

@property (nonatomic, strong) NSMutableArray <SCVideoView *> *videoSequenceArr;
@property (nonatomic, strong) NSMutableDictionary *videoViewArrayDic;

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
    
    //横排视频个数
    NSInteger widthNum = 0;
    //竖排视频个数
    NSInteger heightNum = 0;
    
    switch (self.videoSequenceArr.count)
    {
        case 1:
        {
            widthNum = 1;
            heightNum = 1;
        }
            break;

        case 2:
        {
            widthNum = 2;
            heightNum = 1;
        }
            break;
            
        case 3:
        case 4:
        {
            widthNum = 2;
            heightNum = 2;
        }
            break;
            
        case 5:
        case 6:
        {
            widthNum = 3;
            heightNum = 2;
        }
            break;

        case 7:
        case 8:
        {
            widthNum = 4;
            heightNum = 2;
        }
            break;
        case 9:
        {
            if ([UIDevice bm_isiPad])
            {
                widthNum = 4;
                heightNum = 3;
            }
            else
            {
                widthNum = 3;
                heightNum = 3;
            }
        }
            break;
        case 10:
        case 11:
        case 12:
        {
            widthNum = 4;
            heightNum = 3;
        }
            break;

        case 13:
        case 14:
        case 15:
        {
            widthNum = 5;
            heightNum = 3;
        }
            break;
        case 16:
        case 17:
        case 18:
        {
            widthNum = 6;
            heightNum = 3;
        }
            break;
        case 19:
        case 20:
        case 21:
        case 22:
        case 23:
        case 24:
        case 25:
        {
            widthNum = 7;
            heightNum = 4;
        }
            break;
        default:
            break;
    }

    width = videoWidth * widthNum;
    height = videoHeight * heightNum;

    if (width == 0 || height == 0)
    {
        scale = 1.0f;
        bgWidth = 0;
        bgHeight = 0;
    }
    else
    {
        CGFloat widthScale = (maxWidth - VIDEOGRIDVIEW_GAP/2 * (widthNum - 1))/width;
        CGFloat heightScale = (maxHeight - VIDEOGRIDVIEW_GAP/2 * (heightNum - 1))/height;
        
        scale = MIN(widthScale, heightScale);
        
        bgWidth = width*scale + VIDEOGRIDVIEW_GAP/2 * (widthNum - 1);
        bgHeight = height*scale + VIDEOGRIDVIEW_GAP /2 * (heightNum - 1);
    }
    
    self.videoWidth = videoWidth*scale;
    self.videoHeight = videoHeight*scale;

    self.videosBgView.bm_width = bgWidth;
    self.videosBgView.bm_height = bgHeight;
    
    CGPoint center = CGPointMake(self.bm_width * 0.5, maxHeight * 0.5 + VIDEOGRIDVIEW_GAP);
    self.videosBgView.center = center;
}

- (void)freshViewWithVideoViewArray:(NSMutableArray<SCVideoView *> *)videoSequenceArr withFouceVideo:(nullable SCVideoView *)fouceVideo withRoomLayout:(YSRoomLayoutType)roomLayout withAppUseTheType:(YSRoomUseType)appUseTheType
{
    self.videoSequenceArr = videoSequenceArr;
    
    [self clearView];
    
    if (roomLayout == YSRoomLayoutType_FocusLayout)
    {
        if (appUseTheType == YSRoomUseTypeSmallClass)
        {
            self.videosBgView.backgroundColor = YSSkinDefineColor(@"defaultBgColor");
            
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
    }
    else
    {
        self.videosBgView.backgroundColor = [UIColor clearColor];
        [self changeFrame];

           for (SCVideoView *videoView in self.videoSequenceArr)
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
    
    NSInteger count = self.videoSequenceArr.count;
    
    if (count == 1)
    {
        SCVideoView *videoView = self.videoSequenceArr[0];
        
        videoView.bm_top = 0;
        videoView.bm_left = 0;
    }
    else if (count == 2)
    {
        SCVideoView *videoView1 = self.videoSequenceArr[0];
        SCVideoView *videoView2 = self.videoSequenceArr[1];
        
        videoView1.bm_top = 0;
        videoView1.bm_left = 0;
        
        videoView2.bm_top = 0;
        videoView2.bm_left = width;
    }
    else if (count == 3)
    {
        SCVideoView *videoView1 = self.videoSequenceArr[0];
        SCVideoView *videoView2 = self.videoSequenceArr[1];
        SCVideoView *videoView3 = self.videoSequenceArr[2];
        
        videoView1.bm_top = 0;
        videoView1.bm_left = (self.videosBgView.bm_width - self.videoWidth)*0.5f;
        
        videoView2.bm_top = height;
        videoView2.bm_left = 0;
        
        videoView3.bm_top = height;
        videoView3.bm_left = width;
    }
    else if (count == 4)
    {
        for (int i = 0; i < count; i++)
        {
            SCVideoView *videoView = self.videoSequenceArr[i];
            
            videoView.bm_top = (i / 2) * height;
            videoView.bm_left = (i % 2) * width;
        }
    }
    else if (count == 5)
    {

        CGFloat left = (self.videosBgView.bm_width - self.videoWidth * 2 + VIDEOGRIDVIEW_GAP/2) * 0.5f;
        
        for (int i = 0; i < count; i++)
        {
            SCVideoView *videoView = self.videoSequenceArr[i];
            if (i < 2)
            {
                videoView.bm_top = 0;
                videoView.bm_left = left + (i % 2) * width;
            }
            else
            {
                videoView.bm_top = height;
                videoView.bm_left = ((i - 2) % 3) * width;
            }
        }
    }
    else if (count == 6)
    {
        for (int i = 0; i < count; i++)
        {
            SCVideoView *videoView = self.videoSequenceArr[i];
            
            videoView.bm_top = (i / 3) * height;
            videoView.bm_left = (i % 3) * width;
        }
    }
    else if (count == 7 || count == 8)
    {
        for (int i = 0; i < count; i++)
        {
            SCVideoView *videoView = self.videoSequenceArr[i];
            
            videoView.bm_top = (i / 4) * height;
            videoView.bm_left = (i % 4) * width;
        }
    }
    else  if (count > 8 && count<13)
    {
        if ([UIDevice bm_isiPad])
        {
            if (count == 9 || count == 10 || count == 11 || count == 12)
            {
                for (int i = 0; i < count; i++)
                {
                    SCVideoView *videoView = self.videoSequenceArr[i];
                    
                    videoView.bm_top = (i / 4) * height;
                    videoView.bm_left = (i % 4) * width;
                }
            }
        }
        else
        {
            if (count == 9)
            {
                for (int i = 0; i < self.videoSequenceArr.count; i++)
                {
                    SCVideoView *videoView = self.videoSequenceArr[i];
                    
                    videoView.bm_top = (i / 3) * height;
                    videoView.bm_left = (i % 3) * width;
                }
            }
            else if (count == 10 || count == 11 || count == 12)
            {
                for (int i = 0;i < self.videoSequenceArr.count;i++)
                {
                    SCVideoView *videoView = self.videoSequenceArr[i];
                    
                    videoView.bm_top = (i / 4) * height;
                    videoView.bm_left = (i % 4) * width;
                }
            }
        }
    }
    else if (count == 13 || count == 14 || count == 15)
    {
        for (int i = 0;i<self.videoSequenceArr.count;i++)
        {
            SCVideoView *videoView = self.videoSequenceArr[i];
            
            videoView.bm_top = (i/5) * height;
            videoView.bm_left = (i%5) * width;
        }
    }
    else if (count == 16 || count == 17 || count == 18)
    {
        for (int i = 0;i<self.videoSequenceArr.count;i++)
        {
            SCVideoView *videoView = self.videoSequenceArr[i];
            
            videoView.bm_top = (i / 6) * height;
            videoView.bm_left = (i % 6) * width;
        }
    }
    else
    {
        for (int i = 0;i<self.videoSequenceArr.count;i++)
        {
            SCVideoView *videoView = self.videoSequenceArr[i];
            
            videoView.bm_top = (i / 7) * height;
            videoView.bm_left = (i % 7) * width;
        }
    }
}

#pragma mark - 焦点布局（25路视频）

//计算各控件的尺寸
- (void)changeFrameFocus
{
    self.videosBgView.frame = self.bounds;
    
    self.videoHeight = (self.bm_height - 5 * VIDEOGRIDVIEW_GAP/2 - VIDEOGRIDVIEW_GAP)/6;
    
    if (self.isWideScreen)
    {
        self.videoWidth = ceil(self.videoHeight * 16 / 9);
    }
    else
    {
        self.videoWidth = ceil(self.videoHeight * 4 / 3);
    }
    
    self.rightBgHeight = self.bm_height;
    
    if (self.videoSequenceArr.count < 2)
    {
        self.rightBgWidth = 0.0;
    }
    else if (self.videoSequenceArr.count < 8)
    {
        self.rightBgWidth = self.videoWidth;
    }
    else if (self.videoSequenceArr.count < 14)
    {
        self.rightBgWidth = 2 * self.videoWidth + VIDEOGRIDVIEW_GAP/2;
    }
    else if (self.videoSequenceArr.count < 20)
    {
        self.rightBgWidth = 3 * self.videoWidth + 2 * VIDEOGRIDVIEW_GAP/2;
    }
    else
    {
        self.rightBgWidth = 4 * self.videoWidth + 3 * VIDEOGRIDVIEW_GAP/2;
    }
        
    [self.videosBgView addSubview:self.rightVideoBgView];
}


//布局
- (void)freshViewFocusWithFouceVideo:(SCVideoView *)fouceVideo
{
    CGFloat width = self.videoWidth + VIDEOGRIDVIEW_GAP/2;
    CGFloat height = self.videoHeight + VIDEOGRIDVIEW_GAP/2;

    NSMutableArray * mutArray = [NSMutableArray arrayWithArray:self.videoSequenceArr];
    
    if (mutArray.count > 0)
    {
        CGFloat maxWidth = self.defaultSize.width - VIDEOGRIDVIEW_GAP - self.rightBgWidth;
        CGFloat maxHeight = self.defaultSize.height - VIDEOGRIDVIEW_GAP;
        
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
        
        CGFloat widthScale = maxWidth / videoWidth;
        CGFloat heightScale = maxHeight / videoHeight;
        
        CGFloat scale = MIN(widthScale, heightScale);
        CGFloat bgWidth = videoWidth*scale;
        CGFloat bgHeight = videoHeight*scale;
        
        fouceVideo.frame = CGRectMake((self.defaultSize.width - bgWidth - VIDEOGRIDVIEW_GAP - self.rightBgWidth)/2, (maxHeight-bgHeight)/2+VIDEOGRIDVIEW_GAP, bgWidth, bgHeight);
        
        if (mutArray.count < 2)
        {
            self.rightVideoBgView.hidden = YES;
        }
        else
        {
            self.rightVideoBgView.hidden = NO;
            self.rightVideoBgView.frame = CGRectMake(fouceVideo.bm_right + VIDEOGRIDVIEW_GAP, 0, self.rightBgWidth, self.rightBgHeight);
        }

        [mutArray removeObject:fouceVideo];
    }
    
    CGFloat left = self.rightVideoBgView.bm_originX;
        
    for (int i = 0; i < mutArray.count; i++)
    {
        SCVideoView *videoView = mutArray[i];
        if (i < 6)
        {
            videoView.bm_top = i * height + VIDEOGRIDVIEW_GAP/2;
            videoView.bm_left = left;
        }
        else if (i < 12)
        {
            videoView.bm_top = (i - 6) * height + VIDEOGRIDVIEW_GAP/2;
            videoView.bm_left = left + width;
        }
        else if (i < 18)
        {
            videoView.bm_top = (i - 12) * height + VIDEOGRIDVIEW_GAP/2;
            videoView.bm_left = left + 2 * width;
        }
        else if (i < 24)
        {
            videoView.bm_top = (i - 18) * height + VIDEOGRIDVIEW_GAP/2;
            videoView.bm_left = left + 3 * width;
        }
    }
}

- (void)clearView
{
    [self.videosBgView bm_removeAllSubviews];
}

@end

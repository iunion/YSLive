//
//  YSMediaMarkView.m
//  YSLive
//
//  Created by jiang deng on 2019/11/18.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSMediaMarkView.h"
#import "YSLiveManager.h"
#import "YSLiveUtil.h"

@interface YSMediaMarkView ()
<
    YSDrawViewDelegate
>

// 画板
@property (nonatomic, strong) YSDrawView *drawView;

@property (nonatomic, assign) CGFloat videoRatio;

//// 退出
//@property (nonatomic, strong) UIButton *exitBtn;
//// 擦除
//@property (nonatomic, strong) UIButton *eraserBtn;
//
//// undo/redo
//@property (nonatomic, strong) NSMutableArray *recoveryArray;

@end

@implementation YSMediaMarkView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        [self setupTools];
    }
    return self;
}

- (void)setupTools
{
    YSDrawView *drawView = [[YSDrawView alloc] initWithDelegate:self];
    [self addSubview:drawView];
    //drawView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //drawView.delegate = self;
    [drawView switchToFileID:YSSignaling_VideoWhiteboard_Id pageID:1 refreshImmediately:YES];
    self.drawView = drawView;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGFloat width;
    CGFloat height;
    if (self.videoRatio > 0)
    {
        width = self.bm_height*self.videoRatio;
        if (width < self.bm_width)
        {
            height = self.bm_height;
        }
        else
        {
            width = self.bm_width;
            height = width/self.videoRatio;
        }
        
        self.drawView.bm_size = CGSizeMake(width, height);
        [self.drawView bm_centerInSuperView];
    }
    else
    {
        self.drawView.frame = self.bounds;
    }
}

- (void)freshViewWithSavedSharpsData:(NSArray <NSDictionary *> *)sharpsDataArray videoRatio:(CGFloat)videoRatio
{
    if (self.superview)
    {
        self.frame = self.superview.bounds;
    }
    
    self.videoRatio = videoRatio;
    
    CGFloat width;
    CGFloat height;

    if (self.videoRatio > 0)
    {
        width = self.bm_height*self.videoRatio;
        if (width < self.bm_width)
        {
            height = self.bm_height;
        }
        else
        {
            width = self.bm_width;
            height = width/self.videoRatio;
        }
        
        self.drawView.bm_size = CGSizeMake(width, height);
        [self.drawView bm_centerInSuperView];
        
        [self.drawView switchToFileID:YSSignaling_VideoWhiteboard_Id pageID:1 refreshImmediately:YES];
        //[self.drawView addDrawData:data refreshImmediately:YES];
    }
    else
    {
        self.drawView.frame = self.bounds;
    }
    
    for (NSDictionary *dic in sharpsDataArray)
    {
        [self.drawView addDrawData:dic refreshImmediately:YES];
    }
}

- (void)freshViewWithData:(NSDictionary *)data savedSharpsData:(NSArray <NSDictionary *> *)sharpsDataArray
{
    if (![data bm_isNotEmptyDictionary])
    {
        return;
    }
    
    for (NSDictionary *dic in sharpsDataArray)
    {
        [self.drawView addDrawData:dic refreshImmediately:YES];
    }
    
    [self.drawView addDrawData:data refreshImmediately:YES];
}

//- (void)didMoveToSuperview
//{
//    [self freshView];
//}


#pragma mark -
#pragma mark YSDrawViewDelegate

- (void)addSharpWithFileID:(NSString *)fileid shapeID:(NSString *)shapeID shapeData:(NSData *)shapeData
{
    if ([YSLiveManager shareInstance].localUser.role != YSUserType_Teacher)
    {
        return;
    }
    
    NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:shapeData options:NSJSONReadingMutableContainers error:nil];
    
    [dic setObject:self.drawView.fileid forKey:@"whiteboardID"];
    [dic setObject:@(false) forKey:@"isBaseboard"];
    
    [dic setObject:[YSLiveManager shareInstance].localUser.nickName forKey:@"nickname"];
    
    NSData *newData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *data = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
    NSString *dataString = [data stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    [[YSLiveManager shareInstance].roomManager pubMsg:sSharpsChange msgID:shapeID toID:YSRoomPubMsgTellAll data:dataString save:YES associatedMsgID:sVideoWhiteboard associatedUserID:nil expires:0 completion:nil];
}

- (void)handleSignal:(NSDictionary *)dictionary isDel:(BOOL)isDel
{
    if (![dictionary bm_isNotEmptyDictionary])
    {
        return;
    }
    
    // 信令相关性
//    NSString *associatedMsgID = [dictionary objectForKey:sAssociatedMsgID];
    
    // 信令名
    NSString *msgName = [dictionary objectForKey:sName];
    
    // 信令内容
    id dataObject = [dictionary objectForKey:@"data"];
    NSDictionary *data = [YSLiveUtil convertWithData:dataObject];
    if (![data bm_isNotEmptyDictionary])
    {
        return;
    }

    if ([msgName isEqualToString:sVideoWhiteboard])
    {
        if (!isDel)
        {
            CGFloat videoRatio = [data bm_doubleForKey:@"videoRatio"];
            self.videoRatio = videoRatio;
            return;
        }
        
        //MARK: 视频标注绘制
        NSString *whiteboardID = [data bm_stringTrimForKey:@"whiteboardID"];
        if ([whiteboardID isEqualToString:@"videoDrawBoard"])
        {
            [self.drawView switchToFileID:whiteboardID pageID:1 refreshImmediately:YES];
            [self.drawView addDrawData:data refreshImmediately:YES];
            return;
        }
    }
}

@end

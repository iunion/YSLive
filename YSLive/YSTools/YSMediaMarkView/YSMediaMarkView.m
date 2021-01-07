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

#import <CloudHubWhiteBoardKit/CHDrawView.h>

@interface YSMediaMarkView ()
//<
//    CHDrawViewDelegate
//>


@property (nonatomic, strong) NSString *fileId;

// 画板
@property (nonatomic, strong) CHDrawView *drawView;

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

- (instancetype)initWithFrame:(CGRect)frame fileId:(NSString *)fileId
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.fileId = fileId;
        
        [self setupTools];
    }
    return self;
}

- (void)setupTools
{
    CloudHubWhiteBoardConfig *whiteBoardConfig = [YSLiveManager sharedInstance].whiteBoardManager.cloudHubWhiteBoardKit.cloudHubWhiteBoardConfig;
    CHDrawView *drawView = [[CHDrawView alloc] initWithWhiteBoardId:sCHSignal_VideoWhiteboard_Id whiteBoardConfig:whiteBoardConfig];
    [self addSubview:drawView];
    //drawView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [drawView switchToFileId:self.fileId pageNum:1 updateImmediately:YES];
    
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

- (void)setVideoRatio:(CGFloat)videoRatio
{
    _videoRatio = videoRatio;
    
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
    self.videoRatio = videoRatio;

    [self.drawView switchToFileId:self.fileId pageNum:1 updateImmediately:YES];

    for (NSDictionary *dic in sharpsDataArray)
    {
        NSString *fromId = [dic objectForKey:@"fromID"];
        BOOL isFromMyself = [fromId isEqualToString:[CHSessionManager sharedInstance].localUser.peerID];
        
        [self.drawView addDrawSharpData:dic authorUserId:@"" seq:0 isRedo:NO isFromMyself:isFromMyself isUpdate:YES];
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
        NSString *fromId = [dic objectForKey:@"fromID"];
        BOOL isFromMyself = [fromId isEqualToString:[CHSessionManager sharedInstance].localUser.peerID];

        [self.drawView addDrawSharpData:dic authorUserId:@"" seq:0 isRedo:NO isFromMyself:isFromMyself isUpdate:YES];
    }
    
    NSString *fromId = [data objectForKey:@"fromID"];
    BOOL isFromMyself = [fromId isEqualToString:[CHSessionManager sharedInstance].localUser.peerID];

    [self.drawView addDrawSharpData:data authorUserId:@"" seq:0 isRedo:NO isFromMyself:isFromMyself isUpdate:YES];
}

//- (void)didMoveToSuperview
//{
//    [self freshView];
//}


#pragma mark -
#pragma mark YSDrawViewDelegate

- (void)addSharpWithFileID:(NSString *)fileid shapeID:(NSString *)shapeID shapeData:(NSData *)shapeData
{
    if ([YSLiveManager sharedInstance].localUser.role != CHUserType_Teacher)
    {
        return;
    }
    
    NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:shapeData options:NSJSONReadingMutableContainers error:nil];
    
    NSString *whiteboardID = [CHWhiteBoardUtil getwhiteboardIdFromFileId:self.drawView.fileId];
    [dic setObject:whiteboardID forKey:@"whiteboardID"];
    [dic setObject:@(false) forKey:@"isBaseboard"];
    
    [dic setObject:[YSLiveManager sharedInstance].localUser.nickName forKey:@"nickname"];
    
//    NSData *newData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
//    NSString *data = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
//    NSString *dataString = [data stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//
//    [[YSRoomInterface instance] pubMsg:sYSSignalSharpsChange msgID:shapeID toID:YSRoomPubMsgTellAll data:dataString save:YES associatedMsgID:sYSSignalVideoWhiteboard associatedUserID:nil expires:0 completion:nil];
    [[YSLiveManager sharedInstance] pubMsg:sCHWBSignal_SharpsChange msgId:shapeID to:CHRoomPubMsgTellAll withData:dic associatedWithUser:nil associatedWithMsg:sCHSignal_VideoWhiteboard save:YES];
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
    NSString *msgName = [dictionary objectForKey:@"name"];
    
    // 信令内容
    id dataObject = [dictionary objectForKey:@"data"];
    NSDictionary *data = [BMCloudHubUtil convertWithData:dataObject];
    if (![data bm_isNotEmptyDictionary])
    {
        return;
    }

    if ([msgName isEqualToString:sCHSignal_VideoWhiteboard])
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
            NSString *fromId = [dictionary objectForKey:@"fromID"];
            BOOL isFromMyself = [fromId isEqualToString:[CHSessionManager sharedInstance].localUser.peerID];
            
            [self.drawView switchToFileId:whiteboardID pageNum:1 updateImmediately:YES];

            [self.drawView addDrawSharpData:data authorUserId:@"" seq:0 isRedo:NO isFromMyself:isFromMyself isUpdate:YES];
            return;
        }
    }
}

@end

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
        [self doSharpData:dic];
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
        [self doSharpData:dic];
    }
    
    [self doSharpData:data];
}

- (void)doSharpData:(NSDictionary *)dictionary
{
    NSString *userId = [dictionary bm_stringForKey:@"fromId"];
    NSUInteger seq = [dictionary bm_uintForKey:@"seq"];

    NSDictionary *shapeDic = [dictionary bm_dictionaryForKey:@"data"];
    
    BOOL isFromMyself = [userId isEqualToString:CHLocalUser.peerID];
    
    if (![userId bm_isNotEmpty] || ![shapeDic bm_isNotEmptyDictionary])
    {
        return;
    }
    
    CHDrawEvent eventType = CHDrawEventUnknown;
    
    NSString *actionName = nil;
    NSString *actionId = nil;
    NSString *eventTypeString = nil;
    NSString *toAuthorUserId = nil;
    
    eventTypeString = [shapeDic bm_stringForKey:@"eventType"];
    // 课件消息
    if (![eventTypeString bm_isNotEmpty])
    {
        return;
    }
    
    if ([eventTypeString isEqualToString:@"shapeSaveEvent"])
    {
        eventType = CHDrawEventShapeAdd;
    }
    else if ([eventTypeString isEqualToString:@"undoEvent"])
    {
        eventType = CHDrawEventShapeUndo;
    }
    else if ([eventTypeString isEqualToString:@"redoEvent"])
    {
        eventType = CHDrawEventShapeRedo;
    }
    else if ([eventTypeString isEqualToString:@"clearEvent"])
    {
        eventType = CHDrawEventShapeClean;
    }
    else if ([eventTypeString isEqualToString:@"selectedShapesMoved"])
    {
        eventType = CHDrawEventShapeMove;
    }
    else if ([eventTypeString isEqualToString:@"deleteSelectedShapes"])
    {
        eventType = CHDrawEventShapeDelete;
    }
    
    if (eventType == CHDrawEventUnknown)
    {
        return;
    }
    
    // 绘制消息
    actionName = [shapeDic bm_stringForKey:@"actionName"];
    actionId = [shapeDic bm_stringForKey:@"actionId"];
    if (![actionId bm_isNotEmpty])
    {
        actionId = [shapeDic bm_stringForKey:@"clearActionId"];
    }
    if ([actionId bm_isNotEmpty])
    {
        toAuthorUserId = [shapeDic bm_stringForKey:@"toAuthorUserId"];
        NSDictionary *otherInfo = [shapeDic bm_dictionaryForKey:@"otherInfo"];
        if ([otherInfo bm_isNotEmptyDictionary])
        {
            userId = [otherInfo bm_stringForKey:@"authorUserId"];
            seq = [otherInfo bm_uintForKey:@"seq"];
            toAuthorUserId = [otherInfo bm_stringForKey:@"toAuthorUserId"];
        }
    }
    
    switch (eventType)
    {
        case CHDrawEventShapeAdd:
        {
            if ([actionName isEqualToString:@"ClearAction"])
            {
                if ([actionId bm_isNotEmpty])
                {
                    // 恢复清空
                    [self.drawView handleClearDrawWithClearId:actionId authorUserId:userId seq:seq toAuthorUserId:toAuthorUserId isRedo:YES isFromMyself:isFromMyself];
                }
            }
            else if ([actionName isEqualToString:@"ShapesMoveAction"])
            {
                
            }
            else if ([actionName isEqualToString:@"DelSelectedShapesAction"])
            {
                if ([actionId bm_isNotEmpty])
                {
                    NSArray *deleteShapeIds = [shapeDic bm_arrayForKey:@"delIds"];
                    [self.drawView handleDeleteDrawWithDeleteId:actionId authorUserId:userId seq:seq toAuthorUserId:toAuthorUserId isRedo:YES deleteShapeIdsArray:deleteShapeIds isFromMyself:isFromMyself];
                }
            }
            else if ([actionName isEqualToString:@"AddShapeAction"])
            {
                [self.drawView addDrawSharpData:shapeDic authorUserId:userId seq:seq isRedo:NO isFromMyself:isFromMyself isUpdate:YES];
            }
        }
            break;
            
        case CHDrawEventShapeClean:
        {
            if ([actionId bm_isNotEmpty])
            {
                [self.drawView handleClearDrawWithClearId:actionId authorUserId:userId seq:seq toAuthorUserId:toAuthorUserId isRedo:NO isFromMyself:isFromMyself];
            }
        }
            break;
            
        case CHDrawEventShapeMove:
        {
            NSDictionary *moveShapesDic = [shapeDic bm_dictionaryForKey:@"posInfos"];
            if ([moveShapesDic bm_isNotEmptyDictionary] && [actionId bm_isNotEmpty])
            {
                [self.drawView handleMoveDrawWithMoveId:actionId authorUserId:userId seq:seq toAuthorUserId:toAuthorUserId isRedo:NO moveShapesDic:moveShapesDic isFromMyself:isFromMyself];
            }
            break;
        }
            
        case CHDrawEventShapeDelete:
        {
            NSArray *deleteShapeIds = [shapeDic bm_arrayForKey:@"delIds"];
            if ([deleteShapeIds bm_isNotEmpty] && [actionId bm_isNotEmpty])
            {
                [self.drawView handleDeleteDrawWithDeleteId:actionId authorUserId:userId seq:seq toAuthorUserId:toAuthorUserId isRedo:NO deleteShapeIdsArray:deleteShapeIds isFromMyself:isFromMyself];
            }
            break;
        }

        case CHDrawEventShapeUndo:
        {
            if ([actionName isEqualToString:@"ClearAction"])
            {
                if ([actionId bm_isNotEmpty])
                {
                    [self.drawView handleUndoDrawWithClearId:actionId];
                }
            }
            else if ([actionName isEqualToString:@"ShapesMoveAction"])
            {
                if ([actionId bm_isNotEmpty])
                {
                    [self.drawView handleUndoDrawWithMoveId:actionId];
                }
            }
            else if ([actionName isEqualToString:@"DelSelectedShapesAction"])
            {
                if ([actionId bm_isNotEmpty])
                {
                    [self.drawView handleUndoDrawWithDeleteId:actionId];
                }
            }
            else if ([actionName isEqualToString:@"AddShapeAction"])
            {
                NSString *shapeId = [shapeDic bm_stringForKey:@"shapeId"];
                if ([shapeId bm_isNotEmpty])
                {
                    [self.drawView handleUndoDrawWithShapeId:shapeId];
                }
            }
            break;
        }
            
        case CHDrawEventShapeRedo:
        {
            if ([actionName isEqualToString:@"ClearAction"])
            {
                if ([actionId bm_isNotEmpty])
                {
                    [self.drawView handleClearDrawWithClearId:actionId authorUserId:userId seq:seq toAuthorUserId:toAuthorUserId isRedo:YES isFromMyself:isFromMyself];
                }
            }
            else if ([actionName isEqualToString:@"ShapesMoveAction"])
            {
                if ([actionId bm_isNotEmpty])
                {
                    NSDictionary *moveShapesDic = [shapeDic bm_dictionaryForKey:@"posInfos"];
                    if ([moveShapesDic bm_isNotEmptyDictionary] && [actionId bm_isNotEmpty])
                    {
                        [self.drawView handleMoveDrawWithMoveId:actionId authorUserId:userId seq:seq toAuthorUserId:toAuthorUserId isRedo:YES moveShapesDic:moveShapesDic isFromMyself:isFromMyself];
                    }
                }
            }
            else if ([actionName isEqualToString:@"DelSelectedShapesAction"])
            {
                if ([actionId bm_isNotEmpty])
                {
                    NSArray *deleteShapeIds = [shapeDic bm_arrayForKey:@"delIds"];
                    [self.drawView handleDeleteDrawWithDeleteId:actionId authorUserId:userId seq:seq toAuthorUserId:toAuthorUserId isRedo:NO deleteShapeIdsArray:deleteShapeIds isFromMyself:isFromMyself];
                }
            }
            else if ([actionName isEqualToString:@"AddShapeAction"])
            {
                [self.drawView addDrawSharpData:shapeDic authorUserId:userId seq:seq isRedo:YES isFromMyself:isFromMyself isUpdate:YES];
            }
            
            break;
        }
            
        default:
            break;
    }
}

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

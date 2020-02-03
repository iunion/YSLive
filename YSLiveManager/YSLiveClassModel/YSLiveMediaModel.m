//
//  YSLiveMediaModel.m
//  YSLive
//
//  Created by jiang deng on 2019/10/29.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSLiveMediaModel.h"

@implementation YSLiveMediaModel

+ (instancetype)mediaModelWithDic:(NSDictionary *)dic
{
    if (![dic bm_isNotEmptyDictionary])
    {
        return nil;
    }
    
    NSString *fileId = [dic bm_stringTrimForKey:@"fileid"];
    if (![fileId bm_isNotEmpty])
    {
        return nil;
    }
    
    YSLiveMediaModel *mediaModel = [[YSLiveMediaModel alloc] init];
    [mediaModel updateWithDic:dic];
    
    if ([mediaModel.fileid bm_isNotEmpty])
    {
        return mediaModel;
    }
    else
    {
        return nil;
    }
}

- (void)updateWithDic:(NSDictionary *)dic
{
    if (![dic bm_isNotEmptyDictionary])
    {
        return;
    }
    
    // id不存在不修改
    
    // 文件Id
    NSString *fileid = [dic bm_stringTrimForKey:@"fileid"];
    if (![fileid bm_isNotEmpty])
    {
        return;
    }
    self.fileid = fileid;

    // 文件名
    self.filename = [dic bm_stringTrimForKey:@"filename"];

    // 音频
    self.audio = [dic bm_boolForKey:@"audio"];
    // 视频
    self.video = [dic bm_boolForKey:@"video"];

    self.width = [dic bm_doubleForKey:@"width"];
    self.height = [dic bm_doubleForKey:@"height"];
}

@end

//
//  YSLiveMediaModel.h
//  YSLive
//
//  Created by jiang deng on 2019/10/29.
//  Copyright © 2019 FS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSLiveMediaModel : NSObject

// Id
@property (nonatomic, strong) NSString *fileid;
// 文件名
@property (nonatomic, strong) NSString *filename;


// 音频
@property (nonatomic, assign) BOOL audio;
// 视频
@property (nonatomic, assign) BOOL video;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong) NSString *user_peerId;

+ (nullable instancetype)mediaModelWithDic:(NSDictionary *)dic;
- (void)updateWithDic:(NSDictionary *)dic;


//    {
//        audio = 1;
//        duration = 64513;
//        fileid = 66;
//        filename = "\U7f8e\U5973\U5e26\U7237\U7237\U62cd\U5c0f\U89c6\U9891\Uff0c\U6ca1\U60f3\U5230\U610f\U5916\U706b\U4e86\Uff0c\U80cc\U540e\U771f\U76f8\U8ba9\U4eba\U6cea\U76ee_\U597d\U770b\U89c6\U9891.mp4";
//        height = 360;
//        pauseWhenOver = 0;
//        source = mediaFileList;
//        type = media;
//        vcodec = 0;
//        video = 1;
//        width = 640;
//    }


@end

NS_ASSUME_NONNULL_END

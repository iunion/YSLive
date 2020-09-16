//
//  CHWhiteBoardUtil.h
//  CHWhiteBoard
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CHWhiteBoardUtil : NSObject

+ (NSString *)getFileIdFromSourceInstanceId:(NSString *)sourceInstanceId;
+ (NSString *)getSourceInstanceIdFromFileId:(NSString *)fileId;
+ (NSString *)getwhiteboardIDFromFileId:(NSString *)fileId;

+ (int)pubWhiteBoardMsg:(NSString *)msgName
                  msgID:(NSString *)msgID
                   data:(NSDictionary * _Nullable)dataDic
          extensionData:(NSDictionary * _Nullable)extensionData
        associatedMsgID:(NSString * _Nullable)associatedMsgID;

+ (int)delWhiteBoardMsg:(NSString *)msgName
                  msgID:(NSString *)msgID
                   data:(NSObject * _Nullable)data;

+ (NSString *)absoluteFileUrl:(NSString*)fileUrl withServerDic:(NSDictionary *)serverDic;

+ (NSString *)change_WithUserId:(NSString *)userId;
+ (NSString *)unchange_WithUserId:(NSString *)userId;

@end

NS_ASSUME_NONNULL_END

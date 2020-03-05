//
//  YSLiveManager+message.m
//  YSLive
//
//  Created by jiang deng on 2019/10/24.
//Copyright © 2019 FS. All rights reserved.
//

#import "YSLiveManager.h"
#import "YSChatMessageModel.h"

@implementation YSLiveManager (message)

#pragma mark -
#pragma mark Message

- (BOOL)sendMessageWithText:(NSString *)message withMessageType:(YSChatMessageType)messageType withMemberModel:(YSRoomUser *)memberModel
{
    if ([message bm_isNotEmpty])
    {
        NSTimeInterval timeInterval = self.tCurrentTime;
        NSString *time = [NSDate bm_stringFromTs:timeInterval formatter:@"HH:mm"];
        NSString *messageId = [NSString stringWithFormat:@"chat_%@_%@", self.localUser.peerID, @((NSUInteger)(timeInterval))];
        NSString *toUserNickname = @"";
        NSString *toUserID = @"";
        if ([memberModel.peerID bm_isNotEmpty]) {
            toUserNickname = memberModel.nickName;
            toUserID = memberModel.peerID;
        }
        NSString *msgtype = @"text";
        if (messageType == YSChatMessageTypeText)
        {
            msgtype = @"text";
        }
        else if(messageType == YSChatMessageTypeOnlyImage)
        {
            msgtype = @"onlyimg";
        }

        NSString *senderId = self.localUser.peerID;
        NSNumber *role = @(self.localUser.role);
        NSString *nickname = self.localUser.nickName;
        
        NSMutableDictionary *messageDic = [[NSMutableDictionary alloc] init];
        // 0 消息
        [messageDic setObject:@(0) forKey:@"type"];
        [messageDic setObject:time forKey:@"time"];
        [messageDic setObject:@(timeInterval) forKey:@"timeInterval"];
        [messageDic setObject:messageId forKey:@"id"];
        [messageDic setObject:toUserNickname forKey:@"toUserNickname"];
        [messageDic setObject:toUserID forKey:@"toUserID"];
        [messageDic setObject:msgtype forKey:@"msgtype"];
        NSDictionary *senderDic = @{ @"id" : senderId, @"role" : role, @"nickname" : nickname };
        [messageDic setObject:senderDic forKey:@"sender"];

        if (![memberModel.peerID bm_isNotEmpty] || [memberModel.peerID isEqualToString:@"__all"])
        {// 群聊
            if ([self.roomManager sendMessage:message toID:YSRoomPubMsgTellAll extensionJson:messageDic] == 0)
            {
                return YES;
            }
        }
        else
        {// 私聊
            
            [messageDic setObject:@(true) forKey:@"isToSender"];
            
            if ([self.roomManager sendMessage:message toID:memberModel.peerID extensionJson:messageDic] == 0)
            {
                return YES;
            }
        }
    }
    return NO;
}
/*
 Map<String, Object> msgMap = new HashMap<String, Object>();
 msgMap.put("type", 0);
 msgMap.put("time", time);
 msgMap.put("id", "chat_" + YSRoomManager.getInstance().getMySelf().peerId + "_" + df.format(new Date()));
 msgMap.put("toUserNickname", RoomSession.touserName);
 msgMap.put("toUserID", RoomSession.mSelectedID);
 msgMap.put("msgtype", "text");
 if (!TextUtils.isEmpty(RoomSession.mSelectedID)) {
 msgMap.put("isToSender", true);
 }
 try {
 JSONObject jsonObject = new JSONObject();
 jsonObject.put("id", YSRoomManager.getInstance().getMySelf().peerId);
 jsonObject.put("role", YSRoomManager.getInstance().getMySelf().role);
 jsonObject.put("nickname", YSRoomManager.getInstance().getMySelf().nickName);
 msgMap.put("sender", jsonObject);
 } catch (JSONException e) {
 e.printStackTrace();
 }
 YSRoomManager.getInstance().sendMessage(msg, RoomSession.mSelectedID, msgMap);
 */

// 收到聊天消息
// @param message 聊天消息内容
// @param peerID 发送者用户ID
// @param extension 消息扩展信息（用户昵称、用户角色等等）
- (void)handleMessageReceived:(NSString *)message fromID:(NSString *)peerID extension:(NSDictionary *)extension
{
    if (![message bm_isNotEmpty] || ![peerID bm_isNotEmpty])
    {
        return;
    }
    
    NSDictionary *messageDic = [YSLiveUtil convertWithData:message];
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(handleMessageWith:)])
    {
        BMWeakSelf
        [self.roomManager getRoomUserWithPeerId:peerID callback:^(YSRoomUser * _Nullable user, NSError * _Nullable error)
         {
             if (error)
             {
                 return;
             }
             
             YSChatMessageModel *messageModel = [[YSChatMessageModel alloc] init];
             messageModel.sendUser = user;
             messageModel.receiveUser = nil;
             if ([messageDic bm_containsObjectForKey:@"timeInterval"])
             {
                 messageModel.timeInterval = [messageDic bm_doubleForKey:@"timeInterval"];
             }
             else if ([messageDic bm_containsObjectForKey:@"time"])
             {
                 messageModel.timeStr = [messageDic bm_stringTrimForKey:@"time"];
             }

             // text onlyimg
             if ([[messageDic bm_stringTrimForKey:@"msgtype"] isEqualToString:@"text"])
             {
                 messageModel.chatMessageType = YSChatMessageTypeText;
             }
             else
             {
                 messageModel.chatMessageType = YSChatMessageTypeOnlyImage;
             }
             if (messageModel.chatMessageType == YSChatMessageTypeText)
             {
                 messageModel.message = [messageDic bm_stringTrimForKey:@"msg"];
             }
             else
             {
                 NSString *server = weakSelf.fileServer;
                 NSString *path = [messageDic bm_stringTrimForKey:@"msg"];
                 NSString *baseName = [path stringByDeletingPathExtension];
                 NSString *extension = [path pathExtension];
                 messageModel.imageUrl = [NSString stringWithFormat:@"%@://%@%@-1.%@", YSLive_Http, server, baseName, extension];
             }
             
             NSString *toUserID = [messageDic bm_stringTrimForKey:@"toUserID"];
             if ([toUserID bm_isNotEmpty])
             {
                 [weakSelf.roomManager getRoomUserWithPeerId:toUserID callback:^(YSRoomUser * _Nullable user, NSError * _Nullable error) {
                     if (!error)
                     {
                         messageModel.receiveUser = user;
                         messageModel.isPersonal = YES;
                     }
                     [weakSelf.roomManagerDelegate handleMessageWith:messageModel];
                 }];
             }
             else
             {
                 [weakSelf.roomManagerDelegate handleMessageWith:messageModel];
             }
         }];
    }
    else if ([self.roomManagerDelegate respondsToSelector:@selector(onRoomMessageReceived:fromID:extension:)])
    {
        [self.roomManagerDelegate onRoomMessageReceived:message fromID:peerID extension:extension];
    }
}

// 系统配置提示消息
// @param message 消息内容
// @param peerID 发送者用户ID
// @param tipType 提示类型
- (void)sendTipMessage:(NSString *)message tipType:(YSChatMessageType)tipType
{
    if (![message bm_isNotEmpty])
    {
        return;
    }
    
    if ([self.roomManagerDelegate respondsToSelector:@selector(handleMessageWith:)])
    {
        YSChatMessageModel *messageModel = [[YSChatMessageModel alloc] init];
        messageModel.sendUser = nil;
        messageModel.receiveUser = nil;
        messageModel.timeInterval = self.tCurrentTime;
        messageModel.chatMessageType = tipType;
        messageModel.message = message;

        [self.roomManagerDelegate handleMessageWith:messageModel];
    }
}


#pragma mark -
#pragma mark Question

// 发送提问
- (NSString *)sendQuestionWithText:(NSString *)textMessage
{
    if ([textMessage bm_isNotEmpty])
    {
        NSTimeInterval timeInterval = self.tCurrentTime;
        NSString *time = [NSDate bm_stringFromTs:timeInterval formatter:@"HH:mm"];
        NSString *messageId = [NSString stringWithFormat:@"quiz_%@_%@", self.localUser.peerID, @((NSUInteger)(timeInterval))];
        NSString *toUserNickname = @"";
        NSString *toUserID = @"";
        NSString *msgtype = @"text";
        
        NSString *senderId = self.localUser.peerID;
        NSNumber *role = @(self.localUser.role);
        NSString *nickname = self.localUser.nickName;
        
        NSMutableDictionary *messageDic = [[NSMutableDictionary alloc] init];
        // 1 提问
        [messageDic setObject:@(false) forKey:@"hasPassed"];
        [messageDic setObject:@(1) forKey:@"type"];
        [messageDic setObject:time forKey:@"time"];
        [messageDic setObject:@(timeInterval) forKey:@"timeInterval"];
        [messageDic setObject:messageId forKey:@"id"];
        [messageDic setObject:toUserNickname forKey:@"toUserNickname"];
        [messageDic setObject:toUserID forKey:@"toUserID"];
        [messageDic setObject:msgtype forKey:@"msgtype"];
        NSDictionary *senderDic = @{ @"id" : senderId, @"role" : role, @"nickname" : nickname };
        [messageDic setObject:senderDic forKey:@"sender"];
        
        // 私聊
        //[messageDic setObject:@(true) forKey:@"isToSender"];
        
        if ([self.roomManager sendMessage:textMessage toID:@"__allSuperUsers" extensionJson:messageDic] == 0)
        {
            return messageId;
        }
    }
    
    return nil;
}
/*
 message: "{"msg":"上课了？","type":1,"id":"quiz_1bcf955b-71ce-d2ee-e8b9-6bc6d6e7dfef_1572062001849","time":"11:53","toUserID":"","toUserNickname":"","msgtype":"text","sender":{"id":"1bcf955b-71ce-d2ee-e8b9-6bc6d6e7dfef","role":2,"nickname":"学生"},"hasPassed":false}"

 */

@end

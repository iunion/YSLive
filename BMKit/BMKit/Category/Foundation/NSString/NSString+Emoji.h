//
//  NSString+Emoji.h
//  BMBaseKit
//
//  Created by jiang deng on 2019/7/23.
//Copyright © 2019 BM. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BMEmojizedStringKey         @"emojizedString"
#define BMEmojiRangesKey            @"emojiRanges"
#define BMEmojiLengthChangesKey     @"emojiLengthChanges"

@interface NSString (Emoji)

+ (NSString *)bm_encodeEmojiStringWithString:(NSString *)text;
- (NSString *)bm_encodeEmojiString;

+ (NSDictionary *)bm_decodeEmojiStringWithString:(NSString *)text;
- (NSDictionary *)bm_decodeEmojiString;


@end

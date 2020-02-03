//
//  PTTextAttachment.m
//  PourOutAllTheWay
//
//  Created by SanW on 2016/11/10.
//  Copyright © 2016年 ONON. All rights reserved.
//

#import "PTTextAttachment.h"

@implementation PTTextAttachment
// 返回附件的位置
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    return CGRectMake(0, -4, _emojiSize.width, _emojiSize.height);
}

@end

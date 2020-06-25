//
//  PTTextAttachment.h
//  PourOutAllTheWay
//
//  Created by SanW on 2016/11/10.
//  Copyright © 2016年 ONON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTTextAttachment : NSTextAttachment
/**
 *  图片的名字 作为id
 */
@property (nonatomic, assign) int emojiName;
/// 表情尺寸
@property(nonatomic, assign) CGSize   emojiSize;
@end

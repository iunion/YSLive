//
//  YSTextView.m
//  YSLive
//
//  Created by fzxm on 2020/7/28.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSTextView.h"

@implementation YSTextView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if ([UIMenuController sharedMenuController])
    {
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:NO];
    }
    return YES;
}


@end

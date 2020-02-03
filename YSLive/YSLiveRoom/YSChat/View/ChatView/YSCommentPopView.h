//
//  CommentPopView.h
//  chatDemo01
//
//  Created by app on 16/9/23.
//  Copyright © 2016年 madi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSCommentPopView : UIViewController

@property(nonatomic,strong)NSArray * titleArr;

@property(nonatomic,copy)void(^popoverCellClick)(NSInteger index);

@end

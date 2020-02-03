//
//  YSChatBasicTableViewCell.h
//  YSLive
//
//  Created by 马迪 on 2019/11/1.
//  Copyright © 2019 FS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSChatBasicTableViewCell : UITableViewCell
@property(nonatomic,copy) void(^nickNameBtnClick)(void);
@end

NS_ASSUME_NONNULL_END

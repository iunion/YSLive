//
//  YSSchoolUser.h
//  YSAll
//
//  Created by 宁杰英 on 2020/2/11.
//  Copyright © 2020 YS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSSchoolUser : NSObject
@property (nonatomic, strong)NSString *domain;
@property (nonatomic, strong)NSString *admin_account;
@property (nonatomic, strong)NSString *admin_pwd;
@property (nonatomic, strong)NSDictionary *schoolUser;
+ (instancetype)shareInstance;
@end

NS_ASSUME_NONNULL_END

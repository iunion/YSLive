//
//  YSAppMacros.h
//  YSLiveSample
//
//  Created by 马迪 on 2020/9/2.
//  Copyright © 2020 yunshuxunlian. All rights reserved.
//

#ifndef YSAppMacros_h
#define YSAppMacros_h

#define YSSkinDefineColor(s) [[YSLiveSkinManager shareInstance] getDefaultColorWithType:YSSkinClassOrOnline_class WithKey:(s)]
#define YSSkinDefineImage(s) [[YSLiveSkinManager shareInstance] getDefaultImageWithType:YSSkinClassOrOnline_class WithKey:(s)]

#define YSSkinElementColor(z , s) [[YSLiveSkinManager shareInstance] getElementColorWithType:YSSkinClassOrOnline_class WithName:(z) andKey:(s)]
#define YSSkinElementImage(z , s) [[YSLiveSkinManager shareInstance] getElementImageWithType:YSSkinClassOrOnline_class WithName:(z) andKey:(s)]

#define BMIS_IPHONE4  (CGSizeEqualToSize(CGSizeMake(320.0f, 480.0f), [[UIScreen mainScreen] bounds].size) || CGSizeEqualToSize(CGSizeMake(480.0f, 320.0f), [[UIScreen mainScreen] bounds].size) ? YES : NO)
#define BMIS_IPHONE5  (CGSizeEqualToSize(CGSizeMake(320.0f, 568.0f), [[UIScreen mainScreen] bounds].size) || CGSizeEqualToSize(CGSizeMake(568.0f, 320.0f), [[UIScreen mainScreen] bounds].size) ? YES : NO)
#define BMIS_IPHONE6  (CGSizeEqualToSize(CGSizeMake(375.0f, 667.0f), [[UIScreen mainScreen] bounds].size) || CGSizeEqualToSize(CGSizeMake(667.0f, 375.0f), [[UIScreen mainScreen] bounds].size) ? YES : NO)
#define BMIS_IPHONE6P (CGSizeEqualToSize(CGSizeMake(414.0f, 736.0f), [[UIScreen mainScreen] bounds].size) || CGSizeEqualToSize(CGSizeMake(736.0f, 414.0f), [[UIScreen mainScreen] bounds].size) ? YES : NO)
#define BMIS_IPHONEX  (CGSizeEqualToSize(CGSizeMake(375.0f, 812.0f), [[UIScreen mainScreen] bounds].size) || CGSizeEqualToSize(CGSizeMake(812.0f, 375.0f), [[UIScreen mainScreen] bounds].size) ?  YES : NO)
#define BMIS_IPHONEXP (CGSizeEqualToSize(CGSizeMake(414.0f, 896.0f), [[UIScreen mainScreen] bounds].size) || CGSizeEqualToSize(CGSizeMake(896.0f, 414.0f), [[UIScreen mainScreen] bounds].size) ? YES : NO)

#define BMIS_IPHONEXANDP (BMIS_IPHONEX || BMIS_IPHONEXP)

//iphone
#define BMIS_IPHONE         (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//ipad
#define BMIS_PAD            (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad)


#define BMUI_HOME_INDICATOR_HEIGHT        (BMIS_IPHONEXANDP ? 34.0f : 0.0f)

#endif /* YSAppMacros_h */

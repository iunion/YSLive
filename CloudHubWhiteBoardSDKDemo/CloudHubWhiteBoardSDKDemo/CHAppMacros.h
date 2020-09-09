//
//  CHAppMacros.h
//  CHLiveSample
//
//

#ifndef CHAppMacros_h
#define CHAppMacros_h

#define CHSkinDefineColor(s) [[CHLiveSkinManager shareInstance] getDefaultColorWithType:CHSkinClassOrOnline_class WithKey:(s)]
#define CHSkinDefineImage(s) [[CHLiveSkinManager shareInstance] getDefaultImageWithType:CHSkinClassOrOnline_class WithKey:(s)]

#define CHSkinElementColor(z , s) [[CHLiveSkinManager shareInstance] getElementColorWithType:CHSkinClassOrOnline_class WithName:(z) andKey:(s)]
#define CHSkinElementImage(z , s) [[CHLiveSkinManager shareInstance] getElementImageWithType:CHSkinClassOrOnline_class WithName:(z) andKey:(s)]

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

#endif /* CHAppMacros_h */

//
//  CHLoginMacros.h
//  CHLogin
//
//

#ifndef CHLoginMacros_h
#define CHLoginMacros_h

#define login_UI_SCREEN_WIDTH                 ([[UIScreen mainScreen] bounds].size.width)
#define login_UI_SCREEN_HEIGHT                ([[UIScreen mainScreen] bounds].size.height)

#define login_kScale_W(w) ((login_UI_SCREEN_WIDTH)/375) * (w)
#define login_kScale_H(h) ((login_UI_SCREEN_HEIGHT)/667) * (h)

#define login_UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#define UI_SCREEN_WIDTH                 ([[UIScreen mainScreen] bounds].size.width)
#define UI_SCREEN_HEIGHT                ([[UIScreen mainScreen] bounds].size.height)

#define UI_SCREEN_WIDTH_ROTATE                 ([[UIScreen mainScreen] bounds].size.height)
#define UI_SCREEN_HEIGHT_ROTATE                ([[UIScreen mainScreen] bounds].size.width)


#define CHWeakSelf                  __weak __typeof(self) weakSelf = self;


#define CHS_BUNDLE_NAME      @ "CHResources.bundle"

#define CHSAPP_Localized     [NSBundle bundleWithPath:[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:CHS_BUNDLE_NAME]]

#define CHSLocalized(s)      [CHSAPP_Localized localizedStringForKey:s value:@"" table:nil]


#endif /* CHLoginMacros_h */

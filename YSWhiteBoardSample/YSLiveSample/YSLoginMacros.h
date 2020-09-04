//
//  YSLoginMacros.h
//  YSLogin
//
//  Created by fzxm on 2019/11/26.
//  Copyright © 2019 ysxl. All rights reserved.
//

#ifndef YSLoginMacros_h
#define YSLoginMacros_h

#define login_UI_SCREEN_WIDTH                 ([[UIScreen mainScreen] bounds].size.width)
#define login_UI_SCREEN_HEIGHT                ([[UIScreen mainScreen] bounds].size.height)

#define login_kScale_W(w) ((login_UI_SCREEN_WIDTH)/375) * (w)
#define login_kScale_H(h) ((login_UI_SCREEN_HEIGHT)/667) * (h)

#define login_UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#define UI_SCREEN_WIDTH                 ([[UIScreen mainScreen] bounds].size.width)
#define UI_SCREEN_HEIGHT                ([[UIScreen mainScreen] bounds].size.height)

#define UI_SCREEN_WIDTH_ROTATE                 ([[UIScreen mainScreen] bounds].size.height)
#define UI_SCREEN_HEIGHT_ROTATE                ([[UIScreen mainScreen] bounds].size.width)


#define YSWeakSelf                  __weak __typeof(self) weakSelf = self;


#define YSS_BUNDLE_NAME      @ "YSResources.bundle"

#define YSSAPP_Localized     [NSBundle bundleWithPath:[[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:YSS_BUNDLE_NAME]]

#define YSSLocalized(s)      [YSSAPP_Localized localizedStringForKey:s value:@"" table:nil]


#endif /* YSLoginMacros_h */

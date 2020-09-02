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

#endif /* YSAppMacros_h */

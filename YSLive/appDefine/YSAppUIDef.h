//
//  YSAppUIDef.h
//  YSLive
//
//  Created by fzxm on 2019/10/11.
//  Copyright © 2019 FS. All rights reserved.
//

#ifndef YSAppUIDef_h
#define YSAppUIDef_h

#import <BMKit/UIColor+BMCategory.h>
#import <BMKit/UIFont+BMCategory.h>

#pragma mark - Color

#define UI_NAVIGATION_BGCOLOR_VALU  0x577EEE

#define UI_COLOR_Y1             [UIColor bm_colorWithHex:0xFBD973]  //251,217,115
#define UI_COLOR_Y2             [UIColor bm_colorWithHex:0xECC85A]  //236,200,90
#define UI_COLOR_Y3             [UIColor bm_colorWithHex:0xF9DF4D]  //249,223,77
#define UI_COLOR_Y4             [UIColor bm_colorWithHex:0xF39025]  //243,144,37
#define UI_COLOR_Y5             [UIColor bm_colorWithHex:0xF4830B]  //244,131,11
#define UI_COLOR_Y6             [UIColor bm_colorWithHex:0xFFF6DB]  //255,246,219

#define UI_COLOR_R1             [UIColor bm_colorWithHex:0xDE3E3E]  //222,62,62
#define UI_COLOR_R2             [UIColor bm_colorWithHex:0xDA2626]  //218,38,38

#define UI_COLOR_B1             [UIColor bm_colorWithHex:0x333333]  //51,51,51
#define UI_COLOR_B2             [UIColor bm_colorWithHex:0x666666]  //102,102,102
#define UI_COLOR_B3             [UIColor bm_colorWithHex:0x888888]  //136,136,136
#define UI_COLOR_B4             [UIColor bm_colorWithHex:0x999999]  //153,153,153
#define UI_COLOR_B5             [UIColor bm_colorWithHex:0xCCCCCC]  //204,204,204
#define UI_COLOR_B6             [UIColor bm_colorWithHex:0xD8D8D8]  //216,216,216
#define UI_COLOR_B7             [UIColor bm_colorWithHex:0xE6E6E6]  //230,230,230
#define UI_COLOR_B8             [UIColor bm_colorWithHex:0xF5F6F7]  //245,246,247
#define UI_COLOR_B9             [UIColor bm_colorWithHex:0xF8F8F8]  //248,248,248
#define UI_COLOR_B10            [UIColor bm_colorWithHex:0xB5B5B5]  //238,238,238
#define UI_COLOR_B11            [UIColor bm_colorWithHex:0xEEEEEE]  //

//#define UI_COLOR_BL1            [UIColor bm_colorWithHex:0x5d80e7]  //93, 128, 231
#define UI_COLOR_BL1            [UIColor bm_colorWithHex:0x577EEE]  //93, 128, 231
#define UI_COLOR_BL2            [UIColor bm_colorWithHex:0xDDE6FF]  //221,230,255
#define UI_COLOR_BL3            [UIColor bm_colorWithHex:0x8DC8FE]  //141,200,254
#define UI_COLOR_BL4            [UIColor bm_colorWithHex:0x77CDEA]  //119,205,234
#define UI_COLOR_BL5            [UIColor bm_colorWithHex:0x54C2E7]  //84,194,231
#define UI_COLOR_BL6            [UIColor bm_colorWithHex:0x5E80E6]  //94, 128,230

#define UI_COLOR_G1             [UIColor bm_colorWithHex:0x53CB4D]  //83,203,77
#define UI_COLOR_G2             [UIColor bm_colorWithHex:0xF2F2F2]  //242,242,242

#define UI_COLOR_P1             [UIColor bm_colorWithHex:0xDE9BFD]  //222,155,253

#define YSColor_LoginPlaceholder    [UIColor bm_colorWithHex:0xC8D1DC]

#define YSColor_LoginTextField      [UIColor bm_colorWithHex:0x345376]
/// 默认蓝色
#define YSColor_DefaultBlue         [UIColor bm_colorWithHex:0x306FFF]
/// 默认灰色背景色
#define YSColor_DefaultBacground    [UIColor bm_colorWithHex:0xF5F5FD]
/// 投票状态绿色背景色
#define YSColor_VoteIngStatus       [UIColor bm_colorWithHex:0x71DCA4]
/// 投票状态灰色背景色
#define YSColor_VoteEndStatus       [UIColor bm_colorWithHex:0xDCDCDC]
/// 投票 老师名字颜色
#define YSColor_VoteTeacherName     [UIColor bm_colorWithHex:0x306FFF]
/// 投票 时间字体颜色
#define YSColor_VoteTime            [UIColor bm_colorWithHex:0x3D3E41]
#pragma mark - Font

#define UI_FSFONT_MAKE(FontName, FontSize)  [UIFont bm_fontForFontName:FontName size:FontSize]

#pragma mark -
#pragma mark systemFont
#define UI_FONT_8           [UIFont systemFontOfSize:8.0f]
#define UI_FONT_9           [UIFont systemFontOfSize:9.0f]
#define UI_FONT_10          [UIFont systemFontOfSize:10.0f]
#define UI_FONT_12          [UIFont systemFontOfSize:12.0f]
#define UI_FONT_13          [UIFont systemFontOfSize:13.0f]
#define UI_FONT_14          [UIFont systemFontOfSize:14.0f]
#define UI_FONT_15          [UIFont systemFontOfSize:15.0f]
#define UI_FONT_16          [UIFont systemFontOfSize:16.0f]
#define UI_FONT_17          [UIFont systemFontOfSize:17.0f]
#define UI_FONT_18          [UIFont systemFontOfSize:18.0f]

#define UI_FONT_20          [UIFont systemFontOfSize:20.0f]
#define UI_FONT_22          [UIFont systemFontOfSize:22.0f]
#define UI_FONT_24          [UIFont systemFontOfSize:24.0f]

#define UI_FONT_30          [UIFont systemFontOfSize:30.0f]
#define UI_FONT_32          [UIFont systemFontOfSize:32.0f]
#define UI_FONT_36          [UIFont systemFontOfSize:36.0f]

#define UI_FONT_40          [UIFont systemFontOfSize:40.0f]
#define UI_FONT_50          [UIFont systemFontOfSize:50.0f]
#define UI_FONT_70          [UIFont systemFontOfSize:70.0f]


#pragma mark -
#pragma mark boldSystemFont

#define UI_BOLDFONT_9       [UIFont boldSystemFontOfSize:9.0f]

#define UI_BOLDFONT_10      [UIFont boldSystemFontOfSize:10.0f]
#define UI_BOLDFONT_12      [UIFont boldSystemFontOfSize:12.0f]
#define UI_BOLDFONT_13      [UIFont boldSystemFontOfSize:13.0f]
#define UI_BOLDFONT_14      [UIFont boldSystemFontOfSize:14.0f]
#define UI_BOLDFONT_15      [UIFont boldSystemFontOfSize:15.0f]
#define UI_BOLDFONT_16      [UIFont boldSystemFontOfSize:16.0f]
#define UI_BOLDFONT_17      [UIFont boldSystemFontOfSize:17.0f]
#define UI_BOLDFONT_18      [UIFont boldSystemFontOfSize:18.0f]

#define UI_BOLDFONT_20      [UIFont boldSystemFontOfSize:20.0f]
#define UI_BOLDFONT_22      [UIFont boldSystemFontOfSize:22.0f]
#define UI_BOLDFONT_24      [UIFont boldSystemFontOfSize:24.0f]

#define UI_BOLDFONT_30      [UIFont boldSystemFontOfSize:30.0f]
#define UI_BOLDFONT_32      [UIFont boldSystemFontOfSize:32.0f]
#define UI_BOLDFONT_36      [UIFont boldSystemFontOfSize:36.0f]

#define UI_BOLDFONT_40      [UIFont boldSystemFontOfSize:40.0f]
#define UI_BOLDFONT_50      [UIFont boldSystemFontOfSize:50.0f]
#define UI_BOLDFONT_70      [UIFont boldSystemFontOfSize:70.0f]


#pragma mark -
#pragma mark numberFont

//#define UI_NUMBER_FONT          @"HelveticaNeue-Bold"
#define UI_NUMBER_FONT(fontSize)    UI_FSFONT_MAKE(FontNameHelveticaNeueBold, fontSize)

#define UI_NUMFONT_9        UI_NUMBER_FONT(9.0f)

#define UI_NUMFONT_10       UI_NUMBER_FONT(10.0f)
#define UI_NUMFONT_12       UI_NUMBER_FONT(12.0f)
#define UI_NUMFONT_13       UI_NUMBER_FONT(13.0f)
#define UI_NUMFONT_14       UI_NUMBER_FONT(14.0f)
#define UI_NUMFONT_15       UI_NUMBER_FONT(15.0f)
#define UI_NUMFONT_16       UI_NUMBER_FONT(16.0f)
#define UI_NUMFONT_17       UI_NUMBER_FONT(17.0f)
#define UI_NUMFONT_18       UI_NUMBER_FONT(18.0f)

#define UI_NUMFONT_20       UI_NUMBER_FONT(20.0f)
#define UI_NUMFONT_22       UI_NUMBER_FONT(22.0f)
#define UI_NUMFONT_24       UI_NUMBER_FONT(24.0f)

#define UI_NUMFONT_30       UI_NUMBER_FONT(30.0f)
#define UI_NUMFONT_32       UI_NUMBER_FONT(32.0f)
#define UI_NUMFONT_36       UI_NUMBER_FONT(36.0f)

#define UI_NUMFONT_40       UI_NUMBER_FONT(40.0f)
#define UI_NUMFONT_50       UI_NUMBER_FONT(50.0f)
#define UI_NUMFONT_70       UI_NUMBER_FONT(70.0f)




#pragma mark -
#pragma mark 默认UI设置

#pragma mark 默认颜色

// View背景颜色 (确定)

#define YS_VIEW_BGCOLOR                     UI_COLOR_B8

#define YS_LOADINGBAR_COLOR                 UI_COLOR_BL1

// 导航条背景颜色 (确定)
#define YS_NAVIGATION_BGCOLOR_VALUE         UI_NAVIGATION_BGCOLOR_VALU
#define YS_NAVIGATION_BGCOLOR               [UIColor whiteColor]
#define YS_NAVIGATION_ITEMCOLOR             UI_COLOR_B2

// 工具条背景颜色
#define YS_BAR_BGCOLOR                      UI_COLOR_B6
#define YS_BAR_TEXTNORMALCOLOR              UI_COLOR_B2
#define YS_BAR_TEXTSELECTCOLOR              UI_COLOR_BL1

// 文本颜色
#define YS_TITLE_TEXTCOLOR                  UI_COLOR_B1
#define YS_CONTENT_TEXTCOLOR                UI_COLOR_B2
#define YS_DETAIL_TEXTCOLOR                 UI_COLOR_B2
#define YS_COUNT_TEXTCOLOR                  UI_COLOR_BL1
#define YS_OTHER_TEXTCOLOR                  UI_COLOR_B2

// Cell背景颜色 (实为table中section header背景色)
#define YS_TABLECELL_BGCOLOR                UI_COLOR_B8
// Cell选中状态背景颜色
#define UI_TABLECELL_SELECTBGCOLOR          UI_COLOR_B5
#define UI_TABLECELL_HIGHLIGHTBGCOLOR       UI_COLOR_BL1

// 分割线颜色 (确定)
#define YS_LINECOLOR                        UI_COLOR_B6


#pragma mark 默认字体

#define YS_TITLE_TEXTFONT                   UI_FONT_17
#define YS_DETAIL_LARGETEXTFONT             UI_FONT_14
#define YS_DETAIL_SMALLTEXTFONT             UI_FONT_12
#define YS_BUTTON_LARGETEXTFONT             UI_FONT_17
#define YS_BUTTON_SMALLTEXTFONT             UI_FONT_14

#define YS_CELLTITLE_TEXTFONT               UI_FONT_15
#define YS_CELLDETAIL_LARGETEXTFONT         YS_DETAIL_LARGETEXTFONT
#define YS_CELLDETAIL_SMALLTEXTFONT         YS_DETAIL_SMALLTEXTFONT


#pragma mark -
#pragma mark 默认值

// CellSection 间隔
#define UI_TABLECELL_SECTIONGAP             (18.0f)

#define YS_Localized(locaString)  NSLocalizedString(locaString, nil)

#define YSToolBar_BtnWidth_iPhone   (44.0f)
#define YSToolBar_BtnWidth_iPad     (52.0f)

#define YSToolBar_BtnWidth          ([UIDevice bm_isiPad] ? YSToolBar_BtnWidth_iPad : YSToolBar_BtnWidth_iPhone)

#define YSPopViewDefaultAlpha       (1.0f)
#endif /* YSAppUIDef_h */

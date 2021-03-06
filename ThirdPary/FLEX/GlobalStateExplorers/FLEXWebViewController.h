//
//  FLEXWebViewController.m
//  Flipboard
//
//  Created by Ryan Olson on 6/10/14.
//  Copyright (c) 2020 FLEX Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLEXWebViewController : UIViewController

- (id)initWithURL:(NSURL *)url;
- (id)initWithText:(NSString *)text;

#if FLEX_BM
- (id)initWithText:(NSString *)text filePath:(NSString *)filePath;
#endif

+ (BOOL)supportsPathExtension:(NSString *)extension;

@end

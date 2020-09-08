//
//  AppDelegate.h
//  YSLogin
//
//

#import <UIKit/UIKit.h>

#define GetAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) BOOL allowRotation;

@end


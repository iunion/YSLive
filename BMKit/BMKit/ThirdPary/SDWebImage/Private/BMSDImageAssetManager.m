/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDImageAssetManager.h"
#import "BMSDInternalMacros.h"

static NSArray *BMSDBundlePreferredScales() {
    static NSArray *scales;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if BMSD_WATCH
        CGFloat screenScale = [WKInterfaceDevice currentDevice].screenScale;
#elif BMSD_UIKIT
        CGFloat screenScale = [UIScreen mainScreen].scale;
#elif BMSD_MAC
        CGFloat screenScale = [NSScreen mainScreen].backingScaleFactor;
#endif
        if (screenScale <= 1) {
            scales = @[@1,@2,@3];
        } else if (screenScale <= 2) {
            scales = @[@2,@3,@1];
        } else {
            scales = @[@3,@2,@1];
        }
    });
    return scales;
}

@implementation BMSDImageAssetManager {
    dispatch_semaphore_t _lock;
}

+ (instancetype)sharedAssetManager {
    static dispatch_once_t onceToken;
    static BMSDImageAssetManager *assetManager;
    dispatch_once(&onceToken, ^{
        assetManager = [[BMSDImageAssetManager alloc] init];
    });
    return assetManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSPointerFunctionsOptions valueOptions;
#if BMSD_MAC
        // Apple says that NSImage use a weak reference to value
        valueOptions = NSPointerFunctionsWeakMemory;
#else
        // Apple says that UIImage use a strong reference to value
        valueOptions = NSPointerFunctionsStrongMemory;
#endif
        _imageTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:valueOptions];
        _lock = dispatch_semaphore_create(1);
#if BMSD_UIKIT
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
    }
    return self;
}

- (void)dealloc {
#if BMSD_UIKIT
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification {
    BMSD_LOCK(_lock);
    [self.imageTable removeAllObjects];
    BMSD_UNLOCK(_lock);
}

- (NSString *)getPathForName:(NSString *)name bundle:(NSBundle *)bundle preferredScale:(CGFloat *)scale {
    NSParameterAssert(name);
    NSParameterAssert(bundle);
    NSString *path;
    if (name.length == 0) {
        return path;
    }
    if ([name hasSuffix:@"/"]) {
        return path;
    }
    NSString *extension = name.pathExtension;
    if (extension.length == 0) {
        // If no extension, follow Apple's doc, check PNG format
        extension = @"png";
    }
    name = [name stringByDeletingPathExtension];
    
    CGFloat providedScale = *scale;
    NSArray *scales = BMSDBundlePreferredScales();
    
    // Check if file name contains scale
    for (size_t i = 0; i < scales.count; i++) {
        NSNumber *scaleValue = scales[i];
        if ([name hasSuffix:[NSString stringWithFormat:@"@%@x", scaleValue]]) {
            path = [bundle pathForResource:name ofType:extension];
            if (path) {
                *scale = scaleValue.doubleValue; // override
                return path;
            }
        }
    }
    
    // Search with provided scale first
    if (providedScale != 0) {
        NSString *scaledName = [name stringByAppendingFormat:@"@%@x", @(providedScale)];
        path = [bundle pathForResource:scaledName ofType:extension];
        if (path) {
            return path;
        }
    }
    
    // Search with preferred scale
    for (size_t i = 0; i < scales.count; i++) {
        NSNumber *scaleValue = scales[i];
        if (scaleValue.doubleValue == providedScale) {
            // Ignore provided scale
            continue;
        }
        NSString *scaledName = [name stringByAppendingFormat:@"@%@x", scaleValue];
        path = [bundle pathForResource:scaledName ofType:extension];
        if (path) {
            *scale = scaleValue.doubleValue; // override
            return path;
        }
    }
    
    // Search without scale
    path = [bundle pathForResource:name ofType:extension];
    
    return path;
}

- (UIImage *)imageForName:(NSString *)name {
    NSParameterAssert(name);
    UIImage *image;
    BMSD_LOCK(_lock);
    image = [self.imageTable objectForKey:name];
    BMSD_UNLOCK(_lock);
    return image;
}

- (void)storeImage:(UIImage *)image forName:(NSString *)name {
    NSParameterAssert(image);
    NSParameterAssert(name);
    BMSD_LOCK(_lock);
    [self.imageTable setObject:image forKey:name];
    BMSD_UNLOCK(_lock);
}

@end

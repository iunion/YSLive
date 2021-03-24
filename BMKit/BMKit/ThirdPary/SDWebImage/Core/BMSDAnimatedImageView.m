/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDAnimatedImageView.h"

#if BMSD_UIKIT || BMSD_MAC

#import "UIImage+BMMetadata.h"
#import "NSImage+BMCompatibility.h"
#import "BMSDInternalMacros.h"
#import "objc/runtime.h"

@interface UIImageView () <CALayerDelegate>
@end

@interface BMSDAnimatedImageView () {
    BOOL _initFinished; // Extra flag to mark the `commonInit` is called
    NSRunLoopMode _runLoopMode;
    NSUInteger _maxBufferSize;
    double _playbackRate;
    BMSDAnimatedImagePlaybackMode _playbackMode;
}

@property (nonatomic, strong, readwrite) BMSDAnimatedImagePlayer *player;
@property (nonatomic, strong, readwrite) UIImage *currentFrame;
@property (nonatomic, assign, readwrite) NSUInteger currentFrameIndex;
@property (nonatomic, assign, readwrite) NSUInteger currentLoopCount;
@property (nonatomic, assign) BOOL shouldAnimate;
@property (nonatomic, assign) BOOL isProgressive;
@property (nonatomic) CALayer *imageViewLayer; // The actual rendering layer.

@end

@implementation BMSDAnimatedImageView
#if BMSD_UIKIT
@dynamic animationRepeatCount; // we re-use this property from `UIImageView` super class on iOS.
#endif

#pragma mark - Initializers

#if BMSD_MAC
+ (instancetype)imageViewWithImage:(NSImage *)image
{
    NSRect frame = NSMakeRect(0, 0, image.size.width, image.size.height);
    SDAnimatedImageView *imageView = [[SDAnimatedImageView alloc] initWithFrame:frame];
    [imageView setImage:image];
    return imageView;
}
#else
// -initWithImage: isn't documented as a designated initializer of UIImageView, but it actually seems to be.
// Using -initWithImage: doesn't call any of the other designated initializers.
- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        [self commonInit];
    }
    return self;
}

// -initWithImage:highlightedImage: also isn't documented as a designated initializer of UIImageView, but it doesn't call any other designated initializers.
- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self) {
        [self commonInit];
    }
    return self;
}
#endif

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    // Pay attention that UIKit's `initWithImage:` will trigger a `setImage:` during initialization before this `commonInit`.
    // So the properties which rely on this order, should using lazy-evaluation or do extra check in `setImage:`.
    self.autoPlayAnimatedImage = YES;
    self.shouldCustomLoopCount = NO;
    self.shouldIncrementalLoad = YES;
    self.playbackRate = 1.0;
#if BMSD_MAC
    self.wantsLayer = YES;
#endif
    // Mark commonInit finished
    _initFinished = YES;
}

#pragma mark - Accessors
#pragma mark Public

- (void)setImage:(UIImage *)image
{
    if (self.image == image) {
        return;
    }
    
    // Check Progressive rendering
    [self updateIsProgressiveWithImage:image];
    
    if (!self.isProgressive) {
        // Stop animating
        self.player = nil;
        self.currentFrame = nil;
        self.currentFrameIndex = 0;
        self.currentLoopCount = 0;
    }
    
    // We need call super method to keep function. This will impliedly call `setNeedsDisplay`. But we have no way to avoid this when using animated image. So we call `setNeedsDisplay` again at the end.
    super.image = image;
    if ([image.class conformsToProtocol:@protocol(BMSDAnimatedImage)]) {
        if (!self.player) {
            id<BMSDAnimatedImageProvider> provider;
            // Check progressive loading
            if (self.isProgressive) {
                provider = [self progressiveAnimatedCoderForImage:image];
            } else {
                provider = (id<BMSDAnimatedImage>)image;
            }
            // Create animated player
            self.player = [BMSDAnimatedImagePlayer playerWithProvider:provider];
        } else {
            // Update Frame Count
            self.player.totalFrameCount = [(id<BMSDAnimatedImage>)image animatedImageFrameCount];
        }
        
        if (!self.player) {
            // animated player nil means the image format is not supported, or frame count <= 1
            return;
        }
        
        // Custom Loop Count
        if (self.shouldCustomLoopCount) {
            self.player.totalLoopCount = self.animationRepeatCount;
        }
        
        // RunLoop Mode
        self.player.runLoopMode = self.runLoopMode;
        
        // Max Buffer Size
        self.player.maxBufferSize = self.maxBufferSize;
        
        // Play Rate
        self.player.playbackRate = self.playbackRate;
        
        // Play Mode
        self.player.playbackMode = self.playbackMode;

        // Setup handler
        @bmweakify(self);
        self.player.animationFrameHandler = ^(NSUInteger index, UIImage * frame) {
            @bmstrongify(self);
            self.currentFrameIndex = index;
            self.currentFrame = frame;
            [self.imageViewLayer setNeedsDisplay];
        };
        self.player.animationLoopHandler = ^(NSUInteger loopCount) {
            @bmstrongify(self);
            // Progressive image reach the current last frame index. Keep the state and pause animating. Wait for later restart
            if (self.isProgressive) {
                NSUInteger lastFrameIndex = self.player.totalFrameCount - 1;
                [self.player seekToFrameAtIndex:lastFrameIndex loopCount:0];
                [self.player pausePlaying];
            } else {
                self.currentLoopCount = loopCount;
            }
        };
        
        // Ensure disabled highlighting; it's not supported (see `-setHighlighted:`).
        super.highlighted = NO;
        
        [self stopAnimating];
        [self checkPlay];

        [self.imageViewLayer setNeedsDisplay];
    }
}

#pragma mark - Configuration

- (void)setRunLoopMode:(NSRunLoopMode)runLoopMode
{
    _runLoopMode = [runLoopMode copy];
    self.player.runLoopMode = runLoopMode;
}

- (NSRunLoopMode)runLoopMode
{
    if (!_runLoopMode) {
        _runLoopMode = [[self class] defaultRunLoopMode];
    }
    return _runLoopMode;
}

+ (NSString *)defaultRunLoopMode {
    // Key off `activeProcessorCount` (as opposed to `processorCount`) since the system could shut down cores in certain situations.
    return [NSProcessInfo processInfo].activeProcessorCount > 1 ? NSRunLoopCommonModes : NSDefaultRunLoopMode;
}

- (void)setMaxBufferSize:(NSUInteger)maxBufferSize
{
    _maxBufferSize = maxBufferSize;
    self.player.maxBufferSize = maxBufferSize;
}

- (NSUInteger)maxBufferSize {
    return _maxBufferSize; // Defaults to 0
}

- (void)setPlaybackRate:(double)playbackRate
{
    _playbackRate = playbackRate;
    self.player.playbackRate = playbackRate;
}

- (double)playbackRate
{
    if (!_initFinished) {
        return 1.0; // Defaults to 1.0
    }
    return _playbackRate;
}

- (void)setPlaybackMode:(BMSDAnimatedImagePlaybackMode)playbackMode {
    _playbackMode = playbackMode;
    self.player.playbackMode = playbackMode;
}

- (BMSDAnimatedImagePlaybackMode)playbackMode {
    if (!_initFinished) {
        return BMSDAnimatedImagePlaybackModeNormal; // Default mode is normal
    }
    return _playbackMode;
}


- (BOOL)shouldIncrementalLoad
{
    if (!_initFinished) {
        return YES; // Defaults to YES
    }
    return _initFinished;
}

#pragma mark - UIView Method Overrides
#pragma mark Observing View-Related Changes

#if BMSD_MAC
- (void)viewDidMoveToSuperview
#else
- (void)didMoveToSuperview
#endif
{
#if BMSD_MAC
    [super viewDidMoveToSuperview];
#else
    [super didMoveToSuperview];
#endif
    
    [self checkPlay];
}

#if BMSD_MAC
- (void)viewDidMoveToWindow
#else
- (void)didMoveToWindow
#endif
{
#if BMSD_MAC
    [super viewDidMoveToWindow];
#else
    [super didMoveToWindow];
#endif
    
    [self checkPlay];
}

#if BMSD_MAC
- (void)setAlphaValue:(CGFloat)alphaValue
#else
- (void)setAlpha:(CGFloat)alpha
#endif
{
#if BMSD_MAC
    [super setAlphaValue:alphaValue];
#else
    [super setAlpha:alpha];
#endif
    
    [self checkPlay];
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    
    [self checkPlay];
}

#pragma mark - UIImageView Method Overrides
#pragma mark Image Data

- (void)setAnimationRepeatCount:(NSInteger)animationRepeatCount
{
#if BMSD_UIKIT
    [super setAnimationRepeatCount:animationRepeatCount];
#else
    _animationRepeatCount = animationRepeatCount;
#endif
    
    if (self.shouldCustomLoopCount) {
        self.player.totalLoopCount = animationRepeatCount;
    }
}

- (void)startAnimating
{
    if (self.player) {
        [self updateShouldAnimate];
        if (self.shouldAnimate) {
            [self.player startPlaying];
        }
    } else {
#if BMSD_UIKIT
        [super startAnimating];
#else
        [super setAnimates:YES];
#endif
    }
}

- (void)stopAnimating
{
    if (self.player) {
        if (self.resetFrameIndexWhenStopped) {
            [self.player stopPlaying];
        } else {
            [self.player pausePlaying];
        }
        if (self.clearBufferWhenStopped) {
            [self.player clearFrameBuffer];
        }
    } else {
#if BMSD_UIKIT
        [super stopAnimating];
#else
        [super setAnimates:NO];
#endif
    }
}

#if BMSD_UIKIT
- (BOOL)isAnimating
{
    if (self.player) {
        return self.player.isPlaying;
    } else {
        return [super isAnimating];
    }
}
#endif

#if BMSD_MAC
- (BOOL)animates
{
    if (self.player) {
        return self.player.isPlaying;
    } else {
        return [super animates];
    }
}

- (void)setAnimates:(BOOL)animates
{
    if (animates) {
        [self startAnimating];
    } else {
        [self stopAnimating];
    }
}
#endif

#pragma mark Highlighted Image Unsupport

- (void)setHighlighted:(BOOL)highlighted
{
    // Highlighted image is unsupported for animated images, but implementing it breaks the image view when embedded in a UICollectionViewCell.
    if (!self.player) {
        [super setHighlighted:highlighted];
    }
}


#pragma mark - Private Methods
#pragma mark Animation

/// Check if it should be played
- (void)checkPlay
{
    // Only handle for SDAnimatedImage, leave UIAnimatedImage or animationImages for super implementation control
    if (self.player && self.autoPlayAnimatedImage) {
        [self updateShouldAnimate];
        if (self.shouldAnimate) {
            [self startAnimating];
        } else {
            [self stopAnimating];
        }
    }
}

// Don't repeatedly check our window & superview in `-displayDidRefresh:` for performance reasons.
// Just update our cached value whenever the animated image or visibility (window, superview, hidden, alpha) is changed.
- (void)updateShouldAnimate
{
#if BMSD_MAC
    BOOL isVisible = self.window && self.superview && ![self isHidden] && self.alphaValue > 0.0;
#else
    BOOL isVisible = self.window && self.superview && ![self isHidden] && self.alpha > 0.0;
#endif
    self.shouldAnimate = self.player && isVisible;
}

// Update progressive status only after `setImage:` call.
- (void)updateIsProgressiveWithImage:(UIImage *)image
{
    self.isProgressive = NO;
    if (!self.shouldIncrementalLoad) {
        // Early return
        return;
    }
    // We must use `image.class conformsToProtocol:` instead of `image conformsToProtocol:` here
    // Because UIKit on macOS, using internal hard-coded override method, which returns NO
    id<BMSDAnimatedImageCoder> currentAnimatedCoder = [self progressiveAnimatedCoderForImage:image];
    if (currentAnimatedCoder) {
        UIImage *previousImage = self.image;
        if (!previousImage) {
            // If current animated coder supports progressive, and no previous image to check, start progressive loading
            self.isProgressive = YES;
        } else {
            id<BMSDAnimatedImageCoder> previousAnimatedCoder = [self progressiveAnimatedCoderForImage:previousImage];
            if (previousAnimatedCoder == currentAnimatedCoder) {
                // If current animated coder is the same as previous, start progressive loading
                self.isProgressive = YES;
            }
        }
    }
}

// Check if image can represent a `Progressive Animated Image` during loading
- (id<BMSDAnimatedImageCoder, BMSDProgressiveImageCoder>)progressiveAnimatedCoderForImage:(UIImage *)image
{
    if ([image.class conformsToProtocol:@protocol(BMSDAnimatedImage)] && image.bmsd_isIncremental && [image respondsToSelector:@selector(animatedCoder)]) {
        id<BMSDAnimatedImageCoder> animatedCoder = [(id<BMSDAnimatedImage>)image animatedCoder];
        if ([animatedCoder conformsToProtocol:@protocol(BMSDProgressiveImageCoder)]) {
            return (id<BMSDAnimatedImageCoder, BMSDProgressiveImageCoder>)animatedCoder;
        }
    }
    return nil;
}


#pragma mark Providing the Layer's Content
#pragma mark - CALayerDelegate

- (void)displayLayer:(CALayer *)layer
{
    UIImage *currentFrame = self.currentFrame;
    if (currentFrame) {
        layer.contentsScale = currentFrame.scale;
        layer.contents = (__bridge id)currentFrame.CGImage;
    } else {
        // If we have no animation frames, call super implementation. iOS 14+ UIImageView use this delegate method for rendering.
        if ([UIImageView instancesRespondToSelector:@selector(displayLayer:)]) {
            [super displayLayer:layer];
        }
    }
}

#if BMSD_MAC
// NSImageView use a subview. We need this subview's layer for actual rendering.
// Why using this design may because of properties like `imageAlignment` and `imageScaling`, which it's not available for UIImageView.contentMode (it's impossible to align left and keep aspect ratio at the same time)
- (NSView *)imageView {
    NSImageView *imageView = objc_getAssociatedObject(self, SD_SEL_SPI(imageView));
    if (!imageView) {
        // macOS 10.14
        imageView = objc_getAssociatedObject(self, SD_SEL_SPI(imageSubview));
    }
    return imageView;
}

// on macOS, it's the imageView subview's layer (we use layer-hosting view to let CALayerDelegate works)
- (CALayer *)imageViewLayer {
    NSView *imageView = self.imageView;
    if (!imageView) {
        return nil;
    }
    if (!_imageViewLayer) {
        _imageViewLayer = [CALayer new];
        _imageViewLayer.delegate = self;
        imageView.layer = _imageViewLayer;
        imageView.wantsLayer = YES;
    }
    return _imageViewLayer;
}
#else
// on iOS, it's the imageView itself's layer
- (CALayer *)imageViewLayer {
    return self.layer;
}

#endif

@end

#endif

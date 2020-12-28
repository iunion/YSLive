//
//  CHWBMediaControlviewDelegate.h
//  CHWhiteBoard
//
//

#ifndef CHWBMediaControlviewDelegate_h
#define CHWBMediaControlviewDelegate_h

@protocol CHWBMediaControlviewDelegate <NSObject>

@optional

- (void)mediaControlviewPlay:(BOOL)isPause withFileModel:(CHSharedMediaFileModel *)mediaFileModel;

- (void)mediaControlviewSliderPos:(NSTimeInterval)value withFileModel:(CHSharedMediaFileModel *)mediaFileModel;

- (void)mediaControlviewCloseWithFileModel:(CHSharedMediaFileModel *)mediaFileModel;

@end

#endif /* CHWBMediaControlviewDelegate_h */

//
//  CHPropsViewCell.m
//  YSAll
//
//  Created by 马迪 on 2021/3/26.
//  Copyright © 2021 CH. All rights reserved.
//

#import "CHPropsViewCell.h"

@interface CHPropsViewCell ()

@property(nonatomic,weak) UIImageView *imageView;

@end

@implementation CHPropsViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupView];
    }
    
    return self;
}

- (void)setupView
{
    self.contentView.backgroundColor = [UIColor bm_colorWithHex:0xFFFFFF alpha:0.6f];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, 4.0f, 4.0f)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:imageView];
    
    self.imageView = imageView;
}

- (void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;
    
    if (![imageUrl bm_isNotEmpty])
    {
        self.imageView.image = [UIImage imageNamed:@"beauty_defaultprop"];
    }
    else
    {
        [self.imageView bmsd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"beauty_defaultprop"] options:BMSDWebImageRetryFailed | BMSDWebImageLowPriority];
    }
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    
    if (isSelected)
    {
        self.backgroundColor = [UIColor bm_colorWithHex:0x82ABEC alpha:0.6f];
    }
    else
    {
        self.backgroundColor = [UIColor bm_colorWithHex:0xFFFFFF alpha:0.6f];
    }
}

@end

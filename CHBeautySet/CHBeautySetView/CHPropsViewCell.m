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
        self.backgroundColor = [YSSkinDefineColor(@"WhiteColor") bm_changeAlpha:0.6];
        
        [self setupView];
    }
    
    return self;
}

- (void)setupView
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(1, 1, self.bm_width - 2, self.bm_height - 2)];
    self.imageView = imageView;
    [self.contentView addSubview:imageView];
}

- (void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;
    
    if ([_imageUrl isEqualToString:@"hud_network_poor0"])
    {
        self.imageView.image = [UIImage imageNamed:@"hud_network_poor0"];
    }
    else if ([_imageUrl bm_isNotEmpty])
    {
        [self.imageView bmsd_setImageWithURL:[NSURL URLWithString:_imageUrl] placeholderImage:[UIImage imageNamed:@"120"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, BMSDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                
        }];
    }
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    if (isSelected)
    {
        self.backgroundColor = [UIColor bm_colorWithHex:0x82ABEC];
    }
    else
    {
        self.backgroundColor = [YSSkinDefineColor(@"WhiteColor") bm_changeAlpha:0.6];
    }
}

@end

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
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.bounds];
    self.imageView = imageView;
    [self addSubview:imageView];
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

@end

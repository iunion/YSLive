//
//  YSPermissionsVResultView.m
//  YSAll
//
//  Created by fzxm on 2019/12/19.
//  Copyright © 2019 YS. All rights reserved.
//

#import "YSPermissionsVResultView.h"

@interface YSPermissionsVResultView ()

@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UILabel *resultLabel;

@end

@implementation YSPermissionsVResultView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UILabel *typeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    typeLabel.numberOfLines = 0;
    typeLabel.font = UI_FONT_14;
    typeLabel.textColor = [UIColor bm_colorWithHex:0x82ABEC];
    [self addSubview:typeLabel];
    typeLabel.adjustsFontSizeToFitWidth = YES;
    self.typeLabel = typeLabel;
   
    UILabel *resultLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    resultLabel.numberOfLines = 0;
    resultLabel.font = UI_FONT_14;
    resultLabel.textColor = [UIColor bm_colorWithHex:0x82ABEC];
    [self addSubview:resultLabel];
    resultLabel.adjustsFontSizeToFitWidth = YES;
    self.resultLabel = resultLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.typeLabel.frame = CGRectMake(0, 0, 80, 20);
    self.resultLabel.frame = CGRectMake(CGRectGetMaxX(self.typeLabel.frame) + 10, 0, 80, 20);
}

- (void)freshWithResult:(BOOL)result
{
    if (result)
    {
        self.typeLabel.textColor = self.permissionColor;
        self.resultLabel.textColor = self.permissionColor;
    }
    else
    {
        self.typeLabel.textColor = self.noPermissionColor;
        self.resultLabel.textColor = self.noPermissionColor;
    }
        
    self.typeLabel.text = self.title;
    self.resultLabel.text = result ? self.permissionText : self.noPermissionText;
}

@end

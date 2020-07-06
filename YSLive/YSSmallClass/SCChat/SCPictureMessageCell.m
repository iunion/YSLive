//
//  SCChatPictureCell.m
//  YSLive
//
//  Created by 马迪 on 2019/11/16.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCPictureMessageCell.h"

//右侧聊天视图宽度
#define ChatViewWidth 284

@interface SCPictureMessageCell ()

///用户名
@property (nonatomic, strong) UIButton *nickNameBtn;
///气泡View
@property (nonatomic, strong) UIImageView * bubbleView;
///图片内容
@property (nonatomic, strong) UIImageView * msgImageView;
///大图
@property (nonatomic, strong) UIImageView * bigImageView;

@end

@implementation SCPictureMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = UIColor.clearColor;
        self.contentView.backgroundColor = UIColor.clearColor;
        
        _bubbleView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _bubbleView.userInteractionEnabled = YES;
        self.bubbleView.layer.cornerRadius = 10;
        self.bubbleView.layer.masksToBounds = YES;
        [self.contentView addSubview:_bubbleView];
        
        self.nickNameBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, ChatViewWidth-2*10, 20)];
        [self.nickNameBtn setBackgroundColor:[UIColor clearColor]];
        self.nickNameBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.nickNameBtn.titleLabel.font = UI_FONT_14;
        [self.nickNameBtn setTitleColor:[UIColor bm_colorWithHexString:@"#8D9CBC"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.nickNameBtn];
        
        _msgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _msgImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.bubbleView addSubview:_msgImageView];
        
        _msgImageView.userInteractionEnabled = YES;
        [_msgImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smallImageClick:)]];
    }
    return self;
}

- (void)setModel:(YSChatMessageModel *)model
{
    _model = model;
    
    NSString * nameTimeStr = nil;
    CGFloat bubbleX = 0;
    
    if ([model.sendUser.peerID isEqualToString:YSCurrentUser.peerID])
    {//我的消息
        nameTimeStr = [NSString stringWithFormat:@"%@ %@",YSLocalized(@"Role.Me"),model.timeStr];
        self.nickNameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.nickNameBtn setTitleColor:YSSkinDefineColor(@"defaultSelectedBgColor") forState:UIControlStateNormal];
        self.bubbleView.backgroundColor = YSSkinDefineColor(@"defaultSelectedBgColor");
        bubbleX = ChatViewWidth-108-15;
    }
    else
    {//别人的消息
        nameTimeStr = [NSString stringWithFormat:@"%@ %@",model.sendUser.nickName,model.timeStr];
        self.nickNameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.nickNameBtn setTitleColor:YSSkinDefineColor(@"placeholderColor") forState:UIControlStateNormal];
        self.bubbleView.backgroundColor = YSSkinDefineColor(@"defaultTitleColor");
        bubbleX = 15;
    }
    
    [self.nickNameBtn setTitle:nameTimeStr forState:UIControlStateNormal];
    
    UIImage *image = _bubbleView.image;
    CGFloat top = image.size.height/2.0;
    CGFloat left = image.size.width/2.0;
    CGFloat bottom = image.size.height/2.0;
    CGFloat right = image.size.width/2.0;
    
    self.bubbleView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
    
    _bubbleView.frame = CGRectMake(bubbleX, CGRectGetMaxY(_nickNameBtn.frame) + 5, 108, 90);
    self.msgImageView.frame = CGRectMake(0, 0, 108, 90);
    
    [self.msgImageView bm_setImageWithURL:[NSURL URLWithString:model.imageUrl] placeholderImage:[UIImage imageNamed:@"tk_login_logo_black"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, BMSDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        if (![image bm_isNotEmpty])
        {
            self.msgImageView.image = [UIImage imageNamed:@"tk_login_logo_black"];
        }
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.msgImageView.image)
    {
        CGFloat bubbleX = 0;
        CGFloat bubbleW = 0;
        CGFloat bubbleH = 90;
        
        CGSize size = [_msgImageView.image size];
        bubbleW = size.width *(90/size.height);

        if ([self.model.sendUser.peerID isEqualToString:YSCurrentUser.peerID])
        {//我的消息
            bubbleX = ChatViewWidth-bubbleW-10;
        }
        else
        {//别人的消息
            bubbleX = 10;
        }
        _bubbleView.frame = CGRectMake(bubbleX, CGRectGetMaxY(_nickNameBtn.frame) + 5, bubbleW, bubbleH);
        self.msgImageView.frame = CGRectMake(0, 0, bubbleW, bubbleH);
    }
}
- (void) smallImageClick:(UITapGestureRecognizer *)tap
{
    if (nil == _bigImageView)
    {
        self.bigImageView = [[UIImageView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
        self.bigImageView.userInteractionEnabled = YES;
        [self.bigImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigImageClick:)]];
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.bigImageView];
    self.bigImageView.image = [self.msgImageView.image copy];
    self.bigImageView.backgroundColor = UIColor.whiteColor;
    CGSize size = [self.bigImageView.image size];
    if (size.width >= BMUI_SCREEN_WIDTH || size.height >= BMUI_SCREEN_HEIGHT)
    {
        self.bigImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    else
    {
        self.bigImageView.contentMode = UIViewContentModeCenter;
    }
}

- (void) bigImageClick:(UITapGestureRecognizer *) tap
{
    if (self.bigImageView)
    {
        [self.bigImageView removeFromSuperview];
        self.bigImageView = nil;
    }
}



@end

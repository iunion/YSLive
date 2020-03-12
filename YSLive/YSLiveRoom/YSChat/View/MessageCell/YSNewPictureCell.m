//
//  TKNewPictureCell.m
//  EduClass
//
//  Created by talkcloud on 2019/7/11.
//  Copyright © 2019 talkcloud. All rights reserved.
//

#import "YSNewPictureCell.h"

@interface YSNewPictureCell ()

///用户名
//@property (nonatomic, strong) UILabel *nickNameLab;
///用户名
@property (nonatomic, strong) UIButton *nickNameBtn;
///气泡View
@property (nonatomic, strong) UIImageView * bubbleView;
///图片内容
@property (nonatomic, strong) UIImageView * msgImageView;
///大图
@property (nonatomic, strong) UIImageView * bigImageView;
@end

@implementation YSNewPictureCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = UIColor.clearColor;
        self.contentView.backgroundColor = UIColor.clearColor;
        
        self.bubbleView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.bubbleView.userInteractionEnabled = YES;
        [self.contentView addSubview:self.bubbleView];

        self.nickNameBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScale_W(12), 10, UI_SCREEN_WIDTH-2*kScale_W(12), kScale_H(12))];
        [self.nickNameBtn setBackgroundColor:[UIColor clearColor]];
        self.nickNameBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.nickNameBtn addTarget:self action:@selector(nickNameBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        self.nickNameBtn.titleLabel.font = UI_FONT_14;
        [self.nickNameBtn setTitleColor:[UIColor bm_colorWithHexString:@"#828282"] forState:UIControlStateNormal];
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
    if (model.isPersonal)
    {//私聊
        if ([model.sendUser.peerID isEqualToString:YSCurrentUser.peerID])
        {//我的消息
            nameTimeStr = [NSString stringWithFormat:@"%@ 我对”%@”说",model.timeStr,model.receiveUser.nickName];
            self.nickNameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            bubbleX = UI_SCREEN_WIDTH-kScale_W(108)-kScale_W(19);
            self.bubbleView.backgroundColor = [UIColor bm_colorWithHexString:@"#82ABEC"];
            
            NSMutableAttributedString * mutAtt = [[NSMutableAttributedString alloc]initWithString:nameTimeStr];
            [mutAtt addAttributes:@{NSForegroundColorAttributeName:[UIColor bm_colorWithHexString:@"#5A8CDC"]} range:NSMakeRange(nameTimeStr.length-model.receiveUser.nickName.length-3, model.receiveUser.nickName.length+3)];
            [mutAtt addAttributes:@{NSForegroundColorAttributeName:[UIColor bm_colorWithHexString:@"#828282"]} range:NSMakeRange(0, nameTimeStr.length-model.receiveUser.nickName.length-3)];
            [self.nickNameBtn setTitle:nil forState:UIControlStateNormal];
            [self.nickNameBtn setAttributedTitle:mutAtt forState:UIControlStateNormal];
            
        }
        else
        {//别人的消息
            nameTimeStr = [NSString stringWithFormat:@"”%@“ %@ %@",model.sendUser.nickName,YSLocalized(@"Label.ChatToMe"),model.timeStr];
            self.nickNameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            self.bubbleView.backgroundColor = [UIColor bm_colorWithHexString:@"#DEEAFF"];
            bubbleX = kScale_W(19);
            
            NSMutableAttributedString * mutAtt = [[NSMutableAttributedString alloc]initWithString:nameTimeStr];
            [mutAtt addAttributes:@{NSForegroundColorAttributeName:[UIColor bm_colorWithHexString:@"#5A8CDC"]} range:NSMakeRange(0, model.sendUser.nickName.length+2)];
            [mutAtt addAttributes:@{NSForegroundColorAttributeName:[UIColor bm_colorWithHexString:@"#828282"]} range:NSMakeRange(model.receiveUser.nickName.length+2, nameTimeStr.length-model.receiveUser.nickName.length-2)];
            [self.nickNameBtn setTitle:nil forState:UIControlStateNormal];
            [self.nickNameBtn setAttributedTitle:mutAtt forState:UIControlStateNormal];
        }
    }
    else
    {//群聊
        [self.nickNameBtn setTitleColor:[UIColor bm_colorWithHexString:@"#8D9CBC"] forState:UIControlStateNormal];
        if ([model.sendUser.peerID isEqualToString:YSCurrentUser.peerID])
        {//我的消息
            self.nickNameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            self.bubbleView.backgroundColor = [UIColor bm_colorWithHexString:@"#82ABEC"];
            [self.nickNameBtn setTitleColor:[UIColor bm_colorWithHexString:@"#5A8CDC"] forState:UIControlStateNormal];
            bubbleX = UI_SCREEN_WIDTH-kScale_W(108)-kScale_W(19);
        }
        else
        {//别人的消息
            self.nickNameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            self.bubbleView.backgroundColor = [UIColor bm_colorWithHexString:@"#DEEAFF"];
            [self.nickNameBtn setTitleColor:[UIColor bm_colorWithHexString:@"#828282"] forState:UIControlStateNormal];
            bubbleX = kScale_W(19);
        }
        
        nameTimeStr = [NSString stringWithFormat:@"%@ %@",model.sendUser.nickName,model.timeStr];
        [self.nickNameBtn setAttributedTitle:nil forState:UIControlStateNormal];
        [self.nickNameBtn setTitle:nameTimeStr forState:UIControlStateNormal];
        
    }
    
    
    UIImage *image = _bubbleView.image;
    CGFloat top = image.size.height/2.0;
    CGFloat left = image.size.width/2.0;
    CGFloat bottom = image.size.height/2.0;
    CGFloat right = image.size.width/2.0;
    
    self.bubbleView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
    
    _bubbleView.frame = CGRectMake(bubbleX, CGRectGetMaxY(_nickNameBtn.frame) + kScale_H(12), kScale_W(108), kScale_H(88));
    _msgImageView.frame = CGRectMake(0, 0, kScale_W(108), kScale_H(88));
    
    [_msgImageView bm_setImageWithURL:[NSURL URLWithString:model.imageUrl] placeholderImage:[UIImage imageNamed:@"tk_login_logo_black"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, BMSDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }];
    
    if ([self.model.sendUser.peerID isEqualToString:YSCurrentUser.peerID])
    {//我的消息
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight  cornerRadii:CGSizeMake(20, 20)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bubbleView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.bubbleView.layer.mask = maskLayer;
    }
    else
    {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(20, 20)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bubbleView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.bubbleView.layer.mask = maskLayer;
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_msgImageView.image)
    {
        CGFloat bubbleX = 0;
        CGFloat bubbleW = 0;
        CGFloat bubbleH = kScale_H(88);
        
        CGSize size = [_msgImageView.image size];
        bubbleW = size.width *(88/size.height);
        
        if ([self.model.sendUser.peerID isEqualToString:YSCurrentUser.peerID])
        {//我的消息
            bubbleX = UI_SCREEN_WIDTH-bubbleW-kScale_W(19);
        }
        else
        {//别人的消息
            bubbleX = kScale_W(19);
        }
        _bubbleView.frame = CGRectMake(bubbleX, CGRectGetMaxY(_nickNameBtn.frame) + kScale_H(12), bubbleW, bubbleH);
        _msgImageView.frame = CGRectMake(0, 0, bubbleW, bubbleH);
    }
    
    if ([self.model.sendUser.peerID isEqualToString:YSCurrentUser.peerID])
    {//我的消息
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight  cornerRadii:CGSizeMake(20, 20)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bubbleView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.bubbleView.layer.mask = maskLayer;
    }
    else
    {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(20, 20)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bubbleView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.bubbleView.layer.mask = maskLayer;
    }
}

- (void) smallImageClick:(UITapGestureRecognizer *)tap
{
    if (nil == _bigImageView)
    {
        _bigImageView = [[UIImageView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
        _bigImageView.userInteractionEnabled = YES;
        [_bigImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigImageClick:)]];
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:_bigImageView];
    _bigImageView.image = [_msgImageView.image copy];
    _bigImageView.backgroundColor = UIColor.whiteColor;
    CGSize size = [_bigImageView.image size];
    if (size.width >= UI_SCREEN_WIDTH || size.height >= UI_SCREEN_HEIGHT)
    {
        _bigImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    else
    {
        _bigImageView.contentMode = UIViewContentModeCenter;
    }
}

- (void) bigImageClick:(UITapGestureRecognizer *) tap
{
    if (_bigImageView)
    {
        [_bigImageView removeFromSuperview];
        _bigImageView = nil;
    }
}

- (void)nickNameBtnClick:(UIButton *)sender
{
    if (![self.model.sendUser.peerID isEqualToString:YSCurrentUser.peerID])
    {
        if (![YSLiveManager shareInstance].roomConfig.isDisablePrivateChat)
        {
            if (self.nickNameBtnClick)
            {
                self.nickNameBtnClick();
            }
        }
    }
}

@end

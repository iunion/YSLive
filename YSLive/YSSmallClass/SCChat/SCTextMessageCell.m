//
//  SCChatTableViewCell.m
//  YSLive
//
//  Created by 马迪 on 2019/11/7.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCTextMessageCell.h"

#define ChatViewWidth 284

@interface SCTextMessageCell()

///用户名
@property (nonatomic, strong) UILabel *nickNameLab;
///气泡View
@property (nonatomic, strong) UIImageView * bubbleView;
///消息内容
@property (nonatomic, strong) UILabel * msgLab;
//翻译按钮
@property (nonatomic, strong) UIButton *translateBtn;
/// 分割线
@property (nonatomic, strong) UIView *lineView;
///翻译内容
@property (nonatomic, strong) UILabel *translationText;

@end

@implementation SCTextMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor             = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;        
        [self setupView];
    }
    return self;
}

///创建控件
- (void)setupView
{
    //昵称
    self.nickNameLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, ChatViewWidth-2*10, 20)];
    self.nickNameLab.backgroundColor = [UIColor clearColor];
    self.nickNameLab.textAlignment = NSTextAlignmentLeft;
    self.nickNameLab.lineBreakMode = NSLineBreakByTruncatingTail;
    self.nickNameLab.font = UI_FONT_14;
    self.nickNameLab.textColor = [UIColor bm_colorWithHexString:@"#8D9CBC"];
    [self.contentView addSubview:self.nickNameLab];
    
    //气泡
    self.bubbleView = [[UIImageView alloc] init];
    self.bubbleView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.bubbleView];
    
    //翻译按钮
    self.translateBtn = [[UIButton alloc]init];
    [self.translateBtn addTarget:self action:@selector(translateBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.translateBtn setBackgroundColor:[UIColor clearColor]];
    [self.bubbleView addSubview:self.translateBtn];
    
    //文字内容
    self.msgLab = [[UILabel alloc]init];
    self.msgLab.font = UI_FONT_14;
    self.msgLab.numberOfLines = 0;
    [self.bubbleView addSubview:self.msgLab];
    
}
- (void)setModel:(YSChatMessageModel *)model
{
    _model = model;
    
    NSString * nameTimeStr = nil;
        
    NSMutableAttributedString * attMessage = [model emojiViewWithMessage:model.message font:15];
    if (!model.messageSize.width && [model.message bm_isNotEmpty]) {
        
        model.messageSize = [attMessage bm_sizeToFitWidth:200];
    }
    
    NSMutableAttributedString * attTranslation = [model emojiViewWithMessage:model.detailTrans font:15];
    
    if (!model.translatSize.width && [model.detailTrans bm_isNotEmpty]) {
        model.translatSize = [attTranslation bm_sizeToFitWidth:200];
    }
    
    CGFloat bubbleW = model.messageSize.width + 10 + 10 + 13 + 10;
    
    if (model.messageSize.width<model.translatSize.width) {
        bubbleW = model.translatSize.width + 10 + 10 + 13 + 10;
    }
    
    CGFloat bubbleH = 0;
    CGFloat bubbleX = 0;
    
    self.msgLab.attributedText = attMessage;
    
    if ([model.sendUser.peerID isEqualToString:YSCurrentUser.peerID])
    {//我的消息
        nameTimeStr = [NSString stringWithFormat:@"%@ %@",YSLocalized(@"Role.Me"),model.timeStr];
        self.nickNameLab.textAlignment = NSTextAlignmentRight;
        self.nickNameLab.textColor = [UIColor bm_colorWithHexString:@"#5A8CDC"];
        self.msgLab.textColor = [UIColor whiteColor];
        self.translationText.textColor = [UIColor whiteColor];
        self.bubbleView.backgroundColor = [UIColor bm_colorWithHexString:@"#82ABEC"];
        [self.translateBtn setImage:[UIImage imageNamed:@"myTranslate"] forState:UIControlStateNormal];
        bubbleX = ChatViewWidth-10-bubbleW;
    }
    else
    {//别人的消息
        nameTimeStr = [NSString stringWithFormat:@"%@ %@",model.sendUser.nickName,model.timeStr];
        self.nickNameLab.textAlignment = NSTextAlignmentLeft;;
        self.nickNameLab.textColor = [UIColor bm_colorWithHexString:@"#828282"];
        self.msgLab.textColor = [UIColor bm_colorWithHexString:@"#828282"];
        self.translationText.textColor = [UIColor bm_colorWithHexString:@"#828282"];
        self.bubbleView.backgroundColor = [UIColor bm_colorWithHexString:@"#DEEAFF"];
        [self.translateBtn setImage:[UIImage imageNamed:@"translate"] forState:UIControlStateNormal];
        bubbleX = 10;
    }
    
    self.nickNameLab.text = nameTimeStr;
    
    if (model.detailTrans.length)
    {//有翻译
        bubbleH = 5 + model.messageSize.height + 5+1+5+model.translatSize.height+5;
        self.bubbleView.frame = CGRectMake(bubbleX, CGRectGetMaxY(self.nickNameLab.frame)+5, bubbleW, bubbleH);
        self.msgLab.frame = CGRectMake(10, 5, model.messageSize.width, model.messageSize.height);
        self.translateBtn.frame = CGRectMake(bubbleW-10-23, 3, 23, 20);
        self.lineView.hidden = NO;
        self.translationText.hidden = NO;
        self.translationText.attributedText = attTranslation;
        self.lineView.frame = CGRectMake(10, CGRectGetMaxY(self.msgLab.frame)+5, self.bubbleView.bm_width-20, 1.0);
        self.translationText.frame = CGRectMake(self.msgLab.bm_originX,CGRectGetMaxY(self.lineView.frame) + 5, self.model.translatSize.width, self.model.translatSize.height);
    }
    else
    {//无翻译
        bubbleH = 5 + model.messageSize.height + 5;
        self.bubbleView.frame = CGRectMake(bubbleX, CGRectGetMaxY(self.nickNameLab.frame)+5, bubbleW, bubbleH);
        self.msgLab.frame = CGRectMake(10, 5, model.messageSize.width, model.messageSize.height);
        self.translateBtn.frame = CGRectMake(bubbleW-10-23, 3, 23 , 20);
        self.lineView.hidden = YES;
        self.translationText.hidden = YES;
    }
    
    UIImage *image = _bubbleView.image;
    CGFloat top = image.size.height/2.0;
    CGFloat left = image.size.width/2.0;
    CGFloat bottom = image.size.height/2.0;
    CGFloat right = image.size.width/2.0;
    
    self.bubbleView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
    
    if ([model.sendUser.peerID isEqualToString:YSCurrentUser.peerID])
    {//我的消息
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight  cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bubbleView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.bubbleView.layer.mask = maskLayer;
    }
    else
    {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bubbleView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.bubbleView.layer.mask = maskLayer;
    }    
}


- (void)translateBtnClick
{
    if (_translationBtnClick)
    {
        _translationBtnClick();
    }
}


/// 分割线
- (UIView *)lineView
{
    if (!_lineView)
    {
        self.lineView = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(self.msgLab.frame)+5, self.bubbleView.bm_width-20, 1.0)];
        self.lineView.backgroundColor = [UIColor bm_colorWithHexString:@"#EEEEEE"];
        [self.bubbleView addSubview:self.lineView];
    }
    return _lineView;
}
///翻译内容
- (UILabel *)translationText
{
    if (!_translationText)
    {
        self.translationText = [[UILabel alloc] initWithFrame:CGRectMake(self.msgLab.bm_originX,CGRectGetMaxY(self.lineView.frame) + 5, self.model.translatSize.width, self.model.translatSize.height)];
        self.translationText.backgroundColor = [UIColor clearColor];
        self.translationText.lineBreakMode = NSLineBreakByTruncatingTail;
        self.translationText.font = UI_FONT_14;
        self.translationText.numberOfLines = 0;
        self.translationText.textColor = [UIColor bm_colorWithHexString:@"#345376"];
        [self.bubbleView addSubview:self.translationText];
    }
    return _translationText;
}

@end

//
//  SYTextMessageCell.m
//  YSLive
//
//  Created by 马迪 on 2019/10/16.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSTextMessageCell.h"

@interface YSTextMessageCell()

///用户名
//@property (nonatomic, strong) UILabel *nickNameLab;
///用户名
@property (nonatomic, strong) UIButton *nickNameBtn;
///气泡View
@property (nonatomic, strong) UIImageView * bubbleView;
///消息内容
@property (nonatomic, strong) UILabel * msgLab;

@end

@implementation YSTextMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        //        self.backgroundColor = UIColor.redColor;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupUIView];
    }
    return self;
}


- (void)setupUIView
{
    //昵称
    //    self.nickNameLab = [[UILabel alloc] initWithFrame:CGRectMake(kScale_W(12), 0, UI_SCREEN_WIDTH-2*kScale_W(12), kScale_H(12))];
    //    self.nickNameLab.backgroundColor = [UIColor clearColor];
    //    self.nickNameLab.lineBreakMode = NSLineBreakByTruncatingTail;
    //    self.nickNameLab.font = UI_FONT_14;
    //    [self.contentView addSubview:self.nickNameLab];
    
    self.nickNameBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScale_W(12), 0, UI_SCREEN_WIDTH-2*kScale_W(12), kScale_H(12))];
    [self.nickNameBtn setBackgroundColor:[UIColor clearColor]];
    self.nickNameBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.nickNameBtn addTarget:self action:@selector(nickNameBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.nickNameBtn.titleLabel.font = UI_FONT_14;
    [self.contentView addSubview:self.nickNameBtn];
    
    
    //气泡
    self.bubbleView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.bubbleView];
    
    //    self.bubbleView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    //    //剪切边界 如果视图上的子视图layer超出视图layer部分就截取掉 如果添加阴影这个属性必须是NO 不然会把阴影切掉
    //    self.bubbleView.layer.masksToBounds = NO;
    //    //阴影半径，默认3
    //    self.bubbleView.layer.shadowRadius = 3;
    //    //shadowOffset阴影偏移，有偏移量的情况,默认向右向下有阴影,设置偏移量为0,四周都有阴影
    //    self.bubbleView.layer.shadowOffset = CGSizeZero;
    //    // 阴影透明度，默认0
    //    self.bubbleView.layer.shadowOpacity = 0.9f;
    
    //文字内容
    self.msgLab = [[UILabel alloc]init];
    self.msgLab.font = UI_FONT_15;
    self.msgLab.textColor = [UIColor whiteColor];
    self.msgLab.numberOfLines = 0;
    [self.bubbleView addSubview:self.msgLab];
}

- (void)setModel:(YSChatMessageModel *)model
{
    _model = model;
    NSString * nameTimeStr = nil;
    
    // iOS 获取设备当前语言和地区的代码
    NSString *currentLanguageRegion = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject];
    
    NSMutableAttributedString * att = [model emojiViewWithMessage:model.message font:15];
    CGSize size = [att bm_sizeToFitWidth:kScale_W(300)];
    
    CGFloat bubbleW = size.width + kScale_W(22)+kScale_W(20);
    
    CGFloat bubbleX = 0;
    self.msgLab.attributedText = att;
    
    if (model.isPersonal)
    {//私聊
        [self.nickNameBtn setTitleColor:[UIColor bm_colorWithHexString:@"#40B76B"] forState:UIControlStateNormal];
        if ([model.sendUser.peerID isEqualToString:YSCurrentUser.peerID])
        {//我的消息
            
            if ([currentLanguageRegion isEqualToString:@"zh-Hans-CN"]) {
                nameTimeStr = [NSString stringWithFormat:@"%@ 我对“%@”说",model.timeStr,model.receiveUser.nickName];
            }
            else if([currentLanguageRegion isEqualToString:@"zh-Hant-CN"])
            {
                nameTimeStr = [NSString stringWithFormat:@"%@ 我對“%@”說",model.timeStr,model.receiveUser.nickName];
            }
            else if ([currentLanguageRegion bm_containString:@"en"])

            {
                nameTimeStr = [NSString stringWithFormat:@"%@ Chat to “%@”",model.timeStr,model.receiveUser.nickName];
            }
            
            
            self.nickNameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            self.msgLab.textColor = [UIColor whiteColor];
            self.bubbleView.backgroundColor = [UIColor bm_colorWithHexString:@"#82ABEC"];
            bubbleX = UI_SCREEN_WIDTH-kScale_W(10)-bubbleW;
            
            NSMutableAttributedString * mutAtt = [[NSMutableAttributedString alloc]initWithString:nameTimeStr];
            [mutAtt addAttributes:@{NSForegroundColorAttributeName:[UIColor bm_colorWithHexString:@"#5A8CDC"]} range:NSMakeRange(nameTimeStr.length-model.receiveUser.nickName.length-3, model.receiveUser.nickName.length+3)];
            [mutAtt addAttributes:@{NSForegroundColorAttributeName:[UIColor bm_colorWithHexString:@"#828282"]} range:NSMakeRange(0, nameTimeStr.length-model.receiveUser.nickName.length-3)];
             [self.nickNameBtn setTitle:nil forState:UIControlStateNormal];
            [self.nickNameBtn setAttributedTitle:mutAtt forState:UIControlStateNormal];
        }
        else
        {//别人的消息
            nameTimeStr = [NSString stringWithFormat:@"“%@” %@ %@",model.sendUser.nickName,YSLocalized(@"Label.ChatToMe"),model.timeStr];
            self.nickNameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            self.msgLab.textColor = [UIColor bm_colorWithHexString:@"#345376"];
            self.bubbleView.backgroundColor = [UIColor bm_colorWithHexString:@"#DEEAFF"];
            bubbleX = kScale_W(10);
            
            NSMutableAttributedString * mutAtt = [[NSMutableAttributedString alloc]initWithString:nameTimeStr];
            [mutAtt addAttributes:@{NSForegroundColorAttributeName:[UIColor bm_colorWithHexString:@"#5A8CDC"]} range:NSMakeRange(0, model.sendUser.nickName.length+2)];
            [mutAtt addAttributes:@{NSForegroundColorAttributeName:[UIColor bm_colorWithHexString:@"#828282"]} range:NSMakeRange(model.sendUser.nickName.length+2, nameTimeStr.length-model.sendUser.nickName.length-2)];
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
            self.msgLab.textColor = [UIColor whiteColor];
            self.bubbleView.backgroundColor = [UIColor bm_colorWithHexString:@"#82ABEC"];
            bubbleX = UI_SCREEN_WIDTH-kScale_W(10)-bubbleW;
        }
        else
        {//别人的消息
            self.nickNameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            self.msgLab.textColor = [UIColor bm_colorWithHexString:@"#345376"];
            self.bubbleView.backgroundColor = [UIColor bm_colorWithHexString:@"#DEEAFF"];
            bubbleX = kScale_W(10);
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
    
    
    _bubbleView.frame = CGRectMake(bubbleX, CGRectGetMaxY(_nickNameBtn.frame)+kScale_H(12), bubbleW, size.height+kScale_H(20));
    _msgLab.frame = CGRectMake(kScale_W(20), kScale_H(10), size.width , size.height);
    
    
    NSAttributedString * test = [[NSAttributedString alloc]initWithString:@"你好吗"];
    
    CGSize testSize = [test bm_sizeToFitWidth:kScale_W(300)];
    
    CGFloat textH = (testSize.height+ kScale_H(20))/2;
    
    if ([self.model.sendUser.peerID isEqualToString:YSCurrentUser.peerID])
    {//我的消息
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerBottomRight  cornerRadii:CGSizeMake(textH, textH)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bubbleView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.bubbleView.layer.mask = maskLayer;
    }
    else
    {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(textH, textH)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bubbleView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.bubbleView.layer.mask = maskLayer;
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

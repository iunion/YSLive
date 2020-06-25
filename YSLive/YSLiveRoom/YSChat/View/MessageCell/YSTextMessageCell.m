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
//@property (nonatomic, strong) UIImageView * bubbleView;
@property (nonatomic, strong) UIView * bubbleView;


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
    self.nickNameBtn = [[UIButton alloc]initWithFrame:CGRectMake(kBMScale_W(12), 0, BMUI_SCREEN_WIDTH-2*kBMScale_W(12), kBMScale_H(12))];
//    [self.nickNameBtn setBackgroundColor:[UIColor clearColor]];
    self.nickNameBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.nickNameBtn addTarget:self action:@selector(nickNameBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.nickNameBtn.titleLabel.font = UI_FONT_14;
    [self.contentView addSubview:self.nickNameBtn];
    
    //气泡
    self.bubbleView = [[UIView alloc] init];
    self.bubbleView.backgroundColor = YSSkinDefineColor(@"defaultTitleColor");
    [self.contentView addSubview:self.bubbleView];
    self.bubbleView.layer.cornerRadius = 4;
    
    //文字内容
    self.msgLab = [[UILabel alloc]init];
    self.msgLab.font = UI_FONT_15;
    self.msgLab.numberOfLines = 0;
    [self.bubbleView addSubview:self.msgLab];
//    self.msgLab.backgroundColor = UIColor.w;
}

- (void)setModel:(YSChatMessageModel *)model
{
    _model = model;
    NSString * nameTimeStr = nil;
    
    // iOS 获取设备当前语言和地区的代码
    NSString *currentLanguageRegion = [[NSLocale preferredLanguages] firstObject];
    
    NSMutableAttributedString * att = [model emojiViewWithMessage:model.message font:15];
    CGSize size = [att bm_sizeToFitWidth:kBMScale_W(300)];
    
    CGFloat bubbleW = size.width + kBMScale_W(5)+kBMScale_W(5);
    
    CGFloat bubbleX = 0;
    self.msgLab.attributedText = att;
    
    if (model.isPersonal)
    {//私聊
        [self.nickNameBtn setTitleColor:[UIColor bm_colorWithHexString:@"#40B76B"] forState:UIControlStateNormal];
        if ([model.sendUser.peerID isEqualToString:YSCurrentUser.peerID])
        {//我的消息
            
            if ([currentLanguageRegion bm_containString:@"zh-Hans"]) {
                nameTimeStr = [NSString stringWithFormat:@"%@ 我对“%@”说",model.timeStr,model.receiveUser.nickName];
            }
            else if([currentLanguageRegion bm_containString:@"zh-Hant"])
            {
                nameTimeStr = [NSString stringWithFormat:@"%@ 我對“%@”說",model.timeStr,model.receiveUser.nickName];
            }
            else
            {
                nameTimeStr = [NSString stringWithFormat:@"%@ Chat to “%@”",model.timeStr,model.receiveUser.nickName];
            }
            
            self.nickNameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            bubbleX = BMUI_SCREEN_WIDTH - kBMScale_W(10)-bubbleW;
            
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
            bubbleX = kBMScale_W(10);
            
            NSMutableAttributedString * mutAtt = [[NSMutableAttributedString alloc]initWithString:nameTimeStr];
            [mutAtt addAttributes:@{NSForegroundColorAttributeName:[UIColor bm_colorWithHexString:@"#5A8CDC"]} range:NSMakeRange(0, model.sendUser.nickName.length+2)];
            [mutAtt addAttributes:@{NSForegroundColorAttributeName:[UIColor bm_colorWithHexString:@"#828282"]} range:NSMakeRange(model.sendUser.nickName.length+2, nameTimeStr.length-model.sendUser.nickName.length-2)];
             [self.nickNameBtn setTitle:nil forState:UIControlStateNormal];
            [self.nickNameBtn setAttributedTitle:mutAtt forState:UIControlStateNormal];
        }
    }
    else
    {//群聊
        [self.nickNameBtn setTitleColor:YSSkinDefineColor(@"liveTimeTextColor") forState:UIControlStateNormal];
        
        if ([model.sendUser.peerID isEqualToString:YSCurrentUser.peerID])
        {//我的消息
            self.nickNameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;            bubbleX = BMUI_SCREEN_WIDTH-kBMScale_W(10)-bubbleW;
        }
        else
        {//别人的消息
            self.nickNameBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            bubbleX = kBMScale_W(10);
        }
        nameTimeStr = [NSString stringWithFormat:@"%@ %@",model.sendUser.nickName,model.timeStr];
        [self.nickNameBtn setAttributedTitle:nil forState:UIControlStateNormal];
        [self.nickNameBtn setTitle:nameTimeStr forState:UIControlStateNormal];
    }
    
    _bubbleView.frame = CGRectMake(bubbleX, CGRectGetMaxY(_nickNameBtn.frame)+kBMScale_H(5), bubbleW, size.height+kBMScale_H(10));
    _msgLab.frame = CGRectMake(kBMScale_W(5), kBMScale_H(5), size.width , size.height);
 
}

- (void)nickNameBtnClick:(UIButton *)sender
{
    if (![self.model.sendUser.peerID isEqualToString:YSCurrentUser.peerID])
    {
        if (![YSLiveManager sharedInstance].roomConfig.isDisablePrivateChat)
        {
            if (self.nickNameBtnClick)
            {
                self.nickNameBtnClick();
            }
        }
    }
}


@end

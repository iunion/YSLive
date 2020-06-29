//
//  TMNewMessageCell.m
//  EduClass
//
//  Created by talk on 2018/11/21.
//  Copyright © 2018年 talkcloud. All rights reserved.
//

#import "YSNewTipMessageCell.h"


@interface YSNewTipMessageCell ()

@property (nonatomic, strong) UILabel *iMessageLabel;

@end

@implementation YSNewTipMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor             = [UIColor clearColor];
        //                self.backgroundColor = [UIColor greenColor];
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    self.backView = [[UIView alloc] init];
    self.backView.backgroundColor = YSSkinDefineColor(@"defaultTitleColor");
    self.backView.layer.cornerRadius = 12.5;
    [self.contentView addSubview:self.backView];
    
    self.iMessageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.iMessageLabel.backgroundColor = UIColor.clearColor;
    self.iMessageLabel.textAlignment = NSTextAlignmentCenter;
    self.iMessageLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.iMessageLabel.numberOfLines = 1;
    [self.iMessageLabel setFont:UI_FONT_12];
    self.iMessageLabel.textColor = YSSkinDefineColor(@"placeholderColor");
    [self.backView addSubview:self.iMessageLabel];
}

- (void)setModel:(YSChatMessageModel *)model
{
    _model = model;
    
    if (model.chatMessageType == YSChatMessageType_ImageTips)
    {
        NSString * str = [NSString stringWithFormat:@"  %@%@ ",model.sendUser.nickName,YSLocalized(@"Role.ToTeacher")];
        NSMutableAttributedString * mutAttrString = [[NSMutableAttributedString alloc]initWithString:str];
        NSTextAttachment * attch = [[NSTextAttachment alloc]init];
        attch.bounds = CGRectMake(0, 0, 20, 19);
        attch.image = [UIImage imageNamed:@"flower"];
        NSAttributedString * imageStr = [NSAttributedString attributedStringWithAttachment:attch];
        [mutAttrString appendAttributedString:imageStr];
        
        [mutAttrString insertAttributedString:[[NSAttributedString alloc] initWithString:model.timeStr] atIndex:0];
        [mutAttrString appendAttributedString:[[NSAttributedString alloc]initWithString:@" x1"]];
        [mutAttrString addAttributes:@{NSFontAttributeName:UI_FONT_14,NSForegroundColorAttributeName:[UIColor bm_colorWithHexString:@"#FF5E95"]} range:NSMakeRange(mutAttrString.length-2, 2)];
        //花两侧的文字上浮，跟花的中心平齐
        [mutAttrString addAttributes:@{NSBaselineOffsetAttributeName:@(3)} range:NSMakeRange(0, mutAttrString.length-4)];
        [mutAttrString addAttributes:@{NSBaselineOffsetAttributeName:@(-2)} range:NSMakeRange(mutAttrString.length-4, 1)];
        [mutAttrString addAttributes:@{NSBaselineOffsetAttributeName:@(3)} range:NSMakeRange(mutAttrString.length-2, 2)];
        self.iMessageLabel.text = nil;
        self.iMessageLabel.attributedText = mutAttrString;
    }
    else
    {
        self.iMessageLabel.attributedText = nil;
        self.iMessageLabel.text = [NSString stringWithFormat:@"%@ %@",model.timeStr,model.message];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = 0.f;

    if (self.model.chatMessageType == YSChatMessageType_ImageTips)
    {
        width = [self.iMessageLabel.attributedText bm_sizeToFitHeight:25].width+20;
    }
    else
    {
        width = [self.iMessageLabel.text bm_sizeToFitWidth:self.bm_width - 20 withFont:UI_FONT_12].width;
    }
    self.backView.frame = CGRectMake((BMUI_SCREEN_WIDTH-width - kBMScale_W(20))/2, kBMScale_H(10), width + kBMScale_W(20), kBMScale_H(25));
    self.iMessageLabel.frame = CGRectMake(kBMScale_W(10), 0, width, kBMScale_H(25));
    
    
}

@end

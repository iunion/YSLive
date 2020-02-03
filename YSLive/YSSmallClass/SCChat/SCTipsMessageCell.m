//
//  SCTipsMessageCell.m
//  YSLive
//
//  Created by 马迪 on 2019/11/16.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCTipsMessageCell.h"

//右侧聊天视图宽度
#define ChatViewWidth 284

@interface SCTipsMessageCell ()

@property (nonatomic, strong) UILabel *iMessageLabel;

@end

@implementation SCTipsMessageCell

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
    self.backView.backgroundColor = [UIColor bm_colorWithHexString:@"#EFF3FA"];
    self.backView.layer.cornerRadius = 12.5;
    [self.contentView addSubview:self.backView];
    
    self.iMessageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.iMessageLabel.backgroundColor = UIColor.clearColor;
    self.iMessageLabel.textAlignment = NSTextAlignmentCenter;
    self.iMessageLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.iMessageLabel.numberOfLines = 1;
    [self.iMessageLabel setFont:UI_FONT_12];
    self.iMessageLabel.textColor = [UIColor bm_colorWithHexString:@"#8D9CBC"];
    [self.backView addSubview:self.iMessageLabel];
}

- (void)setModel:(YSChatMessageModel *)model
{
    _model = model;
    
    if (model.chatMessageType == YSChatMessageTypeImageTips)
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
        self.iMessageLabel.attributedText = mutAttrString;
    }
    else
    {
        self.iMessageLabel.text = [NSString stringWithFormat:@"%@ %@",model.timeStr,model.message];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = 0.f;
    if (self.model.chatMessageType == YSChatMessageTypeImageTips)
    {
        width = [self.iMessageLabel.attributedText bm_sizeToFitHeight:25].width+20;
    }
    else
    {
        width = [self.iMessageLabel.text bm_sizeToFitWidth:ChatViewWidth - 20 withFont:UI_FONT_12].width;
    }
    self.backView.frame = CGRectMake((ChatViewWidth-width - 20)/2, 10, width + 20, 25);
    self.iMessageLabel.frame = CGRectMake(10, 0, width, 25);
}
@end

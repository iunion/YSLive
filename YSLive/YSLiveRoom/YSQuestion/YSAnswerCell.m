//
//  YSAnswerCell.m
//  YSLive
//
//  Created by 马迪 on 2019/10/21.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSAnswerCell.h"

@interface YSAnswerCell()

///标签
@property (nonatomic, strong) UILabel *tagLab;
///用户名
@property (nonatomic, strong) UILabel *nickNameLab;
///气泡View
@property (nonatomic, strong) UIView * bubbleView;
///提问的内容
@property (nonatomic, strong) UILabel *questLab;
///提问的翻译按钮
@property (nonatomic, strong) UIButton *questTransBtn;
/// 提问的分割线
@property (nonatomic, strong) UIView *questLine;
///提问的翻译内容
@property (nonatomic, strong) UILabel *questTransLab;
///回复的内容
@property (nonatomic, strong) UILabel * answerLab;
///回复的翻译按钮
@property (nonatomic, strong) UIButton *answerTransBtn;
///回复的翻译内容
@property (nonatomic, strong) UILabel *answerTransLab;

@end

@implementation YSAnswerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor             = [UIColor clearColor];
//        self.backgroundColor = UIColor.greenColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupView];
    }
    return self;
}

//创建控件
- (void)setupView
{
    //v标签
    self.tagLab = [[UILabel alloc] init];
    self.tagLab.font = UI_FONT_12;
    self.tagLab.textColor = [UIColor whiteColor];
    self.tagLab.layer.cornerRadius = 4;
    self.tagLab.layer.masksToBounds = YES;
    self.tagLab.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.tagLab];
    
    //昵称
    self.nickNameLab = [[UILabel alloc] init];
    self.nickNameLab.backgroundColor = [UIColor clearColor];
    self.nickNameLab.font = UI_FONT_12;
    self.nickNameLab.textColor = YSSkinDefineColor(@"liveTimeTextColor");
    [self.contentView addSubview:self.nickNameLab];
    
    //气泡
    self.bubbleView = [[UIView alloc] init];
    self.bubbleView.backgroundColor = YSSkinDefineColor(@"defaultTitleColor");
    self.bubbleView.layer.cornerRadius = 4;
    [self.contentView addSubview:self.bubbleView];
    
    //提问文字内容
    self.questLab = [[UILabel alloc]init];
    self.questLab.font = UI_FONT_14;
    self.questLab.textColor = YSSkinDefineColor(@"login_placeholderColor");
    self.questLab.numberOfLines = 0;
    [self.bubbleView addSubview:self.questLab];
    
    //提问翻译按钮
    self.questTransBtn = [[UIButton alloc]init];
    self.questTransBtn.tag = 1;
    [self.questTransBtn addTarget:self action:@selector(translateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.questTransBtn setImage:[UIImage imageNamed:@"translate"] forState:UIControlStateNormal];
    [self.questTransBtn setBackgroundColor:[UIColor clearColor]];
    [self.bubbleView addSubview:self.questTransBtn];
//    [self.questTransBtn setBackgroundColor:UIColor.redColor];
    
    //提问的翻译内容
    self.questTransLab = [[UILabel alloc]init];
    self.questTransLab.font = UI_FONT_14;
    self.questTransLab.textColor = YSSkinDefineColor(@"login_placeholderColor");
    self.questTransLab.numberOfLines = 0;
    [self.bubbleView addSubview:self.questTransLab];
    
    //回复文字内容
    self.answerLab = [[UILabel alloc]init];
    self.answerLab.font = UI_FONT_14;
    self.answerLab.textColor = YSSkinDefineColor(@"login_placeholderColor");
    self.answerLab.numberOfLines = 0;
    [self.contentView addSubview:self.answerLab];
    
    //回复翻译按钮
    self.answerTransBtn = [[UIButton alloc]init];
    self.answerTransBtn.tag = 2;
    [self.answerTransBtn addTarget:self action:@selector(translateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.answerTransBtn setImage:[UIImage imageNamed:@"translate"] forState:UIControlStateNormal];
    [self.answerTransBtn setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:self.answerTransBtn];
//    [self.answerTransBtn setBackgroundColor:UIColor.redColor];
    
    //回复的翻译内容
    self.answerTransLab = [[UILabel alloc]init];
    self.answerTransLab.font = UI_FONT_14;
    self.answerTransLab.textColor = YSSkinDefineColor(@"login_placeholderColor");
    self.answerTransLab.numberOfLines = 0;
    [self.contentView addSubview:self.answerTransLab];
}

- (void)setModel:(YSQuestionModel *)model
{
    _model = model;
        
    CGFloat bubbleX = 0;
    CGFloat bubbleW = 0;
    CGFloat bubbleH = 0;
    
    if (model.state == YSQuestionState_Answer)
    {//回复
        self.questTransBtn.hidden = YES;
        self.questTransLab.hidden = YES;
        self.questLine.hidden = YES;
        self.answerLab.hidden = NO;
        self.answerTransBtn.hidden = NO;
        self.answerTransLab.hidden = NO;
        self.answerTransLab.hidden = ![model.detailTrans bm_isNotEmpty];
        
        NSString * nameTimeStr = [NSString stringWithFormat:@"%@ %@",model.nickName,model.timeStr];
        CGSize nameSize = [nameTimeStr bm_sizeToFitWidth:150 withFont:UI_FONT_12];
        self.nickNameLab.text = nameTimeStr;
        
        self.tagLab.backgroundColor = [UIColor bm_colorWithHex:0x5ABEDC];
        self.tagLab.text = YSLocalized(@"Label.Reply");
        
        CGSize tagSize = [self.tagLab.text bm_sizeToFitWidth:100 withFont:UI_FONT_12];
        self.nickNameLab.frame = CGRectMake(20, 10, nameSize.width, nameSize.height);
        self.tagLab.frame = CGRectMake(self.nickNameLab.bm_right+10, 10, tagSize.width+10, tagSize.height);

        self.answerLab.text = model.answerDetails;
        self.answerLab.frame = CGRectMake(20, 10 + tagSize.height + 5, model.answerDetailsSize.width, model.answerDetailsSize.height);
        self.answerTransBtn.frame = CGRectMake(self.answerLab.bm_right + 5, self.answerLab.bm_top-5, 14+10, 14+10);
         
        NSString * kkk = YSLocalized(@"Label.Question");
        
        NSString * questStr = [NSString stringWithFormat:@"%@：%@",kkk,model.questDetails];
        CGSize questStrSize = [questStr bm_sizeToFitWidth:kBMScale_W(300) withFont:UI_FONT_14];
        self.questLab.text = questStr;
                
        if (![model.detailTrans bm_isNotEmpty])
        {//没有翻译
            self.bubbleView.frame = CGRectMake(20, self.answerLab.bm_bottom + 5, 5 + questStrSize.width + 10 , 10 + questStrSize.height + 10);
        }
        else
        {//有翻译
            self.answerTransLab.text = model.detailTrans;
            self.answerTransLab.frame = CGRectMake(20, self.answerLab.bm_bottom+5, model.translatSize.width, model.translatSize.height);
            self.bubbleView.frame = CGRectMake(20, self.answerTransLab.bm_bottom + 5, 5 + questStrSize.width + 10 , 10 + questStrSize.height + 10);
        }
        self.questLab.frame = CGRectMake(5, 10, questStrSize.width, questStrSize.height);
    }
    else
    {//提问和审核
        self.questTransBtn.hidden = NO;
        self.answerLab.hidden = YES;
        self.answerTransBtn.hidden = YES;
        self.answerTransLab.hidden = YES;
        self.questLine.hidden = ![model.detailTrans bm_isNotEmpty];
        self.questTransLab.hidden = ![model.detailTrans bm_isNotEmpty];
        
        NSString * nameTimeStr = [NSString stringWithFormat:@"%@ %@",model.nickName,model.timeStr];
        
        if (model.state  == YSQuestionState_Question)
        {//待审核
            self.tagLab.backgroundColor = [UIColor bm_colorWithHex:0xFB8B2C];
            self.tagLab.text = YSLocalized(@"Label.Inspect");
        }
        else
        {//通过审核
            self.tagLab.backgroundColor = [UIColor bm_colorWithHex:0x82ABEC];
            self.tagLab.text = YSLocalized(@"Label.Pass");
            if ([model.toUserNickname bm_isNotEmpty])
            {
                nameTimeStr = [NSString stringWithFormat:@"%@ %@",model.toUserNickname,model.timeStr];
            }
            else
            {
                nameTimeStr = [NSString stringWithFormat:@"%@ %@",model.nickName,model.timeStr];
            }
        }
              
        CGSize nameSize = [nameTimeStr bm_sizeToFitWidth:150 withFont:UI_FONT_12];
        self.nickNameLab.text = nameTimeStr;
        
        CGSize tagSize = [self.tagLab.text bm_sizeToFitWidth:100 withFont:UI_FONT_12];
        
        self.nickNameLab.frame = CGRectMake(BMUI_SCREEN_WIDTH-20-nameSize.width, 10, nameSize.width, nameSize.height);
        self.tagLab.frame = CGRectMake(self.nickNameLab.bm_left-10-10-tagSize.width, 10, tagSize.width+10, tagSize.height);

        self.questLab.text = model.questDetails;
        if (![model.detailTrans bm_isNotEmpty])
        {//没有翻译
            
            bubbleW = model.questDetailsSize.width + 5 + 35;
            bubbleX = BMUI_SCREEN_WIDTH - 20 - bubbleW;
            bubbleH = model.questDetailsSize.height + 2 * 10;
            
            self.bubbleView.frame = CGRectMake(bubbleX, 10 + tagSize.height + 5, bubbleW, bubbleH);
            self.questLab.frame = CGRectMake(5, 10, model.questDetailsSize.width, model.questDetailsSize.height);
        }
        else
        {//有翻译
            
            self.questTransLab.text = model.detailTrans;
            
            if (model.questDetailsSize.width >= model.translatSize.width)
            {
                bubbleW = model.questDetailsSize.width + 10 + 5;
            }
            else
            {
                bubbleW = model.translatSize.width + 10 + 5;
            }
            bubbleX = BMUI_SCREEN_WIDTH-20- bubbleW;
            bubbleH = 10 + model.questDetailsSize.height + 4 + 1 + 4 + model.translatSize.height + 10;
            
            self.bubbleView.frame = CGRectMake(bubbleX, self.tagLab.bm_bottom + 5, bubbleW, bubbleH);
            
            self.questLab.frame = CGRectMake(5, 10, model.questDetailsSize.width, model.questDetailsSize.height);
            self.questLine.frame = CGRectMake(13, self.questLab.bm_bottom+4, self.bubbleView.bm_width-13*2, 1);
            self.questTransLab.frame = CGRectMake(5, self.questLine.bm_bottom+4, model.translatSize.width, model.translatSize.height);
        }
        self.questTransBtn.frame = CGRectMake(self.bubbleView.bm_width-15-15, self.questLab.bm_top-5, 14+10, 14+10);
    }
}

//翻译按钮点击
- (void)translateBtnClick:(UIButton *)sender
{
    if (_translationBtnClick)
    {
        _translationBtnClick();
    }
}

// 提问翻译的分割线
- (UIView *)questLine
{
    if (!_questLine)
    {
        self.questLine = [[UIView alloc]initWithFrame:CGRectMake(13, CGRectGetMaxY(self.questLab.frame)+4, self.bubbleView.bm_width-2*13, 1.0)];
        self.questLine.backgroundColor = [UIColor bm_colorWithHexString:@"#EEEEEE"];
        [self.bubbleView addSubview:self.questLine];
    }
    return _questLine;
}

@end

//
//  YSLessonNotifyTableCell.m
//  YSLive
//
//  Created by fzxm on 2019/10/17.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSLessonNotifyTableCell.h"
#import "YSLessonModel.h"
#import <BMKit/BMImageTextView.h>

@interface YSLessonNotifyTableCell()
/// 时间
@property (nonatomic, strong) UILabel *timeL;
/// 底部气泡
@property (nonatomic, strong) UIView *bacView;
/// logo
@property (nonatomic, strong) UIImageView *typeView;
/// 翻译按钮
@property (nonatomic, strong) UIButton *translatBtn;
/// 翻译前文本
@property (nonatomic, strong) UILabel *originalL;
/// 分割线
@property (nonatomic, strong) UIView *lineView;
/// 翻译后的文字
@property (nonatomic, strong) UILabel *translatL;
/// 展开
@property (nonatomic, strong) UIButton *openBtn;

@end

@implementation YSLessonNotifyTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.timeL];
    
    [self.contentView addSubview:self.bacView];
    
    [self.contentView addSubview:self.typeView];
    
    [self.contentView addSubview:self.translatBtn];
    [self.translatBtn addTarget:self action:@selector(translatBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.originalL];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.translatL];
    
    [self.contentView addSubview:self.openBtn];
    [self.openBtn addTarget:self action:@selector(openBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.timeL.frame = CGRectMake(0, 5, UI_SCREEN_WIDTH, 17);
    
    self.bacView.frame = CGRectMake(20, 25, UI_SCREEN_WIDTH - 20 - 20, self.contentView.bm_height-25  - 10);
    self.bacView.layer.cornerRadius = self.bacView.bm_height/2 > 29 ? 16 : self.bacView.bm_height/2;
    self.bacView.layer.masksToBounds = YES;
    
    self.typeView.frame = CGRectMake(0, 0, 19, 23);
    self.typeView.bm_left = self.bacView.bm_left + 18 ;
    
    
    self.translatBtn.frame = CGRectMake(0, 0, 14, 14);
    self.translatBtn.bm_right = self.bacView.bm_right - 20;
    
    self.originalL.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH - 72 - 62, self.lessonModel.detailsHeight);
    self.originalL.bm_left = self.typeView.bm_right + 20 ;
    self.originalL.bm_top = self.bacView.bm_top + 10 ;
    
    self.typeView.bm_centerY = self.originalL.bm_centerY;//设置与原文字 居中
    self.translatBtn.bm_centerY = self.typeView.bm_centerY;
    
    self.lineView.frame = CGRectMake(0, CGRectGetMaxY(self.originalL.frame) + 8, CGRectGetWidth(self.bacView.frame) - 20, 1);
    self.lineView.bm_left = self.bacView.bm_left + 10;
    self.lineView.bm_right = self.bacView.bm_right - 10;
    
    self.translatL.frame = CGRectMake(0, CGRectGetMaxY(self.lineView.frame) + 8, UI_SCREEN_WIDTH - 72 - 62, self.lessonModel.translatHeight);
    self.translatL.bm_left = self.typeView.bm_right + 20 ;
    
    self.openBtn.bm_width = 10;
    self.openBtn.bm_height = 5;
    self.openBtn.bm_bottom = self.bacView.bm_bottom - 10;
    self.openBtn.bm_centerX = self.contentView.bm_centerX;
    self.openBtn.bm_ActionEdgeInsets =UIEdgeInsetsMake(-5, -5, -5, -5);
    
}

- (void)setLessonModel:(YSLessonModel *)lessonModel
{
    _lessonModel = lessonModel;
    self.timeL.text = lessonModel.publishTime;
    self.originalL.text = lessonModel.details;
    self.translatL.text = lessonModel.detailTrans;
    switch (_lessonModel.notifyType)
    {
        case YSLessonNotifyType_Message:
            //公告
            [self.typeView setImage:[UIImage imageNamed:@"yslive_lesson_message"]];
            break;
        case YSLessonNotifyType_Status:
            //通知
            [self.typeView setImage:[UIImage imageNamed:@"yslive_lesson_status"]];
            break;
        default:
            break;
    }
    
    if ([lessonModel.detailTrans bm_isNotEmpty])
    {
        self.openBtn.hidden = NO;
    }
    else
    {
        self.openBtn.hidden = YES;
    }

    if (lessonModel.isOpen)
    {
        self.lineView.hidden = NO;
        self.translatL.hidden = NO;
        [_openBtn setImage:[UIImage imageNamed:@"lesson_close"] forState:UIControlStateNormal];
    }
    else
    {
        self.lineView.hidden = YES;
        self.translatL.hidden = YES;
        [_openBtn setImage:[UIImage imageNamed:@"lesson_open"] forState:UIControlStateNormal];
    }
 
}


#pragma mark -
#pragma mark SEL
- (void)translatBtn:(UIButton *)btn
{
    //翻译
    if (self.translationBlock)
    {
        self.translationBlock(self);
    }
}

- (void)openBtnClicked:(UIButton *)btn
{
    if (self.openBlock)
    {
        self.openBlock(self);
    }
}

#pragma mark -
#pragma mark Lazy
- (UILabel *)timeL
{
    if (!_timeL)
    {
        _timeL = [[UILabel alloc] init];
        _timeL.textAlignment = NSTextAlignmentCenter;
        _timeL.font = UI_FSFONT_MAKE(FontNamePingFangSCRegular, 12);
        _timeL.numberOfLines = 1;
        _timeL.lineBreakMode = NSLineBreakByCharWrapping;
        _timeL.textColor = [UIColor bm_colorWithHex:0x818181];
    }
    return _timeL;
}

- (UIView *)bacView
{
    if (!_bacView)
    {
        _bacView = [[UIView alloc] init];
        _bacView.backgroundColor = [UIColor bm_colorWithHex:0xDEEAFF];
    }
    
    return _bacView;
    
}

- (UIImageView *)typeView
{
    if (!_typeView)
    {
        _typeView = [[UIImageView alloc] init];
    }
    return _typeView;
}

- (UIButton *)translatBtn
{
    if (!_translatBtn)
    {
        _translatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_translatBtn setImage:[UIImage imageNamed:@"lesson_translate"] forState:UIControlStateNormal];
    }
    
    return _translatBtn;
}

- (UILabel *)originalL
{
    if (!_originalL)
       {
           _originalL = [[UILabel alloc] init];
           _originalL.textAlignment = NSTextAlignmentLeft;
           _originalL.font = UI_FSFONT_MAKE(FontNamePingFangSCRegular, 14);
           _originalL.textColor = [UIColor bm_colorWithHex:0x828282];
           _originalL.numberOfLines = 0;
           _originalL.lineBreakMode = NSLineBreakByCharWrapping;
       }
    
       return _originalL;
}

- (UIView *)lineView
{
    if (!_lineView)
    {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor bm_colorWithHex:0x6D7278];
        _lineView.hidden = YES;
    }
    
    return _lineView;
}

- (UILabel *)translatL
{
    if (!_translatL)
       {
           _translatL = [[UILabel alloc] init];
           _translatL.textAlignment = NSTextAlignmentLeft;
           _translatL.font = UI_FSFONT_MAKE(FontNamePingFangSCRegular, 14);
           _translatL.numberOfLines = 0;
           _translatL.textColor = [UIColor bm_colorWithHex:0x828282];
           _translatL.lineBreakMode = NSLineBreakByCharWrapping;
           _translatL.hidden = YES;
       }
    
       return _translatL;
}

- (UIButton *)openBtn
{
    if (!_openBtn)
    {
        _openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_openBtn setImage:[UIImage imageNamed:@"lesson_open"] forState:UIControlStateNormal];
        _openBtn.hidden = YES;
    }
    
    return _openBtn;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end

//
//  YSClassMediumCell.m
//  YSAll
//
//  Created by jiang deng on 2020/2/6.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSClassMediumCell.h"

@interface YSClassMediumCell ()
<
    YSClassMediumCellDelegate
>

@property (nonatomic, strong) YSClassReplayListModel *classReplayListModel;

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

@implementation YSClassMediumCell

- (void)dealloc
{
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    [self makeCellStyle];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)makeCellStyle
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.bgView.backgroundColor = [UIColor clearColor];
    
    self.topView.backgroundColor = [UIColor whiteColor];
    
    self.iconView.backgroundColor = [UIColor bm_colorWithHex:0x9DBEF3];
    [self.iconView bm_roundedRect:2.0f];

    self.titleLabel.textColor = [UIColor bm_colorWithHex:0x828282];
    self.titleLabel.font = UI_BOLDFONT_16;

    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self.bottomView bm_roundedRect:6.0f];
}

- (void)drawCellWithModel:(YSClassReplayListModel *)classReplayListModel withClassState:(YSClassState)classState
{
    self.classReplayListModel = classReplayListModel;

    self.titleLabel.text = YSLocalizedSchool(@"ClassMediumCell.Title");
        
    [self.bottomView bm_removeAllSubviews];
    
    if ([classReplayListModel.classReplayList bm_isNotEmpty])
    {
        for (NSUInteger index = 0; index<classReplayListModel.classReplayList.count; index++)
        {
            YSClassReviewModel *classReviewModel = classReplayListModel.classReplayList[index];
            
            YSClassReplayView *classReplayView = [[YSClassReplayView alloc] init];
            classReplayView.name = self.classReplayListModel.lessonsName;
            classReplayView.classReviewModel = classReviewModel;
            classReplayView.index = index;
            classReplayView.delegate = self;
            
            [self.bottomView addSubview:classReplayView];
            classReplayView.bm_top = index*(YSClassReplayView_Height+YSClassReplayView_Gap)+6.0f;
            classReplayView.bm_left = 15.0f;
        }
    }
    else
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, BMUI_SCREEN_WIDTH-60.0f, YSClassReplayView_NoDateHeight)];
        label.textColor = [UIColor bm_colorWithHex:0x9F9F9F];
        label.font = UI_FONT_12;
        label.text = YSLocalizedSchool(@"ClassMediumCell.NoTitle");
        
        if (classState == YSClassState_End)
        {
            label.hidden = NO;
        }
        else
        {
            label.hidden = YES;
        }
        
        [self.bottomView addSubview:label];
    }
    
//    self.bottomView.bm_height = classDetailModel.classReplayList.count*(YSClassReplayView_Height+YSClassReplayView_Gap)+6.0f;
}

- (void)playReviewClassWithClassReviewModel:(YSClassReviewModel *)classReviewModel index:(NSUInteger)replayIndex
{
    if ([self.delegate respondsToSelector:@selector(playReviewClassWithClassReviewModel:index:)])
    {
        [self.delegate playReviewClassWithClassReviewModel:classReviewModel index:replayIndex];
    }
}

@end

#define YSClassReplayView_LeftGap       (15.0f)
#define YSClassReplayView_IconWidth     (26.0f)
#define YSClassReplayView_IconGap       (10.0f)
#define YSClassReplayView_TextGap       (5.0f)

@interface YSClassReplayView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UIImageView *playImageView;

@property (nonatomic, strong) UIControl *clickControl;

@end

@implementation YSClassReplayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = YSSkinOnlineDefineColor(@"timer_timeBgColor");;
        [self creatUI];
    }
    
    return self;
}

- (void)creatUI
{
    self.bm_size = CGSizeMake(BMUI_SCREEN_WIDTH-YSClassReplayView_LeftGap*4.0f, YSClassReplayView_Height);
    [self bm_roundedRect:10.0f];
    
    CGFloat maxWidth = self.bm_width - YSClassReplayView_LeftGap*2.0f - YSClassReplayView_IconWidth - YSClassReplayView_IconGap - YSClassReplayView_TextGap*2.0f;

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(YSClassReplayView_LeftGap, 8, maxWidth, 20.0f)];
    self.titleLabel.textColor = YSSkinOnlineDefineColor(@"placeholderColor");
    self.titleLabel.font = UI_BOLDFONT_12;
    [self addSubview:self.titleLabel];

    CGFloat timeWidth = maxWidth * 0.25f;
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(YSClassReplayView_LeftGap, self.titleLabel.bm_bottom+4.0f, timeWidth, 20.0f)];
    self.timeLabel.textColor = YSSkinOnlineDefineColor(@"placeholderColor");
    self.timeLabel.font = UI_FONT_12;
    [self addSubview:self.timeLabel];
    
    timeWidth = maxWidth * 0.35f;
    self.sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.timeLabel.bm_right+YSClassReplayView_TextGap, self.titleLabel.bm_bottom+4.0f, timeWidth, 20.0f)];
    self.sizeLabel.textColor = YSSkinOnlineDefineColor(@"placeholderColor");
    self.sizeLabel.font = UI_FONT_12;
    [self addSubview:self.sizeLabel];

    self.playImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bm_width-YSClassReplayView_LeftGap-YSClassReplayView_IconGap-YSClassReplayView_IconWidth, (self.bm_height-YSClassReplayView_IconWidth)*0.5, YSClassReplayView_IconWidth, YSClassReplayView_IconWidth)];
    self.playImageView.image = YSSkinOnlineElementImage(@"classReplayView_playIcon", @"iconNor");
    [self addSubview:self.playImageView];
    
    self.clickControl = [[UIControl alloc] initWithFrame:self.bounds];
    self.clickControl.backgroundColor = [UIColor clearColor];
    self.clickControl.exclusiveTouch = YES;
    [self.clickControl addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.clickControl];
}

- (void)setClassReviewModel:(YSClassReviewModel *)classReviewModel
{
    _classReviewModel = classReviewModel;
    
    NSString *title;
    if ([self.name bm_isNotEmpty])
    {
        title = [NSString stringWithFormat:@"%@_%@", self.name, classReviewModel.part];
    }
    else
    {
        title = classReviewModel.part;
    }
    NSString *time = [NSString stringWithFormat:@"%@: %@", YSLocalizedSchool(@"ClassReplayView.Duration"), classReviewModel.duration];
    NSString *size = [NSString stringWithFormat:@"%@: %@", YSLocalizedSchool(@"ClassReplayView.Size"), classReviewModel.size];

    self.titleLabel.text = title;
    self.timeLabel.text = time;
    self.sizeLabel.text = size;

    [self setNeedsDisplay];
}

- (void)click:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(playReviewClassWithClassReviewModel:index:)])
    {
        [self.delegate playReviewClassWithClassReviewModel:self.classReviewModel index:self.index];
    }
}

@end

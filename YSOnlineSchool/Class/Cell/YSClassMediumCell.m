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

@property (nonatomic, strong) YSClassDetailModel *classDetailModel;

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

- (void)drawCellWithModel:(YSClassDetailModel *)classDetailModel
{
    self.classDetailModel = classDetailModel;

    self.titleLabel.text = YSLocalizedSchool(@"ClassMediumCell.Title");
    
    for (NSUInteger index = 0; index<classDetailModel.classReplayList.count; index++)
    {
        YSClassReviewModel *classReviewModel = classDetailModel.classReplayList[index];
        
        YSClassReplayView *classReplayView = [[YSClassReplayView alloc] init];
        classReplayView.classReviewModel = classReviewModel;
        classReplayView.index = index;
        classReplayView.delegate = self;
        
        [self.bottomView addSubview:classReplayView];
        classReplayView.bm_top = index*(YSClassReplayView_Height+YSClassReplayView_Gap)+6.0f;
        classReplayView.bm_left = 15.0f;
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
        self.backgroundColor = [UIColor bm_colorWithHex:0x9DBEF3];
        [self creatUI];
    }
    
    return self;
}

- (void)creatUI
{
    self.bm_size = CGSizeMake(UI_SCREEN_WIDTH-YSClassReplayView_LeftGap*4.0f, YSClassReplayView_Height);
    [self bm_roundedRect:10.0f];
    
    CGFloat maxWidth = self.bm_width - YSClassReplayView_LeftGap*2.0f - YSClassReplayView_IconWidth - YSClassReplayView_IconGap - YSClassReplayView_TextGap*2.0f;

    CGFloat titleWidth = maxWidth * 0.4f;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(YSClassReplayView_LeftGap, 0, titleWidth, self.bm_height)];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = UI_BOLDFONT_12;
    [self addSubview:self.titleLabel];

    CGFloat timeWidth = maxWidth * 0.25f;
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLabel.bm_right+YSClassReplayView_TextGap, 0, timeWidth, self.bm_height)];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = UI_FONT_12;
    [self addSubview:self.timeLabel];
    
    timeWidth = maxWidth * 0.35f;
    self.sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.timeLabel.bm_right+YSClassReplayView_TextGap, 0, timeWidth, self.bm_height)];
    self.sizeLabel.textColor = [UIColor whiteColor];
    self.sizeLabel.font = UI_FONT_12;
    [self addSubview:self.sizeLabel];

    self.playImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bm_width-YSClassReplayView_LeftGap-YSClassReplayView_IconGap-YSClassReplayView_IconWidth, (self.bm_height-YSClassReplayView_IconWidth)*0.5, YSClassReplayView_IconWidth, YSClassReplayView_IconWidth)];
    self.playImageView.image = [UIImage imageNamed:@"classReplayView_playIcon"];
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
    
    NSString *title = classReviewModel.title;
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

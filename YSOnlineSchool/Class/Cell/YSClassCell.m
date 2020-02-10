//
//  YSClassCell.m
//  YSAll
//
//  Created by jiang deng on 2020/2/6.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSClassCell.h"
#import "UIImageView+WebCache.h"

@interface YSClassCell ()

@property (nonatomic, strong) YSClassModel *classModel;

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *gistLabel;

@property (weak, nonatomic) IBOutlet UIButton *enterBtn;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@property (nonatomic, assign) BOOL isDetail;

- (IBAction)enterClass:(id)sender;

@end

@implementation YSClassCell

+ (CGFloat)cellHeight
{
    return 122.0f;
}

- (void)dealloc
{
    [self.classModel removeObserver:self forKeyPath:@"classState"];
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
    self.isDetail = NO;
    
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self.bgView bm_roundedRect:6.0f];

    self.topView.backgroundColor = [UIColor bm_colorWithHex:0xDEEAFF];

    [self.iconImageView bm_roundedRect:4.0f];
    
    self.titleLabel.textColor = [UIColor bm_colorWithHex:0x828282];
    self.titleLabel.font = UI_BOLDFONT_16;

    self.nameLabel.textColor = [UIColor bm_colorWithHex:0x9F9F9F];
    self.nameLabel.font = UI_FONT_12;
    self.gistLabel.textColor = [UIColor bm_colorWithHex:0x9F9F9F];
    self.gistLabel.font = UI_FONT_12;

    [self.enterBtn bm_roundedRect:self.enterBtn.bm_height * 0.5f];
    self.enterBtn.backgroundColor = [UIColor bm_colorWithHex:0x82ABEC];
    
    self.timeLabel.textColor = [UIColor bm_colorWithHex:0x9F9F9F];
    self.timeLabel.font = UI_FONT_12;

    self.stateLabel.textColor = [UIColor whiteColor];
    self.stateLabel.font = UI_FONT_12;
    [self.stateLabel bm_roundedRect:self.stateLabel.bm_height * 0.5f];
}

- (void)setClassModel:(YSClassModel *)classModel
{
    [self.classModel removeObserver:self forKeyPath:@"classState"];

    _classModel = classModel;
    
    [self.classModel addObserver:self forKeyPath:@"classState" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 课程状态
    if ([keyPath isEqualToString:@"classState"])
    {
        YSClassState oldValue = [change bm_uintForKey:NSKeyValueChangeOldKey];
        YSClassState newValue = [change bm_uintForKey:NSKeyValueChangeNewKey];
        
        if (oldValue != newValue)
        {
            [self freshClassStateIconWithState:newValue];
        }
    }
}

- (void)freshClassStateIconWithState:(YSClassState)state
{
    switch (state)
    {
        // 教室预约时间前10分钟才可以进入
        case YSClassState_Waiting:
            self.enterBtn.hidden = NO;
            self.stateLabel.text = YSLocalizedSchool(@"ClassListCell.State.Waiting");
            self.stateLabel.backgroundColor = [UIColor bm_colorWithHex:0x5ABEDC];
            break;
            
        // 到了预约结束时间30分钟后会自动关闭教室
        case YSClassState_Begin:
            self.enterBtn.hidden = NO;
            self.stateLabel.text = YSLocalizedSchool(@"ClassListCell.State.Begin");
            self.stateLabel.backgroundColor = [UIColor bm_colorWithHex:0xEA7676];
            break;
            
        case YSClassState_End:
        default:
            self.enterBtn.hidden = YES;
            self.stateLabel.text = YSLocalizedSchool(@"ClassListCell.State.End");
            self.stateLabel.backgroundColor = [UIColor bm_colorWithHex:0xA2A2A2];
            break;
    }
}

- (void)drawCellWithModel:(YSClassModel *)classModel isDetail:(BOOL)isDetail
{
    self.classModel = classModel;
    self.isDetail = isDetail;

    if (self.isDetail)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.stateLabel.hidden = YES;
    }
    else
    {
        self.stateLabel.hidden = NO;
    }

    self.titleLabel.text = classModel.title;

    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:classModel.classImage] placeholderImage:[UIImage imageNamed:@"classdefault_icon"] options:SDWebImageRetryFailed|SDWebImageLowPriority];

    self.nameLabel.text = [NSString stringWithFormat:@"%@: %@", YSLocalizedSchool(@"ClassListCell.Text.Teacher"), classModel.teacherName ? classModel.teacherName : @""];
    self.gistLabel.text = [NSString stringWithFormat:@"%@: %@", YSLocalizedSchool(@"ClassListCell.Text.Class"), classModel.classGist ? classModel.classGist : @""];

    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:classModel.startTime];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:classModel.endTime];
    
    NSString *startStr = [NSDate bm_stringFromDate:startDate formatter:@"yyyy/MM/dd HH:mm"];
    NSString *endStr = @"";
    if ([startDate bm_isSameDayAsDate:endDate])
    {
        endStr = [NSDate bm_stringFromDate:startDate formatter:@"MM/dd HH:mm"];
    }
    else
    {
        endStr = [NSDate bm_stringFromDate:startDate formatter:@"HH:mm"];
    }
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@—%@", startStr, endStr];
    
    [self freshClassStateIconWithState:classModel.classState];
}

- (IBAction)enterClass:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(enterClassWith:)])
    {
        [self.delegate enterClassWith:self.classModel];
    }
}

@end

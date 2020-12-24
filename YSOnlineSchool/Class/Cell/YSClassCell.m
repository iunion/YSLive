//
//  YSClassCell.m
//  YSAll
//
//  Created by jiang deng on 2020/2/6.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSClassCell.h"
#import "YSLiveManager.h"

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
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.bgView.backgroundColor = YSSkinOnlineDefineColor(@"onlineSchoolTimeColor");
    [self.bgView bm_roundedRect:6.0f];

    self.topView.backgroundColor = YSSkinOnlineDefineColor(@"defaultTitleColor");

    [self.iconImageView bm_roundedRect:4.0f];
    
    self.titleLabel.textColor = YSSkinOnlineDefineColor(@"placeholderColor");
    self.titleLabel.font = UI_BOLDFONT_16;

    self.nameLabel.textColor = YSSkinOnlineDefineColor(@"onlineSchoolSubTextColor");
    self.nameLabel.font = UI_FONT_12;
    self.gistLabel.textColor = YSSkinOnlineDefineColor(@"onlineSchoolSubTextColor");
    self.gistLabel.font = UI_FONT_12;

    [self.enterBtn bm_roundedRect:4.0f];
    self.enterBtn.backgroundColor = YSSkinOnlineDefineColor(@"MainColor");
    [self.enterBtn setTitle:YSLocalizedSchool(@"ClassListCell.Enter") forState:UIControlStateNormal];
    
    self.timeLabel.textColor = YSSkinOnlineDefineColor(@"onlineSchoolSubTextColor");
    self.timeLabel.font = UI_FONT_12;

    self.stateLabel.textColor = YSSkinOnlineDefineColor(@"defaultTitleColor");
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
        {
#if 0
            self.enterBtn.hidden = YES;
            YSLiveManager *liveManager = [YSLiveManager sharedInstance];
            if (liveManager.tServiceTime)
            {
                CGFloat timecount = self.classModel.startTime - liveManager.tCurrentTime;
                if (timecount <= 600 && timecount > 0)
                {
                    self.enterBtn.hidden = NO;
                    [self.enterBtn setTitle:YSLocalizedSchool(@"ClassListCell.Enter") forState:UIControlStateNormal];
                }
            }
#else
            self.enterBtn.hidden = NO;
#endif
            [self.enterBtn setTitle:YSLocalizedSchool(@"ClassListCell.Enter") forState:UIControlStateNormal];
            self.stateLabel.text = YSLocalizedSchool(@"ClassListCell.State.Waiting");
            self.stateLabel.backgroundColor = YSSkinOnlineDefineColor(@"onlineSchoolStateWaitingColor");
        }
            break;
            
        // 到了预约结束时间30分钟后会自动关闭教室
        case YSClassState_Begin:
            self.enterBtn.hidden = NO;
            [self.enterBtn setTitle:YSLocalizedSchool(@"ClassListCell.Enter") forState:UIControlStateNormal];
            self.stateLabel.text = YSLocalizedSchool(@"ClassListCell.State.Begin");
            self.stateLabel.backgroundColor = YSSkinOnlineDefineColor(@"onlineSchoolStateBeginColor");
            break;
            
        case YSClassState_End:
        default:
            if (self.isDetail)
            {
                self.enterBtn.hidden = YES;
            }
            else
            {
                self.enterBtn.hidden = NO;
            }
            [self.enterBtn setTitle:YSLocalizedSchool(@"ClassListCell.RePlay") forState:UIControlStateNormal];
            self.stateLabel.text = YSLocalizedSchool(@"ClassListCell.State.End");
            self.stateLabel.backgroundColor = YSSkinOnlineDefineColor(@"onlineSchoolStateEndColor");
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

    self.titleLabel.text = classModel.classGist;//classModel.title;

    [self.iconImageView bmsd_setImageWithURL:[NSURL URLWithString:classModel.classImage] placeholderImage:[UIImage imageNamed:@"classdefault_icon"] options:BMSDWebImageRetryFailed|BMSDWebImageLowPriority];

    self.nameLabel.text = [NSString stringWithFormat:@"%@: %@", YSLocalizedSchool(@"ClassListCell.Text.Teacher"), classModel.teacherName ? classModel.teacherName : @""];
    self.gistLabel.text = [NSString stringWithFormat:@"%@: %@", YSLocalizedSchool(@"ClassListCell.Text.Class"), classModel.title ? classModel.title : @""];

    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:classModel.startTime];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:classModel.endTime];
    
    NSString *startStr = [NSDate bm_stringFromDate:startDate formatter:@"yyyy/MM/dd HH:mm"];
    NSString *endStr = @"";
    if ([startDate bm_isSameDayAsDate:endDate])
    {
        endStr = [NSDate bm_stringFromDate:endDate formatter:@"MM/dd HH:mm"];
    }
    else
    {
        endStr = [NSDate bm_stringFromDate:endDate formatter:@"HH:mm"];
    }
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@—%@", startStr, endStr];
    
    [self freshClassStateIconWithState:classModel.classState];
}

- (IBAction)enterClass:(id)sender
{
    if (self.classModel.classState < YSClassState_End)
    {
        if ([self.delegate respondsToSelector:@selector(enterClassWith:)])
        {
            [self.delegate enterClassWith:self.classModel];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(openClassWith:)])
        {
            [self.delegate openClassWith:self.classModel];
        }
    }
}

@end

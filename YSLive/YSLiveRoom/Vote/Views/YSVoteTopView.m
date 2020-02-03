//
//  YSVoteTopView.m
//  YSLive
//
//  Created by fzxm on 2019/10/15.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSVoteTopView.h"
#import "YSVoteModel.h"

@interface YSVoteTopView()
/// 背景
@property (nonatomic, strong) UIImageView *backImgV;
/// 名字以及 发布时间 label
@property (nonatomic, strong) UILabel * nameAndTimeLabel;

/// 投票状态图片
@property (nonatomic, strong) UIButton *statusBtn;
@end

@implementation YSVoteTopView

- (instancetype)initWithFrame:(CGRect)frame withVoteStatus:(BOOL)isEnd
{
    
    if (self = [super initWithFrame:frame])
    {
        self.isEnd = isEnd;
//        self.backgroundColor = [UIColor whiteColor];
        [self setup];
    }
    return self;
}

- (void)setup
{
    [self addSubview:self.backImgV];
    
    
    [self addSubview:self.statusBtn];
   
    
    [self addSubview:self.nameAndTimeLabel];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backImgV.frame = CGRectMake(0, 0, self.bm_width, self.bm_height);
    UIImage *image = [UIImage imageNamed:@"yslive_vote_topbackimage"];
    CGFloat top = image.size.height/2.0;
    CGFloat left = image.size.width/2.0;
    CGFloat bottom = image.size.height/2.0;
    CGFloat right = image.size.width/2.0;
    self.backImgV.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(top, left, bottom, right) resizingMode:UIImageResizingModeStretch];
    
    self.statusBtn.frame = CGRectMake(20, 14, 46, 24);
       self.statusBtn.bm_centerY = self.bm_centerY;
    self.nameAndTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.statusBtn.frame) + 10, 0, UI_SCREEN_WIDTH - 20 - 46 - 10 - 10, self.voteModel.topViewHeight);
     
    self.nameAndTimeLabel.bm_centerY = self.statusBtn.bm_centerY;

}

#pragma mark -
#pragma mark SET
- (void)setIsEnd:(BOOL)isEnd
{
    _isEnd = isEnd;
    if (isEnd)
       {
           //投票结束
           [self.statusBtn setBackgroundImage:[UIImage imageNamed:@"yslive_vote_end"] forState:UIControlStateNormal];
           [self.statusBtn setTitle:YSLocalized(@"title.Voted") forState:UIControlStateNormal];
       }
    else
       {
           //投票中
           [self.statusBtn setBackgroundImage:[UIImage imageNamed:@"yslive_vote_ing"] forState:UIControlStateNormal];
           [self.statusBtn setTitle:YSLocalized(@"title.Voting") forState:UIControlStateNormal];
       }
}

- (void)setVoteModel:(YSVoteModel *)voteModel
{
    _voteModel = voteModel;
    NSString *time =[voteModel.timeStr substringFromIndex:5];
    
    self.nameAndTimeLabel.attributedText = [self dealStrWithName:voteModel.teacherName andTime:time];
    CGSize size = [self.nameAndTimeLabel bm_attribSizeToFitWidth:UI_SCREEN_WIDTH - 20 - 46 - 10 - 10];
    _voteModel.topViewHeight = size.height;
//    self.bm_height = 28 +  size.height + 30;
//    self.backImgV.frame = CGRectMake(0, 0, self.bm_width, self.bm_height);
    [self.nameAndTimeLabel sizeToFit];
    
}

#pragma mark -
#pragma mark Lazy

- (UIImageView *)backImgV
{
    if (!_backImgV)
    {
        _backImgV = [[UIImageView alloc] init];
//        _backImgV.backgroundColor = [UIColor bm_randomColor];
//        [_backImgV setImage:[UIImage imageNamed:@"yslive_vote_topbackimage"]];
    }
    return _backImgV;
}

- (UILabel *)nameAndTimeLabel
{
    if (!_nameAndTimeLabel)
    {
        _nameAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameAndTimeLabel.textAlignment = NSTextAlignmentLeft;
        _nameAndTimeLabel.numberOfLines = 0;
    }
    return _nameAndTimeLabel;
}


- (UIButton *)statusBtn
{
    if (!_statusBtn)
    {
        _statusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _statusBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _statusBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_statusBtn setTitleColor:[UIColor bm_colorWithHex:0xFFFFFF] forState:UIControlStateNormal];
        _statusBtn.userInteractionEnabled = NO;
        
    }
    return _statusBtn;
}


#pragma mark -
#pragma mark SEL

/// 处理名字以及时间 生成属性字符串
/// @param name 名字
/// @param time 时间
- (NSAttributedString *) dealStrWithName:(NSString *) name andTime:(NSString *)time
{
    NSMutableAttributedString * nameString = [[NSMutableAttributedString alloc] initWithString:name attributes:@{
        NSFontAttributeName: UI_FSFONT_MAKE(FontNamePingFangSCRegular, 16),
        NSForegroundColorAttributeName: [UIColor bm_colorWithHex:0x5A8CDC]
    }];
    
    NSString * timeStr = [NSString stringWithFormat:@" %@ %@ ",time,YSLocalized(@"title.ToVote")];
    NSMutableAttributedString * timeAttString = [[NSMutableAttributedString alloc] initWithString:timeStr attributes:@{
        NSFontAttributeName: UI_FSFONT_MAKE(FontNamePingFangSCRegular, 16),
        NSForegroundColorAttributeName: [UIColor bm_colorWithHex:0x6D7278]
    }];
    
    [nameString appendAttributedString:timeAttString];
    
    return nameString;
}


@end

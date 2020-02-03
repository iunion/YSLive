//
//  YSSignedAlertView.m
//  YSLive
//
//  Created by fzxm on 2019/10/22.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSSignedAlertView.h"
#import <BMKit/BMCountDownManager.h>

#define ViewHeight      (185)
#define ViewWidth       (270)
#define ViewBottomGap   (60)

#define SignedAlertCountDownKey     @"SignedAlertCountDownKey"

@interface YSSignedAlertView ()

@property (nonatomic, strong) UIImageView * bacView;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UILabel * tagLabel;
@property (nonatomic, strong) UIButton * sureBtn;
@property (nonatomic, strong) UIView * topBacView;

/// 签到按钮的回调
@property (nonatomic, copy) SignedAlertViewSigned signedBlock;

@end

@implementation YSSignedAlertView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.showAnimationType = BMNoticeViewShowAnimationSlideInFromBottom;
        self.noticeMaskBgEffectView.alpha = 1;
        self.noticeMaskBgEffect = nil;//[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        self.noticeMaskBgColor = [UIColor bm_colorWithHex:0x000000 alpha:0.6];
        self.shouldDismissOnTapOutside = NO;
    }
    return self;
}


#pragma mark -
#pragma mark SEL

+ (YSSignedAlertView *)showWithTime:(NSTimeInterval)timeInterval inView:(UIView *)inView backgroundEdgeInsets:(UIEdgeInsets)backgroundEdgeInsets topDistance:(CGFloat)topDistance signedBlock:(SignedAlertViewSigned)signedBlock;
{
    YSSignedAlertView * alert = [[YSSignedAlertView alloc] init];
    if (timeInterval > 0)
    {
        alert.signedBlock = signedBlock;
        
        alert.backgroundEdgeInsets = backgroundEdgeInsets; 
        alert.topDistance = topDistance;//UI_SCREEN_HEIGHT - ViewBottomGap - ViewHeight;
        
        alert.bacView.bm_height = ViewHeight;
        alert.bacView.bm_width = ViewWidth;

        [alert.bacView addSubview:alert.timeLabel];
        alert.timeLabel.frame = CGRectMake(0, 0, ViewWidth, 59);

        alert.timeLabel.bm_centerX = alert.bacView.bm_centerX ;
        alert.timeLabel.bm_top = alert.bacView.bm_top + 60;
        
        [alert.bacView addSubview:alert.tagLabel];

        [alert.bacView addSubview:alert.sureBtn];
        alert.sureBtn.frame = CGRectMake(0, 0, CGRectGetWidth(alert.bacView.frame), 48);
        alert.sureBtn.bm_left = alert.bacView.bm_left;
        alert.sureBtn.bm_bottom = alert.bacView.bm_bottom;
        
        [alert showWithView:alert.bacView inView:inView];
        [alert startCuntDown:timeInterval];
    }
    return alert;
}

- (void)startCuntDown:(NSTimeInterval)timeInterval
{
    BMWeakSelf
    [[BMCountDownManager manager] startCountDownWithIdentifier:SignedAlertCountDownKey timeInterval:timeInterval processBlock:^(id  _Nonnull identifier, NSInteger timeInterval, BOOL forcedStop) {
        BMLog(@"%ld", (long)timeInterval);
        weakSelf.timeLabel.attributedText = [weakSelf creatTimeStringWithTimeInterval:timeInterval];
    }];
}

- (void)sureBtnClick:(UIButton *)btn
{
    // 签到
//    [self dismiss];
    
    if (self.signedBlock)
    {
        self.signedBlock();
    }
}

- (void)dismiss:(id)sender animated:(BOOL)animated dismissBlock:(BMNoticeViewDismissBlock)dismissBlock
{
    [[BMCountDownManager manager] stopCountDownIdentifier:SignedAlertCountDownKey];
    
    [super dismiss:sender animated:animated dismissBlock:dismissBlock];
}

- (NSMutableAttributedString *)creatTimeStringWithTimeInterval:(NSInteger)timeInterval
{
    if (timeInterval <= 0)
    {
        return nil;
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
 
    [dateFormat setDateFormat:@"HH  :  mm  :  ss"];
    NSString * timeStr = [dateFormat stringFromDate:date];
    
    
    NSMutableAttributedString * timeAttribut = [[NSMutableAttributedString alloc] initWithString:timeStr];
    
    [timeAttribut bm_setFont:UI_FSFONT_MAKE(FontNameHelveticaBold, 42) range:NSMakeRange(0, 2)];
    [timeAttribut bm_setTextColor:[UIColor bm_colorWithHex:0x6D7278] range:NSMakeRange(0, 2)];
    
    [timeAttribut bm_setFont:UI_FSFONT_MAKE(FontNameHelveticaBold, 30) range:NSMakeRange(4, 1)];
    [timeAttribut bm_setTextColor:[UIColor bm_colorWithHex:0x6D7278] range:NSMakeRange(4, 1)];
    [timeAttribut addAttribute:NSBaselineOffsetAttributeName value:@(7) range:NSMakeRange(4, 1)];
    
    [timeAttribut bm_setFont:UI_FSFONT_MAKE(FontNameHelveticaBold, 42) range:NSMakeRange(7, 2)];
    [timeAttribut bm_setTextColor:[UIColor bm_colorWithHex:0x6D7278] range:NSMakeRange(7, 2)];

    [timeAttribut bm_setFont:UI_FSFONT_MAKE(FontNameHelveticaBold, 30) range:NSMakeRange(11, 1)];
    [timeAttribut bm_setTextColor:[UIColor bm_colorWithHex:0x6D7278] range:NSMakeRange(11, 1)];
    [timeAttribut addAttribute:NSBaselineOffsetAttributeName value:@(7) range:NSMakeRange(11, 1)];

    [timeAttribut bm_setFont:UI_FSFONT_MAKE(FontNameHelveticaBold, 42) range:NSMakeRange(14, 2)];
    [timeAttribut bm_setTextColor:[UIColor bm_colorWithHex:0x6D7278] range:NSMakeRange(14, 2)];

    return timeAttribut;
}


#pragma mark -
#pragma mark Lazy

- (UIImageView *)bacView
{
    if (!_bacView)
    {
        _bacView = [[UIImageView alloc] init];
        [_bacView setImage:[UIImage imageNamed:@"yslive_sign_backimg"]];
        _bacView.userInteractionEnabled = YES;
    }
    return _bacView;
}

- (UIView *)topBacView
{
    if (!_topBacView)
    {
        _topBacView = [[UIView alloc] init];
        
        _topBacView.backgroundColor = [UIColor whiteColor];
    }
    
    return _topBacView;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel)
    {
        _timeLabel = [[UILabel alloc] init];

        _timeLabel.textAlignment = NSTextAlignmentCenter;
        //_timeLabel.numberOfLines = 1;
        _timeLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }

   return _timeLabel;
}

- (UILabel *)tagLabel
{
    if (!_tagLabel)
    {
        _tagLabel = [[UILabel alloc] init];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        _tagLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _tagLabel.textColor = [UIColor bm_colorWithHex:0x44474b];
        _tagLabel.font = [UIFont systemFontOfSize:11.0f];
        _tagLabel.text = @"  Hours          Minutes        Seconds ";
    }
    
    return _tagLabel;
}

- (UIButton *)sureBtn
{
    if (!_sureBtn)
    {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sureBtn setTitle:YSLocalized(@"Button.Sign") forState:UIControlStateNormal];
        [_sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [_sureBtn setBackgroundImage:[UIImage imageNamed:@"signAlert_sign"] forState:UIControlStateNormal];
        [_sureBtn addTarget:self action:@selector(sureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _sureBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        _sureBtn.titleEdgeInsets = UIEdgeInsetsMake(-10,0, 0, 0);
    }
    
    return _sureBtn;
}

@end

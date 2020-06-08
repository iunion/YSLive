//
//  YSLessonDetailHeaderView.m
//  YSLive
//
//  Created by fzxm on 2019/10/31.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSLessonDetailHeaderView.h"
#import "YSLessonModel.h"

@interface YSLessonDetailHeaderView()
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *roomIDL;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel * lessonTitleL;
//@property (nonatomic, strong) UILabel * startTimeL;
//@property (nonatomic, strong) UILabel * endTimeL;

@end

@implementation YSLessonDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    return self;
}

- (void)setup
{   self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backView];
    [self addSubview:self.iconImgV];
    [self addSubview:self.lessonTitleL];
    [self addSubview:self.roomIDL];
    [self addSubview:self.lineView];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backView.frame = CGRectMake(20, 35, BMUI_SCREEN_WIDTH - 40, self.lessonModel.nameHeight + 52);
    self.backView.layer.cornerRadius = 4.0f;
    self.backView.layer.masksToBounds = YES;
    
    self.iconImgV.frame = CGRectMake(40, 0, 20, 20);
    self.iconImgV.bm_centerY = self.backView.bm_centerY;
    
    self.roomIDL.frame = CGRectMake(CGRectGetMaxX(self.iconImgV.frame) + 10, 0, BMUI_SCREEN_WIDTH - 72 - 62, 20);
    self.roomIDL.bm_top = self.backView.bm_top + 10;
    
    self.lineView.frame = CGRectMake(CGRectGetMaxX(self.iconImgV.frame) + 10, CGRectGetMaxY(self.roomIDL.frame) + 5, BMUI_SCREEN_WIDTH - 72 - 36, 1);
    
    self.lessonTitleL.frame = CGRectMake(72, CGRectGetMaxY(self.lineView.frame) + 5, BMUI_SCREEN_WIDTH - 72 - 62, self.lessonModel.nameHeight);
    
}


#pragma mark -
#pragma mark Set

- (void)setLessonModel:(YSLessonModel *)lessonModel
{
    _lessonModel = lessonModel;
    self.lessonTitleL.text =[NSString stringWithFormat:@"%@: %@",YSLocalized(@"Label.RoomName"),lessonModel.name];
    self.roomIDL.text = [NSString stringWithFormat:@"%@: %@",YSLocalized(@"Label.roomid"),lessonModel.roomId];
}


#pragma mark -
#pragma mark Lazy
- (UIView *)backView
{
    if (!_backView)
    {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = YSSkinDefineColor(@"defaultTitleColor");
    }
    return _backView;
}

- (UILabel *)lessonTitleL
{
    if (!_lessonTitleL)
    {
        _lessonTitleL = [[UILabel alloc] init];
        _lessonTitleL.textColor = YSSkinDefineColor(@"placeholderColor");
        _lessonTitleL.textAlignment = NSTextAlignmentLeft;
        _lessonTitleL.font = UI_FSFONT_MAKE(FontNamePingFangSCRegular, 12);
        _lessonTitleL.numberOfLines = 0;
        _lessonTitleL.lineBreakMode = NSLineBreakByCharWrapping;
    }
    
    return _lessonTitleL;
    
}

- (UIImageView *)iconImgV
{
    if (!_iconImgV)
    {
        _iconImgV = [[UIImageView alloc] init];
        [_iconImgV setImage:YSSkinElementImage(@"live_lesson_header", @"iconNor")];
    }
    
    return _iconImgV;
}

- (UILabel *)roomIDL
{
    if (!_roomIDL)
    {
        _roomIDL = [[UILabel alloc] init];
        _roomIDL.textColor = YSSkinDefineColor(@"placeholderColor");
        _roomIDL.textAlignment = NSTextAlignmentLeft;
        _roomIDL.font = UI_FSFONT_MAKE(FontNamePingFangSCRegular, 12);
    }
    
    return _roomIDL;
}

- (UIView *)lineView
{
    if (!_lineView)
    {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [YSSkinDefineColor(@"login_placeholderColor") changeAlpha:0.24f];
    }
    
    return _lineView;
}
@end

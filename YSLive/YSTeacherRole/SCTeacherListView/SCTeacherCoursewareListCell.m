//
//  SCTeacherCoursewareListCell.m
//  YSLive
//
//  Created by fzxm on 2019/12/26.
//  Copyright © 2019 YS. All rights reserved.
//

#import "SCTeacherCoursewareListCell.h"

@interface SCTeacherCoursewareListCell ()

/// 课件类型标识
@property (nonatomic, strong) UIImageView *iconImgView;
/// 课件姓名
@property (nonatomic, strong) UILabel *nameLabel;
/// 打开
@property (nonatomic, strong) UIImageView *openImageView;
/// 删除
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) CHFileModel *fileModel;

@end

@implementation SCTeacherCoursewareListCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setup];
    }
    return self;
}


- (void)setup
{
    UIImageView *iconImgView = [[UIImageView alloc] init];
    [self.contentView addSubview:iconImgView];
    self.iconImgView = iconImgView;
    
    UILabel *nameLabel = [[UILabel alloc] init];
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    nameLabel.font = [UIDevice bm_isiPad] ? UI_FONT_14 : UI_FONT_12;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.textColor = YSSkinDefineColor(@"Color3");
    
    UIImageView *openImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:openImageView];
    self.openImageView = openImageView;
    openImageView.contentMode = UIViewContentModeScaleAspectFit;
    [openImageView setImage:YSSkinElementImage(@"coursewareList_open", @"iconNor")];

    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:deleteBtn];
    self.deleteBtn = deleteBtn;
    [deleteBtn setBackgroundImage:YSSkinElementImage(@"coursewareList_delete", @"iconNor") forState:UIControlStateNormal];
    UIImage * deleteDisImage = [YSSkinElementImage(@"coursewareList_out", @"iconNor") bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
    [deleteBtn setImage:deleteDisImage forState:UIControlStateDisabled];
    [deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ([UIDevice bm_isiPad])
    {
        self.iconImgView.frame = CGRectMake(35, 0, 40, 40);
        self.iconImgView.bm_centerY = self.contentView.bm_centerY;
        
        self.deleteBtn.frame = CGRectMake(0, 0, 20, 20);
        self.deleteBtn.bm_centerY = self.contentView.bm_centerY;
        self.deleteBtn.bm_right = self.contentView.bm_right - 20;
        
        self.openImageView.frame = CGRectMake(0, 0, 20, 20);
        self.openImageView.bm_centerY = self.contentView.bm_centerY;
        self.openImageView.bm_right = self.deleteBtn.bm_left - 20;

        self.nameLabel.frame = CGRectMake(0, 0, 10, 26);
        [self.nameLabel bm_setLeft:self.iconImgView.bm_right + 10 right:self.openImageView.bm_left - 10];
        self.nameLabel.bm_centerY = self.contentView.bm_centerY;
    }
    else
    {
        
        self.iconImgView.frame = CGRectMake(10, 0, 20, 20);
        self.iconImgView.bm_centerY = self.contentView.bm_centerY;
        
        self.deleteBtn.frame = CGRectMake(0, 0, 15, 15);
        self.deleteBtn.bm_centerY = self.contentView.bm_centerY;
        self.deleteBtn.bm_right = self.contentView.bm_right - 10;
        
        self.openImageView.frame = CGRectMake(0, 0, 15, 15);
        self.openImageView.bm_centerY = self.contentView.bm_centerY;
        self.openImageView.bm_right = self.deleteBtn.bm_left - 15;

        self.nameLabel.font = [UIFont systemFontOfSize:12.0];
        self.nameLabel.frame = CGRectMake(0, 0, 10, 20);
        [self.nameLabel bm_setLeft:self.iconImgView.bm_right + 5 right:self.openImageView.bm_left - 5];
        self.nameLabel.bm_centerY = self.contentView.bm_centerY;
    }

}

- (void)setUserRole:(CHUserRoleType)userRoleType
{
    if (userRoleType == CHUserType_Patrol)
    {
        self.deleteBtn.hidden = YES;
        
    }
}
- (void)setFileModel:(CHFileModel *)fileModel isCurrent:(BOOL)isCurrent mediaFileID:(nonnull NSString *)mediaFileID mediaState:(CHMediaState)state
{
    _fileModel = fileModel;

//    BOOL isCurrent = [[YSLiveManager sharedInstance].currentFile.fileid isEqualToString:fileModel.fileid];
    NSString *filename = @"";
    if (fileModel.fileid.intValue == 0)
    {
        filename = YSLocalized(@"Title.whiteBoard");
    }
    else
    {
        filename = fileModel.filename;
    }
    self.nameLabel.text = filename;
    YSClassFiletype type = YSClassFiletype_Other;
    NSString *imageName = nil;
    self.deleteBtn.hidden = NO;
    /// 关联课件的情况下处理
    type = [self creatFileTypeWithFilePath:fileModel.filename];
    
    if (fileModel.isDynamicPPT)
    {
        type = YSClassFiletype_PPT;
    }
    
    if (fileModel.isH5Document )
    {
        type = YSClassFiletype_H5;
    }
    
    if (fileModel.isGeneralFile)
    {
        if (fileModel.fileid.intValue == 0)
        {
            type = YSClassFiletype_WhiteBoard;
            self.deleteBtn.hidden = YES;
        }
        else
        {
            type = [self creatFileTypeWithFilePath:fileModel.filename];
        }
    }
    
    if (type == YSClassFiletype_Mp3 || type == YSClassFiletype_Mp4)
    {
        UIImage * playDisImage = [YSSkinElementImage(@"coursewareList_play", @"iconNor") bm_imageWithTintColor:[UIColor bm_colorWithHex:0x888888]];
        
        if (mediaFileID && [mediaFileID isEqualToString:fileModel.fileid])
        {
            if (state == CHMediaState_Play)
            {
                [self.openImageView setImage:YSSkinElementImage(@"coursewareList_play", @"iconSel")];
            }
            else if (state == CHMediaState_Pause)
            {
                [self.openImageView setImage:YSSkinElementImage(@"coursewareList_play", @"iconNor")];
            }
            else if (state == CHMediaState_Stop)
            {
                [self.openImageView setImage:playDisImage];
            }
        }
        else
        {
            [self.openImageView setImage:playDisImage];
        }
    }
    else
    {
        if (isCurrent)
        {
            [self.openImageView setImage:YSSkinElementImage(@"coursewareList_open", @"iconSel")];
            
        }
        else
        {
            [self.openImageView setImage:YSSkinElementImage(@"coursewareList_open", @"iconNor")];
            
        }
    }
    
    imageName = [self imageNameWithFileType:type];
    self.iconImgView.image = YSSkinElementImage(imageName, @"iconNor");
}

- (YSClassFiletype)creatFileTypeWithFilePath:(NSString *)filepath
{
    YSClassFiletype type;
    
    NSString *fileType = [[filepath pathExtension] lowercaseString];
    if ([fileType isEqualToString:YSLocalized(@"Title.whiteBoard")])
    {
        type = YSClassFiletype_WhiteBoard;
    }
    else if ([fileType isEqualToString:@"pptx"] || [fileType isEqualToString:@"ppt"] || [fileType isEqualToString:@"pps"])
    {
        type = YSClassFiletype_PPT;
    }
    else if ([fileType isEqualToString:@"docx"] || [fileType isEqualToString:@"doc"])
    {
        type = YSClassFiletype_Word;
    }
    else if ([fileType isEqualToString:@"jpg"] || [fileType isEqualToString:@"jpeg"] || [fileType isEqualToString:@"png"] || [fileType isEqualToString:@"gif"] || [fileType isEqualToString:@"bmp"])
    {
        type = YSClassFiletype_JPG;
    }
    else if ([fileType isEqualToString:@"xls"] || [fileType isEqualToString:@"xlsx"] || [fileType isEqualToString:@"xlt"] || [fileType isEqualToString:@"xlsm"])
    {
        type = YSClassFiletype_Excel;
    }
    else if ([fileType isEqualToString:@"pdf"])
    {
        type = YSClassFiletype_PDF;
    }
    else if ([fileType isEqualToString:@"txt"])
    {
        type = YSClassFiletype_Txt;
    }
    else if ([fileType isEqualToString:@"mp4"] || [fileType isEqualToString:@"webm"])
    {
        type = YSClassFiletype_Mp4;
    }
    else if ([fileType isEqualToString:@"mp3"] || [fileType isEqualToString:@"wav"] || [fileType isEqualToString:@"ogg"])
    {
        type = YSClassFiletype_Mp3;
    }
    else if ([fileType isEqualToString:@"zip"] )
    {
        type = YSClassFiletype_H5;
    }
    else
    {
        type = YSClassFiletype_H5;
    }
    
    
    return type;
}

- (NSString *)imageNameWithFileType:(YSClassFiletype)type
{
    NSString *imageName = nil;
    switch (type)
    {
        case YSClassFiletype_WhiteBoard:
            imageName = @"coursewareList_WhiteBoard";
            break;
        case YSClassFiletype_PPT:
            imageName = @"coursewareList_PPT";
            break;
        case YSClassFiletype_Excel:
            imageName = @"coursewareList_Excel";
            break;
        case YSClassFiletype_Word:
            imageName = @"coursewareList_Word";
            break;
        case YSClassFiletype_JPG:
            imageName = @"coursewareList_JPG";
            break;
        case YSClassFiletype_Txt:
            imageName = @"coursewareList_Txt";
            break;
        case YSClassFiletype_Mp4:
            imageName = @"coursewareList_Mp4";
            break;
        case YSClassFiletype_Mp3:
            imageName = @"coursewareList_Mp3";
            break;
        case YSClassFiletype_PDF:
            imageName = @"coursewareList_PDF";
            break;
        case YSClassFiletype_H5:
            imageName = @"coursewareList_H5";
            break;
        default:
            imageName = @"coursewareList_OtherFile";
            break;
    }
    return imageName;
}

- (void)deleteBtnClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(deleteBtnProxyClickWithFileModel:)])
    {
        [self.delegate deleteBtnProxyClickWithFileModel:self.fileModel];
    }
}


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted)
    {
        [self showHighlightedAnimation];
    }
}

- (void)showHighlightedAnimation
{
    UIView *tmpView = [[UIView alloc] initWithFrame:self.bounds];
    tmpView.backgroundColor = YSSkinDefineColor(@"Color9");
    tmpView.alpha = 0.f;
    [self addSubview:tmpView];
    
    [UIView animateWithDuration:0.20 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        tmpView.alpha = 0.8f;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.20 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            tmpView.alpha = 0.f;
            
        } completion:^(BOOL finished) {
            
            [tmpView removeFromSuperview];
        }];
    }];
}

@end

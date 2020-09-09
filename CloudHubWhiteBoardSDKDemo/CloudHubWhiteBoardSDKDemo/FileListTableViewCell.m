//
//  FileListTableViewCell.m

#import "FileListTableViewCell.h"
@interface FileListTableViewCell()

/// 课件姓名
@property (nonatomic, strong) UILabel *nameLabel;
/// 删除
@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) CHFileModel *fileModel;
/// 打开
@property (nonatomic, strong) UIImageView *openImageView;
@end


@implementation FileListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor blackColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setup];
    }
    return self;
}


- (void)setup
{
    UILabel *nameLabel = [[UILabel alloc] init];
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    nameLabel.font = [UIFont systemFontOfSize:14.0f];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.textColor = [UIColor grayColor];
    
    UIImageView *openImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:openImageView];
    self.openImageView = openImageView;
    openImageView.contentMode = UIViewContentModeScaleAspectFit;
    [openImageView setImage:CHSkinElementImage(@"coursewareList_open", @"iconNor")];

    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:deleteBtn];
    self.deleteBtn = deleteBtn;
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"smallBoard_deleteimageBtn_skin"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.deleteBtn.frame = CGRectMake(0, 0, 15, 15);
    self.deleteBtn.bm_centerY = self.contentView.bm_centerY;
    self.deleteBtn.bm_right = self.contentView.bm_right - 10;
    
    self.nameLabel.font = [UIFont systemFontOfSize:12.0];
    self.nameLabel.frame = CGRectMake(10, 0, 150, 20);
    self.nameLabel.bm_centerY = self.contentView.bm_centerY;
    
    self.openImageView.frame = CGRectMake(0, 0, 15, 15);
    self.openImageView.bm_centerY = self.contentView.bm_centerY;
    self.openImageView.bm_right = self.deleteBtn.bm_left - 15;
}

- (void)deleteBtnClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(deleteBtnWithFileModel:)])
    {
        [self.delegate deleteBtnWithFileModel:self.fileModel];
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


- (void)setFileModel:(CHFileModel *)fileModel isCurrent:(BOOL)isCurrent
{
    _fileModel = fileModel;
    NSString *filename = @"";
    if (fileModel.fileid.intValue == 0)
    {
        filename = @"whiteBoard";
    }
    else
    {
        filename = fileModel.filename;
    }
    self.nameLabel.text = filename;
    
    if (isCurrent)
    {
        [self.openImageView setImage:CHSkinElementImage(@"coursewareList_open", @"iconSel")];
        
    }
    else
    {
        [self.openImageView setImage:CHSkinElementImage(@"coursewareList_open", @"iconNor")];
        
    }
}


@end

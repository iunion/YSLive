//
//  FileListTableViewCell.m

#import "FileListTableViewCell.h"
@interface FileListTableViewCell()

/// 课件姓名
@property (nonatomic, strong) UILabel *nameLabel;
/// 删除
@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) CHFileModel *fileModel;

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
    self.nameLabel.frame = CGRectMake(10, 0, 200, 20);
    self.nameLabel.bm_centerY = self.contentView.bm_centerY;
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


- (void)setFileModel:(CHFileModel *)fileModel
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
}


@end

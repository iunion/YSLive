//
//  YSDefaultLayoutPopView.m
//  YSAll
//
//  Created by 马迪 on 2020/12/2.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSDefaultLayoutPopView.h"

@interface YSDefaultLayoutPopView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,weak)UITableView * tabView;

@property(nonatomic,assign) NSInteger firstRow;

@end

@implementation YSDefaultLayoutPopView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = YSSkinDefineColor(@"Color2");
    
    self.view.frame = CGRectMake(0, 0, 60, 50 *self.menusArr.count);
    self.preferredContentSize = CGSizeMake(60, 50 *self.menusArr.count);
    
    UITableView * tabView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tabView.delegate = self;
    tabView.dataSource = self;
    [self.view addSubview:tabView];
    tabView.backgroundColor = UIColor.clearColor;
    
    self.tabView = tabView;
    
    NSIndexPath * index = [NSIndexPath indexPathForRow:self.firstRow inSection:0];
    
    [self.tabView selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionNone];
    
}

#pragma mark - 数据源方法和代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _menusArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *KEY=@"MenuViewControllerCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:KEY];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:KEY];
        cell.backgroundColor = UIColor.clearColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *titleString = nil;
        NSString *imageNorPath = nil;
        NSString *imageSelPath = nil;
        
        if (indexPath.row < _menusArr.count)
        {
            titleString = _menusArr[indexPath.row];
        }
        
        if (!indexPath.row)
        {
            imageNorPath = @"aroundNor";
            imageSelPath = @"aroundSel";
        }
        else if (indexPath.row == 1)
        {
            imageNorPath = @"videoNor";
            imageSelPath = @"videoSel";
        }
        else if (indexPath.row == 2)
        {
            imageNorPath = @"doubleNor";
            imageSelPath = @"videoSel";
        }
        else if (indexPath.row == 3)
        {
            imageNorPath = @"focusNor";
            imageSelPath = @"videoSel";
        }
        
        BMImageTitleButtonView * layoutBtn = [self creatButtonWithTitle:YSLocalized(titleString) selectTitle:YSLocalized(titleString) image:YSSkinElementImage(@"layout_bottombar", imageNorPath) selectImage:YSSkinElementImage(@"layout_bottombar", imageSelPath)];
        layoutBtn.frame = CGRectMake(0, 0, self.view.bm_width, 50);
        layoutBtn.tag = 10;
        [cell.contentView addSubview:layoutBtn];
        layoutBtn.userInteractionEnabled = NO;
        
        [layoutBtn setBackgroundColor:UIColor.clearColor];
        
        if (self.firstRow == indexPath.row)
        {
            layoutBtn.selected = YES;
        }
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if ([self.delegate respondsToSelector:@selector(layoutCellClick:)])
    {
        [self.delegate layoutCellClick:indexPath.row];
        
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        BMImageTitleButtonView * button = (BMImageTitleButtonView *)[cell bm_descendantOrSelfWithClass:[BMImageTitleButtonView class]];
        button.selected = YES;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    BMImageTitleButtonView * button = (BMImageTitleButtonView *)[cell bm_descendantOrSelfWithClass:[BMImageTitleButtonView class]];
    button.selected = NO;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)setRoomLayout:(CHRoomLayoutType)roomLayout
{
    _roomLayout = roomLayout;

    if (roomLayout == CHRoomLayoutType_AroundLayout)
    {
        self.firstRow = 0;
    }
    else if (roomLayout == CHRoomLayoutType_VideoLayout)
    {
        self.firstRow = 1;
    }
    else if (roomLayout == CHRoomLayoutType_FocusLayout || roomLayout == CHRoomLayoutType_DoubleLayout)
    {
        self.firstRow = 2;
    }
    
    
    
//    NSIndexPath * index = [NSIndexPath indexPathForRow:row inSection:0];
//
//    UITableViewCell * cell = [self.tabView cellForRowAtIndexPath:index];
//
//    BMImageTitleButtonView * button = (BMImageTitleButtonView *)[cell bm_descendantOrSelfWithClass:[BMImageTitleButtonView class]];
//    button.selected = YES;
}

///创建button
- (BMImageTitleButtonView *)creatButtonWithTitle:(NSString *)title selectTitle:(NSString *)selectTitle image:(UIImage *)image selectImage:(UIImage *)selectImage
{
    BMImageTitleButtonView * button = [[BMImageTitleButtonView alloc]init];
    button.userInteractionEnabled = YES;
    button.type = BMImageTitleButtonView_ImageTop;
    button.textNormalColor = YSSkinDefineColor(@"Color3");
    button.textSelectedColor = YSSkinDefineColor(@"Color4");
    button.textFont= UI_FONT_10;
    button.normalText = title;
    
    if (selectTitle.length)
    {
        button.selectedText = selectTitle;
    }
    
    button.normalImage = image;
    if (selectImage)
    {
        button.selectedImage = selectImage;
    }
    return button;
}

///移动button上图片和文字的位置（图片在上，文字在下）
- (void)moveButtonTitleAndImageWithButton:(UIButton *)button
{
    CGFloat margin = 18;
    if ([UIDevice bm_isiPad])
    {
        margin = 13;
    }

    button.imageEdgeInsets = UIEdgeInsetsMake(0,margin, button.titleLabel.bounds.size.height + 10.0f, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(button.currentImage.size.width + 0.0f, -(button.currentImage.size.width), 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
}
@end

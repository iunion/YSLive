//
//  YS222ViewController.m
//  YSAll
//
//  Created by 马迪 on 2020/12/2.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSLayoutViewController.h"

@interface YSLayoutViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation YSLayoutViewController


//-(NSArray *)menusArr
//{
//    if (!_menusArr)
//    {
//        _menusArr=@[@"综合布局",@"平铺布局",@"双师布局"];
//    }
//    return _menusArr;
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = YSSkinDefineColor(@"PopViewBgColor");
    
    self.view.frame = CGRectMake(0, 0, 80, 50 *3);
    self.preferredContentSize = CGSizeMake(80, 50 *3);
    
    self.menusArr = @[@"Title.VideoLayout",@"Title.AroundLayout",@"Title.DoubleLayout"];
    
    UITableView * tabView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tabView.delegate = self;
    tabView.dataSource = self;
    [self.view addSubview:tabView];
    tabView.backgroundColor = UIColor.clearColor;
    
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
        NSString *titleString = nil;
        NSString *imagePath = nil;
        
        if (indexPath.row < _menusArr.count)
        {
            titleString = _menusArr[indexPath.row];
        }
        
        if (!indexPath.row)
        {
            imagePath = @"iconNor";
        }
        else if (indexPath.row == 1)
        {
            imagePath = @"iconSel";
        }
        else if (indexPath.row == 2)
        {
            imagePath = @"iconDouble";
        }
        else if (indexPath.row == 3)
        {
            imagePath = @"iconFouce";
        }
        
        //双师布局
        BMImageTitleButtonView * doubleLayoutBtn = [self creatButtonWithTitle:YSLocalized(titleString) selectTitle:nil image:YSSkinElementImage(@"layout_bottombar", imagePath) selectImage:nil];
        doubleLayoutBtn.frame = CGRectMake(0, 0, self.view.bm_width, 50);
//       doubleLayoutBtn.disabledImage = YSSkinElementImage(@"videoPop_soundButton", @"iconDis");
//        doubleLayoutBtn.disabledText = YSLocalized(@"Button.MutingAudio");
        doubleLayoutBtn.tag = SCVideoViewControlTypeAudio;
        [cell addSubview:doubleLayoutBtn];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //点击cell时的block
    if ([self.delegate respondsToSelector:@selector(layoutCellClick:)])
    {
        [self.delegate layoutCellClick:indexPath.row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

///创建button
- (BMImageTitleButtonView *)creatButtonWithTitle:(NSString *)title selectTitle:(NSString *)selectTitle image:(UIImage *)image selectImage:(UIImage *)selectImage
{
    BMImageTitleButtonView * button = [[BMImageTitleButtonView alloc]init];
    button.userInteractionEnabled = YES;
    button.type = BMImageTitleButtonView_ImageTop;
//    [button addTarget:self action:@selector(userBtnsClick:) forControlEvents:UIControlEventTouchUpInside];
//    button.textNormalColor = YSSkinDefineColor(@"defaultTitleColor");
    button.textNormalColor = UIColor.whiteColor;
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

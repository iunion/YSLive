//
//  YSEmotionView.m
//  YSLive
//
//  Created by 马迪 on 2019/10/16.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSEmotionView.h"
#import "YSEmotionCollectionCell.h"

@interface YSEmotionView ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource
>

///
@property (nonatomic, strong)UICollectionView * collectionView;
///表情名称数组
@property (nonatomic, strong)NSMutableArray * emotionArr;
///删除表情的按钮
@property (nonatomic, strong) UIButton *deleteBtn;

@end

@implementation YSEmotionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor lightGrayColor];
        [self creatCollectionView];
        
        [self emotionDeleteBtn];
        
        self.emotionArr = [NSMutableArray array];
        for (int i = 0; i<8; i++)
        {
            NSString * emotionName = [NSString stringWithFormat:@"em_%d",i+1];
            [self.emotionArr addObject:emotionName];
        }
    }
    return self;
}

- (void)emotionDeleteBtn
{
    self.deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bm_width-20-40,self.bm_height-15-22, 40, 22)];
    [self.deleteBtn setImage:[UIImage imageNamed:@"emotionDelete"] forState:UIControlStateNormal];
    [self.deleteBtn setImage:[UIImage imageNamed:@"emotionDelete_push"] forState:UIControlStateHighlighted];
    [self.deleteBtn addTarget:self action:@selector(deleteEmotionButtons) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deleteBtn];
}

- (void)creatCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // 设置item的大小 相当于UITableView中cell大小
    layout.itemSize = CGSizeMake(40, 40);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing      = 0;

    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.scrollDirection         = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.bounces = NO;
    self.collectionView.delegate       = self;
    self.collectionView.dataSource     = self;
    self.collectionView.backgroundColor = UIColor.whiteColor;
    //注册cell 一定得注册
    [self.collectionView registerClass:[YSEmotionCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([YSEmotionCollectionCell class])];
    [self addSubview:self.collectionView];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _emotionArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    YSEmotionCollectionCell * cell = [YSEmotionCollectionCell cellWithCollectionView:collectionView indexPath:indexPath];
    cell.emotionName = self.emotionArr[indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * emotionName = self.emotionArr[indexPath.row];
    if (_addEmotionToTextView) {
        _addEmotionToTextView(emotionName);
    }
}


- (void)deleteEmotionButtons
{
    if (_deleteEmotionBtnClick)
    {
        _deleteEmotionBtnClick();
    }
}


@end

//
//  CHPropsView.m
//  YSAll
//
//  Created by 马迪 on 2021/3/26.
//  Copyright © 2021 CH. All rights reserved.
//

#import "CHPropsView.h"
#import "CHPropsViewCell.h"

#define CellMarginX 10
#define CellMarginY 10
#define cellWidth 80
#define cellHeight 56
#define Identifier @"CHPropsViewCell"

@interface CHPropsView ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource
>

@property (nonatomic,weak) UICollectionView *collectView;

@end

@implementation CHPropsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupView];
    }
    
    return self;
}

- (void)setupView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(cellWidth,cellHeight);
    flowLayout.sectionInset = UIEdgeInsetsMake(0, CellMarginX, CellMarginY, CellMarginX);
    flowLayout.minimumLineSpacing = CellMarginY;
    flowLayout.minimumInteritemSpacing = CellMarginX;

    UICollectionView * collectView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    collectView.showsHorizontalScrollIndicator = false;
    collectView.backgroundColor = [UIColor clearColor];
    [collectView registerClass:[CHPropsViewCell class] forCellWithReuseIdentifier:Identifier];
    collectView.delegate = self;
    collectView.dataSource = self;
    [self addSubview:collectView];
    self.collectView = collectView;

}

- (void)setDataArray:(NSArray *)dataArray
{
    _dataArray = dataArray;
    
    [self.collectView reloadData];
}

- (void)setBeautySetModel:(CHBeautySetModel *)beautySetModel
{
    _beautySetModel = beautySetModel;
    
    [self.collectView selectItemAtIndexPath:[NSIndexPath indexPathForRow:beautySetModel.propIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
    [self collectionView:self.collectView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:beautySetModel.propIndex inSection:0]];
}


- (void)clearPropsValue
{
    self.beautySetModel.propIndex = 0;
    
    [self.collectView reloadData];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArray.count + 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CHPropsViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier forIndexPath:indexPath];
    
    if (indexPath.row == 0)
    {
        cell.imageUrl = @"hud_network_poor0";
    }
    else
    {
        cell.imageUrl = _dataArray[indexPath.row - 1];
    }

    if (self.beautySetModel.propIndex == indexPath.row)
    {
        cell.isSelected = YES;
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CHPropsViewCell * cell = (CHPropsViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    self.beautySetModel.propIndex = indexPath.row;
    cell.isSelected = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CHPropsViewCell * cell = (CHPropsViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.isSelected = NO;
}

@end

//
//  CHPropsView.m
//  YSAll
//
//  Created by 马迪 on 2021/3/26.
//  Copyright © 2021 CH. All rights reserved.
//

#import "CHPropsView.h"
#import "CHPropsViewCell.h"

#define CHPropsView_Gap     20.0f

#define CellMarginX         10.0f
#define CellMarginY         10.0f

#define cellWidth           80.0f
#define cellHeight          56.0f

#define CHPropsViewCellIdentifier @"CHPropsViewCell"

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
    self.backgroundColor = UIColor.clearColor;

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
    flowLayout.sectionInset = UIEdgeInsetsMake(CHPropsView_Gap, CellMarginX, CellMarginY, CHPropsView_Gap);
    flowLayout.minimumLineSpacing = CellMarginY;
    flowLayout.minimumInteritemSpacing = CellMarginX;

    UICollectionView *collectView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    collectView.showsHorizontalScrollIndicator = false;
    collectView.backgroundColor = [UIColor clearColor];
    [collectView registerClass:[CHPropsViewCell class] forCellWithReuseIdentifier:CHPropsViewCellIdentifier];
    collectView.delegate = self;
    collectView.dataSource = self;
    [self addSubview:collectView];
    self.collectView = collectView;
}

- (void)setBeautySetModel:(CHBeautySetModel *)beautySetModel
{
    _beautySetModel = beautySetModel;
    
    [self reloadData];
}

- (void)reloadData
{
    [self.collectView reloadData];
    
    [self.collectView selectItemAtIndexPath:[NSIndexPath indexPathForRow:self.beautySetModel.propIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
    [self collectionView:self.collectView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:self.beautySetModel.propIndex inSection:0]];
}

- (void)clearPropsValue
{
    //[self.collectView deselectItemAtIndexPath:[NSIndexPath indexPathForRow:self.beautySetModel.propIndex inSection:0] animated:NO];

    self.beautySetModel.propIndex = 0;
    
    [self reloadData];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([self.beautySetModel bm_isNotEmpty])
    {
        return self.beautySetModel.propUrlArray.count + 1;
    }
    else
    {
        return 1;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CHPropsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CHPropsViewCellIdentifier forIndexPath:indexPath];
    
    if (indexPath.row == 0)
    {
        cell.imageUrl = nil;
    }
    else
    {
        cell.imageUrl = self.beautySetModel.propUrlArray[indexPath.row - 1];
    }

    if (self.beautySetModel.propIndex == indexPath.row)
    {
        cell.isSelected = YES;
    }
    else
    {
        cell.isSelected = NO;
    }

    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CHPropsViewCell *cell = (CHPropsViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    self.beautySetModel.propIndex = indexPath.row;
    cell.isSelected = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CHPropsViewCell *cell = (CHPropsViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.isSelected = NO;
}

@end

//
//  SCPopoverCell.h
//  ddddd
//
//  Created by 马迪 on 2019/11/6.
//  Copyright © 2019 马迪. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSEmotionCollectionCell : UICollectionViewCell

@property(nonatomic,copy)NSString *emotionName;

//类方法快速创建cell
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;


@end

NS_ASSUME_NONNULL_END

//
//  CHPropsViewCell.h
//  YSAll
//
//  Created by 马迪 on 2021/3/26.
//  Copyright © 2021 CH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CHPropsViewCell : UICollectionViewCell

/// 是否选中这一行
@property (nonatomic, assign) BOOL isSelected;

@property (nullable, nonatomic, strong) NSString *imageUrl;

@end

NS_ASSUME_NONNULL_END

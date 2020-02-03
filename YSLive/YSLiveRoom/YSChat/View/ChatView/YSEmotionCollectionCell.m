//
//  SCPopoverCell.m
//  ddddd
//
//  Created by 马迪 on 2019/11/6.
//  Copyright © 2019 马迪. All rights reserved.
//

#import "YSEmotionCollectionCell.h"

@interface YSEmotionCollectionCell ()

@property(nonatomic,strong)UIButton *emotionBtn;

@end

@implementation YSEmotionCollectionCell


//类方法快速创建cell
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = NSStringFromClass([self class]);
    YSEmotionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    return cell;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
//        self.backgroundColor = UIColor.greenColor;
        // 创建子控件
        [self createSubViews];
    }
    return self;
}
/**
 *  创建子控件
 */
- (void)createSubViews{

    self.emotionBtn = [[UIButton alloc]initWithFrame:self.bounds];
    self.emotionBtn.userInteractionEnabled = NO;
    [self.contentView addSubview:self.emotionBtn];
}

- (void)setEmotionName:(NSString *)emotionName
{
    _emotionName = emotionName;
    [self.emotionBtn setImage:[UIImage imageNamed:self.emotionName] forState:UIControlStateNormal];
}



@end

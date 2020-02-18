//
//  YSLessonView.m
//  YSLive
//
//  Created by fzxm on 2019/10/17.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSLessonView.h"
#import "AFNetworking.h"

#import "YSLessonNotifyTableCell.h"
#import "YSLessonModel.h"
#import "YSLessonDetailHeaderView.h"


static  NSString * const   YSLessonNotifyTableCellID      = @"YSLessonNotifyTableCell";

@interface YSLessonView()

<
    UITableViewDelegate,
    UITableViewDataSource
>
/// 表格主体
@property (nonatomic, strong) UITableView *lessonTableView;
@property (nonatomic, strong) YSLessonDetailHeaderView *headerView;
@end

@implementation YSLessonView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.lessonTableView];
    [self.lessonTableView registerClass:[YSLessonNotifyTableCell class] forCellReuseIdentifier:YSLessonNotifyTableCellID];
    
    self.headerView = [[YSLessonDetailHeaderView alloc] init];
    [self addSubview:self.headerView];
}

- (void)layoutSubviews
{
    YSLessonModel * model = self.dataSource[0];
    self.headerView.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, model.nameHeight + 52 + 35 + 10);
    self.headerView.lessonModel = model;
    self.lessonTableView.frame = CGRectMake(0, CGRectGetMaxY(self.headerView.frame)+ 10, self.bm_width, self.bm_height - 10 - model.nameHeight - 90);
}


#pragma mark -
#pragma mark DataSource
- (void)setDataSource:(NSMutableArray *)dataSource
{
    _dataSource = dataSource;
    [self.lessonTableView reloadData];
    

}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowNum = self.dataSource.count - 1;
    return rowNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSLessonModel * lessonModel = self.dataSource[indexPath.row+1];
    BMLog(@"%lu",(unsigned long)lessonModel.notifyType);

    YSLessonNotifyTableCell * notifyCell = [tableView dequeueReusableCellWithIdentifier:YSLessonNotifyTableCellID forIndexPath:indexPath];
    notifyCell.lessonModel = lessonModel;
    BMWeakSelf
    notifyCell.translationBlock = ^(YSLessonNotifyTableCell * _Nonnull tableCell) {
        [weakSelf getBaiduTranslateWithIndexPathRow:indexPath.row + 1];
    };
    
    notifyCell.openBlock = ^(YSLessonNotifyTableCell * _Nonnull tableCell) {
        lessonModel.isOpen = !lessonModel.isOpen;
        [weakSelf.lessonTableView reloadData];
    };
    
    return notifyCell;
}


#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSLessonModel * model = self.dataSource[indexPath.row + 1];
    
    if (model.isOpen)
    {
        return model.detailsHeight + 10 + 25 + 20 +model.translatHeight + 10;
    }
    return model.detailsHeight +10 + 25 + 20;
    
}


#pragma mark -
#pragma mark Request
- (void)getBaiduTranslateWithIndexPathRow:(NSUInteger)row
{
    YSLessonModel * model = self.dataSource[row];
    
    AFHTTPSessionManager * manger = [AFHTTPSessionManager manager];
    [manger.requestSerializer setTimeoutInterval:30];
    manger.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
        @"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript",
        @"text/xml", @"image/jpeg", @"image/*"
    ]];
    //=====增加表情的识别，表情不进行翻译 ===  +  === 对链接地址不进行翻译======
    NSString * aTranslationString = model.details;

    aTranslationString = [aTranslationString stringByReplacingOccurrencesOfString:@"\n" withString:@","];
    
    if (![aTranslationString bm_isNotEmpty])
    {
        return;
    }
    
    unichar ch = [aTranslationString characterAtIndex:0];
    NSString *tTo;
    NSString *tFrom;

    //中日互译。默认为日译中，探测到输入为中文则改成中译日
//    if ([TKEduClassRoom shareInstance].roomJson.configuration.isChineseJapaneseTranslation == YES) {
//        /*
//         /u4e00-/u9fa5 (中文)
//         /u0800-/u4e00 (日文)
//         */
//        tTo   = @"zh";
//        tFrom = @"jp";
//
//        float chNum = 0;
//        for (int i = 0; i < aTranslationString.length; i++) {
//            unichar ch = [aTranslationString characterAtIndex:i];
//            if (ch >= 0x4e00 && ch <= 0x9fa5) { chNum++; }
//        }
//        if (chNum > 0) {
//            //纯中文，则中译日
//            tTo   = @"jp";
//            tFrom = @"zh";
//        }
//    } else {
        //中英互译。默认英译中，探测到输入为中文则改成中译英
        tTo   = @"zh";
        tFrom = @"en";

        if ((int)(ch)>127) {
            tFrom = @"auto";
            tTo   = @"en";
        }
//    }

    NSNumber *tSaltNumber = @(arc4random());
    // APP_ID + query + salt + SECURITY_KEY;
    NSString *tSign = [[NSString stringWithFormat:@"%@%@%@%@", YSAPP_ID_BaiDu, aTranslationString,
                                                tSaltNumber, YSSECURITY_KEY] bm_md5String];
    NSDictionary *tParamDic = @{
           @"appid" : YSAPP_ID_BaiDu,
           @"q" : aTranslationString,
           @"from" : tFrom,
           @"to" : tTo,
           @"salt" : tSaltNumber,
           @"sign" : tSign
       
    };
    BMWeakSelf
    [manger GET:YSTRANS_API_HOST parameters:tParamDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BMLog(@"%@",responseObject);
        if (responseObject == nil)
        {
            return;
        }
        
    
        NSArray *tRanslationArray    = [responseObject objectForKey:@"trans_result"];
        NSDictionary *tRanslationDic = [tRanslationArray firstObject];
        NSString * transString = [tRanslationDic objectForKey:@"dst"];
        model.detailTrans = transString;
        model.isOpen = YES;
        
        [weakSelf.lessonTableView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BMLog(@"%@",error);
    }];
}


#pragma mark -
#pragma mark Lazy

- (UITableView *)lessonTableView
{
    if (!_lessonTableView)
    {
        _lessonTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _lessonTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _lessonTableView.delegate = self;
        _lessonTableView.dataSource = self;
        _lessonTableView.showsVerticalScrollIndicator = NO;
        _lessonTableView.backgroundColor = [UIColor whiteColor];
    }
    
    return _lessonTableView;
}

@end

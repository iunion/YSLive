//
//  YSTableViewVC.m
//  YSAll
//
//  Created by jiang deng on 2020/2/5.
//  Copyright © 2020 YS. All rights reserved.
//

#import "YSTableViewVC.h"
#import "YSCoreStatus.h"

#define DEFAULT_COUNTPERPAGE    20

@interface YSTableViewVC ()

@property (nonatomic, strong) YSTableView *tableView;

// 内容数据
@property (nonatomic, strong) NSMutableArray *dataArray;

// 是否下拉刷新
@property (nonatomic, assign) BOOL isLoadNew;

@end

@implementation YSTableViewVC

- (void)dealloc
{
    [_dataTask cancel];
    _dataTask = nil;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil freshViewType:BMFreshViewType_ALL];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil freshViewType:(BMFreshViewType)freshViewType
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _countPerPage = DEFAULT_COUNTPERPAGE;
        _freshViewType = freshViewType;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    s_IsNoMorePage = NO;
    
    self.tableView = [[YSTableView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_MAINSCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:self.tableViewStyle freshViewType:self.freshViewType];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableViewDelegate = self;
    
    [self.view addSubview:self.tableView];
    
    self.dataArray = [NSMutableArray arrayWithCapacity:0];
    
    self.showEmptyView = YES;
    
    [self.tableView hideEmptyView];
    
    [self bringSomeViewToFront];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)showEmptyView
{
    return self.tableView.bm_showEmptyView;
}

- (void)setShowEmptyView:(BOOL)showEmptyView
{
    self.tableView.bm_showEmptyView = showEmptyView;
}

- (void)bringSomeViewToFront
{
    [self.tableView bringSomeViewToFront];

    [super bringSomeViewToFront];
}

- (void)setFreshTitles:(NSDictionary *)titles
{
    [self.tableView setFreshTitles:titles];
}

- (void)setHeaderFreshTitles:(NSDictionary *)titles
{
    [self.tableView setHeaderFreshTitles:titles];
}

- (void)setFooterFreshTitles:(NSDictionary *)titles
{
    [self.tableView setFooterFreshTitles:titles];
}

- (void)showEmptyViewWithType:(BMEmptyViewType)type
{
    BMWeakSelf
    [self showEmptyViewWithType:type action:^(BMEmptyView *emptyView, BMEmptyViewType state) {
        [weakSelf loadApiData];
    }];
}

- (void)showEmptyViewWithType:(BMEmptyViewType)type action:(BMEmptyViewActionBlock)actionBlock
{
    [self showEmptyViewWithType:type customImageName:nil customMessage:nil customView:nil action:actionBlock];
}

- (void)showEmptyViewWithType:(BMEmptyViewType)type customImageName:(NSString *)customImageName customMessage:(NSString *)customMessage customView:(UIView *)customView
{
    BMWeakSelf
    [self showEmptyViewWithType:type customImageName:customImageName customMessage:customMessage customView:customView action:^(BMEmptyView *emptyView, BMEmptyViewType state) {
        [weakSelf loadApiData];
    }];
}

- (void)showEmptyViewWithType:(BMEmptyViewType)type customImageName:(NSString *)customImageName customMessage:(NSString *)customMessage customView:(UIView *)customView action:(BMEmptyViewActionBlock)actionBlock
{
    if (!self.showEmptyView)
    {
        return;
    }
    
    if (type == BMEmptyViewType_SysError)
    {
        [self.tableView showEmptyViewWithType:type action:actionBlock];
        return;
    }
    
    if (![self.dataArray bm_isNotEmpty])
    {
        if (type == BMEmptyViewType_NetworkError)
        {
            if (![YSCoreStatus isNetworkEnable])
            {
                [self.tableView showEmptyViewWithType:BMEmptyViewType_NetworkError action:actionBlock];
            }
            else
            {
                [self.tableView showEmptyViewWithType:BMEmptyViewType_ServerError action:actionBlock];
            }
        }
        else
        {
            [self.tableView showEmptyViewWithType:type customImageName:customImageName customMessage:customMessage customView:customView action:actionBlock];
        }
    }
    else
    {
        [self.tableView hideEmptyView];
    }
}

- (void)setEmptyViewActionBlock:(BMEmptyViewActionBlock)actionBlock
{
    [self.tableView setEmptyViewActionBlock:actionBlock];
}

- (void)hideEmptyView
{
    [self.tableView hideEmptyView];
}

- (BMEmptyViewType)getNoDataEmptyViewType
{
    return BMEmptyViewType_NoData;
}

- (NSString *)getNoDataEmptyViewCustomImageName
{
    return nil;
}

- (NSString *)getNoDataEmptyViewCustomMessage
{
    return nil;
}

- (UIView *)getNoDataEmptyViewCustomView
{
    return nil;
}


#pragma mark -
#pragma mark Table Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *taskCellIdentifier = @"YSCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:taskCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:taskCellIdentifier];
    }
    cell.backgroundColor = YS_VIEW_BGCOLOR;
    
//    if (cell == nil)
//    {
//        cell = [[[NSBundle mainBundle] loadNibNamed:@"FSCell" owner:self options:nil] lastObject];
//    }
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = [UIColor bm_colorWithHex:0xEEEEEE];
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark -
#pragma mark YSTableViewDelegate

- (void)freshDataWithTableView:(YSTableView *)tableView
{
    [self loadApiData];
}

- (void)loadNextDataWithTableView:(YSTableView *)tableView
{
    [self loadNextApiData];
}

- (void)tableViewFreshFromNoDataView:(YSTableView *)tableView
{
    [self loadApiData];
}

- (void)resetTableViewFreshState:(BMFreshBaseView *)freshView;
{
    BMLog(@"resetTableViewFreshState");
    [self loadDateFinished:(freshView.freshState == BMFreshStateNoMoreData)];
}

#pragma mark -
#pragma mark FSSuperNetVCProtocol

// 刷新数据
- (BOOL)canLoadApiData
{
    return [super canLoadApiData];
}

- (void)loadApiData
{
    self.isLoadNew = YES;
    
    [self loadNextApiData];
}

 // 获取下一页
- (void)loadNextApiData
{
    if (![self canLoadApiData])
    {
        if (self.isLoadNew)
        {
            [self.tableView resetFreshHeaderState];
        }
        else
        {
            [self.tableView resetFreshFooterStateWithNoMoreData];
        }
        
        self.isLoadNew = NO;
        
        return;
    }
    
    if (self.loadDataType == YSAPILoadDataType_Page)
    {
        if (self.isLoadNew)
        {
            s_LoadedPage = 1;
            s_BakLoadedPage = 1;
        }
        else
        {
            if (s_IsNoMorePage)
            {
                [self.tableView resetFreshFooterStateWithNoMoreData];

                self.isLoadNew = NO;
                
                return;
            }
            
            s_BakLoadedPage = s_LoadedPage + 1;
        }
    }
    
    if (self.showProgressHUD)
    {
#if (PROGRESSHUD_UESGIF)
        [self.progressHUD showWait:YES backgroundColor:nil text:nil useHMGif:YES];
#else
        [self.progressHUD bm_showAnimated:NO showBackground:YES];
#endif
    }
    
    [self hideEmptyView];
    
    [self.dataTask cancel];
    self.dataTask = nil;
    
    //AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFHTTPSessionManager *manager = [YSApiRequest makeYSHTTPSessionManager];
    NSMutableURLRequest *request = [self setLoadDataRequest];
    if (!request)
    {
        request = [self setLoadDataRequestWithFresh:self.isLoadNew];
    }
    
    //BMLog(@"absoluteURL1: %@", request.URL.absoluteURL);
    if (self.dataTask)
    {
        request = nil;
    }
    
    if (request)
    {
        BMWeakSelf
        self.dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            //LLog(@"absoluteURL2: %@", response.URL.absoluteURL);

            if (error)
            {
                BMLog(@"Error: %@", error);
                [weakSelf loadDataResponseFailed:response error:error];
                
            }
            else
            {
#ifdef DEBUG
                NSString *responseStr = [NSString stringWithFormat:@"%@", responseObject];
                if (responseStr.length <= 2048) {
                    responseStr = [responseStr bm_convertUnicode];
                    BMLog(@"%@ %@", response, responseStr);
                }
#endif
                [weakSelf loadDataResponseFinished:response responseDic:responseObject];
            }
            weakSelf.dataTask = nil;
        }];
        [self.dataTask resume];
    }
    else
    {
        if (self.isLoadNew)
        {
            [self.tableView resetFreshHeaderState];
        }
        else
        {
            [self.tableView resetFreshFooterStateWithNoMoreData];
        }
        
        self.isLoadNew = NO;
        
        if (self.showProgressHUD)
        {
            [self.progressHUD bm_hideAnimated:NO];
        }
    }
}

// 设置具体的API请求
- (NSMutableURLRequest *)setLoadDataRequest
{
    // 无用
    return nil;
}

- (NSMutableURLRequest *)setLoadDataRequestWithFresh:(BOOL)isLoadNew
{
    return nil;
}

// API请求成功的代理方法
- (void)loadDataResponseFinished:(NSURLResponse *)response responseDic:(NSDictionary *)responseDic
{
    if (!self.showResultHUD)
    {
        [self.progressHUD bm_hideAnimated:NO];
    }
    
    if (![responseDic bm_isNotEmptyDictionary])
    {
        responseDic = [YSLiveUtil convertWithData:responseDic];
    }
    
    if (![responseDic bm_isNotEmptyDictionary])
    {
        [self failLoadedResponse:response responseDic:responseDic withErrorCode:YSAPI_JSON_ERRORCODE];
        
        if (self.showResultHUD)
        {
            [self.progressHUD bm_showAnimated:YES withDetailText:[YSApiRequest publicErrorMessageWithCode:YSAPI_JSON_ERRORCODE] delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
        }
        
        [self showEmptyViewWithType:BMEmptyViewType_DataError];
        self.isLoadNew = NO;

        return;
    }

//#ifdef DEBUG
//    // 上面打印过了，此处打印重复
//    NSString *responseStr = [[NSString stringWithFormat:@"%@", responseDic] bm_convertUnicode];
//    BMLog(@"API返回数据是:+++++%@", responseStr);
//#endif

    NSInteger statusCode = [responseDic bm_intForKey:YSSuperVC_StatusCode_Key];
    if (statusCode == YSSuperVC_StatusCode_Succeed)
    {
        if (self.showResultHUD)
        {
            [self.progressHUD bm_hideAnimated:NO];
        }
        
        BOOL succeed = NO;
        
        NSDictionary *dataDic = [responseDic bm_dictionaryForKey:YSSuperVC_DataDic_Key];
        succeed = [self succeedLoadedRequestWithDic:dataDic];
        NSArray *dataArray = nil;
        if (!succeed)
        {
            dataArray = [responseDic bm_arrayForKey:YSSuperVC_DataDic_Key];
            succeed = [self succeedLoadedRequestWithArray:dataArray];
            if (!succeed)
            {
                NSString *dataStr = [responseDic bm_stringTrimForKey:YSSuperVC_DataDic_Key];
                succeed = [self succeedLoadedRequestWithString:dataStr];
            }
        }
        
        if (succeed)
        {
            [self.tableView resetFreshHeaderState];

            if (self.loadDataType == YSAPILoadDataType_Page)
            {
                if ([self checkLoadFinish:dataDic])
                {
                    [self.tableView resetFreshFooterStateWithNoMoreData];
                }
                else
                {
                    [self.tableView resetFreshFooterState];
                }
            }
            else if (self.loadDataType == YSAPILoadDataType_Count)
            {
                //
            }

            [self showEmptyViewWithType:[self getNoDataEmptyViewType] customImageName:[self getNoDataEmptyViewCustomImageName] customMessage:[self getNoDataEmptyViewCustomMessage] customView:[self getNoDataEmptyViewCustomView]];
            
            // 无数据时隐藏上拉
            if (self.isLoadNew)
            {
                if ([self.dataArray bm_isNotEmpty])
                {
                    self.tableView.bm_freshFooterView.hidden = NO;
                }
                else
                {
                    self.tableView.bm_freshFooterView.hidden = YES;
                }
            }
            self.isLoadNew = NO;
            
            return;
        }
        
        if (![dataDic bm_isNotEmptyDictionary] && ![dataArray bm_isNotEmpty])
        {
            // 允许"data"为空
            if (self.allowEmptyJson)
            {
                [self.tableView resetFreshHeaderState];
                [self.tableView resetFreshFooterState];
                
                self.isLoadNew = NO;
                
                return;
            }
        }
        
        [self failLoadedResponse:response responseDic:responseDic withErrorCode:YSAPI_DATA_ERRORCODE];
        
        // StateError
        [self.tableView resetFreshHeaderState];
        [self.tableView resetFreshFooterState];

        if (self.showResultHUD)
        {
            [self.progressHUD bm_showAnimated:YES withDetailText:[YSApiRequest publicErrorMessageWithCode:YSAPI_DATA_ERRORCODE] delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
        }
        
        [self showEmptyViewWithType:BMEmptyViewType_DataError];
        self.isLoadNew = NO;
    }
    else
    {
        [self failLoadedResponse:response responseDic:responseDic withErrorCode:statusCode];
        
        NSString *message = [responseDic bm_stringTrimForKey:YSSuperVC_ErrorMessage_key withDefault:[YSApiRequest publicErrorMessageWithCode:YSAPI_DATA_ERRORCODE]];
        if ([self checkRequestStatus:statusCode message:message responseDic:responseDic])
        {
            [self.progressHUD bm_hideAnimated:NO];
        }
        else if (self.showResultHUD)
        {
#ifdef DEBUG
            [self.progressHUD bm_showAnimated:YES withDetailText:[NSString stringWithFormat:@"%@:%@", @(statusCode), message] delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
#else
            [self.progressHUD bm_showAnimated:YES withDetailText:message delay:PROGRESSBOX_DEFAULT_HIDE_DELAY];
#endif
        }

        // StateError
        [self.tableView resetFreshHeaderState];
        [self.tableView resetFreshFooterState];
        
        [self showEmptyViewWithType:BMEmptyViewType_DataError];

        self.isLoadNew = NO;
    }
}

- (BOOL)checkRequestStatus:(NSInteger)statusCode message:(NSString *)message responseDic:(NSDictionary *)responseDic
{
    switch (statusCode)
    {
        case 1000:
           // break;
            
        default:
            [self showEmptyViewWithType:BMEmptyViewType_DataError];
            break;
    }
    
    return [super checkRequestStatus:statusCode message:message responseDic:responseDic];
}

// API请求失败的代理方法，一般不需要重写
- (void)loadDataResponseFailed:(NSURLResponse *)response error:(NSError *)error
{
    [super loadDataResponseFailed:response error:error];
    
    [self.tableView resetFreshHeaderState];
    [self.tableView resetFreshFooterState];
    
    [self showEmptyViewWithType:BMEmptyViewType_NetworkError];
    self.isLoadNew = NO;
}

// 处理成功的数据使用succeedLoadedRequestWithDic:
- (BOOL)succeedLoadedRequestWithDic:(NSDictionary *)requestDic
{
    return [super succeedLoadedRequestWithDic:requestDic];
}

- (BOOL)succeedLoadedRequestWithArray:(NSArray *)requestArray
{
    return [super succeedLoadedRequestWithArray:requestArray];
}

- (BOOL)succeedLoadedRequestWithString:(NSString *)requestStr
{
    return [super succeedLoadedRequestWithString:requestStr];
}

// 全部失败情况适用
- (void)failLoadedResponse:(NSURLResponse *)response responseDic:(NSDictionary *)responseDic withErrorCode:(NSInteger)errorCode
{
    return;
}
 
// 全部获取数据判断
- (BOOL)checkLoadFinish:(NSDictionary *)requestDic
{
    if (self.isLoadNew)
    {
        s_IsNoMorePage = NO;
    }
    
    if ([requestDic bm_isNotEmptyDictionary])
    {
        NSDictionary *pageDic = [requestDic bm_dictionaryForKey:YSSuperVC_PageInfo_key];
        
        if ([pageDic bm_isNotEmptyDictionary])
        {
            // 每页记录数: pageSize
            NSUInteger pageSize = [pageDic bm_uintForKey:YSSuperVC_PageSize_key];
            // 当前页码: pageIndex
            NSUInteger curPageNo = [pageDic bm_uintForKey:YSSuperVC_CurrentPageNum_key];
            //总页码: totalPages
            NSUInteger totalPage = [pageDic bm_uintForKey:YSSuperVC_TotalPageNum_key];
            
            if (pageSize)
            {
                //s_LoadedPage = s_BakLoadedPage;
                s_LoadedPage = curPageNo;
                
                // totalRecord/pageSize + 1;
                s_TotalPage = totalPage;
                
                if (s_TotalPage <= s_LoadedPage)
                {
                    s_IsNoMorePage = YES;
                    return YES;
                }
            }
            else
            {
                s_IsNoMorePage = YES;
                return YES;
            }
        }
    }
    
    return NO;
}
 
- (void)loadDateFinished:(BOOL)isNoMoreData
{
    
}


@end

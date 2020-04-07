//
//  YSSuperNetVC.m
//  YSLive
//
//  Created by jiang deng on 2019/10/12.
//  Copyright © 2019 FS. All rights reserved.
//

#import "YSSuperNetVC.h"

@interface YSSuperNetVC ()

// 网络请求
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@end

@implementation YSSuperNetVC

- (void)dealloc
{
    [_dataTask cancel];
    _dataTask = nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // MBProgressHUD显示等待框
    self.progressHUD = [[BMProgressHUD alloc] initWithView:self.view];
    self.progressHUD.animationType = BMProgressHUDAnimationFade;
    [self.view addSubview:self.progressHUD];
    
    self.showProgressHUD = YES;
    self.showResultHUD = YES;
    
    self.allowEmptyJson = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)bringSomeViewToFront
{
    [self.progressHUD bm_bringToFront];
}


#pragma mark -
#pragma mark fresh

- (BOOL)canLoadApiData
{
    return YES;
}

- (void)loadApiData
{
    if (![self canLoadApiData])
    {
        return;
    }
    
    if (self.showProgressHUD)
    {
#if (PROGRESSHUD_UESGIF)
        [self.m_ProgressHUD bm_showWait:YES backgroundColor:nil text:nil useHMGif:YES];
#else
        [self.progressHUD bm_showAnimated:NO showBackground:YES];
#endif
    }
    
    [self.dataTask cancel];
    self.dataTask = nil;
    
    //AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    BMAFHTTPSessionManager *manager = [YSApiRequest makeYSHTTPSessionManager];
    NSMutableURLRequest *request = [self setLoadDataRequest];
    
    if (self.dataTask)
    {
        request = nil;
    }
    
    if (request)
    {
        BMWeakSelf
        self.dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (error)
            {
                BMLog(@"Error: %@", error);
                [weakSelf loadDataResponseFailed:response error:error];
            }
            else
            {
#ifdef DEBUG
                NSString *responseStr = [[NSString stringWithFormat:@"%@", responseObject] bm_convertUnicode];
                BMLog(@"%@ %@", response, responseStr);
#endif
                [weakSelf loadDataResponseFinished:response responseDic:responseObject];
            }
            weakSelf.dataTask = nil;
        }];
        [self.dataTask resume];
    }
    else
    {
        [self.progressHUD bm_hideAnimated:NO];
    }
}


#pragma mark -
#pragma mark API Request

- (NSMutableURLRequest *)setLoadDataRequest
{
    return nil;
}

- (NSMutableURLRequest *)setLoadDataRequestWithFresh:(BOOL)isLoadNew
{
    // 无用
    return nil;
}

- (void)loadDataResponseFinished:(NSURLResponse *)response responseDic:(NSDictionary *)responseDic
{
    if (!self.showResultHUD)
    {
        [self.progressHUD bm_hideAnimated:NO];
    }
    
    if (![responseDic bm_isNotEmptyDictionary])
    {
        [self failLoadedResponse:response responseDic:responseDic withErrorCode:YSAPI_JSON_ERRORCODE];
        
        if (self.showResultHUD)
        {
            [self.progressHUD bm_showAnimated:NO withDetailText:[YSApiRequest publicErrorMessageWithCode:YSAPI_JSON_ERRORCODE] delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
        }
        
        return;
    }
    
#ifdef DEBUG
    NSString *responseStr = [[NSString stringWithFormat:@"%@", responseDic] bm_convertUnicode];
    BMLog(@"API返回数据是:+++++%@", responseStr);
#endif
    
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
                NSString *requestStr = [responseDic bm_stringTrimForKey:YSSuperVC_DataDic_Key];
                succeed = [self succeedLoadedRequestWithString:requestStr];
            }
        }
        
        if (succeed)
        {
            return;
        }
        
        if (![dataDic bm_isNotEmptyDictionary] && ![dataArray bm_isNotEmpty])
        {
            // 允许"data"为空
            if (self.allowEmptyJson)
            {
                return;
            }
        }
        
        [self failLoadedResponse:response responseDic:responseDic withErrorCode:YSAPI_DATA_ERRORCODE];
        
        if (self.showResultHUD)
        {
            [self.progressHUD bm_showAnimated:NO withDetailText:[YSApiRequest publicErrorMessageWithCode:YSAPI_DATA_ERRORCODE] delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
        }
    }
    else
    {
        [self failLoadedResponse:response responseDic:responseDic withErrorCode:statusCode];
        
        NSString *message = [responseDic bm_stringTrimForKey:YSSuperVC_ErrorMessage_key withDefault:[YSApiRequest publicErrorMessageWithCode:YSAPI_DATA_ERRORCODE]];
#if YSShowErrorCode
        message = [NSString stringWithFormat:@"%@: %@", @(statusCode), message];
#endif
        if ([self checkRequestStatus:statusCode message:message responseDic:responseDic])
        {
            [self.progressHUD bm_hideAnimated:NO];
        }
        else if (self.showResultHUD)
        {
#ifdef DEBUG
            [self.progressHUD bm_showAnimated:NO withDetailText:[NSString stringWithFormat:@"%@:%@", @(statusCode), message] delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
#else
            [self.progressHUD bm_showAnimated:NO withDetailText:message delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
#endif
        }
    }
}

- (void)loadDataResponseFailed:(NSURLResponse *)response error:(NSError *)error
{
    BMLog(@"API失败的错误:++++网络超时");
    [self failLoadedResponse:response responseDic:nil withErrorCode:YSAPI_NET_ERRORCODE];
    
    if (self.showResultHUD)
    {
#if YSShowErrorCode
        [self.progressHUD bm_showAnimated:NO withDetailText:[NSString stringWithFormat:@"%@: %@", @(error.code), [YSApiRequest publicErrorMessageWithCode:YSAPI_NET_ERRORCODE]] delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
#else
        [self.progressHUD bm_showAnimated:NO withDetailText:[YSApiRequest publicErrorMessageWithCode:YSAPI_NET_ERRORCODE] delay:BMPROGRESSBOX_DEFAULT_HIDE_DELAY];
#endif
    }
    else
    {
        [self.progressHUD bm_hideAnimated:NO];
    }
}

- (BOOL)succeedLoadedRequestWithDic:(NSDictionary *)requestDic
{
    if ([requestDic bm_isNotEmptyDictionary])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)succeedLoadedRequestWithArray:(NSArray *)requestArray
{
    if ([requestArray bm_isNotEmpty])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)succeedLoadedRequestWithString:(NSString *)requestStr
{
    if ([requestStr bm_isNotEmpty])
    {
        return YES;
    }
    
    return NO;
}

- (void)failLoadedResponse:(NSURLResponse *)response responseDic:(NSDictionary *)responseDic withErrorCode:(NSInteger)errorCode
{
    return;
}


@end

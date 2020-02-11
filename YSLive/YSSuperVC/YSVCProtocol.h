//
//  YSVCProtocol.h
//  YSLive
//
//  Created by jiang deng on 2018/8/25.
//  Copyright © 2018年 FS. All rights reserved.
//

#ifndef YSVCProtocol_h
#define YSVCProtocol_h

// 求情回调状态key
#define YSSuperVC_StatusCode_Key        @"code"
// 求情回调成功码
#define YSSuperVC_StatusCode_Succeed    (0)
// 求情回调数据key
#define YSSuperVC_DataDic_Key           @"data"
// 求情回错误提示key
#define YSSuperVC_ErrorMessage_key      @"info"

// 求情回调页码信息key
#define YSSuperVC_PageInfo_key          @"pageinfo"
// 求情回调页码每页最大数量
#define YSSuperVC_PageSize_key          @"pagesize"
// 求情回调当前页
#define YSSuperVC_CurrentPageNum_key    @"pagenum"
// 求情回调总页数
#define YSSuperVC_TotalPageNum_key      @"total"


@protocol YSSuperVCProtocol <NSObject>

@required

// backAction前操作, 包含手势返回(可用手势返回时)
- (BOOL)shouldPopOnBackButton;
- (void)backAction:(id)sender;
- (void)backRootAction:(id)sender;
- (void)backToViewController:(UIViewController *)viewController;

@optional

@end


@protocol YSSuperNetVCProtocol <NSObject>

@required

// 刷新数据
- (BOOL)canLoadApiData;
- (void)loadApiData;

// 设置具体的API请求
- (NSMutableURLRequest *)setLoadDataRequest;
- (NSMutableURLRequest *)setLoadDataRequestWithFresh:(BOOL)isLoadNew;
// API请求成功的代理方法，直接用默认
- (void)loadDataResponseFinished:(NSURLResponse *)response responseDic:(NSDictionary *)responseDic;
// API请求失败的代理方法，一般不需要重写
- (void)loadDataResponseFailed:(NSURLResponse *)response error:(NSError *)error;

// 处理成功的数据使用succeedLoadedRequestWithDic:
- (BOOL)succeedLoadedRequestWithDic:(NSDictionary *)requestDic;
- (BOOL)succeedLoadedRequestWithArray:(NSArray *)requestArray;
- (BOOL)succeedLoadedRequestWithString:(NSString *)requestStr;

// 全部失败情况适用
- (void)failLoadedResponse:(NSURLResponse *)response responseDic:(NSDictionary *)responseDic withErrorCode:(NSInteger)errorCode;

// 将等待和错误提示等上移
- (void)bringSomeViewToFront;

@optional

// 获取下一页
- (void)loadNextApiData;

// FSAPILoadDataType_Page分页模式，全部获取数据判断
- (BOOL)checkLoadFinish:(NSDictionary *)requestDic;

- (void)loadDateFinished:(BOOL)isNoMoreData;

@end

#endif /* YSVCProtocol_h */

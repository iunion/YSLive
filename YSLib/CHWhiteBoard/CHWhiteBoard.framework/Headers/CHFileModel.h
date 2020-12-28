//
//  CHFileModel.h
//  CHWhiteBoard
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CHFileModel : NSObject

/// 文件ID 纯白板fileid为0
@property (nonatomic, strong) NSString *fileid;

/// 是否转换中 0:没有在转换中 1：正在转换中
@property (nonatomic, assign) BOOL isconverting;


/// 对应白板Id
@property (nonatomic, strong) NSString *sourceInstanceId;

/// 是否默认文档 0：非默认文档 1 默认文档
@property (nonatomic, assign) BOOL type;

/// 文件类型 纯白版为”whiteboard”
@property (nonatomic, strong) NSString *filetype;
/// 文件名 纯白版为”whiteboard”
@property (nonatomic, strong) NSString *filename;

/// 文件地址
@property (nonatomic, strong) NSString *swfpath;
/// pdf地址
@property (nonatomic, strong) NSString *cospdfpath;

/// 区分文件类型 0：频道内上传的文件  1：从后台系统上传的文件
@property (nonatomic, assign) NSUInteger filecategory;
/// 文档类型 0:表示普通文档　１－２动态ppt(1: 第一版动态ppt 2: 新版动态ppt ）  3:h5文档
@property (nonatomic, assign) NSUInteger fileprop;
/// 0:非动态PPT课件 1：动态PPT课件
@property (nonatomic, assign) BOOL dynamicppt;

/// 总页数
@property (nonatomic, assign) NSUInteger pagenum;

/// 是否使用绝对路径 0:相对路径 1：绝对路径
@property (nonatomic, assign) BOOL isContentDocument;

/// 自定义文档课件每页绝对路径
/// 因为currpage从1起始，注意获取每页地址方式
@property (nonatomic, strong) NSArray <NSString *> *pagesAddr;

/// 当前页 起始1
@property (nonatomic, assign) NSUInteger currpage;
@property (nonatomic, assign) NSUInteger pptslide;//1 当前页面
@property (nonatomic, assign) NSUInteger pptstep;//0 贞
/// 总帧数
@property (nonatomic, assign) NSUInteger steptotal;

/// H5脚本使用
@property (nonatomic, assign) BOOL isDynamicPPT;
@property (nonatomic, assign) BOOL isGeneralFile;
@property (nonatomic, assign) BOOL isH5Document;

/// 媒体课件 独立SDK不支持
@property (nonatomic, assign) BOOL isMedia;

///是暖场视频
@property (nonatomic, assign) BOOL isWarmVideo;

+ (instancetype)fileModelWithServerDic:(NSDictionary *)dic;
- (void)updateWithServerDic:(NSDictionary *)dic;

/// 获取课件数据
+ (NSDictionary *)fileDataDocDic:(CHFileModel *)aDefaultDocment sourceInstanceId:(nullable NSString *)sourceInstanceId;
+ (NSDictionary *)fileDataDocDic:(CHFileModel *)aDefaultDocment currentPage:(NSUInteger)currentPage sourceInstanceId:(nullable NSString *)sourceInstanceId;

@end

NS_ASSUME_NONNULL_END

/*
ShowPage的filedata里面有如下字段是有意义的：
 
currpage: currpage,
pptslide: pptslide,
pptstep: pptstep,
steptotal: steptotal

pagesAddr  //这个只有自定义文档有这个字段，正常文档没有这个字段

    fileid:0, //文件ID。纯白板为fileid为0。
    pagenum:1, //总页数。
    filetype:'whiteboard', //文件类型。纯白版为”whiteboard”。
    filename:'whiteboard', //文件名。纯白版为”whiteboard”。
    swfpath:'',  //文件地址。
    dynamicppt:0,  //0: 非动态PPT课件, 1：动态PPT课件
    filecategory: 0, //0: 频道内上传的文件， 1: 从后台系统上传的文件
    fileprop: 0, //0：普通文档， 2：动态ppt， 3：h5文档
    type: 0, //0：非默认文档， 1：默认文档
    isContentDocument: 0, //0: 相对路径， 1：绝对路径
    isconverting: 0, //是否转换中。 0: 没有在转换中 1：正在转换中
    cospdfpath:'' , //pdf地址。 如果文件允许使用pdf显示文档，则有值，否则为””。
*/

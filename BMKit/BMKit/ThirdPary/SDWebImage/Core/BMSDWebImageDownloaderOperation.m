/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "BMSDWebImageDownloaderOperation.h"
#import "BMSDWebImageError.h"
#import "BMSDInternalMacros.h"
#import "BMSDWebImageDownloaderResponseModifier.h"
#import "BMSDWebImageDownloaderDecryptor.h"
#import "BMSDImageLoader.h"

static NSString *const kBMProgressCallbackKey = @"progress";
static NSString *const kBMCompletedCallbackKey = @"completed";

typedef NSMutableDictionary<NSString *, id> BMSDCallbacksDictionary;

@interface BMSDWebImageDownloaderOperation ()

@property (strong, nonatomic, nonnull) NSMutableArray<BMSDCallbacksDictionary *> *callbackBlocks;

@property (assign, nonatomic, readwrite) BMSDWebImageDownloaderOptions options;
@property (copy, nonatomic, readwrite, nullable) BMSDWebImageContext *context;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@property (strong, nonatomic, nullable) NSMutableData *imageData;
@property (copy, nonatomic, nullable) NSData *cachedData; // for `SDWebImageDownloaderIgnoreCachedResponse`
@property (assign, nonatomic) NSUInteger expectedSize; // may be 0
@property (assign, nonatomic) NSUInteger receivedSize;
@property (strong, nonatomic, nullable, readwrite) NSURLResponse *response;
@property (strong, nonatomic, nullable) NSError *responseError;
@property (assign, nonatomic) double previousProgress; // previous progress percent

@property (strong, nonatomic, nullable) id<BMSDWebImageDownloaderResponseModifier> responseModifier; // modify original URLResponse
@property (strong, nonatomic, nullable) id<BMSDWebImageDownloaderDecryptor> decryptor; // decrypt image data

// This is weak because it is injected by whoever manages this session. If this gets nil-ed out, we won't be able to run
// the task associated with this operation
@property (weak, nonatomic, nullable) NSURLSession *unownedSession;
// This is set if we're using not using an injected NSURLSession. We're responsible of invalidating this one
@property (strong, nonatomic, nullable) NSURLSession *ownedSession;

@property (strong, nonatomic, readwrite, nullable) NSURLSessionTask *dataTask;

@property (strong, nonatomic, readwrite, nullable) NSURLSessionTaskMetrics *metrics API_AVAILABLE(macosx(10.12), ios(10.0), watchos(3.0), tvos(10.0));

@property (strong, nonatomic, nonnull) NSOperationQueue *coderQueue; // the serial operation queue to do image decoding
#if BMSD_UIKIT
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;
#endif

@end

@implementation BMSDWebImageDownloaderOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (nonnull instancetype)init {
    return [self initWithRequest:nil inSession:nil options:0];
}

- (instancetype)initWithRequest:(NSURLRequest *)request inSession:(NSURLSession *)session options:(BMSDWebImageDownloaderOptions)options {
    return [self initWithRequest:request inSession:session options:options context:nil];
}

- (nonnull instancetype)initWithRequest:(nullable NSURLRequest *)request
                              inSession:(nullable NSURLSession *)session
                                options:(BMSDWebImageDownloaderOptions)options
                                context:(nullable BMSDWebImageContext *)context {
    if ((self = [super init])) {
        _request = [request copy];
        _options = options;
        _context = [context copy];
        _callbackBlocks = [NSMutableArray new];
        _responseModifier = context[BMSDWebImageContextDownloadResponseModifier];
        _decryptor = context[BMSDWebImageContextDownloadDecryptor];
        _executing = NO;
        _finished = NO;
        _expectedSize = 0;
        _unownedSession = session;
        _coderQueue = [NSOperationQueue new];
        _coderQueue.maxConcurrentOperationCount = 1;
#if BMSD_UIKIT
        _backgroundTaskId = UIBackgroundTaskInvalid;
#endif
    }
    return self;
}

- (nullable id)addHandlersForProgress:(nullable BMSDWebImageDownloaderProgressBlock)progressBlock
                            completed:(nullable BMSDWebImageDownloaderCompletedBlock)completedBlock {
    BMSDCallbacksDictionary *callbacks = [NSMutableDictionary new];
    if (progressBlock) callbacks[kBMProgressCallbackKey] = [progressBlock copy];
    if (completedBlock) callbacks[kBMCompletedCallbackKey] = [completedBlock copy];
    @synchronized (self) {
        [self.callbackBlocks addObject:callbacks];
    }
    return callbacks;
}

- (nullable NSArray<id> *)callbacksForKey:(NSString *)key {
    NSMutableArray<id> *callbacks;
    @synchronized (self) {
        callbacks = [[self.callbackBlocks valueForKey:key] mutableCopy];
    }
    // We need to remove [NSNull null] because there might not always be a progress block for each callback
    [callbacks removeObjectIdenticalTo:[NSNull null]];
    return [callbacks copy]; // strip mutability here
}

- (BOOL)cancel:(nullable id)token {
    if (!token) return NO;
    
    BOOL shouldCancel = NO;
    @synchronized (self) {
        NSMutableArray *tempCallbackBlocks = [self.callbackBlocks mutableCopy];
        [tempCallbackBlocks removeObjectIdenticalTo:token];
        if (tempCallbackBlocks.count == 0) {
            shouldCancel = YES;
        }
    }
    if (shouldCancel) {
        // Cancel operation running and callback last token's completion block
        [self cancel];
    } else {
        // Only callback this token's completion block
        @synchronized (self) {
            [self.callbackBlocks removeObjectIdenticalTo:token];
        }
        BMSDWebImageDownloaderCompletedBlock completedBlock = [token valueForKey:kBMCompletedCallbackKey];
        dispatch_main_async_bmsafe(^{
            if (completedBlock) {
                completedBlock(nil, nil, nil, [NSError errorWithDomain:BMSDWebImageErrorDomain code:BMSDWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user during sending the request"}], YES);
            }
        });
    }
    return shouldCancel;
}

- (void)start {
    @synchronized (self) {
        if (self.isCancelled) {
            if (!self.isFinished) self.finished = YES;
            // Operation cancelled by user before sending the request
            [self callCompletionBlocksWithError:[NSError errorWithDomain:BMSDWebImageErrorDomain code:BMSDWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user before sending the request"}]];
            [self reset];
            return;
        }

#if BMSD_UIKIT
        Class UIApplicationClass = NSClassFromString(@"UIApplication");
        BOOL hasApplication = UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)];
        if (hasApplication && [self shouldContinueWhenAppEntersBackground]) {
            __weak typeof(self) wself = self;
            UIApplication * app = [UIApplicationClass performSelector:@selector(sharedApplication)];
            self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
                [wself cancel];
            }];
        }
#endif
        NSURLSession *session = self.unownedSession;
        if (!session) {
            NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            sessionConfig.timeoutIntervalForRequest = 15;
            
            /**
             *  Create the session for this task
             *  We send nil as delegate queue so that the session creates a serial operation queue for performing all delegate
             *  method calls and completion handler calls.
             */
            session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                    delegate:self
                                               delegateQueue:nil];
            self.ownedSession = session;
        }
        
        if (self.options & BMSDWebImageDownloaderIgnoreCachedResponse) {
            // Grab the cached data for later check
            NSURLCache *URLCache = session.configuration.URLCache;
            if (!URLCache) {
                URLCache = [NSURLCache sharedURLCache];
            }
            NSCachedURLResponse *cachedResponse;
            // NSURLCache's `cachedResponseForRequest:` is not thread-safe, see https://developer.apple.com/documentation/foundation/nsurlcache#2317483
            @synchronized (URLCache) {
                cachedResponse = [URLCache cachedResponseForRequest:self.request];
            }
            if (cachedResponse) {
                self.cachedData = cachedResponse.data;
                self.response = cachedResponse.response;
            }
        }
        
        if (!session.delegate) {
            // Session been invalid and has no delegate at all
            [self callCompletionBlocksWithError:[NSError errorWithDomain:BMSDWebImageErrorDomain code:BMSDWebImageErrorInvalidDownloadOperation userInfo:@{NSLocalizedDescriptionKey : @"Session delegate is nil and invalid"}]];
            [self reset];
            return;
        }
        
        self.dataTask = [session dataTaskWithRequest:self.request];
        self.executing = YES;
    }

    if (self.dataTask) {
        if (self.options & BMSDWebImageDownloaderHighPriority) {
            self.dataTask.priority = NSURLSessionTaskPriorityHigh;
            self.coderQueue.qualityOfService = NSQualityOfServiceUserInteractive;
        } else if (self.options & BMSDWebImageDownloaderLowPriority) {
            self.dataTask.priority = NSURLSessionTaskPriorityLow;
            self.coderQueue.qualityOfService = NSQualityOfServiceBackground;
        } else {
            self.dataTask.priority = NSURLSessionTaskPriorityDefault;
            self.coderQueue.qualityOfService = NSQualityOfServiceDefault;
        }
        [self.dataTask resume];
        for (BMSDWebImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kBMProgressCallbackKey]) {
            progressBlock(0, NSURLResponseUnknownLength, self.request.URL);
        }
        __block typeof(self) strongSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:BMSDWebImageDownloadStartNotification object:strongSelf];
        });
    } else {
        if (!self.isFinished) self.finished = YES;
        [self callCompletionBlocksWithError:[NSError errorWithDomain:BMSDWebImageErrorDomain code:BMSDWebImageErrorInvalidDownloadOperation userInfo:@{NSLocalizedDescriptionKey : @"Task can't be initialized"}]];
        [self reset];
    }
}

- (void)cancel {
    @synchronized (self) {
        [self cancelInternal];
    }
}

- (void)cancelInternal {
    if (self.isFinished) return;
    [super cancel];
    
    __block typeof(self) strongSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:BMSDWebImageDownloadStopNotification object:strongSelf];
    });

    if (self.dataTask) {
        // Cancel the URLSession, `URLSession:task:didCompleteWithError:` delegate callback will be ignored
        [self.dataTask cancel];
        self.dataTask = nil;
    }
    
    // NSOperation disallow setFinished=YES **before** operation's start method been called
    // We check for the initialized status, which is isExecuting == NO && isFinished = NO
    // Ony update for non-intialized status, which is !(isExecuting == NO && isFinished = NO), or if (self.isExecuting || self.isFinished) {...}
    if (self.isExecuting || self.isFinished) {
        if (self.isExecuting) self.executing = NO;
        if (!self.isFinished) self.finished = YES;
    }
    
    // Operation cancelled by user during sending the request
    [self callCompletionBlocksWithError:[NSError errorWithDomain:BMSDWebImageErrorDomain code:BMSDWebImageErrorCancelled userInfo:@{NSLocalizedDescriptionKey : @"Operation cancelled by user during sending the request"}]];

    [self reset];
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)reset {
    @synchronized (self) {
        [self.callbackBlocks removeAllObjects];
        self.dataTask = nil;
        
        if (self.ownedSession) {
            [self.ownedSession invalidateAndCancel];
            self.ownedSession = nil;
        }
        
#if BMSD_UIKIT
        if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
            // If backgroundTaskId != UIBackgroundTaskInvalid, sharedApplication is always exist
            UIApplication * app = [UIApplication performSelector:@selector(sharedApplication)];
            [app endBackgroundTask:self.backgroundTaskId];
            self.backgroundTaskId = UIBackgroundTaskInvalid;
        }
#endif
    }
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isConcurrent {
    return YES;
}

#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSURLSessionResponseDisposition disposition = NSURLSessionResponseAllow;
    
    // Check response modifier, if return nil, will marked as cancelled.
    BOOL valid = YES;
    if (self.responseModifier && response) {
        response = [self.responseModifier modifiedResponseWithResponse:response];
        if (!response) {
            valid = NO;
            self.responseError = [NSError errorWithDomain:BMSDWebImageErrorDomain
                                                     code:BMSDWebImageErrorInvalidDownloadResponse
                                                 userInfo:@{NSLocalizedDescriptionKey : @"Download marked as failed because response is nil"}];
        }
    }
    
    NSInteger expected = (NSInteger)response.expectedContentLength;
    expected = expected > 0 ? expected : 0;
    self.expectedSize = expected;
    self.response = response;
    
    // Check status code valid (defaults [200,400))
    NSInteger statusCode = [response isKindOfClass:NSHTTPURLResponse.class] ? ((NSHTTPURLResponse *)response).statusCode : 0;
    BOOL statusCodeValid = YES;
    if (valid && statusCode > 0 && self.acceptableStatusCodes) {
        statusCodeValid = [self.acceptableStatusCodes containsIndex:statusCode];
    }
    if (!statusCodeValid) {
        valid = NO;
        self.responseError = [NSError errorWithDomain:BMSDWebImageErrorDomain
                                                 code:BMSDWebImageErrorInvalidDownloadStatusCode
                                             userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Download marked as failed because of invalid response status code %ld", (long)statusCode],
                                                        BMSDWebImageErrorDownloadStatusCodeKey : @(statusCode),
                                                        BMSDWebImageErrorDownloadResponseKey : response}];
    }
    // Check content type valid (defaults nil)
    NSString *contentType = [response isKindOfClass:NSHTTPURLResponse.class] ? ((NSHTTPURLResponse *)response).MIMEType : nil;
    BOOL contentTypeValid = YES;
    if (valid && contentType.length > 0 && self.acceptableContentTypes) {
        contentTypeValid = [self.acceptableContentTypes containsObject:contentType];
    }
    if (!contentTypeValid) {
        valid = NO;
        self.responseError = [NSError errorWithDomain:BMSDWebImageErrorDomain
                                                 code:BMSDWebImageErrorInvalidDownloadContentType
                                             userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Download marked as failed because of invalid response content type %@", contentType],
                                                        BMSDWebImageErrorDownloadContentTypeKey : contentType,
                                                        BMSDWebImageErrorDownloadResponseKey : response}];
    }
    //'304 Not Modified' is an exceptional one
    //URLSession current behavior will return 200 status code when the server respond 304 and URLCache hit. But this is not a standard behavior and we just add a check
    if (valid && statusCode == 304 && !self.cachedData) {
        valid = NO;
        self.responseError = [NSError errorWithDomain:BMSDWebImageErrorDomain
                                                 code:BMSDWebImageErrorCacheNotModified
                                             userInfo:@{NSLocalizedDescriptionKey: @"Download response status code is 304 not modified and ignored",
                                                        BMSDWebImageErrorDownloadResponseKey : response}];
    }
    
    if (valid) {
        for (BMSDWebImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kBMProgressCallbackKey]) {
            progressBlock(0, expected, self.request.URL);
        }
    } else {
        // Status code invalid and marked as cancelled. Do not call `[self.dataTask cancel]` which may mass up URLSession life cycle
        disposition = NSURLSessionResponseCancel;
    }
    __block typeof(self) strongSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:BMSDWebImageDownloadReceiveResponseNotification object:strongSelf];
    });
    
    if (completionHandler) {
        completionHandler(disposition);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (!self.imageData) {
        self.imageData = [[NSMutableData alloc] initWithCapacity:self.expectedSize];
    }
    [self.imageData appendData:data];
    
    self.receivedSize = self.imageData.length;
    if (self.expectedSize == 0) {
        // Unknown expectedSize, immediately call progressBlock and return
        for (BMSDWebImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kBMProgressCallbackKey]) {
            progressBlock(self.receivedSize, self.expectedSize, self.request.URL);
        }
        return;
    }
    
    // Get the finish status
    BOOL finished = (self.receivedSize >= self.expectedSize);
    // Get the current progress
    double currentProgress = (double)self.receivedSize / (double)self.expectedSize;
    double previousProgress = self.previousProgress;
    double progressInterval = currentProgress - previousProgress;
    // Check if we need callback progress
    if (!finished && (progressInterval < self.minimumProgressInterval)) {
        return;
    }
    self.previousProgress = currentProgress;
    
    // Using data decryptor will disable the progressive decoding, since there are no support for progressive decrypt
    BOOL supportProgressive = (self.options & BMSDWebImageDownloaderProgressiveLoad) && !self.decryptor;
    // Progressive decoding Only decode partial image, full image in `URLSession:task:didCompleteWithError:`
    if (supportProgressive && !finished) {
        // Get the image data
        NSData *imageData = [self.imageData copy];
        
        // keep maximum one progressive decode process during download
        if (self.coderQueue.operationCount == 0) {
            // NSOperation have autoreleasepool, don't need to create extra one
            @bmweakify(self);
            [self.coderQueue addOperationWithBlock:^{
                @bmstrongify(self);
                if (!self) {
                    return;
                }
                UIImage *image = BMSDImageLoaderDecodeProgressiveImageData(imageData, self.request.URL, NO, self, [[self class] imageOptionsFromDownloaderOptions:self.options], self.context);
                if (image) {
                    // We do not keep the progressive decoding image even when `finished`=YES. Because they are for view rendering but not take full function from downloader options. And some coders implementation may not keep consistent between progressive decoding and normal decoding.
                    
                    [self callCompletionBlocksWithImage:image imageData:nil imageUrl:nil error:nil finished:NO];
                }
            }];
        }
    }
    
    for (BMSDWebImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kBMProgressCallbackKey]) {
        progressBlock(self.receivedSize, self.expectedSize, self.request.URL);
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {
    
    NSCachedURLResponse *cachedResponse = proposedResponse;

    if (!(self.options & BMSDWebImageDownloaderUseNSURLCache)) {
        // Prevents caching of responses
        cachedResponse = nil;
    }
    if (completionHandler) {
        completionHandler(cachedResponse);
    }
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // If we already cancel the operation or anything mark the operation finished, don't callback twice
    if (self.isFinished) return;
    
    @synchronized(self) {
        self.dataTask = nil;
        __block typeof(self) strongSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:BMSDWebImageDownloadStopNotification object:strongSelf];
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:BMSDWebImageDownloadFinishNotification object:strongSelf];
            }
        });
    }
    
    // make sure to call `[self done]` to mark operation as finished
    if (error) {
        // custom error instead of URLSession error
        if (self.responseError) {
            error = self.responseError;
        }
        [self callCompletionBlocksWithError:error];
        [self done];
    } else {
        if ([self callbacksForKey:kBMCompletedCallbackKey].count > 0) {
            NSData *imageData = self.imageData;
            self.imageData = nil;
            // data decryptor
            if (imageData && self.decryptor) {
                imageData = [self.decryptor decryptedDataWithData:imageData response:self.response];
            }
            if (imageData) {
                /**  if you specified to only use cached data via `SDWebImageDownloaderIgnoreCachedResponse`,
                 *  then we should check if the cached data is equal to image data
                 */
                if (self.options & BMSDWebImageDownloaderIgnoreCachedResponse && [self.cachedData isEqualToData:imageData]) {
                    self.responseError = [NSError errorWithDomain:BMSDWebImageErrorDomain
                                                             code:BMSDWebImageErrorCacheNotModified
                                                         userInfo:@{NSLocalizedDescriptionKey : @"Downloaded image is not modified and ignored",
                                                                    BMSDWebImageErrorDownloadResponseKey : self.response}];
                    // call completion block with not modified error
                    [self callCompletionBlocksWithError:self.responseError];
                    [self done];
                } else {
                    // decode the image in coder queue, cancel all previous decoding process
                    [self.coderQueue cancelAllOperations];
                    @bmweakify(self);
                    [self.coderQueue addOperationWithBlock:^{
                        @bmstrongify(self);
                        if (!self) {
                            return;
                        }
                        // check if we already use progressive decoding, use that to produce faster decoding
                        id<BMSDProgressiveImageCoder> progressiveCoder =  BMSDImageLoaderGetProgressiveCoder(self);
                        UIImage *image;
                        if (progressiveCoder) {
                            image = BMSDImageLoaderDecodeProgressiveImageData(imageData, self.request.URL, YES, self, [[self class] imageOptionsFromDownloaderOptions:self.options], self.context);
                        } else {
                            image = BMSDImageLoaderDecodeImageData(imageData, self.request.URL, [[self class] imageOptionsFromDownloaderOptions:self.options], self.context);
                        }
                        // modified by Dennis
                        if (self.options & BMSDWebImageDownloaderDoNotDecodeImageData)
                        {
                            // 增加 imageData 判断，防止不能解析为 image 的数据被作为错误返回
                            if (imageData) {
                                [self callCompletionBlocksWithImage:image imageData:imageData imageUrl:self.request.URL error:nil finished:YES];
                            } else {
                                NSString *description = image == nil ? @"Downloaded image decode failed" : @"Downloaded image has 0 pixels";
                                [self callCompletionBlocksWithError:[NSError errorWithDomain:BMSDWebImageErrorDomain code:BMSDWebImageErrorBadImageData userInfo:@{NSLocalizedDescriptionKey : description}]];
                            }
                        }
                        else
                        {
                            CGSize imageSize = image.size;
                            if (imageSize.width == 0 || imageSize.height == 0) {
                                NSString *description = image == nil ? @"Downloaded image decode failed" : @"Downloaded image has 0 pixels";
                                [self callCompletionBlocksWithError:[NSError errorWithDomain:BMSDWebImageErrorDomain code:BMSDWebImageErrorBadImageData userInfo:@{NSLocalizedDescriptionKey : description}]];
                            } else {
                                // modified by Dennis
                                [self callCompletionBlocksWithImage:image imageData:imageData imageUrl:self.request.URL error:nil finished:YES];
                            }
                        }
                        [self done];
                    }];
                }
            } else {
                [self callCompletionBlocksWithError:[NSError errorWithDomain:BMSDWebImageErrorDomain code:BMSDWebImageErrorBadImageData userInfo:@{NSLocalizedDescriptionKey : @"Image data is nil"}]];
                [self done];
            }
        } else {
            [self done];
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    
// modified by Dennis
#if SDWEBIMAGE_NORMALUSEHTTPDNS
    if (!challenge)
    {
        return;
    }
    
    NSString* host = [[task.originalRequest allHTTPHeaderFields] objectForKey:@"host"];
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if (!host)
    {
        host = task.originalRequest.URL.host;
    }
    
    // 以下逻辑与 AFNetworking -> AFURLSessionManager.m 里的代码一致
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        if ([self evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:host])
        {
            // 上述 `evaluateServerTrust:forDomain:` 方法用于验证 SSL 握手过程中服务端返回的证书是否可信任，
            // 以及请求的 URL 中的域名与证书里声明的的 CN 字段是否一致。
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            if (credential)
            {
                disposition = NSURLSessionAuthChallengeUseCredential;
            }
            else
            {
                disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            }
        }
        else
        {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }
    else
    {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    
    if (completionHandler)
    {
        //        disposition = NSURLSessionAuthChallengeUseCredential;
        //        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        
        if (disposition != NSURLSessionAuthChallengeUseCredential)
        {
            if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
                if (!(self.options & BMSDWebImageDownloaderAllowInvalidSSLCertificates)) {
                    disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                } else {
                    credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                    disposition = NSURLSessionAuthChallengeUseCredential;
                }
            } else {
                if (challenge.previousFailureCount == 0) {
                    if (self.credential) {
                        credential = self.credential;
                        disposition = NSURLSessionAuthChallengeUseCredential;
                    } else {
                        disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
                    }
                } else {
                    disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
                }
            }
            
            if (disposition != NSURLSessionAuthChallengeUseCredential)
            {
                if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
                {
                    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
                    CFDataRef exceptions    = SecTrustCopyExceptions(serverTrust);
                    SecTrustSetExceptions(serverTrust, exceptions);
                    CFRelease(exceptions);
                    completionHandler(NSURLSessionAuthChallengeUseCredential,
                                      [NSURLCredential credentialForTrust:serverTrust]);
                }
                else
                {
                    completionHandler(disposition, credential);
                }
            }
            else
            {
                completionHandler(disposition, credential);
            }
        }
        else
        {
            completionHandler(disposition, credential);
        }
    }
    
#else
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (!(self.options & BMSDWebImageDownloaderAllowInvalidSSLCertificates)) {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        } else {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            disposition = NSURLSessionAuthChallengeUseCredential;
        }
    } else {
        if (challenge.previousFailureCount == 0) {
            if (self.credential) {
                credential = self.credential;
                disposition = NSURLSessionAuthChallengeUseCredential;
            } else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
#endif
}

// modified by Dennis
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain
{
    /*
     * 创建证书校验策略
     */
    NSMutableArray *policies = [NSMutableArray array];
    if (domain)
    {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
    }
    else
    {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
    }
    /*
     * 绑定校验策略到服务端的证书上
     */
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
    /*
     * 评估当前serverTrust是否可信任，
     * 官方建议在result = kSecTrustResultUnspecified 或 kSecTrustResultProceed
     * 的情况下serverTrust可以被验证通过，https://developer.apple.com/library/ios/technotes/tn2232/_index.html
     * 关于SecTrustResultType的详细信息请参考SecTrust.h
     */
    SecTrustResultType result;
    SecTrustEvaluate(serverTrust, &result);
    return (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics API_AVAILABLE(macosx(10.12), ios(10.0), watchos(3.0), tvos(10.0)) {
    self.metrics = metrics;
}

#pragma mark Helper methods
+ (BMSDWebImageOptions)imageOptionsFromDownloaderOptions:(BMSDWebImageDownloaderOptions)downloadOptions {
    BMSDWebImageOptions options = 0;
    if (downloadOptions & BMSDWebImageDownloaderScaleDownLargeImages) options |= BMSDWebImageScaleDownLargeImages;
    if (downloadOptions & BMSDWebImageDownloaderDecodeFirstFrameOnly) options |= BMSDWebImageDecodeFirstFrameOnly;
    if (downloadOptions & BMSDWebImageDownloaderPreloadAllFrames) options |= BMSDWebImagePreloadAllFrames;
    if (downloadOptions & BMSDWebImageDownloaderAvoidDecodeImage) options |= BMSDWebImageAvoidDecodeImage;
    if (downloadOptions & BMSDWebImageDownloaderMatchAnimatedImageClass) options |= BMSDWebImageMatchAnimatedImageClass;
    
    return options;
}

- (BOOL)shouldContinueWhenAppEntersBackground {
    return BMSD_OPTIONS_CONTAINS(self.options, BMSDWebImageDownloaderContinueInBackground);
}

- (void)callCompletionBlocksWithError:(nullable NSError *)error {
    // modified by Dennis
    [self callCompletionBlocksWithImage:nil imageData:nil imageUrl:nil error:error finished:YES];
}

// modified by Dennis
- (void)callCompletionBlocksWithImage:(nullable UIImage *)image
                            imageData:(nullable NSData *)imageData
                             imageUrl:(nullable NSURL *)url
                                error:(nullable NSError *)error
                             finished:(BOOL)finished {
    NSArray<id> *completionBlocks = [self callbacksForKey:kBMCompletedCallbackKey];
    dispatch_main_async_bmsafe(^{
        for (BMSDWebImageDownloaderCompletedBlock completedBlock in completionBlocks) {
            completedBlock(url, image, imageData, error, finished);
        }
    });
}

@end

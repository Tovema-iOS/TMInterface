//
//  TMInterface.m
//  Pods
//
//  Created by LinXiaoBin on 16/3/15.
//
//

#import "TMBaseRequest.h"
#import <AFNetworking/AFNetworking.h>
#import <TMLogger/TMLogger.h>

NSString *const TMHTTPMethodPost = @"POST";
NSString *const TMHTTPMethodGet = @"GET";

@interface TMBaseRequest()
{
    NSURLSessionDataTask *_afURLSessionTask;
    AFURLSessionManager *_sessionManager;

    BOOL _isCancel;
}

@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong) NSDictionary *requestHeader;
@property (nonatomic, strong) NSData *reqeustBodyData;
@property (nonatomic, copy) NSString *requestMethod;
@property (nonatomic, assign) NSInteger tryReloadTimes;
@property (nonatomic, assign) NSInteger statusCode;

@property (nonatomic, copy) NSDictionary *responseHeader;

@end

@implementation TMBaseRequest

- (instancetype)initWithResponseBlock:(TMInterfaceResponseBlock_t)responseBlock
{
    self = [super init];
    if (self) {
        _responseBlock = [responseBlock copy];
    }
    return self;
}

- (void)dealloc
{
    MLOG(@"%@ dealloc", self);

    if (_sessionManager != nil) {
        [_sessionManager invalidateSessionCancelingTasks:YES];
    }
}

#pragma mark - public
- (void)postURL:(NSString *)url header:(NSDictionary<NSString *, NSString *> *)header dictionaryBody:(NSDictionary *)dictionary
{
    NSData *data = nil;
    if (dictionary) {
        data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:NULL];
    }

    [self postURL:url header:header dataBody:data];
}

- (void)postURL:(NSString *)url header:(NSDictionary<NSString *, NSString *> *)header stringBody:(NSString *)string encoding:(NSStringEncoding)encoding
{
    NSData *data = nil;
    if (string) {
        data = [string dataUsingEncoding:encoding];
    }
    [self postURL:url header:header dataBody:data];
}

- (void)postURL:(NSString *)urlString header:(NSDictionary<NSString *, NSString *> *)header dataBody:(NSData *)data
{
    [self sendRequestURL:urlString method:TMHTTPMethodPost header:header dataBody:data];
}

- (void)getURL:(NSString *)urlString header:(NSDictionary<NSString *, NSString *> *)header
{
    [self sendRequestURL:urlString method:TMHTTPMethodGet header:header dataBody:nil];
}

- (void)sendRequestURL:(NSString *)urlString method:(NSString *)method header:(NSDictionary<NSString *, NSString *> *)header dataBody:(NSData *)data
{
    self.urlString = urlString;
    self.requestHeader = header;
    self.reqeustBodyData = data;
    self.requestMethod = method;

    BOOL didRequest = NO;
    if (urlString) {
        NSURL *url = [NSURL URLWithString:urlString];
        self.url = url;
        if (url) {
            NSURLRequest *request = [self URLRequestWithURL:url header:header dataBody:data method:method];
            _sessionManager = [self sessionManager];
            typeof(self) __weak weakSelf = self;
            NSURLSessionDataTask *dataTask = [_sessionManager dataTaskWithRequest:request
                                                                   uploadProgress:nil
                                                                 downloadProgress:nil
                                                                completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {
                                                                    [weakSelf onURLResponse:response responseObject:responseObject error:error];
                                                                }];
            [dataTask resume];

            didRequest = YES;
        }
    }

    if (!didRequest) {
        [self afRequestFailed:nil error:[self errorWithCode:TMInterfaceErrorCodeURLError message:nil]];
    }
}

- (NSURLRequest *)URLRequestWithURL:(NSURL *)url header:(NSDictionary<NSString *, NSString *> *)header dataBody:(NSData *)body method:(NSString *)method
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [header enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *_Nonnull obj, BOOL *_Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    request.HTTPMethod = method;
    if (body) {
        request.HTTPBody = body;
    }
    return request;
}

- (AFURLSessionManager *)sessionManager;
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    return manager;
}

- (void)onURLResponse:(NSURLResponse *_Nonnull)response responseObject:(id _Nullable)responseObject error:(NSError *_Nullable)error
{
    if ([response isKindOfClass:NSHTTPURLResponse.class]) {
        self.statusCode = ((NSHTTPURLResponse *)response).statusCode;
    }

    NSDictionary *header = nil;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        header = [(NSHTTPURLResponse *)response allHeaderFields];
    }

    if (error) {
        [self afRequestFailed:header error:error];
    } else {
        [self afRequestFinished:header responseObject:responseObject];
    }
}


- (void)cancelAndClearDelegate
{
    _isCancel = YES;

    if (_afURLSessionTask && _afURLSessionTask.state != NSURLSessionTaskStateCompleted) {
        [_afURLSessionTask cancel];
        _afURLSessionTask = nil;
    }

    if (_sessionManager != nil) {
        [_sessionManager invalidateSessionCancelingTasks:YES];
        _sessionManager = nil;
    }

    [self didRequestFinished];
}

#pragma mark - private

- (void)didRequestFinished
{
    id<TMInterfaceManagerDelegate> delegate = self.managerDelegate;
    if ([delegate respondsToSelector:@selector(tm_interfaceDidRequestFinished:)]) {
        [delegate tm_interfaceDidRequestFinished:self];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"

- (void)succeedWithResponseHeader:(NSDictionary *)responseHeader responseObject:(id)responseObject
{
    self.responseHeader = responseHeader;
    TMInterfaceResponseBlock_t responseBlock = self.responseBlock;
    if (responseBlock) {
        responseBlock(self, responseObject, nil);
    }
}

- (void)failedWithResponseHeader:(NSDictionary *)responseHeader error:(NSError *)error
{
    self.responseHeader = responseHeader;
    TMInterfaceResponseBlock_t responseBlock = self.responseBlock;
    if (responseBlock) {
        responseBlock(self, nil, error);
    }
}

#pragma clang diagnostic pop

- (void)afRequestFinished:(NSDictionary *)responseHeader responseObject:(id)responseObject
{
    id result = responseObject;
    NSError *error = nil;

    if (self.responsePreSerializeBlock) {
        result = self.responsePreSerializeBlock(self, responseObject, &error);
    }

    if (self.responseSerializeBlock) {
        if (result && !error) {
            result = self.responseSerializeBlock(self, result, &error);
        }
    }

    if (error == nil) {
        [self succeedWithResponseHeader:responseHeader responseObject:result];
    } else {
        [self failedWithResponseHeader:responseHeader error:error];
    }

    [self didRequestFinished];
}

- (void)afRequestFailed:(NSDictionary *)responseHeader error:(NSError *)error
{
    if (_isCancel) {
        return;
    }

    // 添加日志
    MLOG(@"responseHeader:\n%@error:%@", responseHeader, error);

#if !TARGET_OS_SIMULATOR
    if (![self tryReload])
#endif
    {
        [self failedWithResponseHeader:responseHeader error:error];
        [self didRequestFinished];
    }
}

@end

@implementation TMBaseRequest (Protected)

- (BOOL)tryReload
{
    if (self.tryReloadTimes < self.maxTryReloadTimes) {
        self.tryReloadTimes++;
        [self sendRequestURL:self.urlString method:self.requestMethod header:self.requestHeader dataBody:self.reqeustBodyData];
        return YES;
    } else {
        return NO;
    }
}

- (void)failedRequest:(NSString *)url code:(NSInteger)code message:(NSString *)message
{
    NSError *error = [self errorWithCode:code message:message];
    [self afRequestFailed:nil error:error];
}

- (void)failedRequest:(NSError *)error
{
    [self afRequestFailed:nil error:error];
}

- (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code message:(NSString *)message
{
    return [NSError errorWithDomain:domain ? domain : @"" code:code userInfo:@{@"ResultMessage": message ? message : @""}];
}

- (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message
{
    return [self errorWithDomain:self.urlString code:code message:message];
}

@end

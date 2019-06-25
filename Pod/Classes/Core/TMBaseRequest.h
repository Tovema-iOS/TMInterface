//
//  TMInterface.h
//  Pods
//
//  Created by LinXiaoBin on 16/3/15.
//
//

#import <Foundation/Foundation.h>
#import "TMInterfaceCallback.h"

extern NSString *const TMHTTPMethodPost;
extern NSString *const TMHTTPMethodGet;

/**
 接口请求基类
 */
@interface TMBaseRequest : NSObject

@property (nonatomic, assign) NSInteger maxTryReloadTimes;  //默认重试2次

@property (nonatomic, copy) TMInterfaceResponseBlock_t responseBlock;  //  接口响应回调 block
@property (nonatomic, strong) TMResponseSerializeBlock_t responsePreSerializeBlock;  // 接口数据预解析
@property (nonatomic, strong) TMResponseSerializeBlock_t responseSerializeBlock;  // 接口数据解析回调

@property (nonatomic, weak) id<TMInterfaceManagerDelegate> managerDelegate;  // 接口对象管理回调

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, copy, readonly) NSString *urlString;
@property (nonatomic, assign, readonly) NSInteger statusCode;  // HTTP status code
@property (nonatomic, copy, readonly) NSDictionary *responseHeader;
@property (nonatomic, assign, readonly) NSInteger tag;  // 接口编号，用于区分接口请求

- (instancetype)initWithResponseBlock:(TMInterfaceResponseBlock_t)responseBlock;

- (void)postURL:(NSString *)url header:(NSDictionary<NSString *, NSString *> *)header dictionaryBody:(NSDictionary *)dictionary;
- (void)postURL:(NSString *)url header:(NSDictionary<NSString *, NSString *> *)header stringBody:(NSString *)string encoding:(NSStringEncoding)encoding;
- (void)postURL:(NSString *)url header:(NSDictionary<NSString *, NSString *> *)header dataBody:(NSData *)data;

- (void)getURL:(NSString *)urlString header:(NSDictionary<NSString *, NSString *> *)header;

- (void)sendRequestURL:(NSString *)urlString method:(NSString *)method header:(NSDictionary<NSString *, NSString *> *)header dataBody:(NSData *)data;

- (void)cancelAndClearDelegate;

@end


@interface TMBaseRequest(Protected)

@property (nonatomic, assign) NSInteger tag;

- (BOOL)tryReload;

- (void)failedRequest:(NSString *)url code:(NSInteger)code message:(NSString *)message;
- (void)failedRequest:(NSError *)error;

- (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message;
- (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code message:(NSString *)message;

@end

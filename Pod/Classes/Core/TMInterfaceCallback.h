
//
//  TMInterfaceCallback.h
//  Pods
//
//  Created by LinXiaoBin on 2018/8/22.
//

#ifndef TMInterfaceCallback_h
#define TMInterfaceCallback_h

@class TMBaseRequest;
@class TMInterfaceBase;

typedef NS_ENUM(NSInteger, TMInterfaceErrorCode) {
    TMInterfaceErrorCodeURLError = -1000,  //请求地址异常
    TMInterfaceErrorCodeParamError = -1001,  //请求参数异常
};

/**
 接口回调 block

 @param request 接口请求对象
 @param responseObject 解析后的响应对象
 @param error 错误信息
 */
typedef void (^TMInterfaceResponseBlock_t)(TMBaseRequest *request, id responseObject, NSError *error);

/**
 解析模型回调
 */
typedef id (^TMResponseSerializeBlock_t)(TMBaseRequest *request, id responseObject, NSError **error);

/**
 接口对象管理回调
 */
@protocol TMInterfaceManagerDelegate <NSObject>
@required
- (void)tm_interfaceDidRequestFinished:(TMBaseRequest *)interface;
@end

#endif /* TMInterfaceCallback_h */

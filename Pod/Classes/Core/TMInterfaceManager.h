//
//  TMInterfaceManager.h
//  Pods
//
//  Created by LinXiaoBin on 16/3/15.
//
//

#import <Foundation/Foundation.h>

@class TMBaseRequest;

#define INTERFACER [TMInterfaceManager sharedInstance]

/**
 接口请求管理类
 */
@interface TMInterfaceManager : NSObject

+ (instancetype)sharedInstance;
+ (instancetype)modelInstance:(NSString *)name;

/**
 *  @brief 保留接口对象引用，供子类使用，接口请求结束后会自动去除引用
 *
 *  @param interface 接口对象
 */
- (void)addInterface:(TMBaseRequest *)interface;

@end

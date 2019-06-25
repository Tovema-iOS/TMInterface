//
//  TMNetwrokType.h
//  Pods
//
//  Created by LinXiaoBin on 16/8/4.
//
//

#import <Foundation/Foundation.h>

//网络接口对应的网络状态
typedef enum {
    TMNetworkTypeUnknow = 0,

    TMNetworkTypeWifi = 10,
    TMNetworkTypeUSB = 20,

    TMNetworkTypeWWAN = 30,
    TMNetworkTypeChinaUnicomWWAN = 31,
    TMNetworkTypeChinaTelecomWWAN = 32,
    TMNetworkTypeChinaMobileWWAN = 33,

    TMNetworkTypeMobile2G = 50,
    TMNetworkTypeChinaUnicom2G = 51,
    TMNetworkTypeChinaTelecom2G = 52,
    TMNetworkTypeChinaMobile2G = 53,

    TMNetworkTypeMobile3G = 60,
    TMNetworkTypeChinaUnicom3G = 61,
    TMNetworkTypeChinaTelecom3G = 62,
    TMNetworkTypeChinaMobile3G = 63,

    TMNetworkTypeMobile4G = 70,
    TMNetworkTypeChinaUnicom4G = 71,
    TMNetworkTypeChinaTelecom4G = 72,
    TMNetworkTypeChinaMobile4G = 73,
} TMNetworkType;

@interface TMNetwrokTypeManager : NSObject

+ (TMNetworkType)networkType;

@end

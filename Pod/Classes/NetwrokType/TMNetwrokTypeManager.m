//
//  TMNetwrokType.m
//  Pods
//
//  Created by LinXiaoBin on 16/8/4.
//
//

#import "TMNetwrokTypeManager.h"
#import "AFNetworking.h"
#import <objc/message.h>

//手机运营商
typedef enum {
    UnknowCarrier = 0,
    ChinaUnicomCarrier = 1,
    ChinaTelecomCarrier = 2,
    ChinaMobileCarrier = 3,
    ChinaTietongCarrier = 4,
} mobileCarrier;

@protocol CTTelephonyNetworkInfoDelegate <NSObject>  //CoreTelephony.framework
- (id)subscriberCellularProvider;
- (NSString *)mobileNetworkCode;
@end

@implementation TMNetwrokTypeManager

+ (void)load
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (TMNetworkType)networkType
{
    TMNetworkType mobileStatus = TMNetworkTypeUnknow;
    switch ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus) {
        case AFNetworkReachabilityStatusReachableViaWiFi:
            mobileStatus = TMNetworkTypeWifi;
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN: {
            mobileCarrier carrier = [self mobileCarrier];
            switch (carrier) {
                case ChinaUnicomCarrier:
                    mobileStatus = TMNetworkTypeChinaUnicomWWAN;
                    break;
                case ChinaTelecomCarrier:
                    mobileStatus = TMNetworkTypeChinaTelecomWWAN;
                    break;
                case ChinaMobileCarrier:
                    mobileStatus = TMNetworkTypeChinaMobileWWAN;
                    break;
                default:
                    mobileStatus = TMNetworkTypeWWAN;
                    break;
            }
        } break;

        default:
            break;
    }
    return mobileStatus;
}


+ (mobileCarrier)mobileCarrier
{
    mobileCarrier carrier = UnknowCarrier;

    static NSString *carrierCode = nil;
    if (carrierCode == nil) {
        NSString *countryCode = nil;
        id info = [[NSClassFromString(@"CTTelephonyNetworkInfo") alloc] init];
        if (info == nil)
            return carrier;

        id carrier = nil;
        if ([info respondsToSelector:@selector(subscriberCellularProvider)]) {
            carrier = [info subscriberCellularProvider];
        }
        SEL mobileCountryCodeSEL = NSSelectorFromString(@"mobileCountryCode");
        if ([carrier respondsToSelector:mobileCountryCodeSEL]) {
            NSString *(*sendMsg)(id, SEL) = (NSString * (*)(id, SEL)) objc_msgSend;
            countryCode = (NSString *)sendMsg(carrier, mobileCountryCodeSEL);

            if (countryCode && [countryCode isEqualToString:@"460"]) {
                SEL mobileNetworkCodeSEL = NSSelectorFromString(@"mobileNetworkCode");
                if ([carrier respondsToSelector:mobileNetworkCodeSEL]) {
                    NSString *(*sendMsg)(id, SEL) = (NSString * (*)(id, SEL)) objc_msgSend;
                    carrierCode = (NSString *)sendMsg(carrier, mobileNetworkCodeSEL);
                }
            } else {
                //other
            }
        }
    }
    if (carrierCode != nil) {
        if ([carrierCode isEqualToString:@"00"] || [carrierCode isEqualToString:@"02"] || [carrierCode isEqualToString:@"07"]) {
            //china mobile
            carrier = ChinaMobileCarrier;
        } else if ([carrierCode isEqualToString:@"01"] || [carrierCode isEqualToString:@"06"]) {
            //China Unicom
            carrier = ChinaUnicomCarrier;
        } else if ([carrierCode isEqualToString:@"03"] || [carrierCode isEqualToString:@"05"]) {
            //China Telecom
            carrier = ChinaTelecomCarrier;
        } else if ([carrierCode isEqualToString:@"20"]) {
            //China Tietong
            carrier = ChinaTietongCarrier;
        }
    }
    return carrier;
}

@end

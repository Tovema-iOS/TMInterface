//
//  FLCommonInterfaceTests.m
//  FLHomeInterface
//
//  Created by LinXiaoBin on 16/8/23.
//  Copyright © 2016年 linxiaobin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <FLInterface/FLHomeInterface.h>
#import "FLHomeSimpleModels.h"

@interface FLCommonInterfaceTests : XCTestCase

@end

@implementation FLCommonInterfaceTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConfig
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"获取配置参数(6)"];

    NSString *key = @"UrlChanges";
    NSString *version = @"1";
    NSString *defaultValue = @"[\"hello\", \"world\"]";
    [INTERFACER fl_6_appConfig:key
                       version:[version integerValue]
                  defaultValue:defaultValue
                 responseBlock:^(FLBaseRequest *interface, id responseObject, NSError *error) {
                     XCTAssertNotNil(error, @"请求出错");

                     [self testHeader:interface.responseHeader];

                     FLHomeConfigItem *config = (FLHomeConfigItem *)responseObject;
                     XCTAssertTrue([config isKindOfClass:[FLHomeConfigItem class]], @"对象解析异常");
                     XCTAssertTrue([version isEqualToString:config.Version], @"返回值异常");
                     XCTAssertTrue([defaultValue isEqualToString:config.Value], @"返回值异常");

                     [expectation fulfill];
                 }];

    [self waitForExpectationsWithTimeout:5
                                 handler:^(NSError *error) {
                                     XCTAssertNil(error, @"请求出错: %@", error);
                                 }];
}

- (void)testHeader:(NSDictionary *)header
{
    XCTAssertTrue([header isKindOfClass:[NSDictionary class]], @"请求异常");
    XCTAssertNotNil(header[@"ResultCode"], @"缺少接口状态码");
    XCTAssertEqual([header[@"ResultCode"] integerValue], 0, @"接口异常");
}


@end

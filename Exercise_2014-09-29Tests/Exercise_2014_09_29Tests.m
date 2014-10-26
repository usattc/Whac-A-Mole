//
//  Exercise_2014_09_29Tests.m
//  Exercise_2014-09-29Tests
//
//  Created by TTC on 9/29/14.
//  Copyright (c) 2014 TTC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface Exercise_2014_09_29Tests : XCTestCase

@end

@implementation Exercise_2014_09_29Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

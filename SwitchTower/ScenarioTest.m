//
//  ScenarioTest.m
//  SwitchTower
//
//  Created by bowdidge on 11/15/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Scenario.h"
#import "NamedPoint.h"
#import "TestScenario.h"

@interface ScenarioTest : XCTestCase

@end

@implementation ScenarioTest

- (void)testBasics {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    TestScenario *s = [[TestScenario alloc] init];
    
    XCTAssertTrue([s validateTileString], @"");
    XCTAssertEqual(2, s.tileRows, @"Wrong number for rows.");
    XCTAssertEqual(5, s.tileColumns , @"Wrong number for columns.");
    XCTAssertEqualObjects(nil, [s endpointWithName: @"Foo"], @"wrong answer for non-existent name.");
    XCTAssertEqualObjects(@"LeftTop", [s endpointWithName: @"LeftTop"].name, @"Wrong name");
    XCTAssertEqual('-', [s tileAtCell: MakeCellPosition(0,0)], @"Wrong");
    XCTAssertEqual('q', [s tileAtCell: MakeCellPosition(2,0)], @"");
    XCTAssertEqual('/', [s tileAtCell: MakeCellPosition(1,1)], @"");
    // TODO(bowdidge): Expected?
    XCTAssertEqual(' ', [s tileAtCell: MakeCellPosition(9,3)], @"");
    
    
    XCTAssertEqualObjects(@"Right", [s endpointAtCell: MakeCellPosition(4,0)].name, @"");
    XCTAssertEqualObjects(nil, [s endpointAtCell: MakeCellPosition(3,0)], @"");
    XCTAssertEqualObjects(nil, [s endpointAtCell: MakeCellPosition(5,12)], @"");
}

- (void) testFindInvalidCharactersInCellString {
    TestScenario *s = [[TestScenario alloc] init];
    s.tileStrings = [NSArray arrayWithObjects: @"FooBa", @"FooBa", nil];
    XCTAssertFalse([s validateTileString], @"Didn't detect invalid characters.");
}

- (void) testStartDateMidnight {
    NSDateFormatter* f = [[NSDateFormatter alloc] init];
    [f setDateFormat: @"yyyy-MM-dd HH:mm"];
    TestScenario *s = [[TestScenario alloc] init];
    NSDate *start = [f dateFromString: @"1935-01-15 00:00"];
    XCTAssertEqualObjects(@"1935-01-15 00:00", [f stringFromDate: start], @"");
    s.startingTime = start;

    NSDate *eightAM = [s scenarioTime: @"08:00"];
    XCTAssertEqualObjects(@"1935-01-15 08:00", [f stringFromDate: eightAM], @"");

    NSDate *eightPM = [s scenarioTime: @"20:00"];
    XCTAssertEqualObjects(@"1935-01-15 20:00", [f stringFromDate: eightPM], @"");
}

- (void) testStartDateNotMidnight {
    NSDateFormatter* f = [[NSDateFormatter alloc] init];
    [f setDateFormat: @"yyyy-MM-dd HH:mm"];
    TestScenario *s = [[TestScenario alloc] init];
    NSDate *start = [f dateFromString: @"1935-01-15 06:00"];
    XCTAssertEqualObjects(@"1935-01-15 06:00", [f stringFromDate: start], @"");
    s.startingTime = start;
    
    NSDate *eightAM = [s scenarioTime: @"08:00"];
    XCTAssertEqualObjects(@"1935-01-15 08:00", [f stringFromDate: eightAM], @"");
    
    NSDate *eightPM = [s scenarioTime: @"20:00"];
    XCTAssertEqualObjects(@"1935-01-15 20:00", [f stringFromDate: eightPM], @"");
}

// TODO(bowdidge): Fix wrapping, make sure time zones aren't messing things up.
- (void) testWrapDate {
    NSDateFormatter* f = [[NSDateFormatter alloc] init];
    [f setDateFormat: @"yyyy-MM-dd HH:mm"];
    TestScenario *s = [[TestScenario alloc] init];
    NSDate *start = [f dateFromString: @"1935-01-15 20:00"];
    XCTAssertEqualObjects(@"1935-01-15 20:00", [f stringFromDate: start], @"");
    s.startingTime = start;
    
    NSDate *nearMidnight = [s scenarioTime: @"23:59"];
    XCTAssertEqualObjects(@"1935-01-15 23:59", [f stringFromDate: nearMidnight], @"");
    
    NSDate *nextMorning = [s scenarioTime: @"08:00"];
    XCTAssertEqualObjects(@"1935-01-16 08:00", [f stringFromDate: nextMorning], @"");
}
@end

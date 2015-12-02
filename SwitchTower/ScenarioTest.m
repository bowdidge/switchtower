//
//  ScenarioTest.m
//  SwitchTower
//
// Copyright (c) 2015, Robert Bowdidge
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.
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

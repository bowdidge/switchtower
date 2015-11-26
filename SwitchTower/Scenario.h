//
//  LayoutSpecification.h
//  SwitchTower
//
//  Created by Robert Bowdidge on 12/22/12.
// Copyright (c) 2013, Robert Bowdidge
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

#import <Foundation/Foundation.h>

#import "Cell.h"

@class NamedPoint;
@class Signal;

// Scenario hides all the details related to a particular switching game: track arrangement, signals, and trains.
@interface Scenario : NSObject
// Load scenario from plist.
+ (Scenario*) scenarioFromDict: (NSDictionary*) dict;
- (char) tileAtCell: (struct CellPosition) pos;
- (NamedPoint*) endpointWithName: (NSString*) name;
- (NamedPoint*) endpointAtCell: (struct CellPosition) pos;
- (NSUInteger) lengthOfCellInFeet: (struct CellPosition) pos;

// Returns an NSDate for the time provided in HH:mm:ss form.
- (NSDate*) scenarioTime: (NSString*) timeString;

// Returns true if the named locations are identical.
- (BOOL) isNamedPoint: (NamedPoint*) a sameAs: (NamedPoint*) b;

- (NSString*) timetableHTML;
// Returns the HTML text for the Help view for this scenario.
- (NSString*) helpHTML;

// Processes tileStrings. Returns false if raw tile string is invalid.
// Exposed only for testing.
- (BOOL) validateTileString;

// Name and description to show in the UI.
@property (nonatomic, retain) NSString *scenarioName;
@property (nonatomic, retain) NSString *scenarioDescription;
@property (nonatomic, retain) NSDate *startingTime;
@property (nonatomic) int tickIntervalInSeconds;

@property (nonatomic, retain) NSArray *all_endpoints;
@property (nonatomic, retain) NSArray *all_signals;
@property (nonatomic, retain) NSArray *all_labels;
@property (nonatomic, retain) NSArray *all_trains;
@property (nonatomic, retain) NSArray *cellLengths;
@property (nonatomic) NSUInteger tileColumns;
@property (nonatomic) NSUInteger tileRows;
// TODO(bowdidge): Make more structured and validated.
@property (nonatomic, retain) NSArray *tileStrings;
@property (nonatomic, retain) NSString *helpString;
@end

// Helper routines for formatting times in our preferred format.
NSString* formattedTimeInterval(NSTimeInterval interval);
NSString* formattedDate(NSDate* date);

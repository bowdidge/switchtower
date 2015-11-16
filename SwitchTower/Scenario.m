//
//  LayoutSpecification.m
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

#import "Scenario.h"

#import "NamedPoint.h"
#import "Signal.h"
#import "Train.h"

@implementation Scenario

//
//  -  ---
//
//  = Platform / town
//
//      /       \
//  /  /     \   \
//    /           \
//
//       /       \
//  P  ---   p   ---
//
//
//  Q  ---   q   ---
//       \       /
//
//      /       \
//  R  /-    r  -\
//    /           \
//
//    \           /
//  V  \-    v  -/
//      \       /
//
//      /      \
//  Y --     y  --
//      \      /
//

//  /-      p   --
//     /           /
//
//       /          \
//   ---      V   ---
//

//       /          \
//  Q  ---      q   ---
//
//
//
//  Z  --      z    --
//    /               \
//
//     \              /
//  W   --     w    --
//
//  T  |--     t   --|


#define TILE_ROWS 1
#define TILE_COLUMNS 1
// Current track layout to draw.  See above for key of what the letters mean.
static char* cells = "";


- (int) tileRows {
    return TILE_ROWS;
}

- (int) tileColumns {
    return TILE_COLUMNS;
}

- (const char*) rawTileString {
    return cells;
}


- (id) init {
    self = [super init];
    self.tileStrings = [[NSString stringWithUTF8String: [self rawTileString]] componentsSeparatedByString: @"\n"];
    [self validateTileString];
    self.scenarioName = @"Unset scenario name";
    self.scenarioDescription = @"Unset scenario description";
    return self;
}

// Processes rawTileString, and sets self.tileStrings.  Returns false if raw tile string is invalid. 
- (BOOL) validateTileString {
    // TODO(bowdidge): Read from text file, or
    BOOL ok = true;
    NSMutableCharacterSet *invalidChars = [NSMutableCharacterSet characterSetWithCharactersInString: @"PpQqRrVvYyQqZzWwTt/\\.-= "];
    [invalidChars invert];
    if ([self.tileStrings count] != self.tileRows) {
        NSLog(@"Wrong number of tile strings, expected %d, got %d", self.tileRows, [self.tileStrings count]);
        ok = false;
    }
    for (NSString* str in self.tileStrings) {
        if ([str length] != self.tileColumns) {
            NSLog(@"Wrong number of characters in tile string '%@'.  Expected %d, got %d", str, self.tileColumns, [str length]);
            ok = false;
        }
        if ([str rangeOfCharacterFromSet: invalidChars options: 0].location != NSNotFound) {
            NSLog(@"Invalid characters in portion of tile string '%@'.", str);
            ok = false;
        }
        
    }

    return ok;
}
- (char) cellAtTileX: (int) x Y: (int) y {
    char ch;
    if ((y >= self.tileRows) || (x >= self.tileColumns) || (y < 0) || (x < 0)) {
        return ' ';
    }
    @try {
        ch = [[self.tileStrings objectAtIndex: y] characterAtIndex: x];
    } @catch(NSException* e){
        NSLog(@"Eeek!");
    }
    return ch;
}

- (NamedPoint*) endpointWithName: (NSString*) name {
    for (NamedPoint *ep in self.all_endpoints) {
        if ([ep.name isEqualToString: name]) {
            return ep;
        }
    }
    NSLog(@"Unknown end point '%@'!", name);
    return nil;
    
}

- (NamedPoint*) endpointAtTileX: (int) x Y: (int) y {
    for (NamedPoint *ep in self.all_endpoints) {
        if (ep.xPosition == x && ep.yPosition == y) {
            return ep;
        }
    }
    return nil;
    
}

- (NSDate*) zeroDate {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"HH:mm"];
    return [dateFormatter dateFromString: @"00:00"];
}

- (NSDate*) startingTime {
    // Assume all scenarios start at 6:00 am.
    // TODO(bowdidge): Fix time zone.
    return [self scenarioTime: @"05:30"];
}

- (int) tickLengthInSeconds {
    return 60;
}

- (NSDate*) scenarioTime: (NSString*) timeString {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"HH:mm"];

    NSDate* zeroDate = [dateFormatter dateFromString: @"00:00"];
    NSDate* date = [dateFormatter dateFromString: timeString];
    NSTimeInterval offset = [date timeIntervalSinceDate: zeroDate];
    NSDate *returnValue = [[self zeroDate] dateByAddingTimeInterval: offset];
    return returnValue;
}


- (BOOL) isNamedPoint: (NamedPoint*) a sameAs: (NamedPoint*) b {
    return (a == b);
}


NSString* formattedTimeInterval(NSTimeInterval interval) {
    if (interval < 60) {
        return [NSString stringWithFormat: @"%d seconds", (int)interval];
    }
    return [NSString stringWithFormat: @"%d minutes", (int) interval / 60];
}


NSString* formattedDate(NSDate* date) {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"HH:mm"];
    NSString *dateString = [format stringFromDate:date];
    return dateString;
}

// timetableHTML creates the timetable display for the current scenario.
- (NSString*) timetableHTML {
    NSMutableString *result = [NSMutableString string];
    [result appendString: @"<html>\n<head>\n<style>\n td {\n  padding: 5px;\n }\n .trainno {\n weight: bold;\n font-size: 16pt;\n }\n  .trainname {\n weight: normal;\n font-size: 9pt;\n}\n .stationname {\n font-weight: bold;\n text-transform: uppercase;\n text-align:center;\n font-family: @'Helvetica';\n }\n .rules {\n  width: 80%;\n border: solid 1px;\n padding: 5px;\n }\
     </style>\n</head>\n<body>\n<div style='width: 60%;'>\n<center>Timetable No. 1, April 26, 1964</center>\n<center>WESTERN DIVISION</center>\n<table border='1'>\n"];
    [result appendString: @"<tr>\n"];
    NSMutableArray *eastTrains = [NSMutableArray array];
    NSMutableArray *westTrains = [NSMutableArray array];
    for (Train *tr in self.all_trains) {
        if (tr.onTimetable && tr.direction == EastDirection) {
            [result appendFormat: @"<td class='trainno'>%@<br><span class='trainname'>%@</span></td>", tr.trainName, tr.trainDescription];
            [eastTrains addObject: tr];
        }
    }
    [result appendFormat: @"<td class='stationname'></td>" ];
    for (Train *tr in self.all_trains) {
        if (tr.onTimetable && tr.direction == WestDirection) {
            [result appendFormat: @"<td class='trainno'>%@<br><span class='trainname'>%@</span></td>", tr.trainName, tr.trainDescription];
            [westTrains addObject: tr];
        }
    }
    [result appendString: @"</tr>"];
    [result appendString: @"<tr>"];
    for (Train *tr in eastTrains) {
        [result appendFormat: @"<td>%@</td>", formattedDate([tr departureTime])];
    }
    [result appendString: @"<td class='stationname'>Oakland Pier</td>"];
    for (Train *tr in westTrains) {
        [result appendFormat: @"<td>%@</td>", formattedDate([[tr departureTime] dateByAddingTimeInterval: 5 * 60])];
    }
    [result appendString: @"</tr>\n"];
    
    [result appendString: @"<tr bgcolor='LightYellow'>"];
    for (Train *tr in eastTrains) {
        [result appendFormat: @"<td>%@</td>", formattedDate([[tr departureTime] dateByAddingTimeInterval: 3 * 60] )];
    }
    [result appendString: @"<td class='stationname'>Oakland 16th St. </td>"];
    for (Train *tr in westTrains) {
        [result appendFormat: @"<td>%@</td>", formattedDate([[tr departureTime] dateByAddingTimeInterval: 3 * 60])];
    }
    [result appendString: @"</tr>\n"];
    
    [result appendString: @"<tr>"];
    for (Train *tr in eastTrains) {
        [result appendFormat: @"<td>%@</td>", formattedDate([[tr departureTime] dateByAddingTimeInterval: 5 * 60])];
    }
    [result appendString: @"<td class='stationname'>Shellmound</td>"];
    for (Train *tr in westTrains) {
        [result appendFormat: @"<td>%@</td>", formattedDate([tr departureTime])];
    }
    [result appendString: @"</tr>\n"];
    [result appendString: @"</table>\n </div>\n <br>\n <div class='rules'>\n<b>RULE 5.</b> Time applies at the location of station sign at stations between San Francisco and San Jose and on Santa Clara-Newark line will apply at junction switch, Santa Clara.\n<br>\n<B>RULE S-72.</b> Exception: No. 98 is superior to Nos. 371, 373, 75, and 141.\n </div> </body>\n"];
    return result;
}


@synthesize all_endpoints;
@end

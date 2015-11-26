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

#import "Label.h"
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


- (const char*) rawTileString {
    return cells;
}


- (id) init {
    self = [super init];
    self.scenarioName = @"Unset scenario name";
    self.scenarioDescription = @"Unset scenario description";
    self.tickIntervalInSeconds = 30;
    self.cellLengths = nil;
    return self;
}

BOOL ParsePosition(NSString* posString, struct CellPosition* pos) {
    NSArray *components = [posString componentsSeparatedByString: @","];
    if ([components count] != 2) {
        return FALSE;
    }
    pos->x = [[components objectAtIndex: 0] intValue];
    pos->y = [[components objectAtIndex: 1] intValue];
    return TRUE;
}

BOOL ParseDirection(NSString* directionStr, enum TimetableDirection *dir) {
    if ([directionStr isEqualToString: @"West"]) {
        *dir = WestDirection;
    } else if ([directionStr isEqualToString: @"East"]) {
        *dir = EastDirection;
    } else {
        return false;
    }
    return true;
}

+ (Scenario*) scenarioFromDict: (NSDictionary*) dict {
    Scenario *s = [[[Scenario alloc] init] autorelease];
    s.tileStrings = [dict objectForKey: @"Schematic"];
    s.tileRows = [s.tileStrings count];
    NSString *firstRow = [s.tileStrings objectAtIndex: 0];
    s.tileColumns = [firstRow length];
    [s validateTileString];
    
    s.scenarioName = [dict objectForKey: @"Name"];
    s.scenarioDescription = [dict objectForKey: @"Description"];
    NSDate *startingTime = [dict objectForKey: @"StartTime"];
    s.startingTime = startingTime;
    NSNumber *tickInterval = [dict objectForKey: @"TickIntervalSecs"];
    if (tickInterval) {
        s.tickIntervalInSeconds = [tickInterval intValue];
    }
    NSMutableArray *allLabels = [NSMutableArray array];
    NSDictionary *labelDict = [dict objectForKey: @"Labels"];
    for (NSString* labelName in [labelDict allKeys]) {
        NSString* posString = [labelDict objectForKey: labelName];
        struct CellPosition pos;
        if (!ParsePosition(posString, &pos)) {
                // Parsing problem.
        }
        [allLabels addObject: [Label labelWithString: labelName cell: pos]];
    }
    s.all_labels = allLabels;
    
    NSString *helpString = [dict objectForKey: @"Help"];
    if (helpString) {
        s.helpString = helpString;
    }
    
    NSMutableArray *allSignals = [NSMutableArray array];
    NSArray *signals = [dict objectForKey: @"Signals"];
    for (NSDictionary* signalDict in signals) {
        NSString *dirString = [signalDict objectForKey: @"Direction"];
        enum TimetableDirection dir;
        if (ParseDirection(dirString, &dir)) {
            // bad.
        }
        NSString *posString = [signalDict objectForKey: @"Location"];
        struct CellPosition pos;
        if (!ParsePosition(posString, &pos)) {
        }
        Signal *s = [Signal signalControlling:dir position: pos];
        [allSignals addObject: s];
    }
    s.all_signals = allSignals;

    NSMutableArray *allEndpoints = [NSMutableArray array];
    NSArray *endpoints = [dict objectForKey: @"Endpoints"];
    for (NSDictionary *endpoint in endpoints) {
        NSString* endpointName = [endpoint objectForKey: @"Name"];
        NSString *endpointLocationStr = [endpoint objectForKey: @"Location"];
        struct CellPosition pos;
        if (!ParsePosition(endpointLocationStr, &pos)) {
            // Parsing problem.
        }
        [allEndpoints addObject: [NamedPoint namedPointWithName: endpointName cell: pos]];
    }
    s.all_endpoints = allEndpoints;
    NSArray *cellLengths = [dict objectForKey: @"CellLengths"];
    // TODO(bowdidge): Check all are numbers.
    s.cellLengths = cellLengths;
    
    NSMutableArray *allTrains = [NSMutableArray array];
    NSArray *trains = [dict objectForKey: @"Trains"];
    for (NSDictionary *trainDict in trains) {
        NSString* trainIdentifier = [trainDict objectForKey: @"Identifier"];
        NSString *trainName = [trainDict objectForKey: @"Name"];
        NSString *trainDescription = [trainDict objectForKey: @"Description"];
        NSString *directionStr = [trainDict objectForKey: @"Direction"];
        NSString *departureEndpoint = [trainDict objectForKey: @"Departs"];
        NSString *departureTimeStr = [trainDict objectForKey: @"DepartureTime"];
        NSString *arrivalTimeStr = [trainDict objectForKey: @"ArrivalTime"];
        NSNumber *onTimetable = [trainDict objectForKey: @"OnTimetable"];
        NSArray *becomes = [trainDict objectForKey: @"Becomes"];
        NSArray *arrivalEndpoints = [trainDict objectForKey: @"Arrives"];
        NSNumber *speedMPH = [trainDict objectForKey: @"Speed"];
        enum TimetableDirection dir;
        if (ParseDirection(directionStr, &dir)) {
            // bad.
        }

        NSMutableArray *endpoints = [NSMutableArray array];
        for (NSString *end in arrivalEndpoints) {
            NamedPoint *pt = [s endpointWithName: end];
            if (!pt) {
                NSLog(@"Unknown endpoint %@ in train %@", end, trainName);
                continue;
            }
            [endpoints addObject: pt];
        }
        NamedPoint *startPoint = nil;
        if (departureEndpoint != nil && departureEndpoint.length > 0) {
            startPoint = [s endpointWithName: departureEndpoint];
            if (!startPoint) {
                NSLog(@"Unknown start point %@ in train %@", departureEndpoint, trainName);
            }
        }
        Train *tr = [Train trainWithNumber: trainIdentifier name: trainName direction: dir start: startPoint ends: endpoints];
        tr.departureTime = [s scenarioTime: departureTimeStr];
        tr.trainDescription = trainDescription;
        tr.arrivalTime = [s scenarioTime: arrivalTimeStr];
        tr.onTimetable = [onTimetable boolValue];
        tr.currentState = Inactive;
        tr.becomesTrains = becomes;
        if (speedMPH) {
            tr.speedMPH = [speedMPH intValue];
        }
        [allTrains addObject: tr];
    }
    s.all_trains = allTrains;
    return s;
}



// Processes rawTileString, and sets self.tileStrings.  Returns false if raw tile string is invalid. 
- (BOOL) validateTileString {
    BOOL ok = true;
    NSMutableCharacterSet *invalidChars = [NSMutableCharacterSet characterSetWithCharactersInString: @"PpQqRrVvYyQqZzWwTt/\\.-= "];
    [invalidChars invert];
    if ([self.tileStrings count] != self.tileRows) {
        NSLog(@"Wrong number of tile strings, expected %d, got %d", (int) self.tileRows, (int) [self.tileStrings count]);
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
- (char) tileAtCell: (struct CellPosition) pos {
    char ch;
    if ((pos.y >= self.tileRows) || (pos.x >= self.tileColumns) || (pos.y < 0) || (pos.x < 0)) {
        return ' ';
    }
    @try {
        ch = [[self.tileStrings objectAtIndex: pos.y] characterAtIndex: pos.x];
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

- (NamedPoint*) endpointAtCell: (struct CellPosition) pos {
    for (NamedPoint *ep in self.all_endpoints) {
        if (ep.position.x == pos.x && ep.position.y == pos.y) {
            return ep;
        }
    }
    return nil;
    
}

- (NSUInteger) lengthOfCellInFeet: (struct CellPosition) pos {
    if (!self.cellLengths) {
        // Trains go 1320 feet per 30 sec tick at 30 mph.
        return 1300;
    }
    return [[self.cellLengths objectAtIndex: pos.x] intValue];
}

- (NSDate*) zeroDate {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"HH:mm"];
    return [dateFormatter dateFromString: @"00:00"];
}

// Calculates the NSDate for the time listed that is after the starting time for the session.  May wrap to next day.
- (NSDate*) scenarioTime: (NSString*) timeString {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat: @"HH:mm"];
    // Find the time we get for 00:00 and for the requested time.  This gives us an offset from the beginning of the day.
    NSDate* zeroDate = [dateFormatter dateFromString: @"00:00"];
    NSDate* requestedDate = [dateFormatter dateFromString: timeString];
    NSTimeInterval offsetFromZero = [requestedDate timeIntervalSinceDate: zeroDate];
    
    NSDate *startOfDay =[[NSCalendar currentCalendar] startOfDayForDate: self.startingTime];
    NSDate *result = [startOfDay dateByAddingTimeInterval: offsetFromZero];
    if ([result compare: self.startingTime] == NSOrderedDescending) {
        return result;
    }
    // Add an extra day - things wrapped, and the result was smaller than starting time.
    return [result dateByAddingTimeInterval: 24 * 60 * 60];
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

const char *TIMETABLE_HEADER =
    "<html>\n"
    "<head>\n"
    "<style>\n"
    "td {\n"
    "  padding: 5px;\n"
    "}\n"
    ".trainno {\n"
    "  weight: bold;\n"
    "  font-size: 16pt;\n"
    "}\n"
    ".trainname {\n"
    "weight: normal;\n"
    "  font-size: 9pt;\n"
    "}\n"
    ".stationname {\n"
    "  font-weight: bold;\n"
    "  text-transform: uppercase;\n"
    "  text-align:center;\n"
    "  font-family: @'Helvetica';\n"
    "}\n"
    ".rules {\n"
    "  width: 80%;\n"
    "  border: solid 1px;\n"
    "  padding: 5px;\n"
    "}\n"
    "</style>\n"
    "</head>\n"
    "<body>\n"
    "<div style='width: 60%;'>\n"
    "<center>Timetable No. 1, April 26, 1964</center>\n"
    "<center>WESTERN DIVISION</center>\n"
    "<table border='1'>\n";

// timetableHTML creates the timetable display for the current scenario.
- (NSString*) timetableHTML {
    NSMutableString *result = [NSMutableString stringWithUTF8String: TIMETABLE_HEADER];
    [result appendString: @"<tr>\n"];
    NSMutableArray *eastTrains = [NSMutableArray array];
    NSMutableArray *westTrains = [NSMutableArray array];
    NSArray *allTrains = [self.all_trains sortedArrayUsingSelector: @selector(compareByTime:)];
    for (Train *tr in allTrains) {
        if (tr.onTimetable && tr.direction == EastDirection) {
            [result appendFormat: @"<td class='trainno'>%@<br><span class='trainname'>%@</span></td>", tr.trainNumber, tr.trainName];
            [eastTrains addObject: tr];
        }
    }
    [result appendFormat: @"<td class='stationname'></td>" ];
    for (Train *tr in allTrains) {
        if (tr.onTimetable && tr.direction == WestDirection) {
            [result appendFormat: @"<td class='trainno'>%@<br><span class='trainname'>%@</span></td>", tr.trainNumber, tr.trainName];
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

- (NSString*) helpHTML {
    return self.helpString;
}


@synthesize all_endpoints;
@synthesize startingTime;
@end

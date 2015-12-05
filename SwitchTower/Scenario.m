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


BOOL ParsePosition(NSString* posString, struct CellPosition* pos) {
    NSArray *components = [posString componentsSeparatedByString: @","];
    if ([components count] != 2) {
        return FALSE;
    }
    pos->x = [[components objectAtIndex: 0] intValue];
    pos->y = [[components objectAtIndex: 1] intValue];
    return TRUE;
}

NSString *DirectionString(enum TimetableDirection dir) {
    if (dir == WestDirection) {
        return @"West";
    } else {
        return @"East";
    }
}

NSArray *NamedPointNames(NSArray* points) {
    NSMutableArray *names = [NSMutableArray array];
    for (NamedPoint *pt in points) {
        [names addObject: pt.name];
    }
    return names;
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

- (id) initWithDict: (NSDictionary*) dict {
    self = [super init];
    self.tileStrings = [dict objectForKey: @"Schematic"];
    self.tileRows = [self.tileStrings count];
    NSString *firstRow = [self.tileStrings objectAtIndex: 0];
    self.tileColumns = [firstRow length];
    [self validateTileString];
    
    // Process the timetable information.  The TimetableNames is a list
    // of the station names for the timetable, in order they should be
    // drawn.
    // Each train has as TimetableEntry mapping a name to a time.
    self.timetableNames = [dict objectForKey: @"TimetableNames"];
    
    
    NSMutableArray *cellLengths = [NSMutableArray arrayWithArray: [dict objectForKey: @"CellLengths"]];
    // TODO(bowdidge): Check all are numberself.
    self.cellLengths = cellLengths;
    
    self.scenarioName = [dict objectForKey: @"Name"];
    self.scenarioDescription = [dict objectForKey: @"Description"];
    
    NSDate *startTime = [dict objectForKey: @"StartTime"];
    self.startingTime = startTime;
    
    NSNumber *tickInterval = [dict objectForKey: @"TickIntervalSecs"];
    if (tickInterval) {
        self.tickIntervalInSeconds = [tickInterval intValue];
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
    self.all_labels = allLabels;
    
    NSString *helpString = [dict objectForKey: @"Help"];
    if (helpString) {
        self.helpString = helpString;
    }
    
    NSMutableArray *allSignals = [NSMutableArray array];
    NSArray *signals = [dict objectForKey: @"Signals"];
    if (signals.count == 0) {
        NSLog(@"No signals?!");
    }
    
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
    self.all_signals = allSignals;
    
    NSMutableArray *allEndpoints = [NSMutableArray array];
    NSArray *endpoints = [dict objectForKey: @"Endpoints"];
    if (endpoints.count == 0) {
        NSLog(@"No endpoints?!");
    }
    for (NSDictionary *endpoint in endpoints) {
        NSString* endpointName = [endpoint objectForKey: @"Name"];
        NSString *endpointLocationStr = [endpoint objectForKey: @"Location"];
        struct CellPosition pos;
        if (!ParsePosition(endpointLocationStr, &pos)) {
            // Parsing problem.
        }
        [allEndpoints addObject: [NamedPoint namedPointWithName: endpointName cell: pos]];
    }
    self.all_endpoints = allEndpoints;
    
    
    NSMutableArray *allTrains = [NSMutableArray array];
    NSArray *trains = [dict objectForKey: @"Trains"];
    if (!trains || trains.count == 0) {
        NSLog(@"No trains?!");
    } else {
        for (NSDictionary *trainDict in trains) {
            NSString* trainIdentifier = [trainDict objectForKey: @"Identifier"];
            NSString *trainName = [trainDict objectForKey: @"Name"];
            NSString *trainDescription = [trainDict objectForKey: @"Description"];
            NSString *directionStr = [trainDict objectForKey: @"Direction"];
            NSString *departureEndpoint = [trainDict objectForKey: @"Departs"];
            NSString *departureTimeStr = [trainDict objectForKey: @"DepartureTime"];
            NSString *arrivalTimeStr = [trainDict objectForKey: @"ArrivalTime"];
            NSNumber *onTimetable = [trainDict objectForKey: @"OnTimetable"];
            NSMutableArray *becomes = [NSMutableArray arrayWithArray: [trainDict objectForKey: @"Becomes"]];
            NSArray *arrivalEndpoints = [trainDict objectForKey: @"Arrives"];
            NSNumber *speedMPH = [trainDict objectForKey: @"Speed"];
            enum TimetableDirection dir;
            if (ParseDirection(directionStr, &dir)) {
                // bad.
            }
            
            NSMutableArray *endpoints = [NSMutableArray array];
            for (NSString *end in arrivalEndpoints) {
                NamedPoint *pt = [self endpointWithName: end];
                if (!pt) {
                    NSLog(@"Unknown endpoint %@ in train %@", end, trainName);
                    continue;
                }
                [endpoints addObject: pt];
            }
            NamedPoint *startPoint = nil;
            if (departureEndpoint != nil && departureEndpoint.length > 0) {
                startPoint = [self endpointWithName: departureEndpoint];
                if (!startPoint) {
                    NSLog(@"Unknown start point %@ in train %@", departureEndpoint, trainName);
                }
            }
            Train *tr = [Train trainWithNumber: trainIdentifier name: trainName direction: dir start: startPoint ends: endpoints];
            tr.departureTime = [self scenarioTime: departureTimeStr];
            tr.trainDescription = trainDescription;
            tr.arrivalTime = [self scenarioTime: arrivalTimeStr];
            tr.onTimetable = [onTimetable boolValue];
            tr.currentState = Inactive;
            tr.becomesTrains = becomes;
            if (speedMPH) {
                tr.speedMPH = [speedMPH intValue];
            }
            NSDictionary *timetableEntry = [trainDict objectForKey: @"TimetableEntry"];
            tr.timetableEntry = timetableEntry;
            [allTrains addObject: tr];
            
            NSMutableArray *bannedResults = [NSMutableArray array];
            NSArray *bannedRules = [trainDict objectForKey: @"BannedRules"];
            if (bannedRules && bannedRules.count > 0) {
                for (NSDictionary *dict in bannedRules) {
                    BannedRule *br = [[BannedRule alloc] init];
                    NSMutableArray *bannedPoints = [NSMutableArray array];
                    for (NSString* namedPoint in [dict objectForKey: @"NamedPoints"]) {
                        NamedPoint *pt = [self endpointWithName: namedPoint];
                        if (!pt) {
                            NSLog(@"Couldn't find endpoint named %@", namedPoint);
                        } else {
                            [bannedPoints addObject: pt];
                        }
                    }
                    br.bannedPoints = bannedPoints;
                    NSNumber *pts = [dict objectForKey: @"PointsLost"];
                    
                    NSString *explanation = [dict objectForKey: @"Explanation"];
                    br.pointsLost = [pts intValue];
                    br.message = explanation;
                    [bannedResults addObject: br];
                }
                tr.bannedRules = bannedResults;
            }
            
        }
    }
    self.all_trains = allTrains;
    return self;
}

- (NSDictionary*) scenarioAsDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject: self.tileStrings forKey: @"Schematic"];
    
    [dict setObject: self.helpString forKey: @"Help"];
    [dict setObject: self.timetableNames forKey: @"TimetableNames"];
    [dict setObject: self.cellLengths forKey: @"CellLengths"];

    [dict setObject: self.scenarioName forKey: @"Name"];
    [dict setObject: self.scenarioDescription forKey: @"Description"];
    [dict setObject: self.startingTime forKey: @"StartTime"];
    [dict setObject: [NSNumber numberWithInt: self.tickIntervalInSeconds] forKey: @"TickIntervalSecs"];
    
    NSMutableDictionary *labels = [NSMutableDictionary dictionary];
    for (Label *l in self.all_labels) {
        [labels setObject: CellPositionAsString(l.position) forKey: l.labelString];
    }
    [dict setObject: labels forKey: @"Labels"];

    NSMutableArray *signals = [NSMutableArray array];
    for (Signal *sig in self.all_signals) {
        NSMutableDictionary *signalDict = [NSMutableDictionary dictionary];
        [signalDict setObject: CellPositionAsString(sig.position) forKey: @"Location"];
        [signalDict setObject: DirectionString(sig.trafficDirection) forKey: @"Direction"];
        [signals addObject: signalDict];
    }
    [dict setObject: signals forKey: @"Signals"];

    NSMutableArray *endpoints = [NSMutableArray array];
    for (NamedPoint *namedPoint in self.all_endpoints) {
        NSMutableDictionary *endpointDict = [NSMutableDictionary dictionary];
        [endpointDict setObject: CellPositionAsString(namedPoint.position) forKey: @"Location"];
        [endpointDict setObject: namedPoint.name forKey: @"Name"];
        [endpoints addObject: endpointDict];
    }
    [dict setObject: endpoints forKey: @"Endpoints"];

    NSMutableArray *trains = [NSMutableArray array];
    for (Train *tr in self.all_trains) {
        NSMutableDictionary *trainDict = [NSMutableDictionary dictionary];
        [trainDict setObject: tr.trainNumber forKey: @"Identifier"];
        [trainDict setObject: tr.trainName forKey: @"Name"];
        [trainDict setObject: tr.trainDescription forKey: @"Description"];
        [trainDict setObject: DirectionString(tr.direction) forKey: @"Direction"];
        if (tr.startPoint.name) {
            [trainDict setObject: tr.startPoint.name forKey: @"Departs"];
        }
        [trainDict setObject: formattedDate(tr.departureTime) forKey: @"DepartureTime"];
        [trainDict setObject: NamedPointNames(tr.expectedEndPoints) forKey: @"Arrives"];
        [trainDict setObject: formattedDate(tr.arrivalTime) forKey: @"ArrivalTime"];
        if (tr.onTimetable) {
            [trainDict setObject: [NSNumber numberWithInt: 1] forKey: @"OnTimetable"];
        }
        if (tr.becomesTrains.count > 0) {
            [trainDict setObject: tr.becomesTrains forKey: @"Becomes"];
        }
        [trainDict setObject: [NSNumber numberWithInt: (int) tr.speedMPH] forKey: @"Speed"];
        
        if (tr.timetableEntry) {
            [trainDict setObject: tr.timetableEntry forKey: @"TimetableEntry"];
        }
        
        if (tr.bannedRules.count > 0) {
            NSMutableArray *bannedRules = [NSMutableArray array];
            for (BannedRule *br in tr.bannedRules) {
                NSMutableDictionary *ruleDict = [NSMutableDictionary dictionary];
                [ruleDict setObject: NamedPointNames(br.bannedPoints) forKey: @"NamedPoints"];
                [ruleDict setObject: [NSNumber numberWithInt: (int) br.pointsLost] forKey: @"PointsLost"];
                [ruleDict setObject: br.message forKey: @"Explanation"];
                [bannedRules addObject: ruleDict];
            }
            [trainDict setObject: bannedRules forKey: @"BannedRules"];
        }
        [trains addObject: trainDict];
    }
    [dict setObject: trains forKey: @"Trains"];
    
    return dict;
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
            NSLog(@"Wrong number of characters in tile string '%@'.  Expected %lu, got %lu", str, (unsigned long)self.tileColumns, (unsigned long)[str length]);
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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    return [dateFormatter dateFromString: @"00:00"];
}

// Calculates the NSDate for the time listed that is after the starting time for the session.  May wrap to next day.
- (NSDate*) scenarioTime: (NSString*) timeString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
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
    "table,th,td {\n"
    "border 1px solid black\n"
    "}\n"
    "table {\n"
    "  border-collapse: collapse;}\n"
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
    for (NSString *stationName in self.timetableNames) {
        [result appendString: @"<tr>"];

        for (Train *tr in eastTrains) {
            NSString *departureTime = [tr.timetableEntry objectForKey: stationName];
            if (!departureTime) {
                [result appendString: @"<td> </td>"];
            } else {
                [result appendFormat: @"<td>%@</td>", departureTime];
            }
        }
        [result appendFormat: @"<td class='stationname'>%@</td>", stationName];
        for (Train *tr in westTrains) {
            NSString *departureTime = [tr.timetableEntry objectForKey: stationName];
            if (!departureTime) {
                [result appendString: @"<td> </td>"];
            } else {
                [result appendFormat: @"<td>%@</td>", departureTime];
            }
        }
        [result appendString: @"</tr>\n"];
    }
    [result appendString: @"</table>\n </div>\n <br>\n <div class='rules'>\n<b>RULE 5.</b> Time applies at the location of station sign at stations between San Francisco and San Jose and on Santa Clara-Newark line will apply at junction switch, Santa Clara.\n<br>\n<B>RULE S-72.</b> Exception: No. 98 is superior to Nos. 371, 373, 75, and 141.\n </div> </body>\n"];
    return result;
}

- (NSString*) helpHTML {
    return self.helpString;
}


@synthesize all_endpoints;
@synthesize startingTime;
@end

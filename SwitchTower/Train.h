//
//  Train.h
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

#import "Signal.h"
#import "Cell.h"

@class NamedPoint;
@class LayoutView;
@class Train;

// TODO(bowdidge): Also need scripts for splitting a train into two (engine, cars), and another
// for allowing something to sit for a very long time.
enum TrainState {
    Inactive, // waiting to run
    Waiting, // visible, not moving.
    Running, // moving
    Complete // done, off layout.
};

// TODO(bowdidge):
// Need scripts for starting after a short delay.
// Need scripts for splitting train and leaving cars on the tracks.
@interface Train : NSObject

+ (id) train;
+ (id) trainWithNumber: (NSString*) trainNumber name: (NSString*) trainName direction: (enum TimetableDirection) dir
               start: (NamedPoint*) start ends: (NSArray*) end;
- (void) setDepartureTime: (NSDate*) departureTime arrivalTime: (NSDate*) arrivalTime;

// Returns YES if train is at its starting location, which means the train hasn't moved.
- (BOOL) isAtStartPosition;
- (BOOL) isAtEndPosition;

// Helper routine for nicely printing out all the possible exit points for train.
- (NSString*) endPointsAsText;

@property(nonatomic, retain) NSString *trainNumber;
@property(nonatomic, retain) NSString *trainName;
@property(nonatomic, retain) NSString *longDescription;
// Not retained.
@property(nonatomic,assign) LayoutView *currentLayout;
@property(nonatomic) struct CellPosition position;
@property(nonatomic, retain) NamedPoint *startPoint;
// TODO(bowdidge): Could also have separate "not great, but OK exits".
// Array of NamedPoints naming places where train could exit.
@property(nonatomic, retain) NSArray *expectedEndPoints;
@property(nonatomic) enum TimetableDirection direction;
@property(nonatomic) enum TrainState currentState;
// Empty if train is started by another.
@property(nonatomic, retain) NSDate* departureTime;
// Expected time to arrive.  Used to decide if late.
@property(nonatomic, retain) NSDate* arrivalTime;

// Next steps.
// List of trains that this should become when complete.
@property(nonatomic, retain) NSArray *becomesTrains;
@property(nonatomic, retain) NSArray *timetable;
// TODO(bowdidge): Add schedule for passing particular stations.
// True if train should appear in timetables.
@property(nonatomic) BOOL onTimetable;
@end


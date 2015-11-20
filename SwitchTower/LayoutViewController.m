//
//  ViewController.m
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

#import "LayoutViewController.h"

#import "NamedPoint.h"
#import "FourthStreetScenario.h"
#import "Scenario.h"
#import "LayoutView.h"
#import "PenzanceScenario.h"
#import "ShellmoundScenario.h"
#import "SantaCruzScenario.h"
#import "TimetableViewController.h"
#import "Train.h"

@implementation LayoutViewController
- (void) dealloc {
    AudioServicesDisposeSystemSoundID(chimeStartingSound);
    AudioServicesDisposeSystemSoundID(clickSound);
    AudioServicesDisposeSystemSoundID(blockedSound);
    [super dealloc]; // only in manual retain/release, delete for ARC
}
 

// Initializes the scheduled timer.
- (IBAction)startTickTimer:sender {
    layoutView.currentTime = self.scenario.startingTime;
    self.activeTrains = [NSMutableArray arrayWithArray: self.scenario.all_trains];
    self.myTimer_ = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                     target:self
                                                   selector:@selector(nextTick:)
                                                   userInfo: nil
                                                    repeats:YES];
}

- (void) stopTickTimer: (id) sender {
    [self.myTimer_ invalidate];
}

// Handles next clock tick.  Moves al trains that can be moved, removes all trains that reach an
// exit, and starts new trains on their journey.
// TODO(bowdidge): Some of the basic motion code here should really go to LayoutModel, with only the
// code needed for triggering events (redraw, beeps, etc) staying.
- (void) nextTick: (id) sender {
    [self.alertView clearAlerts];
    BOOL someTrainIsBlocked = NO;
    LayoutView *myLayoutView = (LayoutView*) self.layoutView;
     myLayoutView.currentTime = [myLayoutView.currentTime dateByAddingTimeInterval: scenario.tickIntervalInSeconds];
    NSDate *currentTime = myLayoutView.currentTime;
    NSMutableArray *completedTrains = [NSMutableArray array];
    
    for (Train *train in self.activeTrains) {
        if (train.currentState != Running) continue;
        if (train.direction == WestDirection) {
            if (![self.layoutModel moveTrainWest: train]) {
                //blocked.
                if (train.onTimetable) {
                    [self.alertView addAlertAtLocation: train.position.x max: self.scenario.tileColumns];
                    someTrainIsBlocked = YES;
                }
           }
            [self.layoutView setNeedsDisplay];
        } else if (train.direction == EastDirection) {
            if (![self.layoutModel moveTrainEast: train]) {
                //blocked.
                if (train.onTimetable) {
                   [self.alertView addAlertAtLocation: train.position.x max: self.scenario.tileColumns];
                   someTrainIsBlocked = YES;
                }
            }
            [self.layoutView setNeedsDisplay];
        }
        
        // Check if train reached a named point where it's supposed to end.
        NamedPoint *currentNamedPoint = [self.layoutModel isNamedPoint: train.position];
        // If this is either the destination for the train, or if we're on an endpoint, then we stop.
        // Assume all ends have names.
        if (currentNamedPoint && [train isAtEndPosition]) {
            NSString* msg;
            if ([currentTime compare: train.arrivalTime] == NSOrderedAscending) {
                msg = [NSString stringWithFormat: @"%@ arrived on time.\n", train.trainNumber];
                self.layoutView.score += 2;
            } else {
                NSTimeInterval delta = [currentTime timeIntervalSinceDate: train.arrivalTime];
                msg = [NSString stringWithFormat: @"train %@ arrived %.2f minutes late\n", train.trainNumber, delta / 60];
                self.layoutView.score -= 1;
            }
            [self.statusMessages addObject: msg];
            [completedTrains addObject: train];
        } else if ([self.layoutModel isEndPoint: train.position] &&
                    // Not quite correct.  This needs to distinguish between named spots
                    // passing through, and named spots that were the wrong direction.
                   [train isAtStartPosition] == NO &&
                   [train isAtEndPosition] == NO) {
            NSString* message = [NSString stringWithFormat: @"Train %@ exited at %@, not at %@\n",
                                 train.trainNumber, currentNamedPoint.name,
                                 [[train.expectedEndPoints objectAtIndex: 0] name] ];
            self.layoutView.score -= 5;
            [self.statusMessages addObject: message];
            [completedTrains addObject: train];
        }
    }

    if (someTrainIsBlocked) {
        AudioServicesPlaySystemSound(blockedSound);
    }

    for (Train *train in completedTrains) {
        if (train.becomesTrains && train.becomesTrains.count > 0) {
            // TODO(bowdidge): Look up each new train, place in simulation.
            for (Train* newTrain in self.activeTrains) {
                if ([newTrain.trainNumber isEqualToString: [train.becomesTrains objectAtIndex: 0]]) {
                    newTrain.currentState = Waiting;
                    newTrain.position = train.position;
                    [self.layoutModel addActiveTrain: newTrain];
                    train.currentState = Complete;
                    [self.layoutModel.activeTrains removeObject: train];
                    [self.statusMessages addObject: [NSString stringWithFormat: @"Train %@ becomes %@\n", train.trainNumber, newTrain.trainNumber]];
                    break;
                }
            }
        } else {
            train.currentState = Complete;
            [self.layoutModel.activeTrains removeObject: train];
        }
    }
    
    for (Train *train in self.activeTrains) {
        if (train.currentState == Inactive) {
            // Start the train if it's after the appearance time,
            // *and* if the route through the cell hasn't yet been claimed
            // *and* there's no train already there.
            if (([[train.departureTime dateByAddingTimeInterval: -5 * 60] compare: currentTime] == NSOrderedAscending) &&
                [self.layoutModel routeForCell: train.startPoint.position] == 0 &&
                [self.layoutModel occupyingTrainAtCell: train.startPoint.position] == nil) {

                train.currentState = Waiting;
                train.position = train.startPoint.position;
                [self.layoutModel addActiveTrain: train];
                // TODO(bowdidge): Text should be "approaching" for endpoints beyond railroad,
                // "waiting" for intermediate endpoints.
                NSString* message = [NSString stringWithFormat: @"Train %@ approaching %@.\n", train.trainNumber, train.startPoint.name];
                [self.statusMessages addObject: message];
                [self.alertView addAlertAtLocation: train.position.x max: self.scenario.tileColumns];
                AudioServicesPlaySystemSound(chimeStartingSound);

            }
        } else if (train.currentState == Waiting) {
            if ([train.departureTime compare: currentTime] == NSOrderedAscending) {
                train.currentState = Running;
                NamedPoint *currentPoint = [self.scenario endpointAtCell: train.position];
                NSString *message = [NSString stringWithFormat: @"Train %@ is ready to leave %@.\n", train.trainNumber, currentPoint.name];
                [self.statusMessages addObject: message];
            }
        }
    }
    
    currentTime = [currentTime dateByAddingTimeInterval: self.scenario.tickIntervalInSeconds];

    NSMutableString* trainDestinations = [NSMutableString string];
    NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
    [format setDateFormat:@"HH:mm:ss"];

    for (Train* train in self.activeTrains) {
        if (train.currentState == Running) {
            NSString *trainName = train.trainNumber;
            [trainDestinations appendFormat: @"%@: bound for:%@  due: %@\n", trainName, [train endPointsAsText], formattedDate(train.arrivalTime)];
        } else if (train.currentState == Waiting) {
            NSString *trainName = train.trainNumber;
           [trainDestinations appendFormat: @"%@: ready in %@.  bound for:%@  due: %@\n",
            trainName, formattedTimeInterval([train.departureTime timeIntervalSinceDate: currentTime]), [train endPointsAsText], formattedDate(train.arrivalTime)];
            
        }
    }
    
    NSUInteger ct = [self.statusMessages count];
    if (ct > 4) {
        [self.statusMessages removeObjectsAtIndexes: [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, ct-4-1)]];
    }
    NSMutableString *status = [NSMutableString string];
    for (NSString *littleStatus in self.statusMessages) {
        [status appendString: littleStatus];
    }
    self.statusField.text = status;
    self.trainField.text = trainDestinations;
    // TODO(bowdidge): Be more cautious about what's redrawn?
    [self.layoutView setNeedsDisplay];
    [self.alertView setNeedsDisplay];
}

// Handles a press on a signal.
// TODO(bowdidge): Clearing the route behavior is inappropriate and should be removed.
- (BOOL) signalTouched: (Signal*) signal {
    AudioServicesPlaySystemSound(clickSound);
    if (signal.isGreen) {
        signal.isGreen = NO;
        [self.layoutModel clearRoute];
    } else {
        signal.isGreen = YES;
        // TODO(bowdidge): Should animate, and reverse the selection if the route is invalid.
        if (![self.layoutModel selectRouteAtCell: signal.position direction: signal.trafficDirection]) {
            // Play sound to indicate faiure
            AudioServicesPlaySystemSound(blockedSound);
            signal.isGreen = NO;
        }
    }
    return YES;
}

// Handles press on a switch.
- (BOOL) switchTouchedAtCell: (struct CellPosition) pos {
    // Keyclick.
    AudioServicesPlaySystemSound(0x450);
    //AudioServicesPlaySystemSound(clickSound);
    BOOL switchPos = [self.layoutModel isSwitchNormal: pos];
    BOOL success = [self.layoutModel setSwitchPosition: pos isNormal: !switchPos];
    return success;
}

// Set which scenario we're playing.
// TODO(bowdidge): Find better scheme.
- (void) setGame: (Scenario*) s {
    NSLog(@"Game %@", s.scenarioName);
    self.scenario = s;
}

// TODO(bowdidge): Rewrite.  Note that this can be called multiple times.
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"loaded");

    self.statusMessages = [NSMutableArray array];
 
    // Going to timetable and back would cause viewToAppear to be called without LayoutView existing.
    if (!self.layoutView) {
        LayoutView *lv = [[[LayoutView alloc] init] autorelease];
        self.layoutView = lv;
        self.layoutView.containingScrollView = self.scrollView;
        self.layoutView.controller = self;
        [self.scrollView addSubview: lv];
    }
    
    // TODO(bowdidge): Do calculations here to size correctly.
    self.scrollView.contentSize = CGSizeMake(1440, 768);
    [self.layoutView setSizeInTilesX: self.scenario.tileColumns
                                   Y: self.scenario.tileRows];
    if (!self.layoutModel) {
        LayoutModel *myLayoutModel = [[LayoutModel alloc] initWithScenario: scenario];
        self.layoutModel = myLayoutModel;
        self.activeTrains = [NSMutableArray array];
        
        self.layoutView.layoutModel = self.layoutModel;
        self.layoutView.scenario = self.scenario;
        [self startTickTimer: self];
    }

    NSURL *startingChimeURL = [[NSBundle mainBundle] URLForResource:@"startingChime" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((CFURLRef) startingChimeURL, &chimeStartingSound);

    NSURL *clickSoundURL = [[NSBundle mainBundle] URLForResource:@"click" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((CFURLRef) clickSoundURL, &clickSound);

    NSURL *blockedSoundURL = [[NSBundle mainBundle] URLForResource:@"blocked" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((CFURLRef) blockedSoundURL, &blockedSound);

}

// Handles a request to show details about a particular location on the track grid.
- (void) showDetailMessage: (NSString*) msg atLayoutViewX: (float) x Y: (float) y {
    UIScrollView *layoutScrollView = self.scrollView;
    CGPoint upperLeft = layoutScrollView.contentOffset;
    DetailPopoverController *popover = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
    x -= upperLeft.x;
    y -= upperLeft.y;
    UINavigationController *modalNavigationController = [[UINavigationController alloc] initWithRootViewController:popover];
    UIPopoverController *popoverControllerTemp = [[UIPopoverController alloc] initWithContentViewController:modalNavigationController];
    self.popoverController = popoverControllerTemp;
    [self.popoverController presentPopoverFromRect:CGRectMake(x, y, 100, 100) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    popover.message = msg;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Raises the requested popover (either an Edit popover or something else), with the popover's arrow rooted
// within the specified portion of a cell.
// Returns the view controller for the popover.
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"timetable"]) {
      TimetableViewController *tvc = segue.destinationViewController;
      tvc.scenario = self.scenario;
    }
}

- (IBAction) quitGame {
    [self stopTickTimer: self];
    [self dismissViewControllerAnimated: true completion: nil];
}


@synthesize activeTrains;
@synthesize scenario;
@synthesize layoutView;
@end

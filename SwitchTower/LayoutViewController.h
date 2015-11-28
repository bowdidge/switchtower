//
//  ViewController.h
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

#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>

#import "AlertView.h"
#import "Cell.h"
#import "PopoverController.h"

@class LayoutModel;
@class Scenario;
@class LayoutView;
@class Signal;
@class Train;

@interface LayoutViewController : UIViewController {
    SystemSoundID chimeStartingSound;
    SystemSoundID clickSound;
    SystemSoundID blockedSound;
    
    int gameId_;
}

// Choose the game to play.  To be done when segue'ing to the view controller.
- (void) setGame: (Scenario*) s;

- (BOOL) signalTouched: (Signal*) signal;
- (BOOL) switchTouchedAtCell: (struct CellPosition) pos;
// Show a message in a popup at the given location in the LayoutView coordinate system.
- (void) showDetailMessage: (NSString*) msg atPoint: (CGPoint) pt;

- (IBAction) quitGame;

@property(nonatomic, retain) NSMutableArray *activeTrains;
@property(nonatomic, retain) Scenario *scenario;
@property(nonatomic, assign) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) IBOutlet LayoutView *layoutView;
@property(nonatomic, retain) IBOutlet AlertView *alertView;
@property(nonatomic, retain) LayoutModel *layoutModel;
@property(nonatomic, retain) NSTimer *myTimer_;
// TODO(bowdidge): Instead do as array with fixed number of elements.
@property(nonatomic, retain) NSMutableArray *statusMessages;

@property(nonatomic, retain) IBOutlet UITextView *trainField;
@property(nonatomic, retain) IBOutlet UITextView *statusField;
@property(nonatomic, retain) IBOutlet UILabel *timeLabel;
@property(nonatomic, retain) IBOutlet UILabel *scoreLabel;

@property(nonatomic, retain) IBOutlet UIPopoverController *popoverController;

@end

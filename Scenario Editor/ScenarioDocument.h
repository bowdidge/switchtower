//
//  Document.h
//  Scenario Editor
//
//  Created by bowdidge on 11/30/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DragDropToolbarView.h"
#import "EditableScenario.h"
#import "LayoutModel.h"
@class CocoaLayoutView;


@interface ScenarioDocument : NSDocument

// Actions related to Train detail panel.
// When train detail direction popup changes.
- (IBAction) directionPopupChanged: (id) sender;
// When starting point popup changes.
- (IBAction) startingPointChanged: (id) sender;
// When ending point pull down menu changes.
- (IBAction) endingPointChanged: (id) sender;

// Actions related to Cocoa LayoutView.
- (IBAction) addRowBelow: (id) sender;
- (IBAction) removeRow: (id) sender;
- (IBAction) addColumnToRight: (id) sender;
- (IBAction) removeColumn: (id) sender;

@property (nonatomic, retain) EditableScenario *scenario;
@property (nonatomic, retain) LayoutModel *layoutModel;

// Main window / layout view.
@property(nonatomic) IBOutlet NSScrollView *scrollView;
@property(nonatomic) IBOutlet CocoaLayoutView *layoutView;
@property (nonatomic) IBOutlet NSTableView *trainTable;
// Current sorted list of trains being displayed.
@property (nonatomic, retain) IBOutlet NSMutableArray *sortedTrains;


// Train being edited.
@property(nonatomic, retain) Train *trainDetail;

// Train editing panel
@property (nonatomic) IBOutlet NSWindow *trainPanel;
@property (nonatomic) IBOutlet NSTextField *trainNameField;
@property (nonatomic) IBOutlet NSTextField *trainNumberField;
@property (nonatomic) IBOutlet NSTextField *trainDescriptionField;
@property (nonatomic) IBOutlet NSPopUpButton *startingPointPopup;
@property (nonatomic) IBOutlet NSTextField *departureTimeField;
@property (nonatomic) IBOutlet NSTextField *arrivalTimeField;
@property (nonatomic) IBOutlet NSPopUpButton *directionPopup;
@property (nonatomic) IBOutlet NSPopUpButton *endPointPulldown;
@property (nonatomic) IBOutlet NSTextField *becomesField;
@property (nonatomic) IBOutlet NSTextField *timetableField;
@property (nonatomic) IBOutlet NSTextField *speedField;
@property (nonatomic) IBOutlet DragDropToolbarView *toolbarImageView;

@end


//
//  Document.m
//  Scenario Editor
//
//  Created by bowdidge on 11/30/15.
//  Copyright © 2015 bowdidge. All rights reserved.
//

#import "ScenarioDocument.h"

#import "CocoaLayoutView.h"
#import "LayoutModel.h"
#import "NamedPoint.h"
#import "Scenario.h"
#import "Train.h"

@interface ScenarioDocument ()

@end

@implementation ScenarioDocument

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSImage*) makeTile: (char) tile {
    TrackDrawer *drawer = [[TrackDrawer alloc] init];
    NSRect imgRect = NSMakeRect(0.0, 0.0, 40.0, 40.0);
    NSSize imgSize = imgRect.size;
    
    NSBitmapImageRep *offscreenRep = [[NSBitmapImageRep alloc]
                                       initWithBitmapDataPlanes:NULL
                                       pixelsWide:imgSize.width
                                       pixelsHigh:imgSize.height
                                       bitsPerSample:8
                                       samplesPerPixel:4
                                       hasAlpha:YES
                                       isPlanar:NO
                                       colorSpaceName:NSDeviceRGBColorSpace
                                       bitmapFormat:NSAlphaFirstBitmapFormat
                                       bytesPerRow:0
                                       bitsPerPixel:0];
    
    // set offscreen context
    NSGraphicsContext *g = [NSGraphicsContext graphicsContextWithBitmapImageRep:offscreenRep];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext: g];
    
    CGContextRef ctx = [g graphicsPort];
    
    NSColor *backgroundColor = [NSColor colorWithRed:32.0/256 green: 48.0/256 blue: 30.0/256 alpha: 1.0];
    [backgroundColor setFill];
    CGContextFillRect(ctx, imgRect);

    TrackContext *tc = [[TrackContext alloc] init];
    tc.normalTrackColor = drawer.activeTrackColor;
    tc.reversedTrackColor = drawer.inactiveTrackColor;
    // draw first stroke with Cocoa. this works!
    [drawer drawTile: tile withContext:ctx trackContext:tc isReversed: false];
    
    [NSGraphicsContext restoreGraphicsState];
    NSImage *img = [[NSImage alloc] initWithSize:imgSize];
    [img addRepresentation: offscreenRep];
    return img;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    [self.trainPanel close];
    // TODO(bowdidge): Make into helper function to reload.
    [self.startingPointPopup removeAllItems];
    for (NamedPoint *p in self.scenario.all_endpoints) {
        [self.startingPointPopup addItemWithTitle: p.name];
    }
    [self.endPointPulldown removeAllItems];
    for (NamedPoint *p in self.scenario.all_endpoints) {
        [self.endPointPulldown addItemWithTitle: p.name];
    }
    self.layoutView.scenario = self.scenario;
    self.layoutView.layoutModel = self.layoutModel;
    [self.layoutView setNeedsDisplay: YES];
    self.layoutView.controller = self;
    
    // TODO(bowdidge): Need to pull tile drawing code out of CocoaLayoutView so that bounds can be checked separately.
    NSImage *blueSwatch = [NSImage swatchWithColor: [NSColor blueColor] size: NSMakeSize(TILE_WIDTH, TILE_HEIGHT)];

    [self.toolbarImageView registerTile: blueSwatch value: @" " toolTip: @"blank"];
    [self.toolbarImageView registerTile: [self makeTile: '-'] value: @"-" toolTip: @"straight"];
    [self.toolbarImageView registerTile: [self makeTile: '='] value: @"'='" toolTip: @"straight"];
    [self.toolbarImageView registerTile: [self makeTile: '.'] value: @"." toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: 'P']  value: @"P" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: 'p'] value: @"p" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: 'Q'] value: @"Q" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: 'q'] value: @"q" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: 'R'] value: @"R" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: 'r'] value: @"r" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: 'V'] value: @"V" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: 'v'] value: @"v" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: 'Y'] value: @"Y" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: 'y'] value: @"y" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: 'Q'] value: @"Q" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: 'q'] value: @"q" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: 'Z'] value: @"Z" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: 'z'] value: @"z" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: 'W'] value: @"W" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: 'w'] value: @"w" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: '/'] value: @"/" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: '\\'] value: @"\\" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: 'T'] value: @"T" toolTip: @""];
    [self.toolbarImageView registerTile: [self makeTile: 't'] value: @"t" toolTip: @""];

}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (NSString *)windowNibName {
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"ScenarioDocument";
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return nil;
}

// Machinery to do the actual read.
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    NSPropertyListFormat format;
    NSError *error;
    NSPropertyListReadOptions opts = 0;
    NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:data options: opts format: &format error: &error];
    self.scenario = [[EditableScenario alloc] initWithDict: plist];
    // Only for animating the view.
    self.layoutModel = [[LayoutModel alloc] initWithScenario: self.scenario];
    self.sortedTrains = [NSMutableArray arrayWithArray: self.scenario.all_trains];
    return YES;
}

// Machinery to write the actual file.
- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError **)outError {
    NSError *error = nil;
    NSDictionary *scenarioDict = [self.scenario scenarioAsDict];
    if (![NSPropertyListSerialization propertyList: scenarioDict isValidForFormat: NSPropertyListXMLFormat_v1_0]) {
        NSLog(@"Property list can't be written as XML.");
        NSLog(@"%@", scenarioDict);
        return NO;
    }
    NSData *data =
    [NSPropertyListSerialization dataWithPropertyList: scenarioDict
                                               format: NSPropertyListXMLFormat_v1_0
                                              options: 0
                                                error: &error];
    if (data == nil) {
        NSLog (@"error serializing to xml: %@", error);
        return NO;
    }
    
    BOOL writeStatus = [data writeToFile: [NSString stringWithUTF8String: url.fileSystemRepresentation]
                                 options: NSDataWritingAtomic
                                   error: &error];
    if (!writeStatus) {
        NSLog (@"error writing to file: %@", error);
        return NO;
    }
    *outError = nil;
    return YES;
}

// Handle actions on the train detail text fields.
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    BOOL edited = false;
    if (control == self.trainNameField) {
        self.trainDetail.trainName = control.stringValue;
        NSLog(@"Train name changed to %@", self.trainDetail.trainName);
    } else if (control == self.trainNumberField) {
        self.trainDetail.trainNumber = control.stringValue;
        NSLog(@"Train number changed to %@", self.trainDetail.trainNumber);
    } else if (control == self.trainDescriptionField) {
        self.trainDetail.trainDescription = control.stringValue;
        NSLog(@"Train number changed to %@", self.trainDetail.trainDescription);
    } else if (control == self.becomesField) {
        if (control.stringValue.length == 0) {
            self.trainDetail.becomesTrains = [NSMutableArray array];
            NSLog(@"Clearing becomes");
        } else {
            self.trainDetail.becomesTrains = [NSMutableArray arrayWithObject: control.stringValue];
        }
        NSLog(@"becomes changed to %@", [self.trainDetail.becomesTrains objectAtIndex: 0]);
    } else if (control == self.speedField) {
        self.trainDetail.speedMPH = self.speedField.intValue;
        NSLog(@"Changed speed to %d", (unsigned) self.trainDetail.speedMPH);
    } else if (control == self.departureTimeField) {
        NSLog(@"Not handling departure time yet.");
    } else if (control == self.arrivalTimeField) {
        NSLog(@"Not handling arrival time yet.");
    } else {
        NSLog(@"No idea how to handle that text field.");
    }
    if (edited) {
        [self.trainTable reloadData];
    }
    return YES;
}

- (IBAction) directionPopupChanged: (id) sender {
    if ([self.directionPopup indexOfSelectedItem] == 0) {
        self.trainDetail.direction = WestDirection;
    } else {
        self.trainDetail.direction = EastDirection;
    }
    NSLog(@"Train direction now %d", self.trainDetail.direction);
}

- (IBAction) startingPointChanged: (id) sender {
    NSString *newEndPointName = [self.startingPointPopup titleOfSelectedItem];
    NamedPoint *pt = [self.scenario endpointWithName: newEndPointName];
    self.trainDetail.startPoint = pt;
    NSLog(@"Changed start point to %@", pt.name);
}

- (IBAction) endingPointChanged: (id) sender {
}

// Handle actions on right click menu on LayoutView.
- (IBAction) addRowBelow: (id) sender {
    NSLog(@"Add row to right at %d,%d.", self.layoutView.lastRightClick.x, self.layoutView.lastRightClick.y);
    struct CellPosition pos = [self.layoutView lastRightClick];
    [self.scenario addRowBelow: pos.y];
    [self.layoutView setNeedsDisplay: YES];
    
}

// Handle actions on right click menu on LayoutView.
- (IBAction) removeRow: (id) sender {
    NSLog(@"Remove row at %d,%d.", self.layoutView.lastRightClick.x, self.layoutView.lastRightClick.y);
    struct CellPosition pos = [self.layoutView lastRightClick];
    [self.scenario removeRow: pos.y];
    [self.layoutView setNeedsDisplay: YES];
    
}

// Handle actions on right click menu on LayoutView.
- (IBAction) addColumnToRight: (id) sender {
    NSLog(@"Add row to right at %d,%d.", self.layoutView.lastRightClick.x, self.layoutView.lastRightClick.y);
    struct CellPosition pos = [self.layoutView lastRightClick];
    [self.scenario addColumnAfter: pos.x];
    [self.layoutView setNeedsDisplay: YES];
    
}

// Handle actions on right click menu on LayoutView.
- (IBAction) removeColumn: (id) sender {
    NSLog(@"Remove column at %d,%d.", self.layoutView.lastRightClick.x, self.layoutView.lastRightClick.y);
    struct CellPosition pos = [self.layoutView lastRightClick];
    [self.scenario removeColumn: pos.x];
    [self.layoutView setNeedsDisplay: YES];
    
}

// Train table data source and delegates.
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.sortedTrains count];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSTableView *tv = [aNotification object];
    NSInteger row = [tv selectedRow];
    Train *tr = [self.sortedTrains objectAtIndex: row];
    self.trainDetail = tr;
    // TODO(bowdidge): Avoid changing selection if in the process of editing.
    self.trainNameField.stringValue = tr.trainName;
    self.trainNumberField.stringValue = tr.trainNumber;
    [self.trainPanel makeKeyAndOrderFront:self];
    if (tr.direction == WestDirection) {
        [self.directionPopup selectItemWithTag: 0];
    } else {
        [self.directionPopup selectItemWithTag: 1];
    }
    self.trainDescriptionField.stringValue = tr.trainDescription;
    self.departureTimeField.stringValue = formattedDate(tr.departureTime);
    [self.startingPointPopup selectItemWithTitle: tr.startPoint.name];
    [self.endPointPulldown addItemWithTitle: tr.endPointsAsText];
    self.arrivalTimeField.stringValue = formattedDate(tr.arrivalTime);
    if (tr.becomesTrains.count > 0) {
        self.becomesField.stringValue = [tr.becomesTrains objectAtIndex: 0];
    } else {
        self.becomesField.stringValue = @"";
    }
    [self.speedField setStringValue: [NSString stringWithFormat: @"%d", (unsigned) tr.speedMPH]];
    
    NSMutableString *timetable = [NSMutableString string];
    for (NSString *key in tr.timetableEntry.allKeys) {
        NSString *val = [tr.timetableEntry objectForKey: key];
        [timetable appendFormat: @"%@: %@\n", key, val];
    }
    [self.timetableField setStringValue: timetable];
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    [self.sortedTrains sortUsingDescriptors: [tableView sortDescriptors]];
    [tableView reloadData];
}

/* This method is required for the "Cell Based" TableView, and is optional for the "View Based" TableView. If implemented in the latter case, the value will be set to the view at a given row/column if the view responds to -setObjectValue: (such as NSControl and NSTableCellView).
 */
- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([[tableColumn identifier] isEqualToString: @"Number"]) {
        Train *t = [self.sortedTrains objectAtIndex: row];
        return [t trainNumber];
    } else if ([[tableColumn identifier] isEqualToString: @"Name"]) {
        Train *t = [self.sortedTrains objectAtIndex: row];
        return [t trainName];
    } else if ([[tableColumn identifier] isEqualToString: @"Departs"]) {
        Train *t = [self.sortedTrains objectAtIndex: row];
        return t.startPoint.name;
    } else if ([[tableColumn identifier] isEqualToString: @"Departure Time"]) {
        Train *t = [self.sortedTrains objectAtIndex: row];
        return formattedDate(t.departureTime);
    } else if ([[tableColumn identifier] isEqualToString: @"Arrives"]) {
        Train *t = [self.sortedTrains objectAtIndex: row];
        return t.endPointsAsText;
    } else if ([[tableColumn identifier] isEqualToString: @"Arrival Time"]) {
        Train *t = [self.sortedTrains objectAtIndex: row];
        return formattedDate(t.arrivalTime);
    } else {
        return @"Foo";
    }
    return @"Foo";
}

@end
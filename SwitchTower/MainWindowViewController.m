//
//  ViewController.m
//  SwitchTower
//
//  Created by Robert Bowdidge on 9/22/13.
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

#import "MainWindowViewController.h"

#import "LayoutViewController.h"
#import "ScenarioTableCell.h"

#import "ShellmoundScenario.h"
#import "SantaCruzScenario.h"
#import "FourthStreetScenario.h"
#import "PenzanceScenario.h"

@interface MainWindowViewController ()

@end

@implementation MainWindowViewController

// Look for all files that may be scenarios installed in the application.
NSArray* FindScenarioFiles(NSString* bundleRoot) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:bundleRoot error:nil];
    NSPredicate *switchlistFilter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.plist'"];
    return [dirContents filteredArrayUsingPredicate:switchlistFilter];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    // Find what scenarios are installed.
    self.availableScenarios = [NSMutableArray array];
    NSString *bundleRoot = [[NSBundle mainBundle] resourcePath];
    for (NSString *scenarioFile in FindScenarioFiles(bundleRoot)) {
        NSString *fullFilePath = [bundleRoot stringByAppendingPathComponent: scenarioFile];
        NSMutableDictionary *scenarioDict = [NSMutableDictionary dictionaryWithContentsOfFile: fullFilePath];
        NSString *scenarioName = [scenarioDict objectForKey: @"Name"];
        NSString *scenarioDescription = [scenarioDict objectForKey: @"Description"];
        // Was it a scenario?
        if (scenarioName == nil || scenarioDescription == nil) continue;
        [self.availableScenarios addObject: [NSDictionary dictionaryWithObjectsAndKeys: scenarioName, @"Name", scenarioDescription, @"Description", fullFilePath, @"Filename", nil]];
    }
}

- (id) initWithCoder:(NSCoder *)aDecoder  {
    return [super initWithCoder: aDecoder];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get reference to the destination view controller
    LayoutViewController *vc = [segue destinationViewController];

    NSIndexPath *selectedScenarioRow = self.scenarioTable.indexPathForSelectedRow;
    // Sanity: bail if any section other than 0.
    if ([selectedScenarioRow indexAtPosition: 0] != 0) return;
    NSDictionary *scenario = [self.availableScenarios objectAtIndex: [selectedScenarioRow indexAtPosition: 1]];
    NSDictionary *scenarioDict = [NSDictionary dictionaryWithContentsOfFile: [scenario objectForKey: @"Filename"]];
    Scenario *s = [[Scenario alloc] initWithDict: scenarioDict];
    [vc setGame: s];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// How many rows in the scenario selection table?
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.availableScenarios count];
    }
    return 0;
}

// Create the scenario selection table cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"scenarioTableCell";
    ScenarioTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ScenarioTableCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellIdentifier];
        [cell autorelease];
    }

    // Only one section.
    if ([indexPath indexAtPosition: 0] != 0) return nil;
    
    NSDictionary *s = [self.availableScenarios objectAtIndex: [indexPath indexAtPosition: 1]];
    cell.scenarioNameLabel.text = [s objectForKey: @"Name"];
    cell.scenarioDescriptionLabel.text = [s objectForKey: @"Description"];;
    return cell;
}

// Scenario selected.  -[MainWindowViewController prepareForSegue:sender: will do the rest of the work.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier: @"runGame" sender: self];
}

@end

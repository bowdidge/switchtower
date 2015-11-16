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

#import "DiridonScenario.h"
#import "ShellmoundScenario.h"
#import "SantaCruzScenario.h"
#import "FourthStreetScenario.h"
#import "PenzanceScenario.h"

#
@interface MainWindowViewController ()

@end

@implementation MainWindowViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.scenarios = [NSMutableArray array];
    [self.scenarios addObject: [[[DiridonScenario alloc] init] autorelease]];
    [self.scenarios addObject: [[[ShellmoundScenario alloc] init] autorelease]];
    [self.scenarios addObject: [[[FourthStreetScenario alloc] init] autorelease]];
    [self.scenarios addObject: [[[SantaCruzScenario alloc] init] autorelease]];
    [self.scenarios addObject: [[[PenzanceScenario alloc] init] autorelease]];
}

- (id) initWithCoder:(NSCoder *)aDecoder  {
    return [super initWithCoder: aDecoder];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get reference to the destination view controller
    LayoutViewController *vc = [segue destinationViewController];

    NSIndexPath *selectedScenarioRow = self.scenarioTable.indexPathForSelectedRow;
    if ([selectedScenarioRow indexAtPosition: 0] != 0) return;
    
    Scenario *s = [self.scenarios objectAtIndex: [selectedScenarioRow indexAtPosition: 1]];
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
        return [self.scenarios count];
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
    
    Scenario *s = [self.scenarios objectAtIndex: [indexPath indexAtPosition: 1]];
    cell.scenarioNameLabel.text = s.scenarioName;
    cell.scenarioDescriptionLabel.text = s.scenarioDescription;
    return cell;
}

// Scenario selected.  -[MainWindowViewController prepareForSegue:sender: will do the rest of the work.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier: @"runGame" sender: self];
}

@end

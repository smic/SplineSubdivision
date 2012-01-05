//
//  SplineDivisionAppDelegate.m
//  SplineSubdivision
//
//  Created by Stephan Michels on 03.09.10.
//  Copyright 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "SplineDivisionAppDelegate.h"
#import "SplineDivisionView.h"


@implementation SplineDivisionAppDelegate

@synthesize splineDivisionView = _splineDivisionView;

#pragma mark - Initialization / Deallocation

- (void)dealloc {
    self.splineDivisionView = nil;
    
    [super dealloc];
}

#pragma mark - Application delegate

-(void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSMutableArray *newPoints = [NSMutableArray array];
    [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(50, 200)]];
    [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(90, 300)]];
    [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(160, 300)]];
    [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(200, 200)]];
    [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(240, 100)]];
    [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(310, 100)]];
    [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(350, 200)]];
    self.splineDivisionView.points = newPoints;
    
    self.splineDivisionView.curveStart = 50.0f;
    self.splineDivisionView.curveEnd = 150.0f;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

#pragma mark - Actions

- (IBAction)changeCurveStart:(id)sender {
	self.splineDivisionView.curveStart = [sender floatValue];
}

- (IBAction)changeCurveEnd:(id)sender {
	self.splineDivisionView.curveEnd = [sender floatValue];
}

- (IBAction)selectExample:(id)sender {
    switch ([sender indexOfSelectedItem]) {
        case 0: {
            NSMutableArray *newPoints = [NSMutableArray array];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(50, 200)]];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(90, 300)]];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(160, 300)]];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(200, 200)]];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(240, 100)]];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(310, 100)]];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(350, 200)]];
            self.splineDivisionView.points = newPoints;
        } break;
            
        case 1: {
            NSMutableArray *newPoints = [NSMutableArray array];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(100, 100)]];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(400, 100)]];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(100, 400)]];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(400, 400)]];
            self.splineDivisionView.points = newPoints;
        } break;
            
        case 2: {
            NSMutableArray *newPoints = [NSMutableArray array];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(100, 100)]];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(500, 300)]];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(300, 300)]];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(300, 100)]];
            self.splineDivisionView.points = newPoints;
        } break;

        case 3: {
            NSMutableArray *newPoints = [NSMutableArray array];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(100, 100)]];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(350, 300)]];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(50, 300)]];
            [newPoints addObject:[NSValue valueWithPoint:NSMakePoint(300, 100)]];
            self.splineDivisionView.points = newPoints;
        } break;
            
        default:
            break;
    }
}

@end

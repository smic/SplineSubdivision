//
//  SMAppDelegate.m
//  SplineSubdivision
//
//  Created by Stephan Michels on 03.09.10.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "SMAppDelegate.h"
#import "SMSplineDivisionView.h"
#import "NSBezierPath+SMSubdivision.h"


@interface SMAppDelegate () <SMSplineDivisionViewDelegate>

@property (nonatomic, weak) IBOutlet SMSplineDivisionView *splineDivisionView;
@property (nonatomic, weak) IBOutlet NSSlider *startSlider;
@property (nonatomic, weak) IBOutlet NSSlider *endSlider;
@property (nonatomic, weak) IBOutlet NSSlider *probeSlider;

@end


@implementation SMAppDelegate

@synthesize splineDivisionView = _splineDivisionView;
@synthesize startSlider = _startSlider;
@synthesize endSlider = _endSlider;
@synthesize probeSlider = _probeSlider;

#pragma mark - Application delegate

-(void)applicationDidFinishLaunching:(NSNotification *)notification {
    self.splineDivisionView.path = [self pathForExample:0];
    
    self.splineDivisionView.pathStart = 50.0f;
    self.splineDivisionView.pathEnd = 150.0f;
    
    CGFloat length = [self.splineDivisionView.path length];
    self.startSlider.maxValue = length;
    self.endSlider.maxValue = length;
    self.probeSlider.maxValue = length;
    
    self.splineDivisionView.delegate = self;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

#pragma mark - Actions

- (IBAction)changeCurveStart:(id)sender {
	self.splineDivisionView.pathStart = [sender floatValue];
}

- (IBAction)changeCurveEnd:(id)sender {
	self.splineDivisionView.pathEnd = [sender floatValue];
}

- (IBAction)changeCurveProbe:(id)sender {
	self.splineDivisionView.probe = [sender floatValue];
}

- (IBAction)selectExample:(id)sender {
    self.splineDivisionView.path = [self pathForExample:[sender indexOfSelectedItem]];
}

- (NSBezierPath *)pathForExample:(NSUInteger)exampleIndex {
    switch (exampleIndex) {
        case 0: {
            NSBezierPath *path = [NSBezierPath bezierPath];
            [path moveToPoint:NSMakePoint(50, 200)];
            [path curveToPoint:NSMakePoint(200, 200) controlPoint1:NSMakePoint(90, 300) controlPoint2:NSMakePoint(160, 300)];
            [path curveToPoint:NSMakePoint(350, 200) controlPoint1:NSMakePoint(240, 100) controlPoint2:NSMakePoint(310, 100)];
            return path;
        } break;
            
        case 1: {
            NSBezierPath *path = [NSBezierPath bezierPath];
            [path moveToPoint:NSMakePoint(100, 100)];
            [path curveToPoint:NSMakePoint(400, 400) controlPoint1:NSMakePoint(400, 100) controlPoint2:NSMakePoint(100, 400)];
            return path;
        } break;
            
        case 2: {
            NSBezierPath *path = [NSBezierPath bezierPath];
            [path moveToPoint:NSMakePoint(100, 100)];
            [path curveToPoint:NSMakePoint(300, 100) controlPoint1:NSMakePoint(500, 300) controlPoint2:NSMakePoint(300, 300)];
            return path;
        } break;
            
        case 3: {
            NSBezierPath *path = [NSBezierPath bezierPath];
            [path moveToPoint:NSMakePoint(100, 100)];
            [path curveToPoint:NSMakePoint(300, 100) controlPoint1:NSMakePoint(350, 300) controlPoint2:NSMakePoint(50, 300)];
            return path;
        } break;
            
        case 4: {
            NSBezierPath *path = [NSBezierPath bezierPath];
            [path moveToPoint:NSMakePoint(100, 100)];
            [path curveToPoint:NSMakePoint(100, 300) controlPoint1:NSMakePoint(150, 150) controlPoint2:NSMakePoint(150, 250)];
            [path lineToPoint:NSMakePoint(400, 300)];
            [path curveToPoint:NSMakePoint(400, 100) controlPoint1:NSMakePoint(350, 250) controlPoint2:NSMakePoint(350, 150)];
            return path;
        } break;

        case 5: {
            NSBezierPath *path = [NSBezierPath bezierPath];
            [path moveToPoint:NSMakePoint(200, 100)];
            [path curveToPoint:NSMakePoint(200, 300) controlPoint1:NSMakePoint(150, 150) controlPoint2:NSMakePoint(150, 250)];
            [path moveToPoint:NSMakePoint(300, 300)];
            [path curveToPoint:NSMakePoint(300, 100) controlPoint1:NSMakePoint(350, 250) controlPoint2:NSMakePoint(350, 150)];
            return path;
        } break;
            
        case 6: {
            NSBezierPath *path = [NSBezierPath bezierPath];
            [path appendBezierPathWithOvalInRect:NSMakeRect(100, 100, 300, 300)];
            [path appendBezierPathWithOvalInRect:NSMakeRect(250, 100, 300, 300)];
            return path;
        } break;
            
        default:
            break;
    }
    return nil;
}

- (IBAction)replaceWithSubpath:(id)sender {
    self.splineDivisionView.path = [self.splineDivisionView.path subpathFromLength:self.splineDivisionView.pathStart toLength:self.splineDivisionView.pathEnd];
}

#pragma mark - Spline division view delegate

- (void)splineDivisionViewDidChangePath:(SMSplineDivisionView *)view {
    CGFloat length = [self.splineDivisionView.path length];
    self.startSlider.maxValue = length;
    self.endSlider.maxValue = length;
    self.probeSlider.maxValue = length;
}

@end

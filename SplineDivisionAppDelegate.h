//
//  SplineDivisionAppDelegate.h
//  SplineSubdivision
//
//  Created by Stephan Michels on 03.09.10.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class SplineDivisionView;

@interface SplineDivisionAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, retain) IBOutlet SplineDivisionView *splineDivisionView;

- (IBAction)changeCurveStart:(id)sender;
- (IBAction)changeCurveEnd:(id)sender;
- (IBAction)changeCurveProbe:(id)sender;
- (IBAction)selectExample:(id)sender;

@end

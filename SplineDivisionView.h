//
//  SplineDivisionView.h
//  SplineSubdivision
//
//  Created by Stephan Michels on 03.09.10.
//  Copyright 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SplineDivisionView : NSView

@property (nonatomic, retain) NSArray *points;
@property (nonatomic, assign) CGFloat curveStart;
@property (nonatomic, assign) CGFloat curveEnd;

@end

//
//  SplineDivisionView.h
//  SplineSubdivision
//
//  Created by Stephan Michels on 03.09.10.
//  Copyright (c) 2012 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SplineDivisionView : NSView

@property (nonatomic, retain) NSBezierPath *path;
@property (nonatomic, assign) CGFloat pathStart;
@property (nonatomic, assign) CGFloat pathEnd;
@property (nonatomic, assign) CGFloat probe;

@end

//
//  SplineDivisionView.h
//  SplineSubdivision
//
//  Created by Stephan Michels on 03.09.10.
//  Copyright 2010 Beilstein Institut. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SplineDivisionView : NSView {
	NSArray *points;
	CGFloat curveStart;
	CGFloat curveEnd;
}

@property (nonatomic, retain) NSArray *points;
@property (nonatomic, assign) CGFloat curveStart;
@property (nonatomic, assign) CGFloat curveEnd;

- (IBAction)changeCurveStart:(id)sender;
- (IBAction)changeCurveEnd:(id)sender;


@end

NSPoint midPoint(NSPoint p1, NSPoint p2);
//void drawSpline(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, NSInteger deep);

void addCurvesDivision(NSBezierPath *path, NSPoint p[], NSInteger count, CGFloat start, CGFloat end);
BOOL addCurveDivision(NSBezierPath *path, NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, CGFloat start, CGFloat end, BOOL started);
CGFloat calcCurveLength(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4);

//void strokeSpline(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4);
void drawHandle(NSPoint p);

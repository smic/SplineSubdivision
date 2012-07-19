//
//  SMGeometry.h
//  SplineSubdivision
//
//  Created by Stephan Michels on 19.07.12.
//
//

#import <Foundation/Foundation.h>


NSPoint MidPoint(NSPoint p1, NSPoint p2);
CGPoint SMLineGetPointAtParameter(NSPoint p1, NSPoint p2, double u);
CGFloat SMSplineGetTotalLength(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4);
BOOL SMSplineIsLinear(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4);
CGFloat SMLineGetLength(CGPoint p1, CGPoint p2);
CGPoint SMLineGetPointAtParameter(CGPoint p1, CGPoint p2, double u);
double SMSplineParameterForLength(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, CGFloat length);
CGPoint SMSplineGetPointAtParameter(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, double u);
void SMSplineGetSubdivisionAtParameter(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, double u, BOOL first, NSPoint *sdp1, NSPoint *sdp2, NSPoint *sdp3, NSPoint *sdp4);
CGFloat SMSplineTerm1(CGFloat u);
CGFloat SMSplineTerm2(CGFloat u);
CGFloat SMSplineTerm3(CGFloat u);
CGFloat SMSplineTerm4(CGFloat u);

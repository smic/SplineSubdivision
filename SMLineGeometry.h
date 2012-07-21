//
//  SMLineGeometry.h
//  SplineSubdivision
//
//  Created by Stephan Michels on 21.07.12.
//
//

#import <Foundation/Foundation.h>


NSPoint SMLineGetMidPoint(NSPoint p1, NSPoint p2);
CGPoint SMLineGetPointAtParameter(NSPoint p1, NSPoint p2, double u);
CGFloat SMLineGetLength(CGPoint p1, CGPoint p2);
CGPoint SMLineGetPointAtParameter(CGPoint p1, CGPoint p2, double u);

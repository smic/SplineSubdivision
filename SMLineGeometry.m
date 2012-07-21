//
//  SMLineGeometry.m
//  SplineSubdivision
//
//  Created by Stephan Michels on 21.07.12.
//
//

#import "SMLineGeometry.h"


CGFloat SMLineGetLength(CGPoint p1, CGPoint p2) {
    CGFloat dx = p2.x - p1.x;
	CGFloat dy = p2.y - p1.y;
	
    if (dx == 0.0f) {
        return dy;
    } else if (dy == 0.0f) {
        return dx;
    }
    
    return hypotf(dx, dy);
}

NSPoint SMLineGetMidPoint(NSPoint p1, NSPoint p2) {
	return NSMakePoint((p1.x + p2.x) * 0.5f,
                       (p1.y + p2.y) * 0.5f);
}

CGPoint SMLineGetPointAtParameter(CGPoint p1, CGPoint p2, double u) {
    if (u <= 0.0) {
        return p1;
    }
    if (u >= 1.0) {
        return p2;
    }
    if (u == 0.5) {
        return NSMakePoint((p1.x + p2.x) * 0.5f,
                           (p1.y + p2.y) * 0.5f);
    }
    return CGPointMake(p1.x + (p2.x - p1.x) * u,
                       p1.y + (p2.y - p1.y) * u);
}

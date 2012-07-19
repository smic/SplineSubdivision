//
//  SMGeometry.m
//  SplineSubdivision
//
//  Created by Stephan Michels on 19.07.12.
//
//

#import "SMGeometry.h"


NSPoint MidPoint(NSPoint p1, NSPoint p2) {
	return NSMakePoint((p1.x + p2.x) * 0.5f,
                       (p1.y + p2.y) * 0.5f);
}

// see http://www.antigrain.com/research/adaptive_bezier/index.html

CGFloat const m_distance_tolerance = 0.5f;

CGFloat SMSplineGetTotalLength(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4) {
	// Try to approximate the full cubic curve by a single straight line
	if (SMSplineIsLinear(p1, p2, p3, p4)) {
		return SMLineGetLength(p1, p4);
    }
    
    // Calculate all the mid-points of the line segments
    NSPoint p12   = MidPoint(p1, p2);
    NSPoint p23   = MidPoint(p2, p3);
    NSPoint p34   = MidPoint(p3, p4);
    NSPoint p123  = MidPoint(p12, p23);
    NSPoint p234  = MidPoint(p23, p34);
    NSPoint p1234 = MidPoint(p123, p234);
    
    // Continue subdivision
    return SMSplineGetTotalLength(p1, p12, p123, p1234) +
           SMSplineGetTotalLength(p1234, p234, p34, p4);
}

BOOL SMSplineIsLinear(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4) {
    
	CGFloat dx = p4.x - p1.x;
	CGFloat dy = p4.y - p1.y;
	
	CGFloat d2 = fabs(((p2.x - p4.x) * dy - (p2.y - p4.y) * dx));
	CGFloat d3 = fabs(((p3.x - p4.x) * dy - (p3.y - p4.y) * dx));
	
	return (d2 + d3) * (d2 + d3) <= m_distance_tolerance * (dx * dx + dy * dy);
}

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

CGPoint SMLineGetPointAtParameter(CGPoint p1, CGPoint p2, double u) {
    if (u <= 0.0) {
        return p1;
    }
    if (u >= 1.0) {
        return p2;
    }
    return CGPointMake(p1.x + (p2.x - p1.x) * u,
                       p1.y + (p2.y - p1.y) * u);
}

double SMSplineParameterForLength(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, CGFloat length) {
    if (length <= 0) {
        return 0.0;
    }
    
    if (SMSplineIsLinear(p1, p2, p3, p4)) {
        double totalLength = SMLineGetLength(p1, p4);
        if (totalLength == 0.0f) {
            return 0.0;
        }
        return MAX(0.0, MIN(1.0, length / totalLength));
    }
    
    CGFloat totalLength = SMSplineGetTotalLength(p1, p2, p3, p4);
    if (totalLength == 0.0f) {
        return 0.0;
    }
    if (length >= totalLength) {
        return 1.0;
    }
    
    NSPoint p12   = MidPoint(p1, p2);
    NSPoint p23   = MidPoint(p2, p3);
    NSPoint p34   = MidPoint(p3, p4);
    NSPoint p123  = MidPoint(p12, p23);
    NSPoint p234  = MidPoint(p23, p34);
    NSPoint p1234 = MidPoint(p123, p234);
    
    CGFloat halfLength = SMSplineGetTotalLength(p1, p12, p123, p1234);
    if (halfLength == length) {
        return 0.5;
    } else if (length < halfLength) {
        return SMSplineParameterForLength(p1, p12, p123, p1234, length) * 0.5;
    } else {
        return SMSplineParameterForLength(p1234, p234, p34, p4, length - halfLength) * 0.5 + 0.5;
    }
}

CGPoint SMSplineGetPointAtParameter(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, double u) {
    if (u <= 0.0) {
        return p1;
    }
    if (u >= 1.0) {
        return p4;
    }
    CGFloat b0 = SMSplineTerm1(u);
    CGFloat b1 = SMSplineTerm2(u);
    CGFloat b2 = SMSplineTerm3(u);
    CGFloat b3 = SMSplineTerm4(u);
    
    CGPoint point;
    point.x = p1.x * b0 + p2.x * b1 + p3.x * b2 + p4.x * b3;
    point.y = p1.y * b0 + p2.y * b1 + p3.y * b2 + p4.y * b3;
    return point;
}

void SMSplineGetSubdivisionAtParameter(NSPoint p1, NSPoint p2, NSPoint p3, NSPoint p4, double u, BOOL first, NSPoint *sdp1, NSPoint *sdp2, NSPoint *sdp3, NSPoint *sdp4) {
    if (u <= 0.0) {
        if (first) {
            *sdp1 = p1;
            *sdp2 = p1;
            *sdp3 = p1;
            *sdp4 = p1;
        } else {
            *sdp1 = p1;
            *sdp2 = p2;
            *sdp3 = p3;
            *sdp4 = p4;
        }
        return;
    }
    if (u >= 1.0) {
        if (first) {
            *sdp1 = p1;
            *sdp2 = p2;
            *sdp3 = p3;
            *sdp4 = p4;
        } else {
            *sdp1 = p4;
            *sdp2 = p4;
            *sdp3 = p4;
            *sdp4 = p4;
        }
    }
    
    // calculate parameterized point on the lines
    NSPoint p12   = SMLineGetPointAtParameter(p1, p2, u);
    NSPoint p23   = SMLineGetPointAtParameter(p2, p3, u);
    NSPoint p34   = SMLineGetPointAtParameter(p3, p4, u);
    NSPoint p123  = SMLineGetPointAtParameter(p12, p23, u);
    NSPoint p234  = SMLineGetPointAtParameter(p23, p34, u);
    NSPoint p1234 = SMLineGetPointAtParameter(p123, p234, u);
    
    if (first) {
        *sdp1 = p1;
        *sdp2 = p12;
        *sdp3 = p123;
        *sdp4 = p1234;
    } else {
        *sdp1 = p1234;
        *sdp2 = p234;
        *sdp3 = p34;
        *sdp4 = p4;
    }
}

// Bezier multipliers
CGFloat SMSplineTerm1(CGFloat u) {
    CGFloat tmp = 1.0f - u;
    return (tmp * tmp * tmp);
}

CGFloat SMSplineTerm2(CGFloat u) {
    CGFloat tmp = 1.0f - u;
    return (3.0f * u * (tmp * tmp));
}

CGFloat SMSplineTerm3(CGFloat u) {
    CGFloat tmp = 1.0f - u;
    return (3.0f * u * u * tmp);
}

CGFloat SMSplineTerm4(CGFloat u) {
    return (u * u * u);
}
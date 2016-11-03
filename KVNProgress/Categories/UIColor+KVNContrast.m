//
//  UIColor+KVNContrast.m
//  KVNProgress
//
//  Created by Kevin Hirsch on 13/03/15.
//  Copyright (c) 2015 Pinch. All rights reserved.
//

#import "UIColor+KVNContrast.h"

@implementation UIColor (KVNContrast)

- (UIStatusBarStyle)statusBarStyleConstrastStyle
{
    CGColorRef cgColor = self.CGColor;
    size_t count = CGColorGetNumberOfComponents(cgColor);
    const CGFloat *componentColors = CGColorGetComponents(cgColor);
    
    CGFloat darknessScore = 0;
    if (count == 2) {
        darknessScore = (((componentColors[0]*255) * 299) + ((componentColors[0]*255) * 587) + ((componentColors[0]*255) * 114)) / 1000;
    } else if (count == 4) {
        darknessScore = (((componentColors[0]*255) * 299) + ((componentColors[1]*255) * 587) + ((componentColors[2]*255) * 114)) / 1000;
    }
    
    if (darknessScore >= 125) {
        return UIStatusBarStyleDefault;
    }
    
    return UIStatusBarStyleLightContent;
}

@end

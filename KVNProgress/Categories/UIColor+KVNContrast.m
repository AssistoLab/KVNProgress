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
	const CGFloat *componentColors = CGColorGetComponents(self.CGColor);
	CGFloat darknessScore = (((componentColors[0] * 255) * 299) + ((componentColors[1] * 255) * 587) + ((componentColors[2] * 255) * 114)) / 1000;
	
	if (darknessScore >= 125) {
		return UIStatusBarStyleDefault;
	}
	
	return UIStatusBarStyleLightContent;
}

@end

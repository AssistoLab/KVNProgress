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
	CGFloat red, green, blue;
    [self getRed:&red green:&green blue:&blue alpha:nil];
    CGFloat darknessScore = (((red * 255) * 299) + ((green * 255) * 587) + ((blue * 255) * 114)) / 1000;
	
	if (darknessScore >= 125) {
		return UIStatusBarStyleDefault;
	}
	
	return UIStatusBarStyleLightContent;
}

@end

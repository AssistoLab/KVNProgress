//
//  KVNProgressConfiguration.m
//  KVNProgress
//
//  Created by Kevin Hirsch on 20/12/14.
//  Copyright (c) 2014 Pinch. All rights reserved.
//

#import "KVNProgressConfiguration.h"

@implementation KVNProgressConfiguration

#pragma mark - NSObject

- (id)init
{
	if (self = [super init]) {
		_backgroundFillColor = [UIColor colorWithWhite:1.0f alpha:0.85f];
		_backgroundTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6f];
		_backgroundType = KVNProgressBackgroundTypeBlurred;
		_fullScreen = NO;
		_showStop = NO;
		
		_circleStrokeForegroundColor = [UIColor darkGrayColor];
		_circleStrokeBackgroundColor = [_circleStrokeForegroundColor colorWithAlphaComponent:0.3f];
		_circleFillBackgroundColor = [UIColor clearColor];
		_circleSize = (_fullScreen) ? 90.0f : 75.0f;
		_stopRelativeHeight = 0.3;
		_lineWidth = 2.0f;
		
		_statusColor = [UIColor darkGrayColor];
		_statusFont = [UIFont systemFontOfSize:17.0f];
		
		_successColor = [_statusColor copy];
		_errorColor = [_statusColor copy];
        _stopColor = [_statusColor copy];
		
		_minimumDisplayTime = 0.3f;
		_minimumSuccessDisplayTime = 2.0f;
		_minimumErrorDisplayTime = 1.3f;
		
		_tapBlock = nil;
		_allowUserInteraction = NO;
	}
	
	return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	KVNProgressConfiguration *copy = [[KVNProgressConfiguration allocWithZone:zone] init];
	
	copy.backgroundFillColor = [self.backgroundFillColor copy];
	copy.backgroundTintColor = [self.backgroundTintColor copy];
	copy.backgroundType = self.backgroundType;
	copy.fullScreen = [self isFullScreen];
	copy.showStop = [self doesShowStop];
	
	copy.circleStrokeForegroundColor = [self.circleStrokeForegroundColor copy];
	copy.circleStrokeBackgroundColor = [self.circleStrokeBackgroundColor copy];
	copy.circleFillBackgroundColor = [self.circleFillBackgroundColor copy];
	copy.circleSize = self.circleSize;
	copy.stopRelativeHeight = self.stopRelativeHeight;
	copy.lineWidth = self.lineWidth;
	
	copy.statusColor = [self.statusColor copy];
	copy.statusFont = [self.statusFont copy];
	
	copy.successColor = [self.successColor copy];
	copy.errorColor = [self.errorColor copy];
    copy.stopColor = [self.stopColor copy];
	
	copy.minimumDisplayTime = self.minimumDisplayTime;
	copy.minimumSuccessDisplayTime = self.minimumSuccessDisplayTime;
	copy.minimumErrorDisplayTime = self.minimumErrorDisplayTime;
	
	copy.tapBlock = self.tapBlock;
	copy.allowUserInteraction = self.allowUserInteraction;
	
	return copy;
}

#pragma mark - Setters

- (void)setStopRelativeHeight:(CGFloat)stopRelativeHeight
{
	if (stopRelativeHeight > 1) {
		_stopRelativeHeight = 1;
	} else if (stopRelativeHeight < 0) {
		_stopRelativeHeight = 0;
	} else {
		_stopRelativeHeight = stopRelativeHeight;
	}
}

#pragma mark - Helpers

+ (instancetype)defaultConfiguration
{
	return [[self alloc] init];
}

@end

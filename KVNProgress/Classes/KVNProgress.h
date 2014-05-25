//
//  KVNProgress.h
//  KVNProgress
//
//  Created by Kevin Hirsch on 24/05/14.
//  Copyright (c) 2014 Kevin Hirsch. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSUInteger, KVNProgressBackgroundType) {
	/** Don't allow user interactions and show a solid color background */
    KVNProgressBackgroundTypeSolid,
	/** Don't allow user interactions and show a blurred background */
    KVNProgressBackgroundTypeBlurred
};

@interface KVNProgress : UIView

#pragma mark - Appearance

/** Color of the view background. Is not used when backgroundType is KVNProgressBackgroundTypeBlurred */
@property (nonatomic) UIColor *backgroundColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;

@property (nonatomic) UIColor *backgroundTintColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *circleStrokeForegroundColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *circleStrokeBackgroundColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *circleFillBackgroundColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *statusColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIFont *statusFont NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat circleSize NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat lineWidth NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;

#pragma mark - Progress methods

+ (void)show NS_AVAILABLE_IOS(7_0);
+ (void)showWithBackgroundType:(KVNProgressBackgroundType)backgroundType NS_AVAILABLE_IOS(7_0);
+ (void)showWithStatus:(NSString *)status NS_AVAILABLE_IOS(7_0);
+ (void)showWithStatus:(NSString *)status
		backgroundType:(KVNProgressBackgroundType)backgroundType NS_AVAILABLE_IOS(7_0);

+ (void)showProgress:(CGFloat)progress NS_AVAILABLE_IOS(7_0);
+ (void)showProgress:(CGFloat)progress
			  status:(NSString*)status NS_AVAILABLE_IOS(7_0);
+ (void)showProgress:(CGFloat)progress
			  status:(NSString*)status
	  backgroundType:(KVNProgressBackgroundType)backgroundType NS_AVAILABLE_IOS(7_0);

+ (void)dismiss NS_AVAILABLE_IOS(7_0);

#pragma mark - Update

/**
 Change the loading status while it's showing.
 Nothing happens when progress view isn't showing.
 @param status The status to show
 */
+ (void)updateStatus:(NSString*)status;

/**
 Update the progress loader while it's showing
 Nothing happens when progress view isn't showing.
 @param progress The progress value between 0 and 1
 @param animated Wether or not the change has to be animated
 */
+ (void)updateProgress:(CGFloat)progress
			  animated:(BOOL)animated;

#pragma mark - Information

/**
 Tell if the progress view is on screen.
 @return YES if the progress view is on screen, otherwise NO.
 */
+ (BOOL)isVisible;

@end

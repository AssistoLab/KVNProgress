//
//  KVNProgress.h
//  KVNProgress
//
//  Created by Kevin Hirsch on 24/05/14.
//  Copyright (c) 2014 Pinch. All rights reserved.
//

@import UIKit;

#import "KVNProgressConfiguration.h"

typedef void (^KVNCompletionBlock)(void);

@interface KVNProgress : UIView

#pragma mark - Configuration

/**
 Configuration of the <code>KVNProgress</code> UI.
 By default, equals to <code>[KVNProgressConfiguration defaultConfiguration]</code>.
 */
+ (KVNProgressConfiguration *)configuration;

/**
 Changes the configuration of the <code>KVNProgress</code> views.
 @param newConfiguration The new configuration for <code>KVNProgress</code>.
 */
+ (void)setConfiguration:(KVNProgressConfiguration *)newConfiguration;

#pragma mark - Loading

/** Shows an indeterminate progress view without status. */
+ (void)show;

/**
 Shows an indeterminate progress view with the <code>status</code>.
 @param status The status to show.
 */
+ (void)showWithStatus:(NSString *)status;

/**
 Shows an indeterminate progress view added to <code>superview</code> with <code>status</code>.
 @param status The status to show.
 @param onView The superview on which to add the progress view.
 */
+ (void)showWithStatus:(NSString *)status
				onView:(UIView *)superview;

#pragma mark - Progress

/**
 Shows a progress view with a specified <code>progress</code> and no status.
 @param progress The progress to display between 0 and 1.
 */
+ (void)showProgress:(CGFloat)progress;

/**
 Shows a progress view with a specified <code>progress</code> and <code>status</code>.
 @param status The status to show.
 */
+ (void)showProgress:(CGFloat)progress
			  status:(NSString*)status;

/**
 Shows a progress view added to <code>superview</code> with a specified <code>progress</code> and <code>status</code>.
 @param status The status to show.
 @param onView The superview on which to add the progress view.
 */
+ (void)showProgress:(CGFloat)progress
			  status:(NSString*)status
			  onView:(UIView *)superview;

#pragma mark - Success

/** Show a success view without status. */
+ (void)showSuccess;

/**
 Show a success view with <code>status</code>.
 @param status The status to show.
 */
+ (void)showSuccessWithStatus:(NSString *)status;

/**
 Show a success view added to <code>superview</code> with <code>status</code>.
 @param status The status to show.
 @param onView The superview on which to add the progress view.
 */
+ (void)showSuccessWithStatus:(NSString *)status
					   onView:(UIView *)superview;

#pragma mark - Error

/** Show an error view without status. */
+ (void)showError;

/**
 Show an error view with <code>status</code>.
 @param status The status to show.
 */
+ (void)showErrorWithStatus:(NSString *)status;

/**
 Show an error view added to <code>superview</code> with <code>status</code>.
 @param status The status to show.
 @param onView The superview on which to add the progress view.
 */
+ (void)showErrorWithStatus:(NSString *)status
					 onView:(UIView *)superview;

#pragma mark - Dimiss

/**
 Dismiss progress view with a fade animation. Does nothing if the progress view is not on screen.
 <br/><br/><b>Remark:</b> You may want to use <code>dismissWithCompletion:</code> if <code>KVNMinimumDisplayTime</code> is greater than zero.
 @see dismissWithCompletion:
 */
+ (void)dismiss;

/**
 Dismiss progress view with a fade animation and call a completion handler when the dismiss process is finished. Does nothing if the progress view is not on screen.
 <br/><br/><b>Remark:</b> This method can be usefull if the <code>KVNMinimumDisplayTime</code> constant is greater than zero to ensure the view is correctly dismissed.
 @param completion The completion handler called after the view is completely dismissed
 */
+ (void)dismissWithCompletion:(KVNCompletionBlock)completion;

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

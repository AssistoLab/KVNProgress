//
//  KVNProgress.h
//  KVNProgress
//
//  Created by Kevin Hirsch on 24/05/14.
//  Copyright (c) 2014 Pinch. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KVNProgressConfiguration.h"

typedef NS_ENUM(NSUInteger, KVNProgressStyle) {
	KVNProgressStyleHidden,
	KVNProgressStyleProgress,
	KVNProgressStyleSuccess,
	KVNProgressStyleError
};

typedef void (^KVNCompletionBlock)(void);

@interface KVNProgress : UIView

#pragma mark - Properties

@property (nonatomic) KVNProgressStyle style;

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
 @param superview The superview on which to add the progress view. Pass <code>nil</code> to add to main window.
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
 @param superview The superview on which to add the progress view. Pass <code>nil</code> to add to main window.
 */
+ (void)showProgress:(CGFloat)progress
			  status:(NSString*)status
			  onView:(UIView *)superview;

#pragma mark - Success

/** Shows a success view without status. */
+ (void)showSuccess;

/** 
 Shows a success view without status.
 @param completion The completion handler called after the view is completely dismissed.
 */
+ (void)showSuccessWithCompletion:(KVNCompletionBlock)completion;

/**
 Shows a success view with <code>status</code>.
 @param status The status to show.
 */
+ (void)showSuccessWithStatus:(NSString *)status;

/**
 Shows a success view with <code>status</code>.
 @param status The status to show.
 @param completion The completion handler called after the view is completely dismissed.
 */
+ (void)showSuccessWithStatus:(NSString *)status
				   completion:(KVNCompletionBlock)completion;

/**
 Shows a success view added to <code>superview</code> with <code>status</code>.
 @param status The status to show.
 @param superview The superview on which to add the progress view. Pass <code>nil</code> to add to main window.
 */
+ (void)showSuccessWithStatus:(NSString *)status
					   onView:(UIView *)superview;

/**
 Shows a success view added to <code>superview</code> with <code>status</code>.
 @param status The status to show.
 @param superview The superview on which to add the progress view. Pass <code>nil</code> to add to main window.
 @param completion The completion handler called after the view is completely dismissed.
 */
+ (void)showSuccessWithStatus:(NSString *)status
					   onView:(UIView *)superview
				   completion:(KVNCompletionBlock)completion;

#pragma mark - Error

/** Shows an error view without status. */
+ (void)showError;

/**
 Shows an error view without status.
 @param completion The completion handler called after the view is completely dismissed.
 */
+ (void)showErrorWithCompletion:(KVNCompletionBlock)completion;

/**
 Shows an error view with <code>status</code>.
 @param status The status to show.
 */
+ (void)showErrorWithStatus:(NSString *)status;

/**
 Shows an error view with <code>status</code>.
 @param status The status to show.
 @param completion The completion handler called after the view is completely dismissed.
 */
+ (void)showErrorWithStatus:(NSString *)status
				 completion:(KVNCompletionBlock)completion;

/**
 Shows an error view added to <code>superview</code> with <code>status</code>.
 @param status The status to show.
 @param superview The superview on which to add the progress view. Pass <code>nil</code> to add to main window.
 */
+ (void)showErrorWithStatus:(NSString *)status
					 onView:(UIView *)superview;

/**
 Shows an error view added to <code>superview</code> with <code>status</code>.
 @param status The status to show.
 @param superview The superview on which to add the progress view. Pass <code>nil</code> to add to main window.
 @param completion The completion handler called after the view is completely dismissed.
 */
+ (void)showErrorWithStatus:(NSString *)status
					 onView:(UIView *)superview
				 completion:(KVNCompletionBlock)completion;

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
 @param completion The completion handler called after the view is completely dismissed.
 */
+ (void)dismissWithCompletion:(KVNCompletionBlock)completion;

#pragma mark - Update

/**
 Changes the loading status while HUD is displayed.
 Nothing happens when progress view is not displayed.
 @param status The status to show
 */
+ (void)updateStatus:(NSString*)status;

/**
 Update the progress loader while HUD is displayed
 Nothing happens when progress view is not displayed.
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

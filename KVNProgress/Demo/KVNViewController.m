//
//  KVNViewController.m
//  KVNProgress
//
//  Created by Kevin Hirsch on 24/05/14.
//  Copyright (c) 2014 Pinch. All rights reserved.
//

#import "KVNViewController.h"

#import "KVNProgress.h"

@interface KVNViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *fullscreenSwitch;

@end

@implementation KVNViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self setupBaseKVNProgressUI];
}

#pragma mark - UI

- (void)setupBaseKVNProgressUI
{
	// See the documentation of all appearance propoerties
	[KVNProgress appearance].statusColor = [UIColor darkGrayColor];
	[KVNProgress appearance].statusFont = [UIFont systemFontOfSize:17.0f];
	[KVNProgress appearance].circleStrokeForegroundColor = [UIColor darkGrayColor];
	[KVNProgress appearance].circleStrokeBackgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.3f];
	[KVNProgress appearance].circleFillBackgroundColor = [UIColor clearColor];
	[KVNProgress appearance].backgroundFillColor = [UIColor colorWithWhite:0.9f alpha:0.9f];
	[KVNProgress appearance].backgroundTintColor = [UIColor whiteColor];
	[KVNProgress appearance].successColor = [UIColor darkGrayColor];
	[KVNProgress appearance].errorColor = [UIColor darkGrayColor];
	[KVNProgress appearance].circleSize = 75.0f;
	[KVNProgress appearance].lineWidth = 2.0f;
	[KVNProgress appearance].minimumDisplayTime = 5.0f;
	[KVNProgress appearance].minimumSuccessDisplayTime = 0.3f;
	[KVNProgress appearance].minimumErrorDisplayTime = 2.0f;
}

- (void)setupCustomKVNProgressUI
{
	// See the documentation of all appearance propoerties
	[KVNProgress appearance].statusColor = [UIColor whiteColor];
	[KVNProgress appearance].statusFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0f];
	[KVNProgress appearance].circleStrokeForegroundColor = [UIColor whiteColor];
	[KVNProgress appearance].circleStrokeBackgroundColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
	[KVNProgress appearance].circleFillBackgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
	[KVNProgress appearance].backgroundFillColor = [UIColor colorWithRed:0.173f green:0.263f blue:0.856f alpha:0.9f];
	[KVNProgress appearance].backgroundTintColor = [UIColor colorWithRed:0.173f green:0.263f blue:0.856f alpha:1.0f];
	[KVNProgress appearance].successColor = [UIColor whiteColor];
	[KVNProgress appearance].errorColor = [UIColor whiteColor];
	[KVNProgress appearance].circleSize = 110.0f;
	[KVNProgress appearance].lineWidth = 1.0f;
}

#pragma mark - Predefined HUD's

- (IBAction)show
{
	if ([self isFullScreen]) {
		[KVNProgress showWithParameters:@{KVNProgressViewParameterFullScreen: @(YES)}];
	} else {
		[KVNProgress show];
	}
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[KVNProgress dismiss];
	});
}

- (IBAction)showWithSolidBackground
{
	[KVNProgress showWithParameters:@{KVNProgressViewParameterStatus: @"Loading...",
									  KVNProgressViewParameterBackgroundType: @(KVNProgressBackgroundTypeSolid),
									  KVNProgressViewParameterFullScreen: @([self isFullScreen])}];
	
	dispatch_main_after(3.0f, ^{
		[KVNProgress dismiss];
	});
}

- (IBAction)showWithStatus
{
	if ([self isFullScreen]) {
		[KVNProgress showWithParameters:@{KVNProgressViewParameterStatus: @"Loading...",
										  KVNProgressViewParameterFullScreen: @(YES)}];
	} else {
		[KVNProgress showWithStatus:@"Loading..."];
	}
	
	dispatch_main_after(3.0f, ^{
		[KVNProgress dismiss];
	});
}

- (IBAction)showProgress
{
	if ([self isFullScreen]) {
		[KVNProgress showProgress:0.0f
					   parameters:@{KVNProgressViewParameterStatus: @"Loading with progress...",
									KVNProgressViewParameterFullScreen: @(YES)}];
	} else {
		[KVNProgress showProgress:0.0f
						   status:@"Loading with progress..."];
	}
	
	[self updateProgress];
	
	dispatch_main_after(2.7f, ^{
		[KVNProgress updateStatus:@"You can change to a multiline status text dynamically!"];
	});
	dispatch_main_after(5.5f, ^{
		[self showSuccess];
	});
}

- (IBAction)showSuccess
{
	if ([self isFullScreen]) {
		[KVNProgress showSuccessWithParameters:@{KVNProgressViewParameterStatus: @"Success",
												 KVNProgressViewParameterFullScreen: @(YES)}];
	} else {
		[KVNProgress showSuccessWithStatus:@"Success"];
	}
}

- (IBAction)showError
{
	if ([self isFullScreen]) {
		[KVNProgress showErrorWithParameters:@{KVNProgressViewParameterStatus: @"Error",
											   KVNProgressViewParameterFullScreen: @(YES)}];
	} else {
		[KVNProgress showErrorWithStatus:@"Error"];
	}
}

- (IBAction)showCustom
{
	[self setupCustomKVNProgressUI];
	
	if ([self isFullScreen]) {
		[KVNProgress showProgress:0.0f
					   parameters:@{KVNProgressViewParameterStatus: @"You can custom several things like colors, fonts, circle size, and more!",
									KVNProgressViewParameterFullScreen: @(YES)}];
	} else {
		[KVNProgress showProgress:0.0f
						   status:@"You can custom several things like colors, fonts, circle size, and more!"];
	}
	
	[self updateProgress];
	
	dispatch_main_after(5.5f, ^{
		[self showSuccess];
		[self setupBaseKVNProgressUI];
	});
}

#pragma mark - Helper

- (void)updateProgress
{
	dispatch_main_after(2.0f, ^{
		[KVNProgress updateProgress:0.3f
						   animated:YES];
	});
	dispatch_main_after(2.5f, ^{
		[KVNProgress updateProgress:0.5f
						   animated:YES];
	});
	dispatch_main_after(2.8f, ^{
		[KVNProgress updateProgress:0.6f
						   animated:YES];
	});
	dispatch_main_after(3.7f, ^{
		[KVNProgress updateProgress:0.93f
						   animated:YES];
	});
	dispatch_main_after(5.0f, ^{
		[KVNProgress updateProgress:1.0f
						   animated:YES];
	});
}

- (BOOL)isFullScreen
{
	return [self.fullscreenSwitch isOn];
}

static void dispatch_main_after(NSTimeInterval delay, void (^block)(void))
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		block();
	});
}

@end

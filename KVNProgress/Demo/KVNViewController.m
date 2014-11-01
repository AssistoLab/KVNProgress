//
//  KVNViewController.m
//  KVNProgress
//
//  Created by Kevin Hirsch on 24/05/14.
//  Copyright (c) 2014 Pinch. All rights reserved.
//

#import "KVNViewController.h"

#import "KVNProgress.h"

@implementation KVNViewController

#pragma mark - UIViewController

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self setupBaseKVNProgressUI];
}

#pragma mark - UI

- (void)setupBaseKVNProgressUI
{
	[KVNProgress appearance].statusColor = [UIColor brownColor];
	[KVNProgress appearance].circleStrokeForegroundColor = [UIColor brownColor];
	[KVNProgress appearance].circleStrokeBackgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.3f];
	[KVNProgress appearance].circleFillBackgroundColor = [UIColor clearColor];
	[KVNProgress appearance].backgroundFillColor = [UIColor colorWithRed:1.000 green:0.841 blue:0.582 alpha:0.900];
	[KVNProgress appearance].backgroundTintColor = [UIColor colorWithRed:1.000 green:0.841 blue:0.582 alpha:1.000];
	[KVNProgress appearance].circleSize = 75.0f;
	[KVNProgress appearance].lineWidth = 2.0f;
}

- (void)setupCustomKVNProgressUI
{
	[KVNProgress appearance].statusColor = [UIColor darkGrayColor];
	[KVNProgress appearance].circleStrokeForegroundColor = [UIColor colorWithRed:0.261 green:0.678 blue:0.199 alpha:1.000];
	[KVNProgress appearance].circleStrokeBackgroundColor = [UIColor colorWithRed:0.559 green:0.834 blue:0.486 alpha:0.750];
	[KVNProgress appearance].circleFillBackgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.25f];
	[KVNProgress appearance].backgroundFillColor = [UIColor blueColor];
	[KVNProgress appearance].backgroundTintColor = [UIColor colorWithRed:0.681 green:1.000 blue:0.582 alpha:1.000];
	[KVNProgress appearance].circleSize = 150.0f;
	[KVNProgress appearance].lineWidth = 5.0f;
}

#pragma mark - Actions

- (IBAction)show
{
	[KVNProgress show];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[KVNProgress dismiss];
	});
}

- (IBAction)showWithStatus
{
	[KVNProgress showWithStatus:@"Loading..."];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self showProgressFullScreen];
	});
}

- (IBAction)showWithSolidBackground
{
	[KVNProgress showWithParameters:@{KVNProgressViewParameterStatus: @"Loading...",
									  KVNProgressViewParameterBackgroundType: @(KVNProgressBackgroundTypeBlurred)}];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[KVNProgress dismiss];
	});
}

- (void)showProgressFullScreen
{
	[KVNProgress showProgress:0.0f
				   parameters:@{KVNProgressViewParameterStatus: @"Loading with progress...",
								KVNProgressViewParameterBackgroundType: @(KVNProgressBackgroundTypeBlurred),
								KVNProgressViewParameterFullScreen: @(YES)}];
	[self updateProgress];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.70f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[KVNProgress updateStatus:@"You can change multiline status text dynamically !"];
	});
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[KVNProgress dismiss];
	});
}

- (IBAction)showProgress
{
	[KVNProgress showProgress:0.0f
					   status:@"Loading with progress..."];
	[self updateProgress];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.70f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[KVNProgress updateStatus:@"You can change multiline status text dynamically !"];
	});
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[KVNProgress dismiss];
	});
}

- (void)updateProgress
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[KVNProgress updateProgress:0.3
						   animated:YES];
	});
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[KVNProgress updateProgress:0.5
						   animated:YES];
	});
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.8f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[KVNProgress updateProgress:0.6
						   animated:YES];
	});
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.7f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[KVNProgress updateProgress:0.93
						   animated:YES];
	});
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[KVNProgress updateProgress:1
						   animated:YES];
	});
}

- (IBAction)showCustom
{
	[self setupCustomKVNProgressUI];
	
	[KVNProgress showProgress:0.0f
					   status:@"You can custom several things : colors, fonts, circle size, and more !"];
	[self updateProgress];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self setupBaseKVNProgressUI];
		[KVNProgress dismiss];
	});
}

@end

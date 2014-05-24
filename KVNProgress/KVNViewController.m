//
//  KVNViewController.m
//  KVNProgress
//
//  Created by Kevin Hirsch on 24/05/14.
//  Copyright (c) 2014 Kevin Hirsch. All rights reserved.
//

#import "KVNViewController.h"

#import "KVNProgress.h"

@interface KVNViewController ()

@end

@implementation KVNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	sleep(3);
	[KVNProgress showProgressWithStatus:@"Loading..."];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

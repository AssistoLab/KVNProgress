//
//  KVNRotationViewController.m
//  KVNProgress
//
//  Created by Kevin Hirsch on 18/08/16.
//  Copyright © 2016 Pinch. All rights reserved.
//

#import "KVNRotationViewController.h"

/**
 This class is only used to handle rotation automatically with a custom UIWindow
 http://stackoverflow.com/a/27091111/2571566
 */
@implementation KVNRotationViewController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.supportedOrientations = UIInterfaceOrientationMaskAll;
    }
    
    return self;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	return self.supportedOrientations;
}

- (BOOL)shouldAutorotate
{
	return YES;
}

@end

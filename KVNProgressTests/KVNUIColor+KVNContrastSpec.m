//
//  KVNUIColor+KVNContrastSpec.m
//  KVNProgress
//
//  Created by Louis Tur on 4/18/15.
//  Copyright 2015 Pinch. All rights reserved.
//

#import "Specta.h"
#import <Expecta/Expecta.h>
#import "UIColor+KVNContrast.h"


SpecBegin(UIColor_KVNContrast)

describe(@"StatusBarStyle should be correctly set", ^{

    __block UIColor *statusBarComponentColor;
    __block UIStatusBarStyle statusBarStyle;
    
    it(@"Should return UIStatusBarStyleDefault if the color components are dark", ^{
        
        statusBarComponentColor = [UIColor blackColor];
        statusBarStyle = [statusBarComponentColor statusBarStyleConstrastStyle];
        
        expect(statusBarStyle).to.equal(UIStatusBarStyleDefault);
        
    });
    
    it(@"Should return UIStatusBarStyleLightContent if the color components are light", ^{
        
        statusBarComponentColor = [UIColor clearColor];
        statusBarStyle = [statusBarComponentColor statusBarStyleConstrastStyle];
        
        expect(statusBarStyle).to.equal(UIStatusBarStyleLightContent);
    });

});

SpecEnd

//
//  KVNProgressTests.m
//  KVNProgressTests
//
//  Created by Kevin Hirsch on 24/05/14.
//  Copyright (c) 2014 Kevin Hirsch. All rights reserved.
//

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>

#import "KVNProgress.h"

SpecBegin(KVNProgress)

describe(@"showing and hiding", ^{

    it(@"shows the basic progress view", ^{
        [KVNProgress show];
        expect([KVNProgress isVisible]).after(1).to.beTruthy();
    });

    it(@"hides the basic progress view", ^{
        [KVNProgress show];
        expect([KVNProgress isVisible]).after(1).to.beTruthy();
        [KVNProgress dismiss];
        expect([KVNProgress isVisible]).after(1).to.beFalsy();
    });

    it(@"looks right by default", ^{
        // TODO
    });
});

describe(@"notifications", ^{
    it(@"rearranges when UIDeviceOrientationDidChangeNotification is called", ^{
        [KVNProgress show];
        [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
        // TODO
    });

    it(@"calls the tap handler when the KVNProgress is tapped", ^{

        [KVNProgress setConfiguration:[KVNProgressConfiguration defaultConfiguration]];
        KVNProgressConfiguration *configuration = [KVNProgressConfiguration defaultConfiguration];
        configuration.tapBlock = ^(KVNProgress *progressView) {
            // TODO
        };
                    
        [KVNProgress show];
    });
});

SpecEnd
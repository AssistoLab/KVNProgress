//
//  KVNProgressConfigurationTestsSpec.m
//  KVNProgress
//
//  Created by Louis Tur on 4/18/15.
//  Copyright 2015 Pinch. All rights reserved.
//

#import "Specta.h"
#import <Expecta/Expecta.h>
#import "KVNProgressConfiguration.h"


SpecBegin(KVNProgressConfigurationTests)

describe(@"defaultConfiguration", ^{
    __block KVNProgressConfiguration *testConfiguration;
    
    it(@"Default configuration should not return nil instance", ^{
        testConfiguration = [KVNProgressConfiguration defaultConfiguration];
        
        expect(testConfiguration).toNot.beNil;
    });

});

describe(@"default properties for non-fullscreen HUD", ^{
    
    __block KVNProgressConfiguration *testConfiguration;
    beforeAll(^{
        testConfiguration = [KVNProgressConfiguration defaultConfiguration];
    });
    
    it(@"Should have it's default properties set", ^{
        
        expect(testConfiguration.backgroundFillColor).to.equal ([UIColor colorWithWhite:1.0f alpha:0.85f]);
        
        expect(testConfiguration.backgroundType).to.equal(KVNProgressBackgroundTypeBlurred);
        
        expect(testConfiguration.circleStrokeForegroundColor).to.equal([UIColor darkGrayColor]);
        
        expect(testConfiguration.circleStrokeBackgroundColor).to.equal([testConfiguration.circleStrokeForegroundColor colorWithAlphaComponent:0.3f]);
        
        expect(testConfiguration.circleFillBackgroundColor).to.equal([UIColor clearColor]);
        
        expect(testConfiguration.circleSize).to.beGreaterThan(0.0);
        
    });
});

SpecEnd

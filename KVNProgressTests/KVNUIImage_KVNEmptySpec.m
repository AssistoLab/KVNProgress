//
//  KVNUIImage_KVNEmptySpec.m
//  KVNProgress
//
//  Created by Louis Tur on 4/18/15.
//  Copyright 2015 Pinch. All rights reserved.
//

#import "Specta.h"
#import <Expecta/Expecta.h>
#import "UIImage+KVNEmpty.h"


SpecBegin(UIImage_KVNEmpty)

describe(@"emptyImage should return an allocated UIImage", ^{

    it(@"Should return a UIImage without content", ^{
        
        
        UIImage * blankImage = [UIImage emptyImage];
        
        CGImageRef cgref = [blankImage CGImage];
        CIImage *cim = [blankImage CIImage];
        
        expect(cgref).to.beNull;
        expect(cim).to.beNil;
        
    });  
    
});

SpecEnd

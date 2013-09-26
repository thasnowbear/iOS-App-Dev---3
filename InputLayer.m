//
//  InputLayer.m
//  iOS App Dev
//
//  Created by Sveinn Fannar Kristjansson on 9/17/13.
//  Copyright 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "InputLayer.h"
@implementation InputLayer

- (id)init
{
    self = [super init];
    if (self)
    {
        self.touchEnabled = YES;
        self.touchMode = kCCTouchesOneByOne;
    }
    return self;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [_delegate touchEnded];
}

@end
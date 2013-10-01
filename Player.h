//
//  Player.h
//  iOS App Dev
//
//  Created by Sveinn Fannar Kristjansson on 9/17/13.
//  Copyright 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
@interface Player : CCPhysicsSprite
{
    ChipmunkSpace *_space;
    @public
    BOOL shield;
}

- (id)initWithPosition:(ChipmunkSpace *)space position:(CGPoint)position;
- (void)jump;
- (void)walk:(BOOL *)hitbybomb;
- (void)hitbybomb;
@end
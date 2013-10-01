//
//  Shield.h
//  iOS App Dev
//
//  Created by Guet on 10/1/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "cocos2d.h"
#import <Foundation/Foundation.h>

@interface Shield : CCPhysicsSprite

- (id)initWithSpace:(ChipmunkSpace
                     *)space position:(CGPoint)position;

@end

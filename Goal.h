//
//  Goal.h
//  iOS App Dev
//
//  Created by Guet on 9/30/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Goal : CCPhysicsSprite
{

}

- (id)initWithSpace:(ChipmunkSpace
                     *)space position:(CGPoint)position;

@end

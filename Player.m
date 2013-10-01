//
//  Player.h
//  iOS App Dev
//
//  Created by Sveinn Fannar Kristjansson on 9/17/13.
//  Copyright 2013 Sveinn Fannar Kristjansson. All rights reserved.
//


#import "Player.h"


@implementation Player

- (id)initWithPosition:(ChipmunkSpace *)space position:(CGPoint)position;
{
    self = [super initWithFile:@"PlayerFinal.png"];
    if(self)
    {
        _space = space;
        if(_space != nil)
        {
            CGSize size = self.textureRect.size;
            cpFloat mass = size.width * size.height;
            cpFloat moment = cpMomentForBox(mass,size.width,size.height);
            
            ChipmunkBody *body = [ChipmunkBody bodyWithMass:mass andMoment: moment];
            body.pos = position;
            ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:body width:size.width height:size.height];
            
            [_space addBody:body];
            [_space addShape:shape];
            
            self.chipmunkBody = body;
        }
    }
    return self;
}

- (void)jump
{
    cpVect impulseVector = cpv(0, 50 * self.chipmunkBody.mass);
    [self.chipmunkBody applyImpulse:impulseVector offset:cpvzero];
}

- (void)walk:(BOOL*)hitbybomb
{
    if(hitbybomb == NO){
    cpVect impulseVector = cpv(75 * self.chipmunkBody.mass, 0);
    [self.chipmunkBody applyImpulse:impulseVector offset:cpvzero];
    }
    else{
        cpVect impulseVector = cpv(250 * self.chipmunkBody.mass, 0);
        [self.chipmunkBody applyImpulse:impulseVector offset:cpvzero];
    }
}

- (void)hitbybomb
{
    cpVect impulseVector = cpv(-175 * self.chipmunkBody.mass, 75 * self.chipmunkBody.mass);
    [self.chipmunkBody applyImpulse:impulseVector offset:cpvzero];
}

@end
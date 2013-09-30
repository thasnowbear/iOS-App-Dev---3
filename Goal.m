//
//  Goal.m
//  iOS App Dev
//
//  Created by Guet on 9/30/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "Goal.h"
#import "ObjectiveChipmunk.h"

@implementation Goal

-(id)initWithSpace:(ChipmunkSpace *)space position: (CGPoint) position
{
    self = [super initWithFile:@"Player1.png"];
    if(self){
        CGSize size = self.textureRect.size;
        
        ChipmunkBody *body = [ChipmunkBody staticBody];
        body.pos = position;
        ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:body width:size.width height:size.height];
        shape.sensor = YES;
        
        [space addShape:shape];
        
        body.data = self;
        self.chipmunkBody = body;
        
    }
    return self;
}


@end

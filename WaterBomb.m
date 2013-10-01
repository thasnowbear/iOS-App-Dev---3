//
//  WaterBomb.m
//  iOS App Dev
//
//  Created by Guet on 10/1/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "ObjectiveChipmunk.h"
#import "WaterBomb.h"

@implementation WaterBomb

-(id)initWithSpace:(ChipmunkSpace *)space position: (CGPoint) position
{
    self = [super initWithFile:@"WaterBarrel.png"];
    if(self){
        CGSize size = self.textureRect.size;
        
        ChipmunkBody *body = [ChipmunkBody staticBody];
        body.pos = position;
        ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:body width:size.width height:size.height];
        shape.sensor = YES;
        
        [space addShape:shape];
        used = NO;
        body.data = self;
        self.chipmunkBody = body;
        
    }
    return self;
}

@end

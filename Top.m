//
//  Goal.m
//  iOS App Dev
//
//  Created by Guet on 9/30/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "Top.h"
#import "ObjectiveChipmunk.h"

@implementation Top

-(id)initWithSpace:(ChipmunkSpace *)space position: (CGPoint) position
{
    self = [super initWithFile:@"Top.png"];
    if(self){
        CGSize size = self.textureRect.size;
        
        ChipmunkBody *body = [ChipmunkBody staticBody];
        body.pos = position;
        ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:body width:size.width height:size.height];
        
        [space addShape:shape];
        
        body.data = self;
        self.chipmunkBody = body;
        
    }
    return self;
}

@end

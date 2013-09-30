//
//  MenuScene.m
//  iOS App Dev
//
//  Created by Guet on 9/30/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "MenuScene.h"
#import "cocos2d.h"
#import "GameScene.h"

@implementation MenuScene

- (id)init{
    self = [super init];
    if(self != nil)
    {
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"START" fontName:@"Arial" fontSize:48];
        CCMenuItemLabel *button = [CCMenuItemLabel itemWithLabel:label block:^(id sender)
        {
            GameScene *gameScene = [[GameScene alloc] init];
            [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:1.0 scene:gameScene]];
        }];
        button.position = ccp(200,200);
        
        CCMenu *menu = [CCMenu menuWithItems:button, nil];
        menu.position = CGPointZero;
        [self addChild:menu];
    }
    
    return self;
}

@end

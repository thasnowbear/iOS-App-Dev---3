//
//  GameScene.h
//  iOS App Dev
//
//  Created by Sveinn Fannar Kristjansson on 9/17/13.
//  Copyright 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "InputLayer.h"

@class Player;
@class Top;
@class Goal;
@class WaterBomb;
@class Coins;
@interface GameScene : CCScene <InputLayerDelegate>
{
    CGSize _winSize;
    NSDictionary *_configuration;
    CCLayerGradient *_skyLayer;
    CGFloat _windSpeed;
    Player *_player;
    Top *_top;
    Goal *_goal;
    Coins *_coin;
    double score;
    WaterBomb *_waterBomb1;
    ChipmunkSpace *_space;
    ccTime _accumulator;
    CCParallaxNode *_parallaxNode;
    CCParticleSystemQuad *_particle;
    CCNode *_gameNode;
    BOOL _followPlayer;
    BOOL _hitByBomb;
    CGFloat _landscapeWidth;
}

@end

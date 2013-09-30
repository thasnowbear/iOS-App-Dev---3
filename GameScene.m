//
//  Game.m
//  iOS App Dev
//
//  Created by Sveinn Fannar Kristjansson on 9/17/13.
//  Copyright 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "GameScene.h"
#import "Player.h"
#import "InputLayer.h"
#import "ChipmunkAutoGeometry.h"
#import "Top.h"
#import "Goal.h"
#import "SimpleAudioEngine.h"
#import "CCParticleSystemQuad.h"


@implementation GameScene
#pragma mark - Initilization

- (id)init
{
    self = [super init];
    if (self)
    {
        srandom(time(NULL));
        _winSize = [CCDirector sharedDirector].winSize;
        //cant make it work for some reason
        _configuration = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"]];

        _space = [[ChipmunkSpace alloc]init];
        _space.gravity = ccp(0.0f, -100);
        
        [_space setDefaultCollisionHandler:self
                                     begin:@selector(collisionBegan:space:)
                                  preSolve:nil
                                 postSolve:nil
                                  separate:nil];
        
                          
        [self generateRandomWind];
        [self setupGraphicsLandscape];
        [self setupPhysicsLandscape];
        
        
        /*
        CCPhysicsDebugNode *debugNode = [CCPhysicsDebugNode debugNodeForChipmunkSpace:_space];
        debugNode.visible = YES;
        [self addChild:debugNode];*/
    
        _player = [[Player alloc] initWithPosition:_space position:CGPointMake(30, 180)];
        [_gameNode addChild:_player];
        
        //Adding top part of map.
        _top = [[Top alloc] initWithSpace:_space position:CGPointMake(400, 420)];
        [_gameNode addChild:_top];
        
        _goal = [[Goal alloc] initWithSpace:_space position:CGPointMake(900, 160)];
        [_gameNode addChild:_goal];
        
        _particle = [CCParticleSystemQuad particleWithFile:@"Explosion.plist"];
        _particle.position = _goal.position;
        [_particle stopSystem];
        [_gameNode addChild:_particle];
        
        //preload sound
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Impact.wav"];
        
        InputLayer *inputLayer = [[InputLayer alloc] init];
        inputLayer.delegate = self;
        [self addChild:inputLayer];
        
        
        
        [self scheduleUpdate];
    }
    return self;
}

- (bool)collisionBegan:(cpArbiter *)arbiter space:(ChipmunkSpace*)space{
    cpBody *firstBody;
    cpBody *secondBody;
    cpArbiterGetBodies(arbiter, &firstBody, &secondBody);
    
    ChipmunkBody *firstChipmunkBody = firstBody->data;
    ChipmunkBody *secondChipmunkBody = secondBody->data;
    
    if((firstChipmunkBody == _player.chipmunkBody && secondChipmunkBody == _goal.chipmunkBody)||(firstChipmunkBody == _goal.chipmunkBody && secondChipmunkBody == _player.chipmunkBody)){
        NSLog(@"Collision!");
        [[SimpleAudioEngine sharedEngine] playEffect:@"Impact.wav" pitch:(CCRANDOM_0_1() * 0.3f) + 1 pan:0 gain:1];
        
        [_space smartRemove:_player.chipmunkBody];
        for(ChipmunkShape *shape in _player.chipmunkBody.shapes){
            [_space smartRemove:shape];
        }
        
        [_player removeFromParentAndCleanup:YES];
        
        [_particle resetSystem];
        
    }
    
    return YES;
}

- (void)setupGraphicsLandscape
{
    _skyLayer = [CCLayerGradient layerWithColor:ccc4(89, 67, 245, 255) fadingTo:ccc4(67, 219, 245, 255)];
    [self addChild:_skyLayer];
    
    _parallaxNode = [CCParallaxNode node];
    [self addChild:_parallaxNode];
    
    CCSprite *top = [CCSprite spriteWithFile:@"Top.png"];
    top.anchorPoint = ccp(0,-0.70);
    [_parallaxNode addChild:top z:1 parallaxRatio:ccp(1.0f, 1.0f) positionOffset: CGPointZero];
    
    CCSprite *back = [CCSprite spriteWithFile:@"Background.png"];
    _landscapeWidth = back.contentSize.width;
    back.anchorPoint = ccp(0, -0.20);
    [_parallaxNode addChild:back z:0 parallaxRatio:ccp(0.3f, 1.0f) positionOffset:CGPointZero];
    
    CCSprite *ground = [CCSprite spriteWithFile:@"Ground.png"];
    ground.anchorPoint = ccp(0, 0);
    [_parallaxNode addChild:ground z:1 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];
    
    _gameNode = [CCNode node];
    [_parallaxNode addChild:_gameNode z:2 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];
    
}

- (void)setupPhysicsLandscape{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Ground" withExtension:@"png"];
    ChipmunkImageSampler *sampler = [ChipmunkImageSampler samplerWithImageFile:url isMask:NO];
    
    ChipmunkPolylineSet *contour = [sampler marchAllWithBorder:NO hard:YES];
    ChipmunkPolyline *line = [contour lineAtIndex:0];
    ChipmunkPolyline *simpleLine = [line simplifyCurves:1];
    
    ChipmunkBody *terrainBody = [ChipmunkBody staticBody];
    NSArray *terrainShapes = [simpleLine asChipmunkSegmentsWithBody:terrainBody radius:0 offset:cpvzero];
    for (ChipmunkShape *shape in terrainShapes)
        {
            [_space addShape:shape];
        }
}

#pragma mark - Update
- (void)update:(ccTime)delta
{
    _accumulator += delta;
    CGFloat fixedTimeStep = 1.0f/240.0f;
    while (_accumulator > fixedTimeStep) {
        [_space step:fixedTimeStep];
        _accumulator -= fixedTimeStep;
    }
    
    if(_followPlayer == YES)
    {
        if(_player.position.x >= (_winSize.width / 2) && _player.position.x < (_landscapeWidth - (_winSize.width / 2)))
        {
            _parallaxNode.position = ccp(-(_player.position.x - (_winSize.width / 2)), 0);
        }
    }

    // Update logic goes here
}

- (void)generateRandomWind
{
    _windSpeed = CCRANDOM_MINUS1_1() * [_configuration[@"windMaxSpeed"] floatValue];
}

#pragma mark - My Touch Delegate Methods

- (void)touchEnded{
    if(_followPlayer == NO){
        [_player walk];
    }
    _followPlayer = YES;
    [_player jump];
    /*CCMoveBy *move = [CCMoveBy actionWithDuration: 5 position:ccp(400,0)];
    [_player runAction:move];*/
}

@end

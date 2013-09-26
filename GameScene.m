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
        CGFloat gravity = [_configuration[@"gravity"] floatValue];
        _space.gravity = ccp(0.0f, -100);
        
        
        
                          
        [self generateRandomWind];
        [self setupGraphicsLandscape];
        [self setupPhysicsLandscape];
        
        CCPhysicsDebugNode *debugNode = [CCPhysicsDebugNode debugNodeForChipmunkSpace:_space];
        debugNode.visible = YES;
        [self addChild:debugNode];
    
       /* NSString *playerPositionString = _configuration[@"playerPosition"];
        playerPositionString = @"200,200";
        _player = [[Player alloc] initWithPosition:CGPointFromString(playerPositionString)];*/
        CGPoint _point;
        _point.x = 30;
        _point.y = 180;
        _player = [[Player alloc] initWithPosition:_space position:_point];
        [_gameNode addChild:_player];
        
        InputLayer *inputLayer = [[InputLayer alloc] init];
        inputLayer.delegate = self;
        [self addChild:inputLayer];
        
        
        
        [self scheduleUpdate];
    }
    return self;
}

- (void)setupGraphicsLandscape
{
    _skyLayer = [CCLayerGradient layerWithColor:ccc4(89, 67, 245, 255) fadingTo:ccc4(67, 219, 245, 255)];
    [self addChild:_skyLayer];
    
    _parallaxNode = [CCParallaxNode node];
    [self addChild:_parallaxNode];
    
    CCSprite *top = [CCSprite spriteWithFile:@"Top.png"];
    top.anchorPoint = ccp(0,-1.45);
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
    _followPlayer = YES;
    [_player jump];
    /*CCMoveBy *move = [CCMoveBy actionWithDuration: 5 position:ccp(400,0)];
    [_player runAction:move];*/
}

@end

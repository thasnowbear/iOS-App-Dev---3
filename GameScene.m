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
#import "WaterBomb.h"
#import "Coins.h"
#import "Shield.h"


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
        _configuration = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"]];

        _space = [[ChipmunkSpace alloc]init];
        _space.gravity = ccp(0.0f, -100);
        
        score = 0;

        
        [_space setDefaultCollisionHandler:self
                                     begin:@selector(collisionBegan:space:)
                                  preSolve:nil
                                 postSolve:nil
                                  separate:nil];
        [self setupGraphicsLandscape];
        [self setupPhysicsLandscape];
        //setting up character, and items and such
        [self setUpEnviroment];
        //loading particles
        [self setUpParticles];
        //loading sounds
        [self setUpSounds];
        //putting up a scorelabel for player to see score.
        [self setUpScoreLabel];
        
        
        
        InputLayer *inputLayer = [[InputLayer alloc] init];
        inputLayer.delegate = self;
        [self addChild:inputLayer];
        
        [self scheduleUpdate];
    }
    return self;
}

- (void)setUpScoreLabel{
    NSNumber *myDoubleNumber = [NSNumber numberWithDouble:score];
    NSString *textScore = [NSString stringWithFormat:@"Score: %@", [myDoubleNumber stringValue]];
    scoreLabel = [CCLabelTTF labelWithString:textScore fontName:@"Arial" fontSize:20];
    scoreLabel.color = ccBLACK;
    scoreLabel.position = ccp(300, 50);
    [self addChild:scoreLabel z:1];

}

- (void)setUpEnviroment{
    
    _player = [[Player alloc] initWithPosition:_space position:CGPointMake(30, 125)];
    [_gameNode addChild:_player];
    _player->shield = NO;
    
    //Adding top part of map.
    _top = [[Top alloc] initWithSpace:_space position:CGPointMake(400, 420)];
    [_gameNode addChild:_top];
    
    _goal = [[Goal alloc] initWithSpace:_space position:CGPointMake(900, 160)];
    [_gameNode addChild:_goal];
    
    _waterBomb1 = [[WaterBomb alloc] initWithSpace:_space position:CGPointMake(630, 120)];
    [_gameNode addChild:_waterBomb1];
    
    _coin = [[Coins alloc] initWithSpace:_space position:CGPointMake(430, 220)];
    [_gameNode addChild:_coin];
    
    _shield = [[Shield alloc] initWithSpace:_space position:CGPointMake(230, 120)];
    [_gameNode addChild:_shield];
}

-(void) setUpSounds{
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"Impact.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"smw_coin.wav"];
}

-(void) setUpParticles{
    _particle = [CCParticleSystemQuad particleWithFile:@"Explosion.plist"];
    _particle.position = _waterBomb1.position;
    [_particle stopSystem];
    [_gameNode addChild:_particle];
}

- (void)addPoints{
    NSNumber *myDoubleNumber = [NSNumber numberWithDouble:score];
    [scoreLabel setString:[NSString stringWithFormat:@"Score: %@", [myDoubleNumber stringValue]]];
}


- (BOOL)helper:(ChipmunkBody *)firstInput firstEqual:(ChipmunkBody *)firstEqual secondInput:(ChipmunkBody *) secondInput secondEqual:(ChipmunkBody *)secondEqual{
    if((firstInput == firstEqual && secondInput == secondEqual)||(firstInput == secondEqual && secondInput == firstEqual))
        return true;
    return FALSE;
}

- (bool)collisionBegan:(cpArbiter *)arbiter space:(ChipmunkSpace*)space{
    cpBody *firstBody;
    cpBody *secondBody;
    cpArbiterGetBodies(arbiter, &firstBody, &secondBody);
    
    ChipmunkBody *firstChipmunkBody = firstBody->data;
    ChipmunkBody *secondChipmunkBody = secondBody->data;
    
    // character reached goal
    if([self helper:firstChipmunkBody firstEqual:_player.chipmunkBody secondInput:secondChipmunkBody secondEqual:_goal.chipmunkBody]){
        
        [_space smartRemove:_player.chipmunkBody];
        for(ChipmunkShape *shape in _player.chipmunkBody.shapes){
            [_space smartRemove:shape];
        }
        
        [_player removeFromParentAndCleanup:YES];
        [[CCDirector sharedDirector] popScene];
        
        
    }
    
    
    //if player hits waterbarrel
    if([self helper:firstChipmunkBody firstEqual:_player.chipmunkBody secondInput:secondChipmunkBody secondEqual:_waterBomb1.chipmunkBody]){
        if(_player->shield == NO){
            [[SimpleAudioEngine sharedEngine] playEffect:@"Impact.wav" pitch:(CCRANDOM_0_1() * 0.3f) + 1 pan:0 gain:1];
            [_player hitbybomb];
            _followPlayer = NO;
            _hitByBomb = YES;
            [_particle resetSystem];
            for(ChipmunkShape *shape in _waterBomb1.chipmunkBody.shapes){
                [_space smartRemove:shape];
            }
            [_waterBomb1 removeFromParentAndCleanup:YES];}
        
    }
    
    //if player hits coin
    if([self helper:firstChipmunkBody firstEqual:_player.chipmunkBody secondInput:secondChipmunkBody secondEqual:_coin.chipmunkBody]){
        [[SimpleAudioEngine sharedEngine] playEffect:@"smw_coin.wav" pitch:(CCRANDOM_0_1() * 0.3f) + 1 pan:0 gain:1];
        score += 1000;
        [self addPoints];
        for(ChipmunkShape *shape in _coin.chipmunkBody.shapes){
            [_space smartRemove:shape];
        }
        [_coin removeFromParentAndCleanup:YES];
    }
    
    if([self helper:firstChipmunkBody firstEqual:_player.chipmunkBody secondInput:secondChipmunkBody secondEqual:_shield.chipmunkBody]){
        
        _player->shield = YES;
        
        for(ChipmunkShape *shape in _shield.chipmunkBody.shapes){
            [_space smartRemove:shape];
        }
        [_shield removeFromParentAndCleanup:YES];
    }
    
    return YES;
}

- (void)setupGraphicsLandscape
{
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
    //adding physics to the ground so character doesnt fall through the world
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Ground" withExtension:@"png"];
    ChipmunkImageSampler *sampler = [ChipmunkImageSampler samplerWithImageFile:url isMask:NO];
    
    ChipmunkPolylineSet *contour = [sampler marchAllWithBorder:NO hard:YES];
    ChipmunkPolyline *line = [contour lineAtIndex:0];
    ChipmunkPolyline *simpleLine = [line simplifyCurves:1];
    ChipmunkBody *_terrainBody = [ChipmunkBody staticBody];
    NSArray *terrainShapes = [simpleLine asChipmunkSegmentsWithBody:_terrainBody radius:0 offset:cpvzero];
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
        //updating score on how far hes travelled
        score += 1;
        [self addPoints];
    }
    
    // Update logic goes here
}


#pragma mark - My Touch Delegate Methods

- (void)touchEnded{
    // making character walk
    if(_followPlayer == NO){
        [_player walk:_hitByBomb];
        _hitByBomb = NO;
    }
    _followPlayer = YES;
    [_player jump];
}

@end

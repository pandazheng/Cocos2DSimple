//
//  GameOverLayyer.m
//  Cocos2DSimple
//
//  Created by panda zheng on 13-5-23.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "GameOverLayyer.h"
#import "HelloWorldLayer.h"


@implementation GameOverLayyer

+ (CCScene*) scene
{
    CCScene *scene = [CCScene node];
    GameOverLayyer *layer = [GameOverLayyer node];
    [scene addChild:layer];
    
    return scene;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"You Lost!" fontName:@"Marker Felt" fontSize:80];
        label.position = ccp(winSize.width*0.5f,winSize.height*0.5f);
        [self addChild:label];

        
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:3],[CCCallFunc actionWithTarget:self selector:@selector(gameOverDone)], nil]];
    }
    
    return self;
}



- (void) gameOverDone
{
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}

@end

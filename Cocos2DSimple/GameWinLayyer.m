//
//  GameWinLayyer.m
//  Cocos2DSimple
//
//  Created by panda zheng on 13-5-23.
//  Copyright 2013年 __MyCompanyName__. All rights reserved.
//

#import "GameWinLayyer.h"
#import "HelloWorldLayer.h"

@implementation GameWinLayyer

+ (CCScene *) scene
{
    CCScene *scene = [CCScene node];
    GameWinLayyer *layyer = [GameWinLayyer node];
    [scene addChild:layyer];
    
    return scene;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        CCSprite *imgBg = [CCSprite spriteWithFile:@"bj2.png"];
        imgBg.position = ccp(0.0f,0.0f);
        [self addChild:imgBg];
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"You Win!" fontName:@"Marker Felt" fontSize:80];
        label.position = ccp(winSize.width*0.5f,winSize.height*0.5f);
        [self addChild:label];
        
        
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:3],[CCCallFunc actionWithTarget:self selector:@selector(gameWinDone)], nil]];
    }
    return self;
}
- (void) gameWinDone
{
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];
}

@end

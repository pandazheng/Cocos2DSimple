//
//  HelloWorldLayer.h
//  Cocos2DSimple
//
//  Created by panda zheng on 13-5-23.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    NSMutableArray *_targets;
    NSMutableArray *_projectiles;
    int _projectilesDestroyed;
}

- (void) pauseGame;

@property (nonatomic,assign) NSMutableArray *_targets;
@property (nonatomic,assign) NSMutableArray *_projectiles;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end

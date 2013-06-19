//
//  HelloWorldLayer.m
//  Cocos2DSimple
//
//  Created by panda zheng on 13-5-23.
//  Copyright __MyCompanyName__ 2013年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "SimpleAudioEngine.h"
#import "GameOverLayyer.h"
#import "GameWinLayyer.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer
@synthesize _targets,_projectiles;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void) spriteMoveFinished: (id) sender
{
    CCSprite *sprite = (CCSprite *) sender;
    [self removeChild:sprite cleanup:YES];
    
    if (sprite.tag == 1)
    {
        [_targets removeObject:sprite];
        [[CCDirector sharedDirector] replaceScene:[GameOverLayyer scene]];
    }
}

- (void) addTarget
{
    CCSprite *target = [CCSprite spriteWithFile:@"Target.png" rect:CGRectMake(0, 0, 27, 40)];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minY = target.contentSize.height*0.5f;
    int maxY = winSize.height - target.contentSize.height*0.5f;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    target.position = ccp(winSize.width + (target.contentSize.width*0.5),actualY);
    [self addChild:target];
    
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    id actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(-target.contentSize.width*0.5f,actualY)];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
    [target runAction:[CCSequence actions:actionMove,actionMoveDone, nil]];
    target.tag = 1;
    [_targets addObject:target];
}

- (void) gameLogic: (ccTime) dt
{
    [self addTarget];
}

- (void) pauseGame
{
    NSLog(@"Paused!");
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCSprite *imageBg = [CCSprite spriteWithFile:@"bj2.png"];
        imageBg.position = ccp(winSize.width*0.5f,winSize.height*0.5f);
        [self addChild:imageBg];
        CCSprite *player = [CCSprite spriteWithFile:@"Player.png" rect:CGRectMake(0, 0, 27, 40)];
        player.position = ccp(10,winSize.height*0.5f);
        [self addChild:player];
        
        self.isTouchEnabled = YES;
        
        _targets = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];
        
        [self schedule:@selector(gameLogic:) interval:1.0];
        [self schedule:@selector(update:)];

        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-acc.caf"];
	}
	return self;
}

- (void) update: (ccTime) dt
{
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    for (CCSprite *projectile in _projectiles)
    {
		CGRect projectileRect = CGRectMake(projectile.position.x - (projectile.contentSize.width/2),
										   projectile.position.y - (projectile.contentSize.height/2),
										   projectile.contentSize.width,
										   projectile.contentSize.height);
        
		NSMutableArray *targetsToDelete = [[NSMutableArray alloc] init];
		for (CCSprite *target in _targets) {
			CGRect targetRect = CGRectMake(target.position.x - (target.contentSize.width/2),
										   target.position.y - (target.contentSize.height/2),
										   target.contentSize.width,
										   target.contentSize.height);
            
			if (CGRectIntersectsRect(projectileRect, targetRect)) {
				[targetsToDelete addObject:target];
			}						
		}
        
        for (CCSprite *target in targetsToDelete)
        {
            [_targets removeObject:target];
            [self removeChild:target cleanup:YES];
            _projectilesDestroyed++;
            if (_projectilesDestroyed > 30)
            {
                [[CCDirector sharedDirector] replaceScene:[GameWinLayyer scene]];
            }
        }
        if  (targetsToDelete.count > 0)
        {
            [projectilesToDelete addObject:projectile];
        }
        [targetsToDelete release];
    }

    for(CCSprite *projectile in projectilesToDelete)
    {
        [_projectiles removeObject:projectile];
        [self removeChild:projectile cleanup:YES];
    }
    [projectilesToDelete release];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
	// Choose one of the touches to work with
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:[touch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	
	// Set up initial location of projectile
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	CCSprite *projectile = [CCSprite spriteWithFile:@"Projectile.png" rect:CGRectMake(0, 0, 20, 20)];
	projectile.position = ccp(20, winSize.height/2);
	
	// Determine offset of location to projectile
	int offX = location.x - projectile.position.x;
	int offY = location.y - projectile.position.y;
	
	// Bail out if we are shooting down or backwards
	if (offX <= 0) return;
    
    // Ok to add now - we've double checked position
    [self addChild:projectile];
    
	// Play a sound!
	[[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
	
	// Determine where we wish to shoot the projectile to
	int realX = winSize.width + (projectile.contentSize.width/2);
	float ratio = (float) offY / (float) offX;
	int realY = (realX * ratio) + projectile.position.y;
	CGPoint realDest = ccp(realX, realY);
	
	// Determine the length of how far we're shooting
	int offRealX = realX - projectile.position.x;
	int offRealY = realY - projectile.position.y;
	float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
	float velocity = 480/1; // 480pixels/1sec
	float realMoveDuration = length/velocity;
	
	// Move projectile to actual endpoint
	[projectile runAction:[CCSequence actions:
						   [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
						   [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
						   nil]];
	
	// Add to projectiles array
	projectile.tag = 2;
	[_projectiles addObject:projectile];
	
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
    [_targets release];
    _targets = nil;
    [_projectiles release];
    _projectiles = nil;
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end

//
//  Timer.h
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timer : NSObject

@property (strong) NSString *uid;
@property (strong) NSString *name;
@property (assign) BOOL countUp;
@property (assign) BOOL countDown;
@property (assign) NSUInteger fromTime;
@property (strong) NSMutableArray *startOnTimerStart;
@property (strong) NSMutableArray *startOnTimerStop;
@property (strong) NSMutableArray *stopOnTimerStart;
@property (strong) NSMutableArray *stopOnTimerStop;

@property (assign) NSUInteger currentValue;
@property (assign) BOOL running;

-(void) loadFromDictionary:(NSDictionary *)dict;
-(NSDictionary *) saveToDictionary;
-(NSString *) toXMLString;

@end

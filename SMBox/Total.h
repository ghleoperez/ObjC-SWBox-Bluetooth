//
//  Total.h
//  SMBox
//
//  Created by Alisa Nekrasova on 08/08/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Total : NSObject

@property (strong) NSString *uid;
@property (strong) NSString *name;
@property (strong) NSMutableArray *timers;

@property (readonly) time_t totalTime;

-(void) loadFromDictionary:(NSDictionary *)dict;
-(NSDictionary *) saveToDictionary;
-(NSString *) toXMLString;

@end

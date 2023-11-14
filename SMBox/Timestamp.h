//
//  Timestamp.h
//  SMBox
//
//  Created by Alisa Nekrasova on 08/08/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timestamp : NSObject

@property (strong) NSString *uid;
@property (strong) NSString *name;
@property (strong) NSMutableArray *startOnRecord;
@property (strong) NSMutableArray *stopOnRecord;

@property (assign) time_t currentValue;

-(void) loadFromDictionary:(NSDictionary *)dict;
-(NSDictionary *) saveToDictionary;
-(NSString *) toXMLString;

@end

//
//  Project.h
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Timer.h"
#import "Timestamp.h"
#import "Total.h"

@interface Project : NSObject

@property (strong) NSString *shortName;				// Short name of the timer
@property (strong) NSString *longName;				// Full name of the timer
//@property (assign) BOOL useStartEndTime;			// Use start/end times
@property (strong) NSString *emailRecipient;		// E-mail of recepiend (used when tapping on e-mail button)
@property (strong) NSString *displayImage;			// Image to display on projects list
@property (strong) UIColor *displayColor;			// Color to display on projects list
@property (strong) NSMutableArray *timer;			// List of timers
@property (strong) NSMutableArray *timestamp;		// List of timestamps
@property (strong) NSMutableArray *total;			// List of totals
@property (strong) NSMutableArray *order;			// Order of items on production configuration screen (0+ - timers, 1000+ - timestamps, 2000+ - totals, -1 - start time, -2 - end time, -3 - total)
@property (assign) time_t startTime;				// Recorded start time
@property (assign) time_t endTime;					// Recorded end time
@property (assign) BOOL currentTimeShown;			// Current time is shown on projects page

-(Timer *) timerWithUID:(NSString *)uid;
-(Timestamp *) timestampWithUID:(NSString *)uid;
-(Total *) totalWithUID:(NSString *)uid;

-(void) start;
-(void) stop;
-(void) tick;
-(void) tick:(int)ticks;

-(NSString *) timeToString:(NSInteger)t;
-(NSString *) systemTimeToTimeString:(time_t)t;

-(void) loadFromDictionary:(NSDictionary *)dict;
-(NSDictionary *) saveToDictionary;
-(NSString *) toXMLString;

-(NSString *) toString;

@end

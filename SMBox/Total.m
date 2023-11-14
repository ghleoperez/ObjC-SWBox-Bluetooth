//
//  Total.m
//  SMBox
//
//  Created by Alisa Nekrasova on 08/08/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import "Total.h"
#import "Timer.h"
#import "AppDelegate.h"

@implementation Total

-(id)init
{
	self = [super init];
	if (self)
	{
		_uid = [[NSString alloc] initWithFormat:@"%ld_%d", time(NULL), rand()];
		_timers = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) loadFromDictionary:(NSDictionary *)dict
{
	_uid = [[dict objectForKey:@"uid"] copy];
	_name = [[dict objectForKey:@"name"] copy];
	_timers = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"timers"]];
}

-(NSDictionary *) saveToDictionary
{
	return [[NSDictionary alloc] initWithObjectsAndKeys:
			_name, @"name",
			_uid, @"uid",
			_timers, @"timers",
			nil];
}

-(time_t) totalTime
{
	time_t result = 0;
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	Project *proj = appDelegate.activeProject;
	for (NSString *t_uid in _timers)
	{
		Timer *tmr = [proj timerWithUID:t_uid];
		if (tmr)
			result += tmr.currentValue;
	}
	return result;
}

-(NSString *) toXMLString
{
	NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"<total uid=\"%@\" name=\"%@\">",
								  _uid, _name];
	for (NSString *t_uid in _timers)
	{
		[result appendFormat:@"<incTimer uid=\"%@\" />", t_uid];
	}
	[result appendString:@"</total>"];
	return result;
}

@end

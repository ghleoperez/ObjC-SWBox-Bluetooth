//
//  Timer.m
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import "Timer.h"

@implementation Timer

-(id)init
{
	self = [super init];
	if (self)
	{
		_uid = [[NSString alloc] initWithFormat:@"%ld_%d", time(NULL), rand()];
		_startOnTimerStart = [[NSMutableArray alloc] init];
		_startOnTimerStop = [[NSMutableArray alloc] init];
		_stopOnTimerStart = [[NSMutableArray alloc] init];
		_stopOnTimerStop = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) loadFromDictionary:(NSDictionary *)dict
{
	_uid = [[dict objectForKey:@"uid"] copy];
	_name = [[dict objectForKey:@"name"] copy];
	_countUp = [[dict objectForKey:@"countUp"] boolValue];
	_countDown = [[dict objectForKey:@"countDown"] boolValue];
	_fromTime = [[dict objectForKey:@"fromTime"] unsignedIntegerValue];
	_currentValue = [[dict objectForKey:@"currentValue"] unsignedIntegerValue];
	_startOnTimerStart = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"startOnTimerStart"]];
	_startOnTimerStop = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"startOnTimerStop"]];
	_stopOnTimerStart = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"stopOnTimerStart"]];
	_stopOnTimerStop = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"stopOnTimerStop"]];
}

-(NSDictionary *) saveToDictionary
{
	return [[NSDictionary alloc] initWithObjectsAndKeys:
			_name, @"name",
			_uid, @"uid",
			[NSNumber numberWithBool:_countUp], @"countUp",
			[NSNumber numberWithBool:_countDown], @"countDown",
			[NSNumber numberWithUnsignedInteger:_fromTime], @"fromTime",
			[NSNumber numberWithUnsignedInteger:_currentValue], @"currentValue",
			_startOnTimerStart, @"startOnTimerStart",
			_startOnTimerStop, @"startOnTimerStop",
			_stopOnTimerStart, @"stopOnTimerStart",
			_stopOnTimerStop, @"stopOnTimerStop",
			nil];
}

-(NSString *) toXMLString
{
	int iCountUp = _countUp ? 1 : 0;
	int iCountDown = _countDown ? 1 : 0;
	NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"<timer uid=\"%@\" name=\"%@\" countUp=\"%d\" countDown=\"%d\" fromTime=\"%lu\" currentValue=\"%lu\">", _uid, _name, iCountUp, iCountDown, _fromTime, _currentValue];

	for (NSString *s in _startOnTimerStart)
		[result appendFormat:@"<startOnTimerStart uid=\"%@\" />", s];
	for (NSString *s in _startOnTimerStop)
		[result appendFormat:@"<startOnTimerStop uid=\"%@\" />", s];
	for (NSString *s in _stopOnTimerStart)
		[result appendFormat:@"<stopOnTimerStart uid=\"%@\" />", s];
	for (NSString *s in _stopOnTimerStop)
		[result appendFormat:@"<stopOnTimerStop uid=\"%@\" />", s];
	[result appendString:@"</timer>"];
	return result;
}

@end

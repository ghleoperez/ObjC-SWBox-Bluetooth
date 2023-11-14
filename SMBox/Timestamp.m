//
//  Timestamp.m
//  SMBox
//
//  Created by Alisa Nekrasova on 08/08/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import "Timestamp.h"

@implementation Timestamp

-(id)init
{
	self = [super init];
	if (self)
	{
		_uid = [[NSString alloc] initWithFormat:@"%ld_%d", time(NULL), rand()];
		_startOnRecord = [[NSMutableArray alloc] init];
		_stopOnRecord = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) loadFromDictionary:(NSDictionary *)dict
{
	_uid = [[dict objectForKey:@"uid"] copy];
	_name = [[dict objectForKey:@"name"] copy];
	_startOnRecord = [[NSMutableArray alloc] initWithArray: [dict objectForKey:@"startOnRecord"]];
	_stopOnRecord = [[NSMutableArray alloc] initWithArray: [dict objectForKey:@"stopOnRecord"]];
	_currentValue = [[dict objectForKey:@"currentValue"] unsignedLongValue];
}

-(NSDictionary *) saveToDictionary
{
	return [[NSDictionary alloc] initWithObjectsAndKeys:
			_name, @"name",
			_uid, @"uid",
			_startOnRecord, @"startOnRecord",
			_stopOnRecord, @"stopOnRecord",
			[NSNumber numberWithUnsignedLong:_currentValue], @"currentValue",
			nil];
}

-(NSString *) toXMLString
{
	NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"<timestamp uid=\"%@\" name=\"%@\" currentValue=\"%ld\">",
								  _uid, _name, _currentValue];
	for (NSString *s in _startOnRecord)
		[result appendFormat:@"<startOnRecord uid=\"%@\" />", s];
	for (NSString *s in _stopOnRecord)
		[result appendFormat:@"<stopOnRecord uid=\"%@\" />", s];
	[result appendString:@"</timestamp>"];
	return result;
}

@end

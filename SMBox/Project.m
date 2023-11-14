//
//  Project.m
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import "Project.h"
#include <time.h>

@interface Project()
{
	BOOL _started;
}
@end

@implementation Project

-(id) init
{
	self = [super init];
	if (self)
	{
		_timer = [[NSMutableArray alloc] init];
		_total = [[NSMutableArray alloc] init];
		_timestamp = [[NSMutableArray alloc] init];
		_order = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) tick
{
	for (Timer *timer in _timer)
	{
		if (timer.running)
			++timer.currentValue;
	}
}

-(void) tick:(int)ticks
{
	for (Timer *timer in _timer)
	{
		if (timer.running)
			timer.currentValue += ticks;
	}
}

-(void) loadFromDictionary:(NSDictionary *)dict
{
	_shortName = [[NSString alloc] initWithString: [dict valueForKey:@"shortName"]];
	_longName = [[NSString alloc] initWithString: [dict valueForKey:@"longName"]];
	//_useStartEndTime = [(NSNumber *)[dict valueForKey:@"useStartEndTime"] boolValue];
	_emailRecipient = [[NSString alloc] initWithString: [dict valueForKey:@"emailRecipient"]];
	_displayImage = [dict valueForKey:@"displayImage"] ? [[NSString alloc] initWithString: [dict valueForKey:@"displayImage"]] : [[NSString alloc] init];
	_displayColor = [UIColor colorWithRed:[(NSNumber *)[dict valueForKey:@"displayColorR"] floatValue]
									green:[(NSNumber *)[dict valueForKey:@"displayColorG"] floatValue]
									 blue:[(NSNumber *)[dict valueForKey:@"displayColorB"] floatValue]
									alpha:[(NSNumber *)[dict valueForKey:@"displayColorA"] floatValue]];
	_startTime = (time_t)[(NSNumber *)[dict valueForKey:@"startTime"] longLongValue];
	_endTime = (time_t)[(NSNumber *)[dict valueForKey:@"endTime"] longLongValue];
	[_timer removeAllObjects];
	[_timestamp removeAllObjects];
	[_total removeAllObjects];
	[_order removeAllObjects];
	NSArray *arr = [dict valueForKey:@"timers"];
	for (NSDictionary *d in arr)
	{
		Timer *t = [[Timer alloc] init];
		[t loadFromDictionary:d];
		[_timer addObject:t];
	}
	arr = [dict valueForKey:@"totals"];
	for (NSDictionary *d in arr)
	{
		Total *t = [[Total alloc] init];
		[t loadFromDictionary:d];
		[_total addObject:t];
	}
	arr = [dict valueForKey:@"timestamps"];
	for (NSDictionary *d in arr)
	{
		Timestamp *ts = [[Timestamp alloc] init];
		[ts loadFromDictionary:d];
		[_timestamp addObject:ts];
	}
	arr = [dict valueForKey:@"order"];
	for (NSNumber *num in arr)
	{
		if ([num intValue] < 0)
			continue;
		
		[_order addObject:num];
	}
	if ([dict objectForKey:@"currentTimeShown"])
		_currentTimeShown = [[dict valueForKeyPath:@"currentTimeShown"] boolValue];
	else
		_currentTimeShown = NO;
}

-(NSDictionary *) saveToDictionary
{
	CGFloat red;
	CGFloat green;
	CGFloat blue;
	CGFloat alpha;
	[_displayColor getRed:&red green:&green blue:&blue alpha:&alpha];
	
	NSMutableArray *arr_timers = [[NSMutableArray alloc] initWithCapacity:_timer.count];
	for (Timer *timer in _timer)
		[arr_timers addObject:[timer saveToDictionary]];

	NSMutableArray *arr_totals = [[NSMutableArray alloc] initWithCapacity:_total.count];
	for (Total *total in _total)
		[arr_totals addObject:[total saveToDictionary]];

	NSMutableArray *arr_timestamps = [[NSMutableArray alloc] initWithCapacity:_timestamp.count];
	for (Timestamp *timestamp in _timestamp)
		[arr_timestamps addObject:[timestamp saveToDictionary]];

	return [[NSDictionary alloc] initWithObjectsAndKeys:
			_shortName, @"shortName",
			_longName, @"longName",
			//[NSNumber numberWithBool:_useStartEndTime], @"useStartEndTime",
			_emailRecipient, @"emailRecipient",
			_displayImage ? _displayImage : @"", @"displayImage",
			[NSNumber numberWithFloat:red], @"displayColorR",
			[NSNumber numberWithFloat:green], @"displayColorG",
			[NSNumber numberWithFloat:blue], @"displayColorB",
			[NSNumber numberWithFloat:alpha], @"displayColorA",
			[NSNumber numberWithUnsignedLongLong:_startTime], @"startTime",
			[NSNumber numberWithUnsignedLongLong:_endTime], @"endTime",
			_order, @"order",
			arr_timers, @"timers",
			arr_timestamps, @"timestamps",
			arr_totals, @"totals",
			[NSNumber numberWithBool:_currentTimeShown], @"currentTimeShown",
			nil];
}

-(NSString *) timeToString:(NSInteger)t
{
	long lt = (long)t;
	if (lt >= 0)
		return [[NSString alloc] initWithFormat:@"%ld:%02ld:%02ld", lt / 3600, (lt / 60) % 60, lt % 60];
	else
		return [[NSString alloc] initWithFormat:@"-%ld:%02ld:%02ld", -lt / 3600, (-lt / 60) % 60, -lt % 60];
}

-(NSString *) systemTimeToDateString:(time_t)t
{
	char buff[64];
	strftime(buff, 64, "%d %b %Y", localtime(&t));
	return [[NSString alloc] initWithUTF8String:buff];
}

-(NSString *) systemTimeToTimeString:(time_t)t
{
	char buff[64];
	//strftime(buff, 64, "%H:%M:%S", localtime(&t));
	strftime(buff, 64, "%I:%M %p", localtime(&t));
	return [[NSString alloc] initWithUTF8String:buff];
}

-(NSString *) toString
{
	NSMutableString *str = [[NSMutableString alloc] init];
	[str appendFormat:@"Project: %@\n\n", _longName];

	time_t nowtime = 0;
	nowtime = time(&nowtime);

	[str appendFormat:@"Date: %@\n", [self systemTimeToDateString:nowtime]];
	/*
	if (_useStartEndTime)
	{
		if (_startTime)
			[str appendFormat:@"Start Time: %@\n", [self systemTimeToTimeString:_startTime]];
		else
			[str appendString:@"Start Time: (not set)\n"];
		if (_endTime)
			[str appendFormat:@"End Time: %@\n", [self systemTimeToTimeString:_endTime]];
		else
			[str appendString:@"End Time: (not set)\n"];
	}
	 */
	
	[str appendString:@"\n"];
	
	for (NSNumber *ord in _order)
	{
		int iOrd = [ord intValue];
		if (iOrd >= 0)
		{
			if (iOrd < 1000)
			{
				if (iOrd < _timer.count)
				{
					Timer *timer = [_timer objectAtIndex:iOrd];
					[str appendFormat:@"%@: %@\n", timer.name, [self timeToString:timer.currentValue]];
				}
			}
			else if (iOrd < 2000)
			{
				if (iOrd - 1000 < _timestamp.count)
				{
					Timestamp *ts = [_timestamp objectAtIndex:iOrd - 1000];
					NSString *stringFromDate = (ts.currentValue > 0) ? [self systemTimeToTimeString:ts.currentValue] : @"not set";
					/*
					NSDate *date = [NSDate dateWithTimeIntervalSince1970:ts.currentValue];
					
					NSCalendar *calendar = [NSCalendar currentCalendar];
					
					NSDateComponents *componentsForFirstDate = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];
					NSDateComponents *componentsForSecondDate = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];

					NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
					if (([componentsForFirstDate year] == [componentsForSecondDate year]) &&
						([componentsForFirstDate month] == [componentsForSecondDate month]) &&
						([componentsForFirstDate day] == [componentsForSecondDate day])) {
						formatter.dateStyle = NSDateFormatterNoStyle;
					}
					else
						formatter.dateStyle = NSDateFormatterShortStyle;

					formatter.timeStyle = NSDateFormatterMediumStyle;
					
					NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
					[formatter setLocale:usLocale];
					
					NSString *stringFromDate = [formatter stringFromDate:date];
					*/
					[str appendFormat:@"%@: %@\n", ts.name, stringFromDate];
				}
			}
			else
			{
				if (iOrd - 2000 < _total.count)
				{
					Total *total = [_total objectAtIndex:iOrd - 2000];
					[str appendFormat:@"%@: %@\n", total.name, [self timeToString:total.totalTime]];
				}
			}
		}
	}
	
	[str appendString:@"\nRecorded and Sent from SMBox for iOS\nGet your SMBox today at http://backstageapps.com\n"];
	
	return str;
}

-(void) start
{
	_started = YES;
}

-(void) stop
{
	_started = NO;
}

-(Timer *) timerWithUID:(NSString *)uid
{
	for (Timer *t in _timer)
	{
		if ([t.uid isEqualToString:uid])
			return t;
	}
	
	return nil;
}

-(Timestamp *) timestampWithUID:(NSString *)uid
{
	for (Timestamp *ts in _timestamp)
	{
		if ([ts.uid isEqualToString:uid])
			return ts;
	}
	
	return nil;
}

-(Total *) totalWithUID:(NSString *)uid
{
	for (Total *t in _total)
	{
		if ([t.uid isEqualToString:uid])
			return t;
	}
	
	return nil;
}

-(NSString *) toXMLString
{
	//int iUseStartEndTime = _useStartEndTime ? 1 : 0;
	int iCurrentTimeShown = _currentTimeShown ? 1 : 0;
	NSMutableString *strOrder = [[NSMutableString alloc] init];
	BOOL firstOrder = YES;
	for (NSNumber *ord in _order)
	{
		if (firstOrder)
			firstOrder = NO;
		else
			[strOrder appendString:@","];
		[strOrder appendFormat:@"%@", ord];
	}
	int iColor = 0;
	NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"<project shortName=\"%@\" longName=\"%@\" emailRecipient=\"%@\" displayImage=\"%@\" displayColor=\"%d\" startTime=\"%ld\" endTime=\"%ld\" currentTimeShown=\"%d\" order=\"%@\">", _shortName, _longName, _emailRecipient, _displayImage, iColor, _startTime, _endTime, iCurrentTimeShown, strOrder];
	for (Timer *t in _timer)
		[result appendString:t.toXMLString];
	for (Timestamp *ts in _timestamp)
		[result appendString:ts.toXMLString];
	for (Total *t in _total)
		[result appendString:t.toXMLString];
	[result appendString:@"</project>"];
	return result;
}

@end

//
//  Projects.m
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import "Projects.h"
#import "Project.h"
#import "AppDelegate.h"

@implementation Projects

-(NSString *) getFileName
{
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *plistPath = [rootPath stringByAppendingPathComponent:[@"projects" stringByAppendingString:@".plist"]];
	return plistPath;
}

-(id)init
{
	self = [super init];
	if (self)
	{
		[self loadFromFile];
	}
	return self;
}

-(void)loadFromFile
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self getFileName]])
	{
		// Read file
		NSArray *arr = [[NSArray alloc] initWithContentsOfFile:[self getFileName]];
		_project = [[NSMutableArray alloc] initWithCapacity:arr.count];
		for (NSDictionary *d in arr)
		{
			Project *p = [[Project alloc] init];
			[p loadFromDictionary:d];
			[_project addObject:p];
		}
	}
	else
	{
		// Create emply
		_project = [[NSMutableArray alloc] init];
	}
}

-(void)saveToFile
{
	NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:_project.count];
	for (Project *p in _project)
		[arr addObject:[p saveToDictionary]];
	[arr writeToFile:[self getFileName] atomically:YES];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLong:time(NULL)] forKey:@"last_use"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)sendToServer
{
	NSString *txt = self.toXMLString;
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.userMgr saveData:txt];
}

-(NSString *)toXMLString
{
	NSMutableString *result = [[NSMutableString alloc] initWithString:@"<smbox version=\"2.0\">"];
	for (Project *p in _project)
		[result appendString:p.toXMLString];
	[result appendString:@"</smbox>"];
	return result;
}

@end

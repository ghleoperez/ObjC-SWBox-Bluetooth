//
//  ParserViewController.m
//  SMBox
//
//  Created by Alisa Nekrasova on 09/02/15.
//  Copyright (c) 2015 LVWebGuy. All rights reserved.
//

#import "ParserViewController.h"
#import "AppDelegate.h"

@interface ParserViewController ()
{
	NSXMLParser *xmlParser;
	BOOL errorParsing;
	NSMutableArray *arrStack;
}
@end

@implementation ParserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doParsing:(NSString *)data {
	errorParsing = NO;
	arrStack = [[NSMutableArray alloc] init];
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.projects.project removeAllObjects];
	
	xmlParser = [[NSXMLParser alloc] initWithData:[data dataUsingEncoding:NSUTF8StringEncoding]];
	[xmlParser setDelegate:self];
	
	[xmlParser setShouldProcessNamespaces:NO];
	[xmlParser setShouldReportNamespacePrefixes:NO];
	[xmlParser setShouldResolveExternalEntities:NO];
	
	[xmlParser parse];
}

#pragma mark - Parser
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
	NSString *errorString = [NSString stringWithFormat:@"Error code %li", [parseError code]];
	NSLog(@"Error parsing XML: %@", errorString);
	
	errorParsing = YES;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if (errorParsing)
		return;
	
	if ([elementName isEqualToString:@"smbox"])
	{
		// Root element
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		[arrStack addObject:appDelegate.projects.project];
	}
	else if ([elementName isEqualToString:@"project"])
	{
		// Project
		NSMutableArray *arrProjects = [arrStack lastObject];
		Project *p = [[Project alloc] init];
		p.shortName = [attributeDict objectForKey:@"shortName"];
		p.longName = [attributeDict objectForKey:@"longName"];
		//p.useStartEndTime = ([[attributeDict objectForKey:@"useStartEndTime"] intValue] > 0);
		p.emailRecipient = [attributeDict objectForKey:@"emailRecipient"];
		p.displayImage = [attributeDict objectForKey:@"displayImage"];
		long dcolor = (long)[[attributeDict objectForKey:@"displayColor"] longLongValue];
		CGFloat dcolor_a = ((dcolor >> 24) & 0xFF) * 0.003921568627451;
		CGFloat dcolor_r = ((dcolor >> 16) & 0xFF) * 0.003921568627451;
		CGFloat dcolor_g = ((dcolor >> 8) & 0xFF) * 0.003921568627451;
		CGFloat dcolor_b = (dcolor & 0xFF) * 0.003921568627451;
		p.displayColor = [UIColor colorWithRed:dcolor_r green:dcolor_g blue:dcolor_b alpha:dcolor_a];
		p.startTime = (long)[[attributeDict objectForKey:@"startTime"] longLongValue];
		p.endTime = (long)[[attributeDict objectForKey:@"endTime"] longLongValue];
		NSString *order = [attributeDict objectForKey:@"order"];
		if (order.length > 0)
		{
			NSArray *arrOrder = [order componentsSeparatedByString:@","];
			for (NSString *ord in arrOrder)
			{
				if (ord.length > 0)
					[p.order addObject:[NSNumber numberWithInteger:[ord integerValue]]];
			}
		}
		[arrProjects addObject:p];
		[arrStack addObject:p];
	}
	else if ([elementName isEqualToString:@"timer"])
	{
		// Timer
		Project *p = [arrStack lastObject];
		Timer *t = [[Timer alloc] init];
		t.uid = [attributeDict objectForKey:@"uid"];
		t.name = [attributeDict objectForKey:@"name"];
		t.countUp = ([[attributeDict objectForKey:@"countUp"] intValue] > 0);
		t.countDown = ([[attributeDict objectForKey:@"countDown"] intValue] > 0);
		t.fromTime = (long)[[attributeDict objectForKey:@"fromTime"] longLongValue];
		t.currentValue = (long)[[attributeDict objectForKey:@"currentValue"] longLongValue];
		[p.timer addObject:t];
		[arrStack addObject:t];
	}
	else if ([elementName isEqualToString:@"timestamp"])
	{
		// Timestamp
		Project *p = [arrStack lastObject];
		Timestamp *ts = [[Timestamp alloc] init];
		ts.uid = [attributeDict objectForKey:@"uid"];
		ts.name = [attributeDict objectForKey:@"name"];
		ts.currentValue = (long)[[attributeDict objectForKey:@"currentValue"] longLongValue];
		[p.timestamp addObject:ts];
		[arrStack addObject:ts];
	}
	else if ([elementName isEqualToString:@"total"])
	{
		// Total
		Project *p = [arrStack lastObject];
		Total *t = [[Total alloc] init];
		t.uid = [attributeDict objectForKey:@"uid"];
		t.name = [attributeDict objectForKey:@"name"];
		[p.total addObject:t];
		[arrStack addObject:t];
	}
	else if ([elementName isEqualToString:@"startOnTimerStart"])
	{
		// Id of timer or timestamp to start when timer starts (inside a Timer)
		Timer *t = [arrStack lastObject];
		[t.startOnTimerStart addObject:[attributeDict objectForKey:@"uid"]];
	}
	else if ([elementName isEqualToString:@"startOnTimerStop"])
	{
		// Id of timer or timestamp to start when timer stops (inside a Timer)
		Timer *t = [arrStack lastObject];
		[t.startOnTimerStop addObject:[attributeDict objectForKey:@"uid"]];
	}
	else if ([elementName isEqualToString:@"stopOnTimerStart"])
	{
		// Id of timer to stop when timer starts (inside a Timer)
		Timer *t = [arrStack lastObject];
		[t.stopOnTimerStart addObject:[attributeDict objectForKey:@"uid"]];
	}
	else if ([elementName isEqualToString:@"stopOnTimerStop"])
	{
		// Id of timer to stop when timer stops (inside a Timer)
		Timer *t = [arrStack lastObject];
		[t.stopOnTimerStop addObject:[attributeDict objectForKey:@"uid"]];
	}
	else if ([elementName isEqualToString:@"startOnRecord"])
	{
		// Id of timer to start when timestamp is recorded (inside a Timestamp)
		Timestamp *ts = [arrStack lastObject];
		[ts.startOnRecord addObject:[attributeDict objectForKey:@"uid"]];
	}
	else if ([elementName isEqualToString:@"stopOnRecord"])
	{
		// Id of timer to stop when timestamp is recorded (inside a Timestamp)
		Timestamp *ts = [arrStack lastObject];
		[ts.stopOnRecord addObject:[attributeDict objectForKey:@"uid"]];
	}
	else if ([elementName isEqualToString:@"incTimer"])
	{
		// Id of timer included in Total (inside a Total)
		Total *t = [arrStack lastObject];
		[t.timers addObject:[attributeDict objectForKey:@"uid"]];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	if (errorParsing)
		return;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if (errorParsing)
		return;
	
	if ([elementName isEqualToString:@"smbox"])
	{
		// Root element
	}
	else if ([elementName isEqualToString:@"project"])
	{
		// Project
		[arrStack removeLastObject];
	}
	else if ([elementName isEqualToString:@"timer"])
	{
		// Timer
		[arrStack removeLastObject];
	}
	else if ([elementName isEqualToString:@"timestamp"])
	{
		// Timestamp
		[arrStack removeLastObject];
	}
	else if ([elementName isEqualToString:@"total"])
	{
		// Total
		[arrStack removeLastObject];
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	if (errorParsing == NO)
	{
		NSLog(@"XML processing done!");
	} else {
		NSLog(@"Error occurred during XML processing");
	}
}

@end

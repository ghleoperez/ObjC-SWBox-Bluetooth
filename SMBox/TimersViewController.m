//
//  TimersViewController.m
//  SMBox
//
//  Created by Alisa Nekrasova on 06/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import "TimersViewController.h"
#import "AppDelegate.h"

@interface TimersViewController ()
{
	Project *_project;
	NSTimer *_timer;
	BOOL _inSwipe;
	BOOL _alertFromButton;
}
@end

@implementation TimersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.vcTimers = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setProject:(Project *)project
{
	_project = project;
	_lblHead.text = _project.longName;
	[_tvTimers reloadData];
	
	if (_project.currentTimeShown)
	{
		_lblHead.hidden = YES;
		_lblHeadTime.hidden = NO;
	}
	else
	{
		_lblHead.hidden = NO;
		_lblHeadTime.hidden = YES;
	}
	
	[self refreshCurrentTime];
	
	_timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(increaseTimerCount) userInfo:nil repeats:YES];
}

-(IBAction)showHideCurrentTime:(id)sender
{
	_project.currentTimeShown = !_project.currentTimeShown;
	if (_project.currentTimeShown)
	{
		_lblHead.hidden = YES;
		_lblHeadTime.hidden = NO;
	}
	else
	{
		_lblHead.hidden = NO;
		_lblHeadTime.hidden = YES;
	}
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.projects saveToFile];
}

-(void)increaseTimerCount
{
	if (!_project)
		return;
	
	if (!_inSwipe)
		[_tvTimers reloadData];
	
	[self refreshCurrentTime];
}

-(void)refreshCurrentTime
{
	time_t t = time(NULL);
	char buff[64];
	strftime(buff, 64, "%I:%M:%S %p", localtime(&t));
	
	_lblHeadTime.text = [NSString stringWithUTF8String:buff];
}

-(IBAction)backToProduction:(id)sender
{
	[self stopAllTimers];
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (appDelegate.firstProduction)
		[self dismissViewControllerAnimated:YES completion:nil];
	else
		[self performSegueWithIdentifier:@"TimersToProduction" sender:self];
	[appDelegate.vcProduction setProject:_project];
}

-(IBAction)backToProjects:(id)sender
{
	[self stopAllTimers];
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.projects saveToFile];
	[appDelegate.projects sendToServer];
	[_project stop];
	appDelegate.activeProject = nil;
	if (!appDelegate.firstProduction)
		[self dismissViewControllerAnimated:YES completion:nil];
	else
	{
		[self dismissViewControllerAnimated:NO completion:^{
			[appDelegate.vcProduction dismissViewControllerAnimated:NO completion:nil];
		}];
	}
}

-(IBAction)sendEMail:(id)sender
{
	if ([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
		controller.mailComposeDelegate = self;
		NSArray *arrEMails = [[_project.emailRecipient stringByReplacingOccurrencesOfString:@";" withString:@","] componentsSeparatedByString:@","];
		[controller setToRecipients:arrEMails];
		[controller setSubject:[NSString stringWithFormat:@"[SMBox] %@", _project.longName]];
		
		[controller setMessageBody:[_project toString] isHTML:NO];
		if (controller)
			[self presentViewController:controller animated:YES completion:nil];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't compose e-mail" message:@"Can't compose e-mail on this device. Please, check internet connection and mail accounts" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell
{
	// Swipe started
	_inSwipe = YES;
}

- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell
{
	// Swipe ended
	_inSwipe = NO;
}

// Table
- (void) fillCell:(UIView *)view withTimer:(Timer *)timer
{
	if (!view || !view.subviews)
		return;
	
	for (UIView *v in view.subviews)
	{
		if ([v isKindOfClass:[UILabel class]])
		{
			UILabel *label = (UILabel *)v;
			if (v.tag == 1)
			{
				label.text = timer.name;
			}
			else if (v.tag == 3)
			{
				label.hidden = !timer.countUp;
				label.text = [_project timeToString:timer.currentValue];
				if (timer.running)
					label.textColor = [UIColor greenColor];
				else
					label.textColor = [UIColor grayColor];
			}
			else if (v.tag == 2)
			{
				label.hidden = !timer.countDown;
				label.text = [_project timeToString:timer.fromTime - timer.currentValue];
				if (timer.running)
					label.textColor = [UIColor redColor];
				else
					label.textColor = [UIColor grayColor];
			}
		}
		else
			[self fillCell:v withTimer:timer];
	}
}

- (void) fillCellWithStartEndTime:(UIView *)view isEnd:(BOOL)isEnd
{
	if (!view || !view.subviews)
		return;
	
	for (UIView *v in view.subviews)
	{
		if ([v isKindOfClass:[UILabel class]])
		{
			UILabel *label = (UILabel *)v;
			if (v.tag == 0)
			{
				if (isEnd)
					label.text = @"End Time";
				else
					label.text = @"Start Time";
			}
			else if (v.tag == 3)
			{
				if (isEnd)
				{
					if (_project.endTime)
					{
						label.text = [_project systemTimeToTimeString:_project.endTime];
						label.hidden = NO;
					}
					else
						label.hidden = YES;
				}
				else
				{
					if (_project.startTime)
					{
						label.text = [_project systemTimeToTimeString:_project.startTime];
						label.hidden = NO;
					}
					else
						label.hidden = YES;
				}
			}
		}
		else
			[self fillCellWithStartEndTime:v isEnd:isEnd];
	}
}

- (void) fillCell:(UIView *)view withTimestamp:(Timestamp *)ts
{
	if (!view || !view.subviews)
		return;
	
	for (UIView *v in view.subviews)
	{
		if ([v isKindOfClass:[UILabel class]])
		{
			UILabel *label = (UILabel *)v;
			if (v.tag == 0)
			{
				label.text = ts.name;
			}
			else if (v.tag == 3)
			{
				if (ts.currentValue)
				{
					label.text = [_project systemTimeToTimeString:ts.currentValue];
					label.hidden = NO;
				}
				else
					label.hidden = YES;
			}
		}
		else
			[self fillCell:v withTimestamp:ts];
	}
}

- (void) fillCell:(UIView *)view withTotal:(Total *)total
{
	if (!view || !view.subviews)
		return;
	
	for (UIView *v in view.subviews)
	{
		if ([v isKindOfClass:[UILabel class]])
		{
			UILabel *label = (UILabel *)v;
			if (v.tag == 0)
			{
				label.text = total.name;
			}
			else if (v.tag == 3)
			{
				NSUInteger value = 0;
				for (NSString *t_uid in total.timers)
				{
					Timer *t = [_project timerWithUID:t_uid];
					if (!t)
						continue;
					
					value += t.currentValue;
				}
				
				label.text = [_project timeToString:value];
			}
		}
		else
			[self fillCell:v withTotal:total];
	}
}

- (UIView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!_project)
		return nil;
	
	int cnt = 0;
	for (NSNumber *ord in _project.order)
	{
		/*
		if (([ord intValue] == -1) && _project.useStartEndTime)
		{
			if (cnt == indexPath.row)
			{
				// Start Time
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTimestamp" forIndexPath:indexPath];
				[self fillCellWithStartEndTime:cell isEnd:NO];
				
				MCSwipeTableViewCell *mcCell = (MCSwipeTableViewCell *)cell;
				mcCell.defaultColor = [UIColor orangeColor];
				mcCell.delegate = self;
				mcCell.showsReorderControl = YES;
				[mcCell setDragElement:cell];
				
				UIView *checkView = [self viewWithImageName:(isPad() ? @"SwipeToReset" : @"SwipeToResetSm")];
				UIView *crossView = [self viewWithImageName:(isPad() ? @"Reset" : @"ResetSm")];
				
				[mcCell setSwipeGestureWithView:checkView color:[UIColor orangeColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
				 {
					 // Nothing to do
				 }];
				
				[mcCell setSwipeGestureWithView:crossView color:[UIColor redColor] mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState2 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
				 {
					 // Reset a timer
					 NSIndexPath *indexPath = [_tvTimers indexPathForCell:cell];
					 if (!indexPath)
						 return;
					 
					 if ((indexPath.row < 0) || (indexPath.row >= _project.order.count))
						 return;
					 
					 [self clearRow:[[_project.order objectAtIndex:indexPath.row] intValue] indexPath:indexPath];
				 }];

				return cell;
			}
			++cnt;
		}
		else if (([ord intValue] == -2) && _project.useStartEndTime)
		{
			if (cnt == indexPath.row)
			{
				// End Time
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTimestamp" forIndexPath:indexPath];
				[self fillCellWithStartEndTime:cell isEnd:YES];
				
				MCSwipeTableViewCell *mcCell = (MCSwipeTableViewCell *)cell;
				mcCell.defaultColor = [UIColor orangeColor];
				mcCell.delegate = self;
				mcCell.showsReorderControl = YES;
				[mcCell setDragElement:cell];
				
				UIView *checkView = [self viewWithImageName:isPad() ? @"SwipeToReset" : @"SwipeToResetSm"];
				UIView *crossView = [self viewWithImageName:isPad() ? @"Reset" : @"ResetSm"];
				
				[mcCell setSwipeGestureWithView:checkView color:[UIColor orangeColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
				 {
					 // Nothing to do
				 }];
				
				[mcCell setSwipeGestureWithView:crossView color:[UIColor redColor] mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState2 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
				 {
					 // Reset a timer
					 NSIndexPath *indexPath = [_tvTimers indexPathForCell:cell];
					 if (!indexPath)
						 return;
					 
					 if ((indexPath.row < 0) || (indexPath.row >= _project.order.count))
						 return;
					 
					 [self clearRow:[[_project.order objectAtIndex:indexPath.row] intValue] indexPath:indexPath];
				 }];

				return cell;
			}
			++cnt;
		}
		else */
		if (([ord intValue] >= 0) && ([ord intValue] < 1000))
		{
			if (cnt == indexPath.row)
			{
				// Timer
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTimer" forIndexPath:indexPath];
				[self fillCell:cell withTimer:[_project.timer objectAtIndex:[ord intValue]]];
				
				MCSwipeTableViewCell *mcCell = (MCSwipeTableViewCell *)cell;
				mcCell.defaultColor = [UIColor orangeColor];
				mcCell.delegate = self;
				mcCell.showsReorderControl = YES;
				[mcCell setDragElement:cell];
				
				UIView *checkView = nil;
				if (isPad())
					checkView = [self viewWithImageName:(UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? @"SwipeToResetPort" : @"SwipeToReset")];
				else
					checkView = [self viewWithImageName:@"SwipeToResetSm"];
				UIView *crossView = [self viewWithImageName:isPad() ? @"Reset" : @"ResetSm"];
				
				[mcCell setSwipeGestureWithView:checkView color:[UIColor orangeColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
				 {
					 // Nothing to do
				 }];
				
				[mcCell setSwipeGestureWithView:crossView color:[UIColor redColor] mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState2 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
				 {
					 // Reset a timer
					 NSIndexPath *indexPath = [_tvTimers indexPathForCell:cell];
					 if (!indexPath)
						 return;
					 
					 if ((indexPath.row < 0) || (indexPath.row >= _project.order.count))
						 return;

					 [self clearRow:[[_project.order objectAtIndex:indexPath.row] intValue] indexPath:indexPath];
				 }];
				
				return cell;
			}
			++cnt;
		}
		else if (([ord intValue] >= 1000) && ([ord intValue] < 2000))
		{
			if (cnt == indexPath.row)
			{
				// Timestamp
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTimestamp" forIndexPath:indexPath];
				[self fillCell:cell withTimestamp:[_project.timestamp objectAtIndex:[ord intValue] - 1000]];
				
				MCSwipeTableViewCell *mcCell = (MCSwipeTableViewCell *)cell;
				mcCell.defaultColor = [UIColor orangeColor];
				mcCell.delegate = self;
				mcCell.showsReorderControl = YES;
				[mcCell setDragElement:cell];
				
				UIView *checkView = nil;
				if (isPad())
					checkView = [self viewWithImageName:(UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? @"SwipeToResetPort" : @"SwipeToReset")];
				else
					checkView = [self viewWithImageName:@"SwipeToResetSm"];
				UIView *crossView = [self viewWithImageName:isPad() ? @"Reset" : @"ResetSm"];
				
				[mcCell setSwipeGestureWithView:checkView color:[UIColor orangeColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
				 {
					 // Nothing to do
				 }];
				
				[mcCell setSwipeGestureWithView:crossView color:[UIColor redColor] mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState2 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
				 {
					 // Reset a timer
					 NSIndexPath *indexPath = [_tvTimers indexPathForCell:cell];
					 if (!indexPath)
						 return;
					 
					 if ((indexPath.row < 0) || (indexPath.row >= _project.order.count))
						 return;
					 
					 [self clearRow:[[_project.order objectAtIndex:indexPath.row] intValue] indexPath:indexPath];
				 }];
				
				return cell;
			}
			++cnt;
		}
		else if ([ord intValue] >= 2000)
		{
			if (cnt == indexPath.row)
			{
				// Total
				UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTotal" forIndexPath:indexPath];
				[self fillCell:cell withTotal:[_project.total objectAtIndex:[ord intValue] - 2000]];
								
				return cell;
			}
			++cnt;
		}
	}
	
	return nil;
}

- (void)clearRow:(int)row indexPath:(NSIndexPath *)indexPath
{
	/*
	if (row == -2)
	{
		// Clear end time
		_project.endTime = 0;
	}
	else if (row == -1)
	{
		// Clear start time
		_project.startTime = 0;
	}
	else
	 */
	if ((row >= 0) && (row < 1000))
	{
		// Clear timer
		if (row >= _project.timer.count)
			return;
		
		Timer *t = [_project.timer objectAtIndex:row];
		if (!t)
			return;
		
		t.currentValue = 0;
	}
	else if ((row >= 1000) && (row < 2000))
	{
		// Clear timestamp
		if (row - 1000 >= _project.timestamp.count)
			return;
		
		Timestamp *ts = [_project.timestamp objectAtIndex:row - 1000];
		if (!ts)
			return;
		
		ts.currentValue = 0;
	}
	else if ((row >= 2000) && (row < 3000))
	{
		// Clear timer
		if (row - 2000 >= _project.total.count)
			return;
		
		Total *t = [_project.total objectAtIndex:row - 2000];
		if (!t)
			return;
	}
	else
		return;
	
	[_tvTimers reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (!_project)
		return 0;
	
	NSInteger cnt = 0;
	
	for (NSNumber *num in _project.order)
	{
		if ([num intValue] >= 0)
			++cnt;
		
		//if ((([num intValue] == -1) || ([num intValue] == -2)) && _project.useStartEndTime)
		//	++cnt;
		
		//if (([num intValue] == -3) && _project.showTotal)
		//	++cnt;
	}

	return cnt;
}

- (void)stopAllTimers
{
	[_timer invalidate];
	_timer = nil;
}

-(IBAction)clearAllTimers:(id)sender
{
	_alertFromButton = YES;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear all timers?" message:@"" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (_alertFromButton)
	{
		if (buttonIndex > 0)
		{
			for (Timer *t in _project.timer)
			{
				t.currentValue = 0;
				t.running = NO;
			}
			_project.startTime = 0;
			_project.endTime = 0;
			
			for (Timestamp *ts in _project.timestamp)
			{
				ts.currentValue = 0;
			}
		
			if (!_inSwipe)
				[_tvTimers reloadData];
		}
	}
	else
	{
		if (buttonIndex > 0)
		{
			for (Timer *t in _project.timer)
				t.running = NO;
		}
		_project.endTime = time(NULL);
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate.projects saveToFile];
		[appDelegate.projects sendToServer];

		if (!_inSwipe)
			[_tvTimers reloadData];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int cnt = 0;
	for (NSNumber *ord in _project.order)
	{
		/*if (([ord intValue] == -3) && _project.showTotal)
		{
			if (cnt == indexPath.row)
			{
				// Total
				return;
			}
			++cnt;
		}
		else if ([ord intValue] == -1)
		{
			if ((cnt == indexPath.row) && !_project.startTime)
			{
				// Set Start Time
				_project.startTime = time(NULL);
				[_tvTimers reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
				AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
				[appDelegate.projects saveToFile];
				[appDelegate.projects sendToServer];
			}
			++cnt;
		}
		else if ([ord intValue] == -2)
		{
			if ((cnt == indexPath.row) && !_project.endTime)
			{
				// Set End Time
				BOOL workingTimers = NO;
				for (Timer *t in _project.timer)
				{
					if (t.running)
					{
						workingTimers = YES;
						break;
					}
				}
				if (workingTimers)
				{
					_alertFromButton = NO;
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Stop all timers?" message:@"" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
					[alert show];
				}
				else
				{
					_project.endTime = time(NULL);
					[_tvTimers reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
					AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
					[appDelegate.projects saveToFile];
					[appDelegate.projects sendToServer];
				}
			}
			++cnt;
		}
		else */
		if (([ord intValue] >= 0) && ([ord intValue] < 1000))
		{
			if (cnt == indexPath.row)
			{
				// Timer
				Timer *t = [_project.timer objectAtIndex:[ord intValue]];
				if (t.running)
					[self stopTimer:t deep:0];
				else
					[self startTimer:t deep:0];
				
				AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
				[appDelegate.projects saveToFile];
				[appDelegate.projects sendToServer];

				return;
			}
			++cnt;
		}
		else if (([ord intValue] >= 1000) && ([ord intValue] < 2000))
		{
			if (cnt == indexPath.row)
			{
				// Timestamp
				Timestamp *ts = [_project.timestamp objectAtIndex:[ord intValue] - 1000];
				[self recordTimestamp:ts deep:0];

				AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
				[appDelegate.projects saveToFile];
				[appDelegate.projects sendToServer];

				return;
			}
			++cnt;
		}
	}
}

- (void)startTimer:(Timer *)t deep:(int)deep
{
	if (t.running || (deep >= 10))
		return;
	
	t.running = YES;
	
	for (NSString *s in t.startOnTimerStart)
	{
		Timer *t1 = [_project timerWithUID:s];
		if (t1)
		{
			[self startTimer:t1 deep:deep + 1];
			continue;
		}
		Timestamp *ts1 = [_project timestampWithUID:s];
		if (ts1)
			[self recordTimestamp:ts1 deep:deep + 1];
	}
	
	for (NSString *s in t.stopOnTimerStart)
	{
		Timer *t1 = [_project timerWithUID:s];
		if (t1)
			[self stopTimer:(Timer *)t1 deep:deep + 1];
	}
	
	if (!_inSwipe)
		[_tvTimers reloadData];

}

- (void)stopTimer:(Timer *)t deep:(int)deep
{
	if (!t.running || (deep >= 10))
		return;
	
	t.running = NO;
	
	for (NSString *s in t.startOnTimerStop)
	{
		Timer *t1 = [_project timerWithUID:s];
		if (t1)
		{
			[self startTimer:t1 deep:deep + 1];
			continue;
		}
		Timestamp *ts1 = [_project timestampWithUID:s];
		if (ts1)
			[self recordTimestamp:ts1 deep:deep + 1];
	}
	
	for (NSString *s in t.stopOnTimerStop)
	{
		Timer *t1 = [_project timerWithUID:s];
		if (t1)
			[self stopTimer:(Timer *)t1 deep:deep + 1];
	}
	
	if (!_inSwipe)
		[_tvTimers reloadData];
}

- (void)recordTimestamp:(Timestamp *)ts deep:(int)deep
{
	if (deep >= 10)
		return;
	
	ts.currentValue = time(NULL);
	if (!_inSwipe)
		[_tvTimers reloadData];
	
	for (NSString *s in ts.startOnRecord)
	{
		Timer *t1 = [_project timerWithUID:s];
		if (t1)
		{
			[self startTimer:t1 deep:deep + 1];
			continue;
		}
		Timestamp *ts1 = [_project timestampWithUID:s];
		if (ts1)
			[self recordTimestamp:ts1 deep:deep + 1];
	}
	
	for (NSString *s in ts.stopOnRecord)
	{
		Timer *t1 = [_project timerWithUID:s];
		if (t1)
			[self stopTimer:(Timer *)t1 deep:deep + 1];
	}
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
	if (isPad())
	    return UIInterfaceOrientationMaskAll;
	else
		return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end

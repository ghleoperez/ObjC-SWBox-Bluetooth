//
//  ProductionViewController.m
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import "ProductionViewController.h"
#import "MCSwipeTableViewCell.h"
#import "AppDelegate.h"
#import "ATSDragToReorderTableViewController.h"
#import "TimerEditCell.h"
#import "TimestampEditCell.h"
#import "TotalEditCell.h"

@interface ProductionViewController ()
{
	BOOL _inSwipe;
	Project *_project;
	NSInteger _editIndex;
	CGPoint _veryInitialTouchPoint;
	UILongPressGestureRecognizer *_longPressGestureRecognizer;
	ATSDragToReorderTableViewController *_ats;
	CGRect _viewNormalRect;
	CGSize _keyboardSize;
	UITapGestureRecognizer *_singleFingerTap;
	Timer *_selectedTimer;
	Timestamp *_selectedTimestamp;
	Total *_selectedTotal;
	BOOL _isStopMode;
}
@end

@implementation ProductionViewController

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
	appDelegate.vcProduction = self;
	
	_editIndex = -1;
	_viewNormalRect = _vTimers.frame;

	_ats = [[ATSDragToReorderTableViewController alloc] initWithTableView:_tvTimers];
	[_ats viewDidLoad];
	_ats.dragDelegate = self;
}

- (void)dragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController didEndDraggingToRow:(NSIndexPath *)destinationIndexPath
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setProject:(Project *)project
{
	_project = project;
	_editIndex = -1;
	
	_vAdd.hidden = YES;
	
	_lblHead.text = project.longName;
	[_tvTimers reloadData];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (textField.tag == 2)
	{
		BOOL showAlert = NO;
		
		NSArray *arr = [textField.text componentsSeparatedByString:@":"];
		if (arr.count == 0)
		{
			textField.text = @"0:00:00";
		}
		if (arr.count == 1)
		{
			// Seconds only
			if ([[arr objectAtIndex:0] integerValue] < 60)
				textField.text = [[NSString alloc] initWithFormat:@"0:00:%02ld", (long)[[arr objectAtIndex:0] integerValue]];
			else
			{
				NSString *text = [textField text];
				if (text.length == 0)
					textField.text = @"0:00:00";
				else if (text.length <= 2)
				{
					// Seconds
					if ([[arr objectAtIndex:0] integerValue] < 60)
						textField.text = [[NSString alloc] initWithFormat:@"0:00:%02ld", (long)[text integerValue]];
					else
					{
						textField.text = @"0:00:00";
						showAlert = YES;
					}
				}
				else if (text.length <= 4)
				{
					// Minutes and seconds
					int seconds = [text integerValue] % 100;
					int minutes = (int)([text integerValue] / 100);
					if ((seconds >= 60) || (minutes >= 60))
					{
						textField.text = @"0:00:00";
						showAlert = YES;
					}
					else
						textField.text = [[NSString alloc] initWithFormat:@"0:%02d:%02d", minutes, seconds];
				}
				else
				{
					// Hours, minutes and seconds
					int seconds = [text integerValue] % 100;
					int minutes = ([text integerValue] / 100) % 100;
					int hours = (int)([text integerValue] / 10000);
					if ((seconds >= 60) || (minutes >= 60))
					{
						textField.text = @"0:00:00";
						showAlert = YES;
					}
					else
						textField.text = [[NSString alloc] initWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
				}
			}
		}
		else if (arr.count == 2)
		{
			// Minutes and seconds
			if (([[arr objectAtIndex:0] integerValue] < 60) && ([[arr objectAtIndex:1] integerValue] < 60))
				textField.text = [[NSString alloc] initWithFormat:@"0:%02ld:%02ld", (long)[[arr objectAtIndex:0] integerValue], (long)[[arr objectAtIndex:1] integerValue]];
			else
			{
				textField.text = @"0:00:00";
				showAlert = YES;
			}
		}
		else if (arr.count == 3)
		{
			// Hours, minutes and seconds
			if (([[arr objectAtIndex:1] integerValue] < 60) && ([[arr objectAtIndex:2] integerValue] < 60))
				textField.text = [[NSString alloc] initWithFormat:@"%ld:%02ld:%02ld", (long)[[arr objectAtIndex:0] integerValue], (long)[[arr objectAtIndex:1] integerValue], (long)[[arr objectAtIndex:2] integerValue]];
			else
			{
				textField.text = @"0:00:00";
				showAlert = YES;
			}
		}
		else
		{
			textField.text = @"0:00:00";
			showAlert = YES;
		}
		
		if (showAlert)
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Incorrect format" message:@"Write time in format H:MM:SS or HMMSS" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alertView show];
		}
		else
		{
			NSArray *arr = [textField.text componentsSeparatedByString:@":"];
			if (arr.count == 3)
			{
				NSInteger hours = [[arr objectAtIndex:0] integerValue];
				NSInteger minutes = [[arr objectAtIndex:1] integerValue];
				NSInteger seconds = [[arr objectAtIndex:2] integerValue];
				
				if ((_editIndex >= 0) && (_editIndex < _project.order.count))
				{
					int idx = [[_project.order objectAtIndex:_editIndex] intValue];
					if ((idx >= 0) && (idx < _project.timer.count))
					{
						Timer *timer = [_project.timer objectAtIndex:idx];
						timer.fromTime = (NSUInteger)(((hours * 60) + minutes) * 60 + seconds);
					}
				}
			}
		}
	}
}

- (NSInteger) getDeviceWidth
{
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
		return self.view.frame.size.width;
	else
		return self.view.frame.size.height;
}

-(IBAction)addObject:(id)sender
{
	if (_editIndex >= 0)
		return;
	
	CGRect frm = _vAdd.frame;
	frm.origin.x = 10 + [self getDeviceWidth];
	[_vAdd setFrame:frm];
	_vAdd.hidden = NO;
	
	[UIView animateWithDuration:0.3
					 animations:^{
						 CGRect frm = _vAdd.frame;
						 frm.origin.x = 10;
						 [_vAdd setFrame:frm];
					 }
					 completion:^(BOOL finished) {
						 
					 }];
	
	_singleFingerTap =
	[[UITapGestureRecognizer alloc] initWithTarget:self
											action:@selector(handleSingleTap:)];
	[self.view addGestureRecognizer:_singleFingerTap];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)object
{
	UIView *v = nil;
	
	if (!_vAdd.hidden)
		v = _vAdd;
	else if (!_onStartStopView.hidden)
		v = _onStartStopView;
	else if (!_onTimersUpdateView.hidden)
		v = _onTimersUpdateView;
	else
		return;
	
	for (NSUInteger pointIndex = 0; pointIndex < [object numberOfTouches]; ++pointIndex)
	{
		CGPoint touchPoint = [object locationOfTouch:pointIndex inView:v];
		if ((touchPoint.x < 0) ||
			(touchPoint.y < 0) ||
			(touchPoint.x >= v.frame.size.width) ||
			(touchPoint.y >= v.frame.size.height))
		{
			[self removeFrame];
			break;
		}
	}
}

-(void)removeFrame
{
	if (_singleFingerTap)
	{
		[self.view removeGestureRecognizer:_singleFingerTap];
		_singleFingerTap = nil;
	}

	UIView *v = nil;
	
	if (!_vAdd.hidden)
		v = _vAdd;
	else if (!_onStartStopView.hidden)
		v = _onStartStopView;
	else if (!_onTimersUpdateView.hidden)
		v = _onTimersUpdateView;
	else
		return;
	
	[UIView animateWithDuration:0.3
					 animations:^{
						 CGRect frm = v.frame;
						 frm.origin.x = 10 - [self getDeviceWidth];
						 [v setFrame:frm];
					 }
					 completion:^(BOOL finished) {
						 v.hidden = YES;
					 }];
}

-(IBAction)addTimer:(id)sender
{
	[self removeFrame];
	
	if (_editIndex >= 0)
		return;
	
	// Add a timer
	Timer *timer = [[Timer alloc] init];
	timer.name = @"";
	timer.countUp = YES;
	timer.countDown = NO;
	timer.fromTime = 0;
	[_project.timer addObject:timer];
	
	// Add it to an order
	int position = -1;
	int pos = 0;
	for (NSNumber *ord in _project.order)
	{
		if ([ord intValue] >= 0)
			position = pos + 1;
		++pos;
	}
	if (position == -1)
		position = (int)_project.order.count;
	
	[_project.order insertObject:[NSNumber numberWithInt:(int)_project.timer.count - 1] atIndex:position];
	
	_editIndex = position;
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:position inSection:0];
	[_tvTimers insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
	[_tvTimers scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(IBAction)addTimeStamp:(id)sender
{
	[self removeFrame];
	
	if (_editIndex >= 0)
		return;
	
	// Add a timestamp
	Timestamp *timestamp = [[Timestamp alloc] init];
	timestamp.name = @"";
	[_project.timestamp addObject:timestamp];
	
	// Add it to an order
	int position = -1;
	int pos = 0;
	for (NSNumber *ord in _project.order)
	{
		if ([ord intValue] >= 0)
			position = pos + 1;
		++pos;
	}
	
	if (position == -1)
		position = (int)_project.order.count;
	
	[_project.order insertObject:[NSNumber numberWithInt:(int)_project.timestamp.count - 1 + 1000] atIndex:position];
	
	_editIndex = position;
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:position inSection:0];
	[_tvTimers insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
	[_tvTimers scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(IBAction)addTotal:(id)sender
{
	[self removeFrame];
	
	if (_editIndex >= 0)
		return;
	
	// Add a total
	Total *total = [[Total alloc] init];
	total.name = @"";
	[_project.total addObject:total];
	
	// Add it to an order
	int position = -1;
	int pos = 0;
	for (NSNumber *ord in _project.order)
	{
		if ([ord intValue] >= 0)
			position = pos + 1;
		++pos;
	}

	if (position == -1)
		position = (int)_project.order.count;
	
	[_project.order insertObject:[NSNumber numberWithInt:(int)_project.total.count - 1 + 2000] atIndex:position];
	
	_editIndex = position;
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:position inSection:0];
	[_tvTimers insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
	[_tvTimers scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(IBAction)back:(id)sender
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.projects saveToFile];
	[appDelegate.projects sendToServer];
	[_project stop];
	appDelegate.activeProject = nil;
	if (appDelegate.firstProduction)
		[self dismissViewControllerAnimated:YES completion:nil];
	else
	{
		[self dismissViewControllerAnimated:NO completion:^{
			[appDelegate.vcTimers dismissViewControllerAnimated:NO completion:nil];
		}];
	}
}

// Table
- (UIView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
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

- (void)deleteCell:(UITableViewCell *)cell
{
	NSIndexPath *indexPath = [_tvTimers indexPathForCell:cell];
	if (indexPath.section != 0)
		return;

	if ((indexPath.row < 0) || (indexPath.row >= _project.order.count))
		return;
	
	int projectIdx = [[_project.order objectAtIndex:indexPath.row] intValue];
	[_project.order removeObjectAtIndex:indexPath.row];
	
	// Decrease all higher project numbers
	NSUInteger objIdx = 0;
	NSMutableArray *newOrder = [[NSMutableArray alloc] initWithCapacity:_project.order.count];
	for (NSNumber *ord in _project.order)
	{
		if (([ord intValue] > projectIdx) && ([ord intValue] / 1000 == projectIdx / 1000))
			[newOrder addObject:[[NSNumber alloc] initWithInt:[ord intValue] - 1]];
		else
			[newOrder addObject:[[NSNumber alloc] initWithInt:[ord intValue]]];
			
		++objIdx;
	}
	_project.order = newOrder;
	
	if (projectIdx < 1000)
		[_project.timer removeObjectAtIndex:projectIdx];
	else if (projectIdx < 2000)
		[_project.timestamp removeObjectAtIndex:projectIdx - 1000];
	else
		[_project.total removeObjectAtIndex:projectIdx - 2000];
	
    [_tvTimers deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.projects saveToFile];
	[appDelegate.projects sendToServer];
}

- (UIView *)getCellForObject:(UIView *)obj
{
	if (!obj)
		return nil;
	
	UIView *cell = obj.superview;
	while (cell && ![cell isKindOfClass:[UITableViewCell class]])
		cell = cell.superview;
	
	return cell;
}

-(IBAction)editTimer:(id)sender
{
	UIButton *button = (UIButton *)sender;
	UIView *cell = [self getCellForObject:button];
	
	if (cell)
	{
		MCSwipeTableViewCell *mcCell = (MCSwipeTableViewCell *)cell;
		NSIndexPath *indexPath = [_tvTimers indexPathForCell:mcCell];
		if ((indexPath.row < 0) || (indexPath.row >= _project.order.count))
			return;

		NSIndexPath *extraIndex = nil;
		if (_editIndex == indexPath.row)
		{
			// Stop editing
			int projectIdx = [[_project.order objectAtIndex:indexPath.row] intValue];

			Timer *t = [_project.timer objectAtIndex:projectIdx];
			[self storeTimer:t fromCell:mcCell];
			//if (!t.includeInTotal && t.countDown)
			//	t.countUp = NO;
			AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			[appDelegate.projects saveToFile];
			[appDelegate.projects sendToServer];
			_editIndex = -1;
		}
		else
		{
			if ((_editIndex >= 0) && (_editIndex != indexPath.row))
				extraIndex = [NSIndexPath indexPathForRow:_editIndex inSection:0];

			// Start editing
			_editIndex = indexPath.row;
		}
		if (extraIndex)
			[_tvTimers reloadRowsAtIndexPaths:@[indexPath, extraIndex] withRowAnimation:UITableViewRowAnimationFade];
		else
			[_tvTimers reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

-(IBAction)editTimestamp:(id)sender
{
	UIButton *button = (UIButton *)sender;
	UIView *cell = [self getCellForObject:button];
	
	if (cell)
	{
		MCSwipeTableViewCell *mcCell = (MCSwipeTableViewCell *)cell;
		NSIndexPath *indexPath = [_tvTimers indexPathForCell:mcCell];
		if ((indexPath.row < 0) || (indexPath.row >= _project.order.count))
			return;
		
		NSIndexPath *extraIndex = nil;
		if (_editIndex == indexPath.row)
		{
			// Stop editing
			int projectIdx = [[_project.order objectAtIndex:indexPath.row] intValue];
			
			Timestamp *ts = [_project.timestamp objectAtIndex:projectIdx - 1000];
			[self storeTimestamp:ts fromCell:mcCell];
			
			AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			[appDelegate.projects saveToFile];
			[appDelegate.projects sendToServer];
			_editIndex = -1;
		}
		else
		{
			if ((_editIndex >= 0) && (_editIndex != indexPath.row))
				extraIndex = [NSIndexPath indexPathForRow:_editIndex inSection:0];
			
			// Start editing
			_editIndex = indexPath.row;
		}
		if (extraIndex)
			[_tvTimers reloadRowsAtIndexPaths:@[indexPath, extraIndex] withRowAnimation:UITableViewRowAnimationFade];
		else
			[_tvTimers reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

-(IBAction)editTotal:(id)sender
{
	UIButton *button = (UIButton *)sender;
	UIView *cell = [self getCellForObject:button];
	
	if (cell)
	{
		MCSwipeTableViewCell *mcCell = (MCSwipeTableViewCell *)cell;
		NSIndexPath *indexPath = [_tvTimers indexPathForCell:mcCell];
		if ((indexPath.row < 0) || (indexPath.row >= _project.order.count))
			return;
		
		NSIndexPath *extraIndex = nil;
		if (_editIndex == indexPath.row)
		{
			// Stop editing
			int projectIdx = [[_project.order objectAtIndex:indexPath.row] intValue];
			
			Total *t = [_project.total objectAtIndex:projectIdx - 2000];
			[self storeTotal:t fromCell:mcCell];

			AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			[appDelegate.projects saveToFile];
			[appDelegate.projects sendToServer];
			_editIndex = -1;
		}
		else
		{
			if ((_editIndex >= 0) && (_editIndex != indexPath.row))
				extraIndex = [NSIndexPath indexPathForRow:_editIndex inSection:0];
			
			// Start editing
			_editIndex = indexPath.row;
		}
		if (extraIndex)
			[_tvTimers reloadRowsAtIndexPaths:@[indexPath, extraIndex] withRowAnimation:UITableViewRowAnimationFade];
		else
			[_tvTimers reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)storeTimer:(Timer *)timer fromCell:(UIView *)view
{
	if (!view || !view.subviews)
		return;
	
	for (UIView *v in view.subviews)
	{
		if ([v isKindOfClass:[UILabel class]])
		{
			// Nothing to do
		}
		else if ([v isKindOfClass:[UIButton class]])
		{
			// Nothing to do
		}
		else if ([v isKindOfClass:[UITextField class]])
		{
			UITextField *tf = (UITextField *)v;
			[self textFieldDidEndEditing:tf];
			if (v.tag == 1)
				timer.name = [tf.text copy];
		}
		else if ([v isKindOfClass:[NKColorSwitch class]])
		{
			NKColorSwitch *swi = (NKColorSwitch *)v;
			if (v.tag == 1)
				timer.countUp = [swi isOn];
			else if (v.tag == 2)
				timer.countDown = [swi isOn];
		}
		else
			[self storeTimer:timer fromCell:v];
	}
}

- (void)storeTimestamp:(Timestamp *)ts fromCell:(UIView *)view
{
	if (!view || !view.subviews)
		return;
	
	for (UIView *v in view.subviews)
	{
		if ([v isKindOfClass:[UILabel class]])
		{
			// Nothing to do
		}
		else if ([v isKindOfClass:[UIButton class]])
		{
			// Nothing to do
		}
		else if ([v isKindOfClass:[UITextField class]])
		{
			UITextField *tf = (UITextField *)v;
			[self textFieldDidEndEditing:tf];
			if (v.tag == 1)
				ts.name = [tf.text copy];
		}
		else
			[self storeTimestamp:ts fromCell:v];
	}
}

- (void)storeTotal:(Total *)total fromCell:(UIView *)view
{
	if (!view || !view.subviews)
		return;
	
	for (UIView *v in view.subviews)
	{
		if ([v isKindOfClass:[UILabel class]])
		{
			// Nothing to do
		}
		else if ([v isKindOfClass:[UIButton class]])
		{
			// Nothing to do
		}
		else if ([v isKindOfClass:[UITextField class]])
		{
			UITextField *tf = (UITextField *)v;
			[self textFieldDidEndEditing:tf];
			if (v.tag == 1)
				total.name = [tf.text copy];
		}
		else
			[self storeTotal:total fromCell:v];
	}
}

- (void)refreshYellowSpotsInTimerCell:(UIView *)view withTimer:(Timer *)timer forEdit:(BOOL)edit
{
	if (!view || !view.subviews)
		return;
	
	for (UIView *v in view.subviews)
	{
		if ([v isKindOfClass:[UILabel class]])
		{
		}
		else if ([v isKindOfClass:[UIButton class]])
		{
		}
		else if ([v isKindOfClass:[UITextField class]])
		{
		}
		else if ([v isKindOfClass:[NKColorSwitch class]])
		{
		}
		else if ([v isKindOfClass:[UIImageView class]])
		{
			if (v.tag == 2)
			{
				v.hidden = !edit || ((timer.startOnTimerStart.count == 0) && (timer.stopOnTimerStart.count == 0));
			}
			else if (v.tag == 3)
			{
				v.hidden = !edit || ((timer.startOnTimerStop.count == 0) && (timer.stopOnTimerStop.count == 0));
			}
		}
		else
			[self refreshYellowSpotsInTimerCell:v withTimer:timer forEdit:edit];
	}
}

- (void)fillInStartEndCell:(UIView *)view isEnd:(BOOL)isEnd
{
	for (UIView *v in view.subviews)
	{
		if ([v isKindOfClass:[UILabel class]])
		{
			UILabel *label = (UILabel *)v;
			if (isEnd)
			{
				label.text = @"End Time (Tap to Record)";
			}
			else
			{
				label.text = @"Start Time (Tap to Record)";
			}
		}
		else if ([v isKindOfClass:[UIImageView class]])
		{
			UIImageView *img = (UIImageView *)v;
			_ats.touchArea = img.frame;
		}
		else
			[self fillInStartEndCell:v isEnd:isEnd];
	}
}

-(IBAction)goToTimers:(id)sender
{
	if (_editIndex >= 0)
		return;
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.projects saveToFile];
	[appDelegate.projects sendToServer];
	if (appDelegate.firstProduction)
		[self performSegueWithIdentifier:@"ProductionToTimers" sender:self];
	else
		[self dismissViewControllerAnimated:YES completion:nil];
	[appDelegate.vcTimers setProject:_project];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ((tableView == _onStartStopStart) || (tableView == _onStartStopStop) || (tableView == _onTimersUpdateTable))
	{
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		if (cell.accessoryType == UITableViewCellAccessoryNone)
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		else
			cell.accessoryType = UITableViewCellAccessoryNone;
		return NO;
	}
	else
		return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ((tableView == _onStartStopStart) || (tableView == _onStartStopStop) || (tableView == _onTimersUpdateTable))
	{
		[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
	}
	else if (tableView == _tvTimers)
	{
		if ((indexPath.row < 0) || (indexPath.row >= _project.order.count))
			return;
		
		int projIdx = [[_project.order objectAtIndex:indexPath.row] intValue];
		
		/*
		if (projIdx == -1)
		{
			// Set Start Time
			_project.startTime = time(NULL);
			[_tvTimers reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			[appDelegate.projects saveToFile];
			[appDelegate.projects sendToServer];
		}
		else if (projIdx == -2)
		{
			// Set End Time
			_project.endTime = time(NULL);
			[_tvTimers reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			[appDelegate.projects saveToFile];
			[appDelegate.projects sendToServer];
		}
		 */
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"Reloading cell at path %ld/%ld", indexPath.section, indexPath.row);
	
	if (tableView == _tvTimers)
	{
		if ((indexPath.row < 0) || (indexPath.row >= _project.order.count))
			return nil;
		
		int projIdx = [[_project.order objectAtIndex:indexPath.row] intValue];
		
		/*
		if ((projIdx == -1) || (projIdx == -2))
		{
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellStart"];
			[self fillInStartEndCell:cell isEnd:(projIdx == -2)];
			return cell;
		}
		else */
		if (projIdx < 1000)
		{
			// Timer
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTimer"];
			Timer *timer = (Timer *)[_project.timer objectAtIndex:projIdx];
			
			TimerEditCell *teCell = (TimerEditCell *)cell;
			[teCell setUpWithDelegate:self ats:_ats timer:timer];
			
			BOOL edit = (indexPath.row == _editIndex) ? YES : NO;
			[teCell setForEdit:edit fromSwitch:NO];
			
			UIView *checkView = nil;
			if (isPad())
				checkView = [self viewWithImageName:(UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? @"SwipeToDeletePort" : @"SwipeToDelete")];
			else
				checkView = [self viewWithImageName:@"SwipeToDeleteSm"];
			UIView *crossView = [self viewWithImageName:(isPad() ? @"Delete" : @"DeleteSm")];
			
			[teCell setSwipeGestureWithView:checkView color:[UIColor orangeColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
			 {
				 // Nothing to do
			 }];
			
			[teCell setSwipeGestureWithView:crossView color:[UIColor redColor] mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState2 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
			 {
				 // Delete a timer
				 [self deleteCell:cell];
			 }];
			
			return cell;
		}
		else if (projIdx < 2000)
		{
			// Timestamp
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTimestamp"];
			Timestamp *timestamp = [_project.timestamp objectAtIndex:projIdx - 1000];
			
			TimestampEditCell *teCell = (TimestampEditCell *)cell;
			[teCell setUpWithDelegate:self ats:_ats timestamp:timestamp];
			
			BOOL edit = (indexPath.row == _editIndex) ? YES : NO;
			[teCell setForEdit:edit];
			
			UIView *checkView = nil;
			if (isPad())
				checkView = [self viewWithImageName:(UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? @"SwipeToDeletePort" : @"SwipeToDelete")];
			else
				checkView = [self viewWithImageName:@"SwipeToDeleteSm"];
			UIView *crossView = [self viewWithImageName:(isPad() ? @"Delete" : @"DeleteSm")];
			
			[teCell setSwipeGestureWithView:checkView color:[UIColor orangeColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
			 {
				 // Nothing to do
			 }];
			
			[teCell setSwipeGestureWithView:crossView color:[UIColor redColor] mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState2 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
			 {
				 // Delete a timestamp
				 [self deleteCell:cell];
			 }];
			
			return cell;
		}
		else
		{
			// Total
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTotal"];
			Total *total = [_project.total objectAtIndex:projIdx - 2000];
			
			TotalEditCell *teCell = (TotalEditCell *)cell;
			[teCell setUpWithDelegate:self ats:_ats total:total];
			
			BOOL edit = (indexPath.row == _editIndex) ? YES : NO;
			[teCell setForEdit:edit];

			UIView *checkView = nil;
			if (isPad())
				checkView = [self viewWithImageName:(UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? @"SwipeToDeletePort" : @"SwipeToDelete")];
			else
				checkView = [self viewWithImageName:@"SwipeToDeleteSm"];
			UIView *crossView = [self viewWithImageName:(isPad() ? @"Delete" : @"DeleteSm")];
			
			[teCell setSwipeGestureWithView:checkView color:[UIColor orangeColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
			 {
				 // Nothing to do
			 }];
			
			[teCell setSwipeGestureWithView:crossView color:[UIColor redColor] mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState2 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
			 {
				 // Delete a timer
				 [self deleteCell:cell];
			 }];
			
			return cell;
		}
	}
	else if (tableView == _onStartStopStart)
	{
		// Show timers and timestamps
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timerStart"];
		
		if (_editIndex < 0)
		{
			cell.textLabel.text = @"";
			return cell;
		}
		
		int idx = 0;
		NSObject *selected = nil;
		
		int projectIdx = [[_project.order objectAtIndex:_editIndex] intValue];
		NSObject *curT = (projectIdx >= 1000) ? [_project.timestamp objectAtIndex:projectIdx - 1000] : [_project.timer objectAtIndex:projectIdx];
		
		for (Timer *t in _project.timer)
		{
			if (t == curT)
				continue;
			
			if (idx == indexPath.row)
			{
				selected = t;
				break;
			}
			
			++idx;
		}
		
		if (!selected)
		{
			for (Timestamp *ts in _project.timestamp)
			{
				if (ts == curT)
					continue;
				
				if (idx == indexPath.row)
				{
					selected = ts;
					break;
				}
				
				++idx;
			}
		}

		if (selected)
		{
			NSMutableArray *arr = nil;
			if ([curT isKindOfClass:[Timestamp class]])
			{
				Timestamp *curTs = (Timestamp *)curT;
				arr = curTs.startOnRecord;
			}
			else if ([curT isKindOfClass:[Timer class]])
			{
				Timer *curTmr = (Timer *)curT;
				arr = _isStopMode ? curTmr.startOnTimerStop : curTmr.startOnTimerStart;
			}
			else
				return cell;

			if ([selected isKindOfClass:[Timer class]])
			{
				Timer *t = (Timer *)selected;
				cell.textLabel.text = t.name;
				cell.accessoryType = UITableViewCellAccessoryNone;
				
				for (NSString *curt_ts in arr)
				{
					Timer *t1 = [_project timerWithUID:curt_ts];
					if (t1 && [t1.uid isEqualToString:t.uid])
					{
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
						break;
					}
				}

			}
			else if ([selected isKindOfClass:[Timestamp class]])
			{
				Timestamp *ts = (Timestamp *)selected;
				cell.textLabel.text = ts.name;
				
				for (NSString *curt_ts in arr)
				{
					Timestamp *ts1 = [_project timestampWithUID:curt_ts];
					if (ts1 && [ts1.uid isEqualToString:ts.uid])
					{
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
						break;
					}
				}
			}
			else
				cell.textLabel.text = @"";
		}
		else
			cell.textLabel.text = @"";
		
		return cell;
	}
	else if (tableView == _onStartStopStop)
	{
		// Show timers
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timerStop"];
		
		if (_editIndex < 0)
		{
			cell.textLabel.text = @"";
			return cell;
		}
		
		int idx = 0;
		Timer *selected = nil;
		
		int projectIdx = [[_project.order objectAtIndex:_editIndex] intValue];
		NSObject *curT = (projectIdx >= 1000) ? [_project.timestamp objectAtIndex:projectIdx - 1000] : [_project.timer objectAtIndex:projectIdx];
		
		for (Timer *t in _project.timer)
		{
			if (t == curT)
				continue;
			
			if (idx == indexPath.row)
			{
				selected = t;
				break;
			}
			
			++idx;
		}
		
		if (selected)
		{
			NSMutableArray *arr = nil;
			if (projectIdx >= 1000)
			{
				Timestamp *curTs = (Timestamp *)curT;
				arr = curTs.stopOnRecord;
			}
			else
			{
				Timer *curTmr = (Timer *)curT;
				arr = _isStopMode ? curTmr.stopOnTimerStop : curTmr.stopOnTimerStart;
			}
			
			cell.textLabel.text = selected.name;
			
			cell.accessoryType = UITableViewCellAccessoryNone;
			
			for (NSString *curt_ts in arr)
			{
				Timer *t1 = [_project timerWithUID:curt_ts];
				if (t1 && [t1.uid isEqualToString:selected.uid])
				{
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
					break;
				}
			}
		}
		else
			cell.textLabel.text = @"";
		
		return cell;
	}
	else if (tableView == _onTimersUpdateTable)
	{
		// Show timers
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timerInTotal"];
		
		if (_editIndex < 0)
		{
			cell.textLabel.text = @"";
			return cell;
		}
		
		int projectIdx = [[_project.order objectAtIndex:_editIndex] intValue];
		Total *curT = [_project.total objectAtIndex:projectIdx - 2000];
		
		Timer *selected = [_project.timer objectAtIndex:indexPath.row];

		if (selected)
		{
			cell.textLabel.text = selected.name;
			
			cell.accessoryType = UITableViewCellAccessoryNone;
			
			for (NSString *curt_ts in curT.timers)
			{
				Timer *t1 = [_project timerWithUID:curt_ts];
				if (t1 && [t1.uid isEqualToString:selected.uid])
				{
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
					break;
				}
			}
		}
		else
			cell.textLabel.text = @"";
		
		return cell;
	}
	else
		return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView == _tvTimers)
	{
		return _project.order.count;
	}
	else if (tableView == _onStartStopStart)
	{
		if (_editIndex < 0)
			return 0;
		return MAX((NSInteger)_project.timer.count + (NSInteger)_project.timestamp.count - 1, 0);
	}
	else if (tableView == _onStartStopStop)
	{
		if (_editIndex < 0)
			return 0;
		int projectIdx = [[_project.order objectAtIndex:_editIndex] intValue];
		if (projectIdx >= 1000)
			return _project.timer.count;
		else
			return MAX((NSInteger)_project.timer.count - 1, 0);
	}
	else if (tableView == _onTimersUpdateTable)
	{
		if (_editIndex < 0)
			return 0;
		return _project.timer.count;
	}
	else
		return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == _tvTimers)
	{
		if (_editIndex < 0)
			return isPad() ? 100.0f : 51.0f;
		
		if (indexPath.row == _editIndex)
		{
			if ([[_project.order objectAtIndex:indexPath.row] intValue] < 1000)
			{
				// Timers
				return isPad() ? 292.0f : 200.0f;
			}
			else if ([[_project.order objectAtIndex:indexPath.row] intValue] < 2000)
			{
				// Timestamps
				return isPad() ? 190.0f : 108.0f;
			}
			else
			{
				// Totals
				return isPad() ? 190.0f : 108.0f;
			}
		}
		else
			return isPad() ? 100.0f : 51.0f;
	}
	else if ((tableView == _onStartStopStart) || (tableView == _onStartStopStop))
	{
		return 36.0f;
	}
	else if (tableView == _onTimersUpdateTable)
	{
		return 36.0f;
	}
	else
		return 0;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	if (tableView == _tvTimers)
	{
		if ((fromIndexPath.row < 0) || (fromIndexPath.row >= _project.order.count))
			return;
		
		if ((toIndexPath.row < 0) || (toIndexPath.row >= _project.order.count))
			return;
		
		id el = [_project.order objectAtIndex:fromIndexPath.row];
		[_project.order removeObjectAtIndex:fromIndexPath.row];
		[_project.order insertObject:el atIndex:toIndexPath.row];
		
		if (_editIndex >= 0)
		{
			if (_editIndex == fromIndexPath.row)
				_editIndex = toIndexPath.row;
			else if ((_editIndex < fromIndexPath.row) && (_editIndex >= toIndexPath.row))
				++_editIndex;
			else if ((_editIndex > fromIndexPath.row) && (_editIndex <= toIndexPath.row))
				--_editIndex;
		}
		
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate.projects saveToFile];
		[appDelegate.projects sendToServer];
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return (tableView == _tvTimers);
}

-(void)keyboardWillShow:(NSNotification *)notification
{
	NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
	_keyboardSize = keyboardFrameBeginRect.size;
	
	[self setViewMovedUp:YES];
}

-(void)keyboardWillHide {
	[self setViewMovedUp:NO];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
	
	[textField resignFirstResponder];
    return YES;
}

- (UIView *)findFirstResponderForView:(UIView *)v
{
    if (v.isFirstResponder) {
        return v;
    }
    for (UIView *subView in v.subviews) {
        id responder = [self findFirstResponderForView:subView];
        if (responder) return responder;
    }
    return nil;
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
	
    CGRect rect = _viewNormalRect;
    if (movedUp)
    {
		_tvTimers.scrollEnabled = NO;
		UIView *firstResponder = [self findFirstResponderForView:_tvTimers];
		if (firstResponder)
		{
			float kbHeight = (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) ? _keyboardSize.width :  _keyboardSize.height;
			CGPoint relativePos = [firstResponder convertPoint:CGPointMake(0, 0) toView:_vTimers];
			if (relativePos.y > _vTimers.frame.size.height / 3)
			{
				float offset = relativePos.y - _vTimers.frame.size.height / 3;
				if (offset > kbHeight)
					offset = kbHeight;
        		rect.origin.y -= offset;
			}
		}
    }
    else
    {
        // revert back to the normal state.
		rect = _viewNormalRect;
		_tvTimers.scrollEnabled = YES;
    }
    _vTimers.frame = rect;
	
    [UIView commitAnimations];
}


- (void)viewWillAppear:(BOOL)animated
{
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillShowNotification
												  object:nil];
	
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification
												  object:nil];
}

-(IBAction)tutorial:(id)sender
{
	//AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate showTutorialInView:self.view controller:self];
	
	[self performSegueWithIdentifier:@"ProductionToHelp" sender:self];
}

-(void)showEditWindowForTimestamp:(Timestamp *)t
{
	_selectedTimestamp = t;
	[_onStartStopStart reloadData];
	[_onStartStopStop reloadData];
	
	_onStartStopHead.textColor = [UIColor yellowColor];
	_onStartStopHead.text = @"ON RECORD";
	_onStartStopWhen.text = [NSString stringWithFormat:@"When %@ is activated by tap or by logic, START the following Timers and record the following Timestamps:", (t.name.length ? t.name : @"the Timestamp")];
	[_onStartStopUpdate setTitle:@"UPDATE ON RECORD ITEMS" forState:UIControlStateNormal];
	
	CGRect frm = _onStartStopView.frame;
	frm.origin.x = 10 + [self getDeviceWidth];
	[_onStartStopView setFrame:frm];
	_onStartStopView.hidden = NO;
	
	[UIView animateWithDuration:0.3
					 animations:^{
						 CGRect frm = _onStartStopView.frame;
						 frm.origin.x = 10;
						 [_onStartStopView setFrame:frm];
					 }
					 completion:^(BOOL finished) {
						 
					 }];
	
	_singleFingerTap =
	[[UITapGestureRecognizer alloc] initWithTarget:self
											action:@selector(handleSingleTap:)];
	[self.view addGestureRecognizer:_singleFingerTap];

}

-(void)showEditWindowForTotal:(Total *)t
{
	_selectedTotal = t;
	[_onTimersUpdateTable reloadData];

	_onTimersUpdateMessage.text = [NSString stringWithFormat:@"%@ will include the following Timers whether running or stopped:", (t.name.length ? t.name : @"The Total")];
	
	CGRect frm = _onTimersUpdateView.frame;
	frm.origin.x = 10 + [self getDeviceWidth];
	[_onTimersUpdateView setFrame:frm];
	_onTimersUpdateView.hidden = NO;
	
	[UIView animateWithDuration:0.3
					 animations:^{
						 CGRect frm = _onTimersUpdateView.frame;
						 frm.origin.x = 10;
						 [_onTimersUpdateView setFrame:frm];
					 }
					 completion:^(BOOL finished) {
						 
					 }];
	
	_singleFingerTap =
	[[UITapGestureRecognizer alloc] initWithTarget:self
											action:@selector(handleSingleTap:)];
	[self.view addGestureRecognizer:_singleFingerTap];
	
}

-(void)showEditWindowForTimer:(Timer *)t isStop:(BOOL)isstop
{
	_selectedTimer = t;
	_isStopMode = isstop;
	[_onStartStopStart reloadData];
	[_onStartStopStop reloadData];
	if (isstop)
	{
		_onStartStopHead.textColor = [UIColor redColor];
		_onStartStopHead.text = @"ON STOP";
		_onStartStopWhen.text = [NSString stringWithFormat:@"When %@ is deactivated by tap or by logic, START the following Timers and record the following Timestamps:", (t.name.length ? t.name : @"the Timer")];
		[_onStartStopUpdate setTitle:@"UPDATE ON STOP ITEMS" forState:UIControlStateNormal];
	}
	else
	{
		_onStartStopHead.textColor = [UIColor greenColor];
		_onStartStopHead.text = @"ON START";
		_onStartStopWhen.text = [NSString stringWithFormat:@"When %@ is activated by tap or by logic, START the following Timers and record the following Timestamps:", (t.name.length ? t.name : @"the Timer")];
		[_onStartStopUpdate setTitle:@"UPDATE ON START ITEMS" forState:UIControlStateNormal];
	}

	CGRect frm = _onStartStopView.frame;
	frm.origin.x = 10 + [self getDeviceWidth];
	[_onStartStopView setFrame:frm];
	_onStartStopView.hidden = NO;
	
	[UIView animateWithDuration:0.3
					 animations:^{
						 CGRect frm = _onStartStopView.frame;
						 frm.origin.x = 10;
						 [_onStartStopView setFrame:frm];
					 }
					 completion:^(BOOL finished) {
						 
					 }];
	
	_singleFingerTap =
	[[UITapGestureRecognizer alloc] initWithTarget:self
											action:@selector(handleSingleTap:)];
	[self.view addGestureRecognizer:_singleFingerTap];
}

-(IBAction)editOnTimerStart:(id)sender
{
	UIButton *button = (UIButton *)sender;
	UIView *cell = [self getCellForObject:button];
	
	if (cell)
	{
		MCSwipeTableViewCell *mcCell = (MCSwipeTableViewCell *)cell;
		NSIndexPath *indexPath = [_tvTimers indexPathForCell:mcCell];
		if ((indexPath.row < 0) || (indexPath.row >= _project.order.count))
			return;
		
		if (_editIndex == indexPath.row)
		{
			int projectIdx = [[_project.order objectAtIndex:indexPath.row] intValue];
			Timer *t = [_project.timer objectAtIndex:projectIdx];
			[self showEditWindowForTimer:t isStop:NO];
		}
	}
}

-(IBAction)editTimersInTotal:(id)sender
{
	UIButton *button = (UIButton *)sender;
	UIView *cell = [self getCellForObject:button];
	
	if (cell)
	{
		MCSwipeTableViewCell *mcCell = (MCSwipeTableViewCell *)cell;
		NSIndexPath *indexPath = [_tvTimers indexPathForCell:mcCell];
		if ((indexPath.row < 0) || (indexPath.row >= _project.order.count))
			return;
		
		if (_editIndex == indexPath.row)
		{
			int projectIdx = [[_project.order objectAtIndex:indexPath.row] intValue];
			if (projectIdx >= 2000)
			{
				Total *t = [_project.total objectAtIndex:projectIdx - 2000];
				[self showEditWindowForTotal:t];
			}
		}
	}
}

-(IBAction)editOnTimerStop:(id)sender
{
	UIButton *button = (UIButton *)sender;
	UIView *cell = [self getCellForObject:button];
	
	if (cell)
	{
		MCSwipeTableViewCell *mcCell = (MCSwipeTableViewCell *)cell;
		NSIndexPath *indexPath = [_tvTimers indexPathForCell:mcCell];
		if ((indexPath.row < 0) || (indexPath.row >= _project.order.count))
			return;
		
		if (_editIndex == indexPath.row)
		{
			int projectIdx = [[_project.order objectAtIndex:indexPath.row] intValue];
			Timer *t = [_project.timer objectAtIndex:projectIdx];
			[self showEditWindowForTimer:t isStop:YES];
		}
	}
}

-(IBAction)editOnRecord:(id)sender
{
	UIButton *button = (UIButton *)sender;
	UIView *cell = [self getCellForObject:button];
	
	if (cell)
	{
		MCSwipeTableViewCell *mcCell = (MCSwipeTableViewCell *)cell;
		NSIndexPath *indexPath = [_tvTimers indexPathForCell:mcCell];
		if ((indexPath.row < 0) || (indexPath.row >= _project.order.count))
			return;
		
		if (_editIndex == indexPath.row)
		{
			int projectIdx = [[_project.order objectAtIndex:indexPath.row] intValue];
			Timestamp *ts = [_project.timestamp objectAtIndex:projectIdx - 1000];
			[self showEditWindowForTimestamp:ts];
		}
	}
}

-(IBAction)updateOnStartStop:(id)sender
{
	int projectIdx = [[_project.order objectAtIndex:_editIndex] intValue];
	if (projectIdx < 1000)
	{
		Timer *tmr = [_project.timer objectAtIndex:projectIdx];
		NSMutableArray *arr_start = _isStopMode ? tmr.startOnTimerStop : tmr.startOnTimerStart;
		NSMutableArray *arr_stop = _isStopMode ? tmr.stopOnTimerStop : tmr.stopOnTimerStart;
		if (arr_start && arr_stop)
		{
			[arr_start removeAllObjects];
			[arr_stop removeAllObjects];
			int idx = 0;
			for (Timer *t in _project.timer)
			{
				if (t == tmr)
					continue;
				
				if ([_onStartStopStart cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]].accessoryType == UITableViewCellAccessoryCheckmark)
					[arr_start addObject:t.uid];
				if ([_onStartStopStop cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]].accessoryType == UITableViewCellAccessoryCheckmark)
					[arr_stop addObject:t.uid];
				++idx;
			}
			
			for (Timestamp *ts in _project.timestamp)
			{
				if ([_onStartStopStart cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]].accessoryType == UITableViewCellAccessoryCheckmark)
					[arr_start addObject:ts.uid];
				//if ([_onStartStopStop cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]].accessoryType == UITableViewCellAccessoryCheckmark)
				//	[arr_stop addObject:ts.uid];
				
				++idx;
			}
		}
		UIView *cell = [_tvTimers cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_editIndex inSection:0]];
		[self refreshYellowSpotsInTimerCell:cell withTimer:tmr forEdit:YES];
	}
	else if (projectIdx < 2000)
	{
		Timestamp *tstamp = [_project.timestamp objectAtIndex:projectIdx - 1000];
		NSMutableArray *arr_start = tstamp.startOnRecord;
		NSMutableArray *arr_stop = tstamp.stopOnRecord;
		if (arr_start && arr_stop)
		{
			[arr_start removeAllObjects];
			[arr_stop removeAllObjects];
			int idx = 0;
			for (Timer *t in _project.timer)
			{
				if ([_onStartStopStart cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]].accessoryType == UITableViewCellAccessoryCheckmark)
					[arr_start addObject:t.uid];
				if ([_onStartStopStop cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]].accessoryType == UITableViewCellAccessoryCheckmark)
					[arr_stop addObject:t.uid];
				++idx;
			}
			
			for (Timestamp *ts in _project.timestamp)
			{
				if (ts == tstamp)
					continue;
				
				if ([_onStartStopStart cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]].accessoryType == UITableViewCellAccessoryCheckmark)
					[arr_start addObject:ts.uid];
				//if ([_onStartStopStop cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]].accessoryType == UITableViewCellAccessoryCheckmark)
				//	[arr_stop addObject:ts.uid];
				
				++idx;
			}
		}
	}
	[self removeFrame];
}

-(IBAction)updateTimerUpdate:(id)sender
{
	int projectIdx = [[_project.order objectAtIndex:_editIndex] intValue];
	if (projectIdx >= 2000)
	{
		Total *total = [_project.total objectAtIndex:projectIdx - 2000];
		NSMutableArray *arr = total.timers;
		if (arr)
		{
			[arr removeAllObjects];
			int idx = 0;
			for (Timer *t in _project.timer)
			{
				if ([_onTimersUpdateTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]].accessoryType == UITableViewCellAccessoryCheckmark)
					[arr addObject:t.uid];
				++idx;
			}
		}
	}
	[self removeFrame];
}

- (NSUInteger)supportedInterfaceOrientations{
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

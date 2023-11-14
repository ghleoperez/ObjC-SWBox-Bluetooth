//
//  ProjectsViewController.m
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import "ProjectsViewController.h"
#import "AppDelegate.h"
#import "Project.h"

#import <Crashlytics/Crashlytics.h>

@interface ProjectsViewController ()
{
	CGRect _addProjectNormalFrame;
	UILongPressGestureRecognizer *_longTap;
	NSUInteger _rowSelected;
	UIAlertView *_alert;
	UITapGestureRecognizer *_singleFingerTap;
	BOOL _tutorialScheduled;
	BOOL _loginStarted;
}
@end

@implementation ProjectsViewController

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
	appDelegate.vcProjects = self;
	
	_longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _longTap.minimumPressDuration = 1.0;
	
	_tutorialScheduled = NO;
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"NotFirstTime"])
	{
		_tutorialScheduled = YES;
		
		double delayInSeconds = 2.5;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			//code to be executed on the main queue after delay
			if (_tutorialScheduled)
				[self tutorial:self];
		});
		
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"NotFirstTime"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	_addProjectNormalFrame = _vAddProject.frame;
	if (isPad() && UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
	{
		_addProjectNormalFrame.size.width *= 0.742;
		_vAddProject.frame = _addProjectNormalFrame;
	}
	else
	{
		float diff = _addProjectNormalFrame.size.width * 0.05f;
		_addProjectNormalFrame.size.width -= diff;
		_addProjectNormalFrame.origin.x += diff * 0.5f;
		_vAddProject.frame = _addProjectNormalFrame;
	}

	[_cvProjects reloadData];
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	/*
	if (!_loginStarted)
	{
		// Check if already logged in
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		UserMgr *userMgr = appDelegate.userMgr;
		if ([userMgr userDetailsAreSaved:self]) {
			[userMgr restoreSession:self.view completion:^(bool loginSuccess) {
				if (loginSuccess) {
					[appDelegate.userMgr getMetadataWithCompletion:^(time_t remotetime, NSString *deviceType, NSString *appVersion) {
						time_t localtime = (time_t)[[[NSUserDefaults standardUserDefaults] objectForKey:@"last_use"] longValue];
						if (remotetime > localtime)
						{
							// Remote version is newer. Download and update
							[appDelegate.userMgr getDataWithCompletion:^(NSString *data) {
								// Parse data
								[self doParsing:data];
								
								[self dismissViewControllerAnimated:YES completion:nil];
							}];
						}
						else
						{
							[self dismissViewControllerAnimated:YES completion:nil];
						}
					}];
				}
				else {
					[userMgr clearUserDetails:self];
					[self performSegueWithIdentifier:@"GoToLogin" sender:self];
				}
			}];
		}
		else {
			[self performSegueWithIdentifier:@"GoToLogin" sender:self];
		}
		_loginStarted = YES;
	}
	 */
}

-(void)handleLongPress:(id)object
{
	if (_alert)
		return;
	
	_tutorialScheduled = NO;
	
	_alert = [[UIAlertView alloc] initWithTitle:@"Select action" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Select", @"Edit", @"Delete", nil];
	[_alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (_alert != alertView)
		return;
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	switch (buttonIndex) {
		case 1:
			// Select
			[self collectionView:_cvProjects didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:_rowSelected inSection:0]];
			break;
			
		case 2:
			// Edit
		{
			Project *project = [appDelegate.projects.project objectAtIndex:_rowSelected];
			[appDelegate.vcAddProject setEdit:project];
			
			CGRect curFrame = _addProjectNormalFrame;
			curFrame.origin.x += [self getDevideWidth];
			_vAddProject.frame = curFrame;
			
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.3];
			[UIView setAnimationDelay:0.0];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			
			_vAddProject.hidden = NO;
			curFrame.origin.x -= [self getDevideWidth];
			_vAddProject.frame = curFrame;
			
			[UIView commitAnimations];
			
			_singleFingerTap =
			[[UITapGestureRecognizer alloc] initWithTarget:self
													action:@selector(handleSingleTap:)];
			[self.view addGestureRecognizer:_singleFingerTap];
		}
			break;
			
		case 3:
			// Delete
			_vAddProject.hidden = YES;
			[appDelegate.projects.project removeObjectAtIndex:_rowSelected];
			[_cvProjects deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:_rowSelected inSection:0]]];
			[appDelegate.projects saveToFile];
			[appDelegate.projects sendToServer];
			break;

		default:
			break;
	}
	_alert = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) getDevideWidth
{
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
		return self.view.frame.size.width;
	else
		return self.view.frame.size.height;
}

// Project list
- (void)fillInCell:(UIView *)view withProject:(Project *)p
{
	if (!view)
		return;
	
	for (UIView *subview in view.subviews)
    {
		if ([subview isKindOfClass:[UIImageView class]])
		{
			// It's an image
			UIImageView *img = (UIImageView *)subview;
			[img.layer setBorderColor:[[UIColor colorWithWhite:0.43921568627451f alpha:1.0f] CGColor]];
			[img.layer setBorderWidth:2.0f];
			if (p)
			{
				if (p.displayColor)
					img.backgroundColor = p.displayColor;
				else
					img.backgroundColor = [UIColor colorWithWhite:0.27450980392157 alpha:1.0f];
				
				if (p.displayImage && (p.displayImage.length > 0))
				{
					NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
					NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:p.displayImage];
					img.contentMode = UIViewContentModeScaleAspectFit;
					img.image = [[UIImage alloc] initWithContentsOfFile:filePath];
				}
				else
					img.image = nil;
			}
			else
			{
				img.backgroundColor = [UIColor colorWithWhite:0.27450980392157 alpha:1.0f];
				img.contentMode = UIViewContentModeCenter;
				img.image = [UIImage imageNamed:@"AddProject"];
			}
		}
		else if ([subview isKindOfClass:[UILabel class]])
		{
			// It's a label
			UILabel *lbl = (UILabel *)subview;
			if (p)
				lbl.text = p.shortName;
			else
				lbl.text = @"New Project";
		}
		else if ([subview isKindOfClass:[UIView class]])
		{
			[self fillInCell:subview withProject:p];
		}
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProjectCell" forIndexPath:indexPath];

	Project *p = nil;
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (indexPath.row < appDelegate.projects.project.count)
		p = [appDelegate.projects.project objectAtIndex:indexPath.row];
	
	[self fillInCell:cell withProject:p];
	if (p)
		[cell addGestureRecognizer:_longTap];
	else
		[cell removeGestureRecognizer:_longTap];
	
	return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	if (section != 0)
		return 0;
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	Projects *p = appDelegate.projects;
	return (p.project.count + 1);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (!_vAddProject.hidden && (_vAddProject.frame.origin.x >= 0))
		return;
	
	_tutorialScheduled = NO;
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (indexPath.row >= appDelegate.projects.project.count)
	{
		// Create a project
		[appDelegate.vcAddProject setCreate];
		
		CGRect curFrame = _addProjectNormalFrame;
		curFrame.origin.x += [self getDevideWidth];
		_vAddProject.frame = curFrame;
		_vAddProject.hidden = NO;
		
		[UIView animateWithDuration:0.3f animations:^{
			CGRect curFrame = _vAddProject.frame;
			curFrame.origin.x -= [self getDevideWidth];
			_vAddProject.frame = curFrame;
		} completion:^(BOOL finished) {
			_vAddProject.frame = _addProjectNormalFrame;
		}];

		_singleFingerTap =
			[[UITapGestureRecognizer alloc] initWithTarget:self
													action:@selector(handleSingleTap:)];
		[self.view addGestureRecognizer:_singleFingerTap];
	}
	else
	{
		// Select a project
		_vAddProject.hidden = YES;
		Project *project = [appDelegate.projects.project objectAtIndex:indexPath.row];
		if (project.timer.count == 0)
		{
			appDelegate.firstProduction = YES;
			[self performSegueWithIdentifier: @"ProjectsToProduction" sender: self];
			[appDelegate.vcProduction setProject:project];
		}
		else
		{
			appDelegate.firstProduction = NO;
			[self performSegueWithIdentifier: @"ProjectsToTimers" sender: self];
			[appDelegate.vcTimers setProject:project];
		}
		appDelegate.activeProject = project;
		[project start];
	}
}

- (void)handleSingleTap:(UITapGestureRecognizer *)object
{
	if (_vAddProject.hidden)
		return;
	
	for (NSUInteger pointIndex = 0; pointIndex < [object numberOfTouches]; ++pointIndex)
	{
		CGPoint touchPoint = [object locationOfTouch:pointIndex inView:_vAddProject];
		if ((touchPoint.x < 0) ||
			(touchPoint.y < 0) ||
			(touchPoint.x >= _vAddProject.frame.size.width) ||
			(touchPoint.y >= _vAddProject.frame.size.height))
		{
			[self removeFrame];
			break;
		}
	}
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
	_rowSelected = indexPath.row;
	//[collectionView cellForItemAtIndexPath:indexPath].backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
	//[collectionView cellForItemAtIndexPath:indexPath].backgroundColor = [UIColor clearColor];
}

-(IBAction)addProjectFinished:(id)sender
{
	if (_vAddProject.hidden || (_vAddProject.frame.origin.x < 0))
		return;
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (sender == nil)
	{
		[_cvProjects reloadData];
	
		for (int i=0; i < appDelegate.projects.project.count + 1; ++i)
		{
			[_cvProjects deselectItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];
		}

		[NSTimer scheduledTimerWithTimeInterval:0.25f target:self selector:@selector(removeFrame) userInfo:nil repeats:NO];
	}
	else
	{
		[self removeFrame];
	}
	
	_tutorialScheduled = NO;
}

-(void)removeFrame
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.vcAddProject.tfEmailRecipient resignFirstResponder];
	[appDelegate.vcAddProject.tfLongName resignFirstResponder];
	[appDelegate.vcAddProject.tfShortName resignFirstResponder];
	
	[UIView animateWithDuration:0.2f animations:^{
		CGRect curFrame = _addProjectNormalFrame;
		curFrame.origin.x = -curFrame.size.width;
		_vAddProject.frame = curFrame;
	} completion:^(BOOL finished) {
		_vAddProject.hidden = YES;
	}];
	
	if (_singleFingerTap)
	{
		[self.view removeGestureRecognizer:_singleFingerTap];
		_singleFingerTap = nil;
	}
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	CGFloat placeWidth = collectionView.frame.size.width;
	CGFloat totalWidth = 232.0f * (float)(appDelegate.projects.project.count + 1);
	if (totalWidth < placeWidth)
		return UIEdgeInsetsMake(0, (placeWidth - totalWidth) / 2, 0, 0);
	else
	    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(IBAction)tutorial:(id)sender
{
	//AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate showTutorialInView:self.view controller:self];
	[self performSegueWithIdentifier:@"ProjectsToHelp" sender:self];
	
	_tutorialScheduled = NO;
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

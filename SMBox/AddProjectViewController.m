//
//  AddProjectViewController.m
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "AddProjectViewController.h"
#import "AppDelegate.h"
#import "Project.h"

#define MAXLENGTH_IPHONE 25
#define MAXLENGTH_IPAD 50

@interface NonRotatingUIImagePickerController : UIImagePickerController

@end

@implementation NonRotatingUIImagePickerController
// Disable Landscape mode.
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
@end

@interface AddProjectViewController ()
{
	CGRect _viewNormalRect;
	NSString *_selectedImage;
	UIColor *_selectedColor;
	WEPopoverController *_wePopoverController;
	UIImagePickerController *_imagePicker;
	CGSize _keyboardSize;
	Project *_project;
}
@end

@implementation AddProjectViewController

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
	appDelegate.vcAddProject = self;
	
	/*
	[_swiUseTimes addTarget:self action:@selector(switchPressed:) forControlEvents:UIControlEventValueChanged];
	[_swiUseTimes setOn:NO];
	[self switchPressed:_swiUseTimes];
	 */
}

/*
- (void)switchPressed:(id)object
{
	if (_swiUseTimes)
	{
		// Set on/off label
		if ([_swiUseTimes isOn])
		{
			_lblUseTimes.text = @"ON";
			_lblUseTimes.textColor = [UIColor greenColor];
		}
		else
		{
			_lblUseTimes.text = @"OFF";
			_lblUseTimes.textColor = [UIColor redColor];
		}
	}
}
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setCreate
{
	// Clear all fields
	_project = nil;
	_viewNormalRect = self.view.frame;
	_selectedColor = [UIColor colorWithWhite:0.27450980392157 alpha:1.0f];
	_selectedImage = nil;
	_tfEmailRecipient.text = @"";
	_tfShortName.text = @"";
	_tfLongName.text = @"";
	_btnCreate.enabled = YES;
	[_btnCreate setTitle:@"CREATE PROJECT" forState:UIControlStateNormal];
	[_btnCreate setTitle:@"CREATE PROJECT" forState:UIControlStateDisabled];
	[_btnCreate setTitle:@"CREATE PROJECT" forState:UIControlStateHighlighted];
	[_btnCreate setTitle:@"CREATE PROJECT" forState:UIControlStateSelected];
	//[_swiUseTimes setOn:NO];
	//[self switchPressed:_swiUseTimes];
}

-(void) setEdit:(Project *)project
{
	_project = project;
	_viewNormalRect = self.view.frame;
	_selectedColor = project.displayColor;
	_selectedImage = project.displayImage;
	_tfEmailRecipient.text = project.emailRecipient;
	_tfShortName.text = project.shortName;
	_tfLongName.text = project.longName;
	_btnCreate.enabled = YES;
	[_btnCreate setTitle:@"APPLY CHANGES" forState:UIControlStateNormal];
	[_btnCreate setTitle:@"APPLY CHANGES" forState:UIControlStateDisabled];
	[_btnCreate setTitle:@"APPLY CHANGES" forState:UIControlStateHighlighted];
	[_btnCreate setTitle:@"APPLY CHANGES" forState:UIControlStateSelected];
	//[_swiUseTimes setOn:project.useStartEndTime];
	//[self switchPressed:_swiUseTimes];
}

- (IBAction)create:(id)sender
{
	if ((_tfShortName.text.length == 0) ||
		(_tfLongName.text.length == 0))
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Required field is empty" message:@"Fields 'Short name' and 'Full name' are required. You cannot create a project with empty name fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	// Create a new project
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	Project *p = _project ? _project : [[Project alloc] init];
	p.shortName = [_tfShortName.text copy];
	p.longName = [_tfLongName.text copy];
	p.emailRecipient = [_tfEmailRecipient.text copy];
	p.displayImage = [_selectedImage copy];
	p.displayColor = [_selectedColor copy];
	/*
	if ([_swiUseTimes isOn])
	{
		if (!_project || !_project.useStartEndTime)
		{
			// Add timers
			if (p.order.count)
				[p.order insertObject:[[NSNumber alloc] initWithInt:-1] atIndex:0];
			else
				[p.order addObject:[[NSNumber alloc] initWithInt:-1]];
			[p.order addObject:[[NSNumber alloc] initWithInt:-2]];
			p.startTime = 0;
			p.endTime = 0;
		}
	}
	else
	{
		p.startTime = 0;
		p.endTime = 0;
		if (_project && _project.useStartEndTime)
		{
			// Remove timers
			for (NSInteger i = 0; i < p.order.count; ++i)
			{
				if (([[p.order objectAtIndex:i] intValue] == -1) ||
					([[p.order objectAtIndex:i] intValue] == -2))
				{
					[p.order removeObjectAtIndex:i];
					--i;
				}
			}
		}
	}
	
	p.useStartEndTime = [_swiUseTimes isOn];
	 */
	
	[_tfEmailRecipient resignFirstResponder];
	[_tfLongName resignFirstResponder];
	[_tfShortName resignFirstResponder];
	
	_btnCreate.enabled = NO;
	
	if (!_project)
		[appDelegate.projects.project addObject:p];
	
	[appDelegate.projects saveToFile];
	[appDelegate.projects sendToServer];

	[appDelegate.vcProjects addProjectFinished:nil];
}

-(IBAction)chooseColor:(id)sender
{
	[_tfEmailRecipient resignFirstResponder];
	[_tfLongName resignFirstResponder];
	[_tfShortName resignFirstResponder];
	
	if (!_wePopoverController)
	{
		ColorViewController *contentViewController = [[ColorViewController alloc] init];
        contentViewController.delegate = self;
		_wePopoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
		_wePopoverController.delegate = self;
		//_wePopoverController.passthroughViews = [NSArray arrayWithObject:self.parentViewController.view];
		
		CGRect btnRect = [(UIButton *)sender frame];
		
		[_wePopoverController presentPopoverFromRect:btnRect
											  inView:self.view //self.parentViewController.parentViewController.view
							permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown)
											animated:YES];
        
	}
	else
	{
		[_wePopoverController dismissPopoverAnimated:YES];
		_wePopoverController = nil;
	}
}

-(IBAction)chooseImage:(id)sender
{
	[_tfEmailRecipient resignFirstResponder];
	[_tfLongName resignFirstResponder];
	[_tfShortName resignFirstResponder];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Select photo source" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Camera", @"Photo Gallery", @"Camera Roll", nil];
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ((buttonIndex < 1) || (buttonIndex > 3))
		return;
	
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
		_imagePicker = [[UIImagePickerController alloc] init];
	else
		_imagePicker = [[NonRotatingUIImagePickerController alloc] init];
	switch (buttonIndex)
	{
		case 1: _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera; break;
		case 2: _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; break;
		case 3: _imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum; break;
		default: return;
	}
	
	_imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
	_imagePicker.delegate = self;
	_imagePicker.allowsEditing = YES;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate.vcProjects presentViewController:_imagePicker animated:YES completion:nil];
	});
}

-(NSString *) genRandStringLength: (int) len
{
	NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
	
    for (int i=0; i<len; i++) {
		[randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
	
    return randomString;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	// Success
	UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
	if (image)
	{
		_selectedImage = [[self genRandStringLength: 16] stringByAppendingString:@".jpg"];
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:_selectedImage];
		
		[UIImageJPEGRepresentation(image, 0.8) writeToFile:filePath atomically:YES];
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
	_imagePicker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:nil];
	_imagePicker = nil;
}

// Color selection
- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
	_wePopoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}

-(void) colorPopoverControllerDidSelectColor:(NSString *)hexColor
{
	_selectedColor = [GzColors colorFromHex:hexColor];
    [self.view setNeedsDisplay];
    [_wePopoverController dismissPopoverAnimated:YES];
    _wePopoverController = nil;
}

// Keyboard
-(void)keyboardWillShow:(NSNotification*)notification
{
	NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
	_keyboardSize = keyboardFrameBeginRect.size;
	
    // Animate the current view out of the way
    [self setViewMovedUp:YES];
}

-(void)keyboardWillHide {
   [self setViewMovedUp:NO];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
	
	if (textField == _tfShortName)
		[_tfLongName becomeFirstResponder];
	else if (textField == _tfLongName)
	{
		[_tfEmailRecipient becomeFirstResponder];
		[self setViewMovedUp:YES];
	}
	else
		[textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	if (textField == _tfEmailRecipient)
		return YES;
	
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
	
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
	NSUInteger maxLength = isPad() ? MAXLENGTH_IPAD : MAXLENGTH_IPHONE;
	
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
	
    return (newLength <= maxLength) || returnKey;
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
	
    CGRect rect = _viewNormalRect;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
		if (isPad())
		{
        	rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        	rect.size.height += kOFFSET_FOR_KEYBOARD;
		}
		else
		{
			UIView *fr = [self findFirstResponderForView:self.view];
			if ((fr == _tfLongName) || (fr == _tfShortName))
			{
				rect.origin.y -= kOFFSET_FOR_KEYBOARD;
				rect.size.height += kOFFSET_FOR_KEYBOARD;
			}
			else
			{
				rect.origin.y -= kOFFSET_FOR_KEYBOARD * 4;
				rect.size.height += kOFFSET_FOR_KEYBOARD * 4;
			}
		}
    }
    else
    {
        // revert back to the normal state.
		rect = _viewNormalRect;
    }
    self.view.frame = rect;
	
    [UIView commitAnimations];
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

@end

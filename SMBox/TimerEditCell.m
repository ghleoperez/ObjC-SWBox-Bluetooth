//
//  TimerEditCell.m
//  SMBox
//
//  Created by Alisa Nekrasova on 30/12/14.
//  Copyright (c) 2014 LVWebGuy. All rights reserved.
//

#import "TimerEditCell.h"

@interface TimerEditCell()
{
	ATSDragToReorderTableViewController *_ats;
	Timer *_timer;
}
@end

@implementation TimerEditCell

-(void)setUpWithDelegate:(id <MCSwipeTableViewCellDelegate>)delegate ats:(ATSDragToReorderTableViewController *)ats timer:(Timer *)timer
{
	self.defaultColor = [UIColor orangeColor];
	self.delegate = delegate;
	self.showsReorderControl = YES;
	_ats = ats;
	_timer = timer;
}

-(void)setForEdit:(BOOL)forEdit fromSwitch:(BOOL)fromSwitch
{
	_lblTimerName.text = forEdit ? @"Timer Name" : _timer.name;
	_lblCountDownName.hidden = !forEdit;
	_lblCountDownValue.hidden = !forEdit;
	_lblCountUpName.hidden = !forEdit;
	_lblCountUpValue.hidden = !forEdit;
	_lblFromName.hidden = !forEdit;
	_lblOnTimerStartName.hidden = !forEdit;
	_lblOnTimerStopName.hidden = !forEdit;
	_lblCountUpValue.text = _timer.countUp ? @"ON" : @"OFF";
	_lblCountDownValue.text = _timer.countDown ? @"ON" : @"OFF";
	_lblCountUpValue.textColor = _timer.countUp ? [UIColor greenColor] : [UIColor redColor];
	_lblCountDownValue.textColor = _timer.countDown ? [UIColor greenColor] : [UIColor redColor];
	NSString *saveTitle = forEdit ? @"SAVE" : @" EDIT";
	[_btnSave setTitle:saveTitle forState:UIControlStateNormal];
	_btnSave.hidden = NO;
	_btnOnTimerStartSelect.hidden = !forEdit;
	_btnOnTimerStopSelect.hidden = !forEdit;
	_tfFromValue.hidden = !forEdit;
	_tfTimerName.hidden = !forEdit;
	if (!fromSwitch)
		_tfTimerName.text = _timer.name;
	if (forEdit && !fromSwitch && (_tfTimerName.text.length == 0)) {
		double delayInSeconds = 0.8;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			//code to be executed on the main queue after delay
			[_tfTimerName becomeFirstResponder];
		});
	}
	
	int hours = (int)(_timer.fromTime / 3600);
	int minutes = (_timer.fromTime / 60) % 60;
	int seconds = _timer.fromTime % 60;
	_tfFromValue.text = [[NSString alloc] initWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
	
	_swiCountDown.hidden = !forEdit;
	_swiCountUp.hidden = !forEdit;
	if (forEdit) {
		_swiCountDown.tintColor = _swiCountDown.onTintColor = [UIColor colorWithWhite:0.57647058823529f alpha:1.0f];
		_swiCountDown.thumbTintColor = [UIColor colorWithRed:0.08235294117647f green:0.42352941176471f blue:0.68627450980392f alpha:1.0f];
		_swiCountUp.tintColor = _swiCountUp.onTintColor = [UIColor colorWithWhite:0.57647058823529f alpha:1.0f];
		_swiCountUp.thumbTintColor = [UIColor colorWithRed:0.08235294117647f green:0.42352941176471f blue:0.68627450980392f alpha:1.0f];
		
		if (!fromSwitch) {
			[_swiCountUp setOn:_timer.countUp];
			[_swiCountDown setOn:_timer.countDown];
		
			[_swiCountDown removeTarget:self action:@selector(switchPressed:) forControlEvents:UIControlEventValueChanged];
			[_swiCountDown addTarget:self action:@selector(switchPressed:) forControlEvents:UIControlEventValueChanged];
			[_swiCountUp removeTarget:self action:@selector(switchPressed:) forControlEvents:UIControlEventValueChanged];
			[_swiCountUp addTarget:self action:@selector(switchPressed:) forControlEvents:UIControlEventValueChanged];
		}
	}
	
	if (forEdit)
		[self setDragElement:nil];
	else
		[self setDragElement:_ivDragHandle];

	_ats.touchArea = _ivDragHandle.frame;
	
	_ivOnTimerStartIndicator.hidden = !forEdit || ((_timer.startOnTimerStart.count == 0) && (_timer.stopOnTimerStart.count == 0));
	_ivOnTimerStopIndicator.hidden = !forEdit || ((_timer.startOnTimerStop.count == 0) && (_timer.stopOnTimerStop.count == 0));
}

- (void)switchPressed:(id)object
{
	if (!object)
		return;
	
	NKColorSwitch *swi = (NKColorSwitch *)object;
	if ((swi.tag >= 1) && (swi.tag <= 3))
	{
		if (swi.tag == 1)
		{
			// Count Up
			_timer.countUp = [swi isOn];
		}
		else if (swi.tag == 2)
		{
			// Count Down
			_timer.countDown = [swi isOn];
		}
		
		[self setForEdit:YES fromSwitch:YES];
	}
}

@end

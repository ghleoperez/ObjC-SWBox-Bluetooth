//
//  HelpViewController.m
//  SMBox
//
//  Created by Alisa Nekrasova on 11/10/15.
//  Copyright © 2015 LVWebGuy. All rights reserved.
//

#import "HelpViewController.h"
#import "TutorialViewController.h"

#import "UserVoice.h"

@interface HelpViewController()
{
	int tutorialNum;
}
@end

@implementation HelpViewController

-(IBAction)tutorial1:(id)sender {
	tutorialNum = 0;
	[self performSegueWithIdentifier:@"HelpToTutorial" sender:self];
}

-(IBAction)tutorial2:(id)sender {
	tutorialNum = 1;
	[self performSegueWithIdentifier:@"HelpToTutorial" sender:self];
}

-(IBAction)tutorial3:(id)sender {
	tutorialNum = 2;
	[self performSegueWithIdentifier:@"HelpToTutorial" sender:self];
}

-(IBAction)support:(id)sender {
	UVConfig *config = [UVConfig configWithSite:@"backstageapps.uservoice.com"];
	[UserVoice initialize:config];
	[UserVoice presentUserVoiceInterfaceForParentViewController:self];
}

-(IBAction)back:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.destinationViewController isKindOfClass:[TutorialViewController class]]) {
		TutorialViewController *tvc = (TutorialViewController *)segue.destinationViewController;
		tvc.tutorialNum = tutorialNum;
	}
}

@end

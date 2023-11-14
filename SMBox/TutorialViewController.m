//
//  TutorialViewController.m
//  SMBox
//
//  Created by Alisa Nekrasova on 11/10/15.
//  Copyright © 2015 LVWebGuy. All rights reserved.
//

#import "TutorialViewController.h"

#import <MediaPlayer/MediaPlayer.h>

@interface TutorialViewController()
{
	MPMoviePlayerController *moviePlayer;
}
@end

@implementation TutorialViewController

-(IBAction)back:(id)sender {
	[self stopVideo];
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (_tutorialNum == 0) {
		_lblTitle.text = @"SMBOX NAVIGATION";
	}
	else if (_tutorialNum == 1) {
		_lblTitle.text = @"TIMERS AND TIMESTAMPS";
	}
	else if (_tutorialNum == 2) {
		_lblTitle.text = @"SHOW LOGIC ENGINE";
	}
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (_tutorialNum == 0) {
		[self playVideo:@"tutorial1"];
	}
	else if (_tutorialNum == 1) {
		[self playVideo:@"tutorial2"];
	}
	else if (_tutorialNum == 2) {
		[self playVideo:@"tutorial3"];
	}
}

-(void)playVideo:(NSString *)name {
	NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:@"m4v"];
	NSURL *url = [NSURL fileURLWithPath:filePath];
	moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
	moviePlayer.backgroundView.backgroundColor = [UIColor blackColor];
	for (int i = 0; i < moviePlayer.view.subviews.count; ++i) {
		UIView *v = moviePlayer.view.subviews[i];
		v.backgroundColor = [UIColor whiteColor];
	}
	
	moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
	moviePlayer.view.frame = _vVideo.bounds;
	[moviePlayer prepareToPlay];
	moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
	
	[_vVideo addSubview:moviePlayer.view];
}

-(void)stopVideo {
	[moviePlayer stop];
	[moviePlayer.view removeFromSuperview];
	moviePlayer = nil;
}

@end

//
//  ProjectsViewController.h
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParserViewController.h"

@interface ProjectsViewController : ParserViewController <UIAlertViewDelegate>

@property (assign) IBOutlet UICollectionView *cvProjects;
@property (assign) IBOutlet UIView *vAddProject;

-(IBAction)addProjectFinished:(id)sender;
-(IBAction)tutorial:(id)sender;

@end

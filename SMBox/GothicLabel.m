//
//  NovecentoLabel.m
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import "GothicLabel.h"

@implementation GothicLabel

- (void)awakeFromNib
{
    [super awakeFromNib];
	UIFont *fnt = [UIFont fontWithName:@"Century Gothic" size:isPad() ? 70.0f : 22.0f];
	if (fnt)
		self.font = fnt;
	[self sizeToFit];
}

@end

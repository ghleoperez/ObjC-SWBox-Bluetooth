//
//  NovecentoLabel.m
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import "GothicLargeLabel.h"

@implementation GothicLargeLabel

- (void)awakeFromNib
{
    [super awakeFromNib];
	UIFont *fnt = [UIFont fontWithName:@"Century Gothic" size:isPad() ? 64.0f : 36.0f];
	if (fnt)
		self.font = fnt;
}

@end

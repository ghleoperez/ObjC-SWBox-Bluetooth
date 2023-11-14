//
//  NovecentoLabel.m
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import "NovecentoHeadLabel.h"

@implementation NovecentoHeadLabel

- (void)awakeFromNib
{
    [super awakeFromNib];
	UIFont *fnt = [UIFont fontWithName:@"Novecentowide-Light" size:isPad() ? 72.0f : 48.0f];
	if (fnt)
		self.font = fnt;
	[self sizeToFit];
}

@end

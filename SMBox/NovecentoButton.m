//
//  NovecentoButton.m
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import "NovecentoButton.h"

@implementation NovecentoButton

- (void)awakeFromNib
{
    [super awakeFromNib];
	UIFont *fnt = [UIFont fontWithName:@"Novecentowide-Light" size:isPad() ? 32.0f : 22.0f];
	if (fnt)
		self.titleLabel.font = fnt;
	
}

@end

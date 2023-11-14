//
//  NovecentoMediumButton.m
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import "NovecentoMediumButton.h"

@implementation NovecentoMediumButton

- (void)awakeFromNib
{
    [super awakeFromNib];
	UIFont *fnt = [UIFont fontWithName:@"Novecentowide-Regular" size:isPad() ? 22.0f : 16.0f];
	if (fnt)
		self.titleLabel.font = fnt;
	
}

@end

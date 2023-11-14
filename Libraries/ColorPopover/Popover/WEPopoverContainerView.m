//
//  WEPopoverContainerViewProperties.m
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverContainerView.h"

@implementation WEPopoverContainerViewProperties

@synthesize bgImageName, upArrowImageName, downArrowImageName, leftArrowImageName, rightArrowImageName, topBgMargin, bottomBgMargin, leftBgMargin, rightBgMargin, topBgCapSize, leftBgCapSize;
@synthesize leftContentMargin, rightContentMargin, topContentMargin, bottomContentMargin, arrowMargin;


@end

@interface WEPopoverContainerView(Private)

- (void)determineGeometryForSize:(CGSize)theSize anchorRect:(CGRect)anchorRect displayArea:(CGRect)displayArea permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections;
- (CGRect)contentRect;
- (CGSize)contentSize;
- (void)setProperties:(WEPopoverContainerViewProperties *)props;
- (void)initFrame;

@end

@implementation WEPopoverContainerView

@synthesize arrowDirection, contentView;

- (id)initWithSize:(CGSize)theSize 
		anchorRect:(CGRect)anchorRect 
	   displayArea:(CGRect)displayArea
permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections
		properties:(WEPopoverContainerViewProperties *)theProperties {
	if ((self = [super initWithFrame:CGRectZero])) {
		
		[self setProperties:theProperties];
		correctedSize = CGSizeMake(theSize.width + properties.leftBgMargin + properties.rightBgMargin + properties.leftContentMargin + properties.rightContentMargin, 
								   theSize.height + properties.topBgMargin + properties.bottomBgMargin + properties.topContentMargin + properties.bottomContentMargin);	
		[self determineGeometryForSize:correctedSize anchorRect:anchorRect displayArea:displayArea permittedArrowDirections:permittedArrowDirections];
		[self initFrame];
		self.backgroundColor = [UIColor clearColor];
		UIImage *theImage = [UIImage imageNamed:properties.bgImageName];
		bgImage = [theImage stretchableImageWithLeftCapWidth:properties.leftBgCapSize topCapHeight:properties.topBgCapSize];
		
		self.clipsToBounds = YES;
		self.userInteractionEnabled = YES;
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
	[bgImage drawInRect:bgRect blendMode:kCGBlendModeNormal alpha:1.0];
	[arrowImage drawInRect:arrowRect blendMode:kCGBlendModeNormal alpha:1.0]; 
}

- (void)updatePositionWithAnchorRect:(CGRect)anchorRect 
						 displayArea:(CGRect)displayArea
			permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections {
	[self determineGeometryForSize:correctedSize anchorRect:anchorRect displayArea:displayArea permittedArrowDirections:permittedArrowDirections];
	[self initFrame];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	return CGRectContainsPoint(self.contentRect, point);	
} 

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)setContentView:(UIView *)v {
	if (v != contentView) {
		contentView = v;		
		contentView.frame = self.contentRect;		
		[self addSubview:contentView];
	}
}



@end

@implementation WEPopoverContainerView(Private)

- (void)initFrame {
	CGRect theFrame = CGRectOffset(CGRectUnion(bgRect, arrowRect), offset.x, offset.y);
	
	//If arrow rect origin is < 0 the frame above is extended to include it so we should offset the other rects
	arrowOffset = CGPointMake(MAX(0, -arrowRect.origin.x), MAX(0, -arrowRect.origin.y));
	bgRect = CGRectOffset(bgRect, arrowOffset.x, arrowOffset.y);
	arrowRect = CGRectOffset(arrowRect, arrowOffset.x, arrowOffset.y);
	
	self.backgroundColor = [UIColor colorWithWhite:0.09803921568627f alpha:1.0f];
	
	self.frame = theFrame;	
}																		 

- (CGSize)contentSize {
	return self.contentRect.size;
}

- (CGRect)contentRect {
	CGRect rect = CGRectMake(properties.leftBgMargin + properties.leftContentMargin + arrowOffset.x, 
							 properties.topBgMargin + properties.topContentMargin + arrowOffset.y, 
							 bgRect.size.width - properties.leftBgMargin - properties.rightBgMargin - properties.leftContentMargin - properties.rightContentMargin,
							 bgRect.size.height - properties.topBgMargin - properties.bottomBgMargin - properties.topContentMargin - properties.bottomContentMargin);
	return rect;
}

- (void)setProperties:(WEPopoverContainerViewProperties *)props {
	if (properties != props) {
		properties = props;
	}
}

- (void)determineGeometryForSize:(CGSize)theSize anchorRect:(CGRect)anchorRect displayArea:(CGRect)displayArea permittedArrowDirections:(UIPopoverArrowDirection)supportedArrowDirections {	
	
	//Determine the frame, it should not go outside the display area
	UIPopoverArrowDirection theArrowDirection = UIPopoverArrowDirectionUp;
	
	offset =  CGPointZero;
	bgRect = CGRectZero;
	arrowRect = CGRectZero;
	arrowDirection = UIPopoverArrowDirectionUnknown;
	
	CGFloat biggestSurface = 0.0f;
	CGFloat currentMinMargin = 0.0f;
		
	while (theArrowDirection <= UIPopoverArrowDirectionRight) {
		
		if ((supportedArrowDirections & theArrowDirection)) {
			
			CGRect theBgRect = CGRectZero;
			CGRect theArrowRect = CGRectZero;
			CGPoint theOffset = CGPointZero;
			CGFloat xArrowOffset = 0.0;
			CGFloat yArrowOffset = 0.0;
			CGPoint anchorPoint = CGPointZero;
			
			switch (theArrowDirection) {
				case UIPopoverArrowDirectionUp:
					
					anchorPoint = CGPointMake(CGRectGetMidX(anchorRect), CGRectGetMaxY(anchorRect));
					
					xArrowOffset = theSize.width / 2;
					yArrowOffset = properties.topBgMargin;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset, anchorPoint.y  - yArrowOffset);
					theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					if (theOffset.x < 0) {
						xArrowOffset += theOffset.x;
						theOffset.x = 0;
					} else if (theOffset.x + theSize.width > displayArea.size.width) {
						xArrowOffset += (theOffset.x + theSize.width - displayArea.size.width);
						theOffset.x = displayArea.size.width - theSize.width;
					}
					
					break;
				case UIPopoverArrowDirectionDown:
					
					anchorPoint = CGPointMake(CGRectGetMidX(anchorRect), CGRectGetMinY(anchorRect));
					
					xArrowOffset = theSize.width / 2;
					yArrowOffset = theSize.height - properties.bottomBgMargin;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset, anchorPoint.y - yArrowOffset);
					theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					if (theOffset.x < 0) {
						xArrowOffset += theOffset.x;
						theOffset.x = 0;
					} else if (theOffset.x + theSize.width > displayArea.size.width) {
						xArrowOffset += (theOffset.x + theSize.width - displayArea.size.width);
						theOffset.x = displayArea.size.width - theSize.width;
					}
					
					break;
				case UIPopoverArrowDirectionLeft:
					
					anchorPoint = CGPointMake(CGRectGetMaxX(anchorRect), CGRectGetMidY(anchorRect));
					
					xArrowOffset = properties.leftBgMargin;
					yArrowOffset = theSize.height / 2 ;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset, anchorPoint.y - yArrowOffset);
					theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					if (theOffset.y < 0) {
						yArrowOffset += theOffset.y;
						theOffset.y = 0;
					} else if (theOffset.y + theSize.height > displayArea.size.height) {
						yArrowOffset += (theOffset.y + theSize.height - displayArea.size.height);
						theOffset.y = displayArea.size.height - theSize.height;
					}
					
					break;
				case UIPopoverArrowDirectionRight:
					
					anchorPoint = CGPointMake(CGRectGetMinX(anchorRect), CGRectGetMidY(anchorRect));
					
					xArrowOffset = theSize.width - properties.rightBgMargin;
					yArrowOffset = theSize.height / 2;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset, anchorPoint.y - yArrowOffset);
					theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
					
					if (theOffset.y < 0) {
						yArrowOffset += theOffset.y;
						theOffset.y = 0;
					} else if (theOffset.y + theSize.height > displayArea.size.height) {
						yArrowOffset += (theOffset.y + theSize.height - displayArea.size.height);
						theOffset.y = displayArea.size.height - theSize.height;
					}
										
					break;
			}
			
			CGRect bgFrame = CGRectOffset(theBgRect, theOffset.x, theOffset.y);
			
			CGFloat minMarginLeft = CGRectGetMinX(bgFrame) - CGRectGetMinX(displayArea);
			CGFloat minMarginRight = CGRectGetMaxX(displayArea) - CGRectGetMaxX(bgFrame); 
			CGFloat minMarginTop = CGRectGetMinY(bgFrame) - CGRectGetMinY(displayArea); 
			CGFloat minMarginBottom = CGRectGetMaxY(displayArea) - CGRectGetMaxY(bgFrame); 
			
			if (minMarginLeft < 0) {
			    // Popover is too wide and clipped on the left; decrease width
			    // and move it to the right
			    theOffset.x -= minMarginLeft;
			    theBgRect.size.width += minMarginLeft;
			    minMarginLeft = 0;
			    if (theArrowDirection == UIPopoverArrowDirectionRight) {
			        theArrowRect.origin.x = CGRectGetMaxX(theBgRect) - properties.rightBgMargin;
			    }
			}
			if (minMarginRight < 0) {
			    // Popover is too wide and clipped on the right; decrease width.
			    theBgRect.size.width += minMarginRight;
			    minMarginRight = 0;
			}
			if (minMarginTop < 0) {
			    // Popover is too high and clipped at the top; decrease height
			    // and move it down
			    theOffset.y -= minMarginTop;
			    theBgRect.size.height += minMarginTop;
			    minMarginTop = 0;
			}
			if (minMarginBottom < 0) {
			    // Popover is too high and clipped at the bottom; decrease height.
			    theBgRect.size.height += minMarginBottom;
			    minMarginBottom = 0;
			}
			bgFrame = CGRectOffset(theBgRect, theOffset.x, theOffset.y);
            
			CGFloat minMargin = MIN(minMarginLeft, minMarginRight);
			minMargin = MIN(minMargin, minMarginTop);
			minMargin = MIN(minMargin, minMarginBottom);
			
			// Calculate intersection and surface
			CGRect intersection = CGRectIntersection(displayArea, bgFrame);
			CGFloat surface = intersection.size.width * intersection.size.height;
			
			if (surface >= biggestSurface && minMargin >= currentMinMargin) {
				biggestSurface = surface;
				offset = theOffset;
				arrowRect = theArrowRect;
				bgRect = theBgRect;
				arrowDirection = theArrowDirection;
				currentMinMargin = minMargin;
			}
		}
		
		theArrowDirection <<= 1;
	}
	
	/*
	switch (arrowDirection) {
		case UIPopoverArrowDirectionUp:
			arrowImage = upArrowImage;
			break;
		case UIPopoverArrowDirectionDown:
			arrowImage = downArrowImage;
			break;
		case UIPopoverArrowDirectionLeft:
			arrowImage = leftArrowImage;
			break;
		case UIPopoverArrowDirectionRight:
			arrowImage = rightArrowImage;
			break;
	}
	 */
}

@end
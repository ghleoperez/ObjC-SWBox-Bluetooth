//
//  ParserViewController.h
//  SMBox
//
//  Created by Alisa Nekrasova on 09/02/15.
//  Copyright (c) 2015 LVWebGuy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParserViewController : UIViewController <NSXMLParserDelegate>

-(void)doParsing:(NSString *)data;

@end

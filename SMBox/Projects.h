//
//  Projects.h
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Projects : NSObject

@property (strong) NSMutableArray *project;

-(void)loadFromFile;
-(void)saveToFile;
-(void)sendToServer;
-(NSString *)toXMLString;

@end

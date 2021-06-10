//
//  Course.h
//  ObjCGettingStarted
//
//  Created by Brian Voong on 4/7/18.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Hotel : NSObject

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *descriptive;

-(NSString *)description;

@end

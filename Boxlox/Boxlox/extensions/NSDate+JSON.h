//
//  NSUserDefaults+Settings.h
//  Butane
//
//  Created by Tom Adriaenssen on 26/02/12.
//  Copyright (c) 2012 10to1, Interface Implementation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (JSON)

+ (NSDate *)dateWithISO8601String:(NSString *)dateString;
+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)dateFormat;
-(NSString *)formatToUTC;

@end

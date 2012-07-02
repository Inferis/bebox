//
//  NSDate+Formatting.h
//
//  27/06/11.
//  Copyright 2011. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Formatting)

-(NSString *)formatWithStyle:(NSDateFormatterStyle)style;
-(NSString *)formatAs:(NSString*)format;
-(NSString *)formatAsDateOnly;
-(NSString *)formatAsDateOnlyRelative;

@end

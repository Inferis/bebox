#import <Foundation/Foundation.h>

@interface NSArray (Coby)
- (NSArray *)from:(NSUInteger)position;
- (NSArray *)to:(NSUInteger)position;
- (NSArray *)first:(NSUInteger)numberOfElements;
- (id)first;
- (id)second;
- (id)third;
- (id)fourth;
- (id)fifth;
- (id)fortyTwo;
- (id)CB_safeObjectAtIndex:(NSUInteger)index;

- (NSString *)join:(NSString *)seperator;
- (NSArray *)map: (id (^)(id obj))block;
- (NSArray *)map_index: (id (^)(id obj, uint index))block;
- (NSArray *)flatten;
- (NSArray *)flatten:(int)level;
- (void)each: (void (^)(id obj))block;
- (NSArray *)ofClass: (Class)class;
- (NSArray *)select: (BOOL (^)(id obj))block;
- (NSArray *)selectIndex: (BOOL (^)(id obj))block;
- (BOOL)all: (BOOL (^)(id obj))block;
- (NSArray*)uniq;
- (NSArray*)partition:(BOOL (^)(id obj))block;
- (BOOL)any:(BOOL (^)(id obj))block;
- (id)detect:(BOOL (^)(id obj))block;
- (id)detect:(BOOL (^)(id obj))block withIndex:(uint*)index;
- (NSArray *)take:(int)limit;
- (int)index:(BOOL (^)(id obj))block;

- (NSDictionary*)toDictionaryUsingKeyField:(NSString*)field;
- (NSArray*)allIndices;

@end

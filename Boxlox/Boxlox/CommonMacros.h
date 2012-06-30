//
//  CommonMacros.h
//

/*
 * How to use this file:
 *  1. Find your .pch file
 *  2. Import this file
 *  3. Make sure to import this file after UIKit and Foundation
 *  4. Use the functions in your app.
 *
 */

#define RectLog(x) NSLog(@"%s rect: %@",#x, NSStringFromCGRect(x.frame))

// Blatantly picked up from [Wil Shipley](http://blog.wilshipley.com/2005/10/pimp-my-code-interlude-free-code.html)
//
// > Essentially, if you're wondering if an NSString or NSData or
// > NSAttributedString or NSArray or NSSet has actual useful data in
// > it, this is your macro. Instead of checking things like
// > `if (inputString == nil || [inputString length] == 0)` you just
// > say, "if (IsEmpty(inputString))".
//
// It rocks.
static inline BOOL IsEmpty(id thing) {
    if (thing == nil) return YES;
    if ([thing isEqual:[NSNull null]]) return YES;
    if ([thing respondsToSelector:@selector(count)]) return [thing performSelector:@selector(count)] == 0;
    if ([thing respondsToSelector:@selector(length)]) return [thing performSelector:@selector(length)] == 0;
    return NO;
}

// The inverse for IsEmpty
static inline BOOL IsPresent(id thing) {
    return !IsEmpty(thing);
}

static inline BOOL IsInSimulator() {
#if TARGET_IPHONE_SIMULATOR
	return YES;
#endif
	return NO;
}

#define dispatch_async_bg(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block)
#define dispatch_async_main(block) dispatch_async(dispatch_get_main_queue(), block)
#define dispatch_sync_main(block) dispatch_sync(dispatch_get_main_queue(), block)

// A check to see if we're running on an iPad.
// Picked up [here](http://cocoawithlove.com/2010/07/tips-tricks-for-conditional-ios3-ios32.html)
static inline BOOL IsIPad() {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
		return YES;
	} else
#endif
    {
       	return NO;
    }
}


#define partition_result(yes, no, partition) NSArray* yes; NSArray* no; { NSArray* result = partition; yes = [result objectAtIndex:0];

static inline void dispatch_delayed(NSTimeInterval time, dispatch_block_t block) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), dispatch_get_main_queue(), block);
}

#define CGRectFloor(rect) ({__typeof__(rect) __r = (rect); (CGRect) { floorf(__r.origin.x), floorf(__r.origin.y), ceilf(__r.size.width), ceilf(__r.size.height) }; })
#define CGRectSetWidth(rect, width) ((CGRect) { (rect).origin, (width), (rect).size.height })
#define CGRectSetHeight(rect, height) ((CGRect) { (rect).origin, (rect).size.width, (height) })
#define CGRectSetX(rect, x) ((CGRect) { (x), (rect).origin.y, (rect).size })
#define CGRectSetY(rect, x) ((CGRect) { (rect).origin.x, (y), (rect).size })
#define CGRectSetOrigin(rect, origin) ((CGRect) { (origin), (rect).size })
#define CGRectSetSize(rect, size) ((CGRect) { (rect).origin, size })
#define CGRectOffsetLeftAndShrink(rect, offset) ({__typeof__(rect) __r = (rect); __typeof__(offset) __o = (offset); (CGRect) { __r.origin.x + __o, __r.origin.y, __r.size.width-__o, __r.size.height }; })
#define CGRectOffsetRightAndShrink(rect, offset) ({__typeof__(rect) __r = (rect); __typeof__(offset) __o = (offset); (CGRect) { __r.origin.x, __r.origin.y, __r.size.width-__o, __r.size.height }; })
#define CGRectOffsetTopAndShrink(rect, offset) ({__typeof__(rect) __r = (rect); __typeof__(offset) __o = (offset); (CGRect) { __r.origin.x, __r.origin.y + __o, __r.size.width, __r.size.height-__o }; })
#define CGRectOffsetBottomAndShrink(rect, offset) ({__typeof__(rect) __r = (rect); __typeof__(offset) __o = (offset); (CGRect) { __r.origin.x, __r.origin.y, __r.size.width, __r.size.height-__o }; })
#define CGRectShrink(rect, w, h) ({__typeof__(rect) __r = (rect); __typeof__(w) __w = (w); __typeof__(h) __h = (h); (CGRect) { __r.origin, __r.size.width - __w, __r.size.height - __h }; })
#define CGRectShrinkSides(rect, left, top, right, bottom) ({__typeof__(rect) __rt = (rect); __typeof__(left) __l = (left); __typeof__(right) __r = (right); __typeof__(top) __t = (top); __typeof__(bottom) __b = (bottom); (CGRect) { __rt.origin.x + __l, __rt.origin.y + __t, __rt.size.width - __l - __r, __rt.size.height - __t - __b }; })
#define LOGTHREAD NSLog(@"\n\n%s: Thread %@", __PRETTY_FUNCTION__, [NSThread isMainThread] ? @"main" : [NSThread currentThread])


#define MAINCONTEXT [NSManagedObjectContext mainContext]
#define ROOTCONTEXT [NSManagedObjectContext rootContext]
#define LOCALCONTEXT(name) NSManagedObjectContext* name = [NSManagedObjectContext nestedContextFromRoot]
#define NESTEDCONTEXT(name, from) NSManagedObjectContext* name = [(from) nestedContext]; 


//
//  SearchQueueManager.m
//  SpaceScout
//
//  Created by Craig M.Stimmel on 5/13/15.
//  Adopted from http://www.galloway.me.uk/tutorials/singleton-classes/
//
//

#import "SearchQueueManager.h"

@implementation SearchQueueManager

@synthesize searchQueue;

#pragma mark Singleton Methods

+ (id)sharedQueueManager {
    static SearchQueueManager *sharedSearchQueueManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSearchQueueManager = [[self alloc] init];
    });
    return sharedSearchQueueManager;
}

- (id)init {
    if (self = [super init]) {
        searchQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)dealloc {
    // Should never be called.
}

@end

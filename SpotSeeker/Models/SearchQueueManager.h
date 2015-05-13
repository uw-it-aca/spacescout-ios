//
//  SearchQueueManager.h
//  SpaceScout
//
//  Created by Craig M.Stimmel on 5/13/15.
//  Adopted from http://www.galloway.me.uk/tutorials/singleton-classes/
//
//

#import <Foundation/Foundation.h>

@interface SearchQueueManager : NSObject {
    NSOperationQueue *searchQueue;
}

@property (nonatomic, retain) NSOperationQueue *searchQueue;

+ (id)sharedQueueManager;

@end

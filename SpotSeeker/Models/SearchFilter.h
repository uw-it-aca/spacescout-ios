//
//  SearchFilter.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJson.h"

@protocol SearchFilterLoaded;

@interface SearchFilter : NSObject {
    id <SearchFilterLoaded> delegate;
}

-(void)loadSearchFilters;

@property (retain, nonatomic) id <SearchFilterLoaded> delegate;

@end



@protocol SearchFilterLoaded <NSObject>;

-(void) availableFilters:(NSMutableArray *)filters;

@end

//
//  Favorites.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spot.h"

@interface Favorites : NSObject {
    
}

+(BOOL) isFavorite:(Spot *)spot;

+(void) addFavorite:(Spot *)spot;

+(void) removeFavorite:(Spot *)spot;

+(NSArray *) getFavoritesList;

@end

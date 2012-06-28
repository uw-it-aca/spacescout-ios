//
//  Favorites.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Space.h"

@interface Favorites : NSObject {
    
}

+(BOOL) isFavorite:(Space *)spot;

+(void) addFavorite:(Space *)spot;

+(void) removeFavorite:(Space *)spot;

+(NSArray *) getFavoritesIDList;

@end

//
//  Favorites.h
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "REST.h"
#import "Space.h"

@protocol IsFavorite;


@interface Favorites : NSObject <RESTFinished> {
    id <IsFavorite> delegate;
    REST *rest;
}

@property (retain, nonatomic) id <IsFavorite> delegate;
@property (retain, nonatomic) REST *rest;

- (void) getIsFavorite: (Space *)space;

+(BOOL) isFavorite:(Space *)spot;

+(void) addFavorite:(Space *)spot;
+(void) removeFavorite:(Space *)spot;

-(void) addServerFavorite:(Space *)spot;
-(void) removeServerFavorite:(Space *)spot;

+(int) getFavoritesCount;

+(NSArray *) getFavoritesIDList;

@end

@protocol IsFavorite <NSObject>;

-(void)isFavorite:(Boolean)is_favorite;

@end

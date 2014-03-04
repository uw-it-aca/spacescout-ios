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
@protocol MovingFavorites;

@interface Favorites : NSObject <RESTFinished> {
    id <IsFavorite> delegate;
    id <MovingFavorites> moving_delegate;
    REST *rest;
}

@property (retain, nonatomic) id <IsFavorite> delegate;
@property (retain, nonatomic) REST *rest;
@property (nonatomic) BOOL moving_to_server;
@property (nonatomic, retain) id <MovingFavorites> moving_delegate;

- (void) getIsFavorite: (Space *)space;

+(BOOL) isFavorite:(Space *)spot;

+(void) addFavorite:(Space *)spot;
+(void) removeFavorite:(Space *)spot;

-(void) addServerFavorite:(Space *)spot;
-(void) removeServerFavorite:(Space *)spot;

-(void) moveFavoritesToServerFavorites;
+(int) getLocalFavoritesCount;

+(NSArray *) getFavoritesIDList;

@end

@protocol IsFavorite <NSObject>;

-(void)isFavorite:(Boolean)is_favorite;

@end

@protocol MovingFavorites <NSObject>;

-(void)movingFinished;

@end

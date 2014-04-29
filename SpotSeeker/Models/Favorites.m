//
//  Favorites.m
//  SpotSeeker
//
//  Created by Patrick Michaud on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Favorites.h"

@implementation Favorites
@synthesize delegate;
@synthesize rest;
@synthesize moving_to_server;
@synthesize moving_delegate;
@synthesize saving_delegate;

-(void) getIsFavorite:(Space *)space {
    REST *_rest = [[REST alloc] init];
    _rest.delegate = self;
    
    
    NSString *url = [[NSString alloc] initWithFormat:@"/api/v1/user/me/favorite/%@", space.remote_id];
    [_rest getURL:url];
    self.rest = _rest;
}

-(void)requestFromREST:(ASIHTTPRequest *)request {
    if ([[request requestMethod] isEqualToString:@"GET"]) {
        if ([request.responseString isEqual: @"true"]) {
            [self.delegate isFavorite:true];
            return;
        }
        [self.delegate isFavorite:false];
    }
        
    if ([[request requestMethod] isEqualToString:@"PUT"] || [[request requestMethod] isEqualToString:@"DELETE"]) {

        [self.saving_delegate favoriteSaved];
    }
    
    if (self.moving_to_server) {
        // Recursive!
        [self moveFavoritesToServerFavorites];
    }
    return;
}

+(BOOL) isFavorite:(Space *)spot {
    NSMutableDictionary *favorites = [Favorites getFavorites];
    id is_favorite = [favorites objectForKey:[NSString stringWithFormat:@"%@", spot.remote_id]];
    
    return !(is_favorite == nil);
}

-(void) addServerFavorite:(Space *)spot {
    [self addServerFavoriteByID:spot.remote_id];
    [Favorites addLocalCacheFavorite:spot];
    // Just to get data to work with
    // [Favorites addFavorite:spot];

}

-(void)addServerFavoriteByID:(id) remote_id {
    REST *_rest = [[REST alloc] init];
    _rest.delegate = self;
    
    NSString *url = [[NSString alloc] initWithFormat:@"/api/v1/user/me/favorite/%@", remote_id];
    [_rest putURL:url withBody:@"true"];
    self.rest = _rest;
    
}

-(void) removeServerFavorite:(Space *)spot {
    REST *_rest = [[REST alloc] init];
    _rest.delegate = self;
    
    
    NSString *url = [[NSString alloc] initWithFormat:@"/api/v1/user/me/favorite/%@", spot.remote_id];
    [_rest deleteURL:url];
    
    [Favorites removeLocalCacheFavorite: spot];

    self.rest = _rest;
}

// Recursive call through restresponse - don't want to slam the server
// with a ton of concurrent requests.
-(void)moveFavoritesToServerFavorites {
    self.moving_to_server = TRUE;
    NSMutableDictionary *current_local = [Favorites getFavorites];

    for (id remote_id in current_local) {
        [Favorites removeFavoriteByID: remote_id];
        [self addServerFavoriteByID:remote_id];
        return;
    }

    [self.moving_delegate movingFinished];
}

+(void) setLocalCacheFromRESTData:(NSArray *)spot_results {
    NSMutableDictionary *favorites = [[NSMutableDictionary alloc] init];

    for (NSDictionary *spot_info in spot_results) {
        NSString *fav_remote_id = [spot_info objectForKey:@"id"];
        NSString *key_name = [NSString stringWithFormat:@"%@", fav_remote_id];
        [favorites setObject:[NSNumber numberWithBool:TRUE] forKey:key_name];
    }
    [Favorites saveLocalCacheFavorites:favorites];
}

+(int) getLocalFavoritesCount {
    NSMutableDictionary *favorites = [Favorites getFavorites];
    long int full_count = [favorites count];
    // This seems quite unlikely, but displaying 0 seems better than an overflow.
    if (full_count > INT_MAX) {
        return 0;
    }
    int count = (int)full_count;
    return count;
}

+(int)getFavoritesCount {
    int local = [Favorites getLocalFavoritesCount];
    if (local > 0) {
        return local;
    }
    
    NSMutableDictionary *favorites = [Favorites getLocalCacheFavorites];
    long int full_count = [favorites count];
    if (full_count > INT_MAX) {
        return 0;
    }
    return (int)full_count;
}

+(void) addFavorite:(Space *)spot {
    NSMutableDictionary *favorites = [Favorites getFavorites];
    [favorites setObject:[NSNumber numberWithBool:TRUE] forKey:[NSString stringWithFormat:@"%@", spot.remote_id]];
    [Favorites saveFavorites:favorites];
}

+(void) removeFavoriteByID:(id)remote_id {
    NSMutableDictionary *favorites = [Favorites getFavorites];
    [favorites removeObjectForKey:[NSString stringWithFormat:@"%@", remote_id]];
    [Favorites saveFavorites:favorites];
}

+(void) removeFavorite:(Space *)spot {
    [Favorites removeFavoriteByID:spot.remote_id];
}

+(BOOL) saveFavorites:(NSMutableDictionary *)favorites {
    NSString *favorites_path = [Favorites getFavoritesPath];
    return [favorites writeToFile:favorites_path atomically:YES];
}

+(NSMutableDictionary *) getFavorites {
    NSString *favorites_path = [Favorites getFavoritesPath];
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    BOOL exists = [fm fileExistsAtPath:favorites_path];
    
    
    if (!exists) {
        NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
        [tmp writeToFile:favorites_path atomically:YES];
    }
  
    NSMutableDictionary *favorite_spots = [[NSMutableDictionary alloc] initWithContentsOfFile:favorites_path];

    return favorite_spots;
}

+(NSString *) getFavoritesPath {
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSError *err = nil;
    NSURL *support_dir = [fm URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES  error:&err];
    
    NSString *favorites_path = [[support_dir path] stringByAppendingPathComponent:@"favorites.dict"];
    return favorites_path;
}

+(NSArray *)getFavoritesIDList {
    NSDictionary *lookup = [Favorites getFavorites];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    for (NSString *key in lookup) {
        [list addObject:key];
    }
    
    return list;
}

#pragma mark -
#pragma mark local cache for the side menu count
+(void) addLocalCacheFavorite:(Space *)spot {
    NSMutableDictionary *favorites = [Favorites getLocalCacheFavorites];
    // Need to be quite sure that the value in the dictionary is an NSString,
    // otherwise the dictionary won't save the entry.
    [favorites setObject:[NSNumber numberWithBool:TRUE] forKey:[NSString stringWithFormat:@"%@", spot.remote_id]];
    [Favorites saveLocalCacheFavorites:favorites];
}

+(void) removeLocalCacheFavoriteByID:(id)remote_id {
    NSMutableDictionary *favorites = [Favorites getLocalCacheFavorites];
    [favorites removeObjectForKey:[NSString stringWithFormat:@"%@", remote_id]];
    [Favorites saveLocalCacheFavorites:favorites];
}

+(void) removeLocalCacheFavorite:(Space *)spot {
    [Favorites removeLocalCacheFavoriteByID:spot.remote_id];
}

+(BOOL) saveLocalCacheFavorites:(NSMutableDictionary *)favorites {
    NSString *favorites_path = [Favorites getLocalCacheFavoritesPath];
    return [favorites writeToFile:favorites_path atomically:YES];
}

+(NSMutableDictionary *) getLocalCacheFavorites {
    NSString *favorites_path = [Favorites getLocalCacheFavoritesPath];
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    BOOL exists = [fm fileExistsAtPath:favorites_path];
    
    
    if (!exists) {
        NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
        [tmp writeToFile:favorites_path atomically:YES];
    }
    
    NSMutableDictionary *favorite_spots = [[NSMutableDictionary alloc] initWithContentsOfFile:favorites_path];
    
    return favorite_spots;
}

+(NSString *) getLocalCacheFavoritesPath {
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSError *err = nil;
    NSURL *support_dir = [fm URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES  error:&err];
    
    NSString *favorites_path = [[support_dir path] stringByAppendingPathComponent:@"local_cache_favorites.dict"];
    return favorites_path;
}


@end

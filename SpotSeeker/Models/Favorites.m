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
    return;
}

+(BOOL) isFavorite:(Space *)spot {
    NSMutableDictionary *favorites = [Favorites getFavorites];
    id is_favorite = [favorites objectForKey:[NSString stringWithFormat:@"%@", spot.remote_id]];
    
    return !(is_favorite == nil);
}

-(void) addServerFavorite:(Space *)spot {
    REST *_rest = [[REST alloc] init];
    _rest.delegate = self;
    
    
    NSString *url = [[NSString alloc] initWithFormat:@"/api/v1/user/me/favorite/%@", spot.remote_id];
    [_rest putURL:url withBody:@"true"];
    self.rest = _rest;   
}

-(void) removeServerFavorite:(Space *)spot {
    REST *_rest = [[REST alloc] init];
    _rest.delegate = self;
    
    
    NSString *url = [[NSString alloc] initWithFormat:@"/api/v1/user/me/favorite/%@", spot.remote_id];
    [_rest deleteURL:url];
    self.rest = _rest;
}

+(int) getFavoritesCount {
    NSMutableDictionary *favorites = [Favorites getFavorites];
    int count = [favorites count];
    return count;
}

+(void) addFavorite:(Space *)spot {
    NSMutableDictionary *favorites = [Favorites getFavorites];
    [favorites setObject:[NSNumber numberWithBool:TRUE] forKey:[NSString stringWithFormat:@"%@", spot.remote_id]];
    [Favorites saveFavorites:favorites];
}

+(void) removeFavorite:(Space *)spot {
    NSMutableDictionary *favorites = [Favorites getFavorites];
    [favorites removeObjectForKey:[NSString stringWithFormat:@"%@", spot.remote_id]];
    [Favorites saveFavorites:favorites];
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

@end

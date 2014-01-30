//
//  Contact.h
//  SpaceScout
//
//  Created by Michael Seibel on 1/29/14.
//
//

#import <Foundation/Foundation.h>
#import "SBJson.h"

@interface Contact : NSObject {
    NSString *type;
    NSString *title;
    NSString *description;
    NSArray *fields;
    NSArray *email_to;
    NSString *email_prefix;
    NSString *email_postfix;
};

@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSArray *fields;
@property (nonatomic, retain) NSArray *email_to;
@property (nonatomic, retain) NSString *email_prefix;
@property (nonatomic, retain) NSString *email_postfix;

+(NSArray *) getContacts;

@end

//
//  Contact.m
//  SpaceScout
//
//  Created by Michael Seibel on 1/29/14.
//
//

#import "Contact.h"

@implementation Contact
@synthesize type;
@synthesize title;
@synthesize description;
@synthesize fields;
@synthesize email_to;
@synthesize email_prefix;
@synthesize email_postfix;

+(NSArray *)getContacts {
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    NSData *data_source = [[NSData alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"contact_config" ofType:@"json"]];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSArray *values = [parser objectWithData:data_source];
    
    for (NSDictionary *contact_values in values) {
        Contact *current = [[Contact alloc] init];
        current.type = [contact_values objectForKey:@"type"];
        current.title = [contact_values objectForKey:@"title"];
        current.description = [contact_values objectForKey:@"description"];
        current.fields = [contact_values objectForKey:@"fields"];
        current.email_to = [contact_values objectForKey:@"email_to"];
        current.email_prefix = [contact_values objectForKey:@"email_prefix"];
        current.email_postfix = [contact_values objectForKey:@"email_postfix"];
        [contacts addObject:current];
    }
    
    return contacts;
}


@end

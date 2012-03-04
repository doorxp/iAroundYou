//
//  Message+Load.m
//  iAroundYou
//
//  Created by 琦钧 冯 on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Message+Load.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "User+Load.h"

#define MESSAGE_ID @"message_id"
#define MESSAGE_CONTENT @"content"
#define MESSAGE_TIME @"posted_time"

@implementation Message (Load)

+(NSArray *)loadMessages
{
    NSLog(@"start loading data");
    NSURL *url = [NSURL URLWithString:@"http://localhost/api/messages"];    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        
    [request startSynchronous]; 
    //NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    
    NSArray *messages = [decoder objectWithData:[request responseData]];
    NSLog(@"load complete");
    NSLog(@"load %d message", [messages count]);
    return messages;
}

+(Message *)messageWithLoadedInfo:(NSDictionary *)messageInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Message *message = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    request.predicate = [NSPredicate predicateWithFormat:@"messageId = %@", [messageInfo objectForKey:MESSAGE_ID]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"postedTime" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
     
    if (!matches || [matches count] > 1) {
        NSLog(@"more than one message with id:%@ exists, error", [messageInfo objectForKey:MESSAGE_ID]);
    }
    else if(![matches count]){
        message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
        NSString *messageId = [messageInfo valueForKey:MESSAGE_ID];
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterNoStyle];
        message.messageId = [f numberFromString:messageId];
        message.content = [messageInfo valueForKey:MESSAGE_CONTENT];
        message.postedTime = [messageInfo objectForKey:MESSAGE_TIME];
        
        message.whoMessage = [User userWithLoadedInfo:messageInfo inManagedContext:context];
    }else {
        message = [matches lastObject];
    }
    
    return message;
}

@end

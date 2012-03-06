//
//  Message+Load.m
//  iAroundYou
//
//  Created by 琦钧 冯 on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Message+Load.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "User+Load.h"

#define SITE_URL @"http://iaroundyou.com/"

#define MESSAGE_ID @"message_id"
#define MESSAGE_CONTENT @"content"
#define MESSAGE_TIME @"posted_time"

@implementation Message (Load)

+(void)post:(NSString *)message location:(CLLocation *)location;
{
    ASIFormDataRequest *formRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[SITE_URL stringByAppendingString: @"/api/messages"]]];
    [formRequest setPostValue:@"10" forKey:@"user_id"];
    [formRequest setPostValue:message forKey:@"content"];
    [formRequest startSynchronous];
    NSError *error = [formRequest error];
    if (error) {
        NSLog(@"%@", error);
    }else {
        NSLog(@"post complete");
    }
}

+(NSArray *)loadMessages
{
    NSLog(@"start loading data");
    NSURL *url = [NSURL URLWithString: @"http://iaroundyou.com/api/messages"];    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        
    [request startSynchronous]; 
    NSError *error = [request error];
    
    if (!error) {
        //NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
        
        NSArray *messages = [decoder objectWithData:[request responseData]];
        NSLog(@"load complete");
        NSLog(@"load %d message", [messages count]);
        return messages;

    }
    else {
        NSLog(@"%@", error );
        return nil;
    }
}

+(Message *)messageWithLoadedInfo:(NSDictionary *)messageInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Message *message = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    request.predicate = [NSPredicate predicateWithFormat:@"messageId = %d", [[messageInfo objectForKey:MESSAGE_ID] intValue]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"postedTime" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
     
    if (!matches || [matches count] > 1) {
        NSLog(@"more than one message with id:%@ exists, error", [messageInfo objectForKey:MESSAGE_ID]);
    }
    else if([matches count] == 0){
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

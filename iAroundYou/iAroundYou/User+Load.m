//
//  User+Load.m
//  iAroundYou
//
//  Created by 琦钧 冯 on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User+Load.h"

#define USER_ID @"user_id"
#define USER_NAME @"user_name"
#define USER_PROFILE_IMAGE_PATH @"profile_tiny_image_path"

@implementation User (Load)

+(User *)userWithLoadedInfo:(NSDictionary *)userInfo inManagedContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"userId = %@", [userInfo objectForKey:USER_ID]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || [matches count] > 1) {
        NSLog(@"more than one user with id = %@ existed", [userInfo objectForKey:USER_ID]);
    }
    else if([matches count] == 0){
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        NSString * userId = [userInfo objectForKey:USER_ID];
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterNoStyle];

        user.userId = [f numberFromString:userId];
        user.name = [userInfo objectForKey:USER_NAME];
        user.profileImagePath = [userInfo valueForKey:USER_PROFILE_IMAGE_PATH];
    }else {
        user = [matches lastObject];
    }
    
    return user;

}

+(User *)userWithUserId:(NSNumber *)userId inManagedContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"userId = %@", userId];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!error) 
    {
        user = [matches lastObject];
        return user;
    }
    else
    {
        NSLog(@"%@", error);
        return nil;
    }
}

@end

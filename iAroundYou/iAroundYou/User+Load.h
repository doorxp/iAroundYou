//
//  User+Load.h
//  iAroundYou
//
//  Created by 琦钧 冯 on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User.h"

@interface User (Load)

+(User *)userWithLoadedInfo:(NSDictionary *)userInfo inManagedContext:(NSManagedObjectContext *)context;
+(User *)userWithUserId:(NSNumber *)userId inManagedContext:(NSManagedObjectContext *)context;

@end

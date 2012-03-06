//
//  Message+Load.h
//  iAroundYou
//
//  Created by 琦钧 冯 on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Message.h"
#import <CoreLocation/CLLocation.h>

@interface Message (Load)

+(NSArray *)loadMessages;
+(void)post:(NSString *)message location:(CLLocation *)location;
+(Message *)messageWithLoadedInfo:(NSDictionary *)messageInfo
           inManagedObjectContext:(NSManagedObjectContext *)context;
@end

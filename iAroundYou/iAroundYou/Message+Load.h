//
//  Message+Load.h
//  iAroundYou
//
//  Created by 琦钧 冯 on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Message.h"

@interface Message (Load)

+(NSArray *)loadMessages;
+(Message *)messageWithLoadedInfo:(NSDictionary *)messageInfo
           inManagedObjectContext:(NSManagedObjectContext *)context;
@end

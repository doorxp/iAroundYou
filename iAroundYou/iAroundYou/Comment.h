//
//  Comment.h
//  iAroundYou
//
//  Created by 琦钧 冯 on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message, User;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * commentId;
@property (nonatomic, retain) NSString * postedTime;
@property (nonatomic, retain) Message *commentTo;
@property (nonatomic, retain) User *whoComment;

@end

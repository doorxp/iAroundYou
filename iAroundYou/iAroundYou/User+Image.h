//
//  User+Image.h
//  iAroundYou
//
//  Created by 琦钧 冯 on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "User.h"

@interface User (Image)<NSURLConnectionDelegate>

-(UIImage *)profileImage;
-(void)loadImage;

@end

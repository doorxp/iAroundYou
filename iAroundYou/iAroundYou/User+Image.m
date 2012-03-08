//
//  User+Image.m
//  iAroundYou
//
//  Created by 琦钧 冯 on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "User+Image.h"

#define PROFILE_IMAGE_BASE_URL @"http://iaroundyou.com"

@implementation User (Image)

-(UIImage *)profileImage
{
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *name = (NSString *)[[self.profileImagePath componentsSeparatedByString:@"/"] lastObject];
    
    NSString *extension = (NSString *)[[name componentsSeparatedByString:@"."] lastObject];
    NSString *filePath = [[docDir stringByAppendingPathComponent:[self.userId stringValue]] stringByAppendingPathExtension:extension];
    
    NSLog(@"try get file from %@", filePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == YES) {
        
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        return image;
    }
    
    return nil;
        
}

-(void)loadImage
{
//    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *name = (NSString *)[[self.profileImagePath componentsSeparatedByString:@"/"] lastObject];
//    
//    NSString *extension = (NSString *)[[name componentsSeparatedByString:@"."] lastObject];
//    NSString *filePath = [[docDir stringByAppendingPathComponent:[self.userId stringValue]] stringByAppendingPathExtension:extension];
//    
//    NSString *imageUrl = [PROFILE_IMAGE_BASE_URL stringByAppendingString:self.profileImagePath];
//    
//    NSURLConnection *conn = [NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl delegate:self];
//                                                                     
//    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
//    [imageData writeToFile:filePath atomically:YES];
}
@end

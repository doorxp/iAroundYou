//
//  MessageDetailViewController.h
//  iAroundYou
//
//  Created by 琦钧 冯 on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface MessageDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;

@property(strong, nonatomic) Message * detailMessage;

@end

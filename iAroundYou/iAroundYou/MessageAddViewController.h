//
//  MessageAddViewController.h
//  iAroundYou
//
//  Created by 琦钧 冯 on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageAddViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnDone;
@property (weak, nonatomic) IBOutlet UITextView *messageContent;

- (IBAction)dismiss:(id)sender;

- (IBAction)addMessage:(UIBarButtonItem *)sender;

@end

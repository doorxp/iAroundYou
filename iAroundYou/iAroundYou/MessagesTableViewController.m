//
//  MessagesTableViewController.m
//  iAroundYou
//
//  Created by 琦钧 冯 on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessagesTableViewController.h"
#import "JSONKit.h"
#import "ASIHTTPRequest.h"
#import "Message+Load.h"

@interface MessagesTableViewController() 
@property(nonatomic, strong) UIManagedDocument *messageDatabase;

-(void)useDocument;
@end

@implementation MessagesTableViewController

@synthesize messageDatabase = _messageDatabase;

-(void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"postedTime" ascending:NO]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.messageDatabase.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

-(void)fetchMessageDataIntoDocument:(UIManagedDocument *)document
{
    dispatch_queue_t fetchQ = dispatch_queue_create("Message Fetch", NULL);
    dispatch_async(fetchQ, ^{
        NSArray *messages = [Message loadMessages];
        [document.managedObjectContext performBlock:^{
            for (NSDictionary *message in messages){
                [Message messageWithLoadedInfo:message inManagedObjectContext:document.managedObjectContext];
            }
        }];
    });
    
    dispatch_release(fetchQ);
}

-(void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.messageDatabase.fileURL path]]) {
        [self.messageDatabase saveToURL:self.messageDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            [self setupFetchedResultsController];
            [self fetchMessageDataIntoDocument:self.messageDatabase];
        }];
    }
    else if(self.messageDatabase.documentState == UIDocumentStateClosed)
    {
        [self.messageDatabase openWithCompletionHandler:^(BOOL successful){
            [self setupFetchedResultsController];
        }];
    }
}

-(void)setMessageDatabase:(UIManagedDocument *)messageDatabase
{
    if (_messageDatabase != messageDatabase) {
        _messageDatabase = messageDatabase;
        [self useDocument];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.messageDatabase)
    {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        url = [url URLByAppendingPathComponent:@"Message Database"];
        
        self.messageDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self  action:nil];
    
    
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Message Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //cell.textLabel.numberOfLines = 2;
    cell.textLabel.text = message.content;
    cell.detailTextLabel.text = message.postedTime;

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


@end

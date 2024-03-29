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
#import "User+Load.h"
#import "User+Image.h"
#import "MessageDetailViewController.h"
#import "ImageDownloader.h"

@interface MessagesTableViewController()<UserProfileImageDownloader>
@property(nonatomic, strong) UIManagedDocument *messageDatabase;

-(void)startUserProfileImageDownload:(User *)user forIndexPath:(NSIndexPath *)indexPath;

-(void)useDocument;
@end

@implementation MessagesTableViewController

@synthesize messageDatabase = _messageDatabase;
@synthesize imageDownloadsInProgress = _imageDownloadsInProgress;


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
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    if(!self.messageDatabase)
    {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        url = [url URLByAppendingPathComponent:@"Message Database"];
        
        self.messageDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    else
    {
        [self setupFetchedResultsController];
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
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;

    User *user = [User userWithUserId:message.whoMessage.userId inManagedContext:message.managedObjectContext];
    
    if(user.profileImage == nil)
    {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO) {
            NSLog(@"file for user %d doesn't exist", [user.userId intValue]);
            [self startUserProfileImageDownload:user forIndexPath:indexPath];
        }
    }
    else
    {
        cell.imageView.image = user.profileImage;
    }
    cell.textLabel.text = message.content;
    [cell.textLabel sizeToFit];
    cell.detailTextLabel.text = message.whoMessage.name;

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
;
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = (Message *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    CGSize expectedLabelSize = [message.content sizeWithFont:[UIFont fontWithName:@"Helvetica" size:17]
                                           constrainedToSize:CGSizeMake(286, 300)
                                               lineBreakMode:UILineBreakModeWordWrap];
    NSLog(@"%f", expectedLabelSize.height);
    
    return expectedLabelSize.height + 11 + 21;
}

-(void)startUserProfileImageDownload:(User *)user forIndexPath:(NSIndexPath *)indexPath
{
    ImageDownloader *downloader = [self.imageDownloadsInProgress objectForKey:user.userId];
    
    if (downloader == nil) 
    {
        NSLog(@"profile image downloader for user with id: %@ ", user.userId);
        downloader = [[ImageDownloader alloc] init];
        downloader.user = user;
        downloader.indexPathInTableView = indexPath;
        downloader.delegate = self;
        [self.imageDownloadsInProgress setObject:downloader forKey:user.userId];
        [downloader startDownload];
        
        NSLog(@"loader threads count: %@",[self.imageDownloadsInProgress count]);
    }
    else
    {
        NSLog(@"profile image downloader for user with id: %@ exists", user.userId);
    }

}

-(void)profileImageDidLoad:(NSIndexPath *)indexPath
{
        ImageDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
        if (iconDownloader != nil)
        {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
            
            // Display the newly loaded image
            cell.imageView.image = iconDownloader.user.profileImage;
        }
    
}

- (IBAction)loadLatestMessages:(UIBarButtonItem *)sender {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicator startAnimating];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicator];
    
    dispatch_queue_t fetchQ = dispatch_queue_create("Message Refresh", NULL);
    dispatch_async(fetchQ, ^{
        NSArray *messages = [Message loadMessages];
        [self.messageDatabase.managedObjectContext performBlock:^{
            for (NSDictionary *message in messages){
                [Message messageWithLoadedInfo:message inManagedObjectContext:self.messageDatabase.managedObjectContext];
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = sender;
        });
    });
    
    dispatch_release(fetchQ);
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController respondsToSelector:@selector(setDetailMessage:)]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [segue.destinationViewController setDetailMessage:message];
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
        
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in visiblePaths)
    {
        Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        User *user = [User userWithUserId:message.whoMessage.userId inManagedContext:message.managedObjectContext];
        if (!user.profileImage) // avoid the app icon download if the app already has an icon
        {
            [self startUserProfileImageDownload:user forIndexPath:indexPath];
        }
    }
    
}



#pragma scroll view delegate

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


@end

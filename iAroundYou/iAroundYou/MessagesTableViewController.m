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

@interface MessagesTableViewController() 
@property(nonatomic, strong) NSArray *messagesArray;    
-(void)loadData;
@end

@implementation MessagesTableViewController


@synthesize messagesArray = _messagesArray;

//-(void)awakeFromNib
//{
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self  action:nil];
//}

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
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

-(void)loadData
{
    
    NSURL *url = [NSURL URLWithString:@"http://192.168.0.101/api/messages"];    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    //[request setDelegate:self];
    //[request startAsynchronous];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url
//                                             cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0];
    
//    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//    JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
//    
//    self.messagesArray = [decoder objectWithData:response];
//    [self.tableView reloadData]; 
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //NSError *error;
    
    dispatch_async(queue, ^(void){
        [request startSynchronous]; 
        //NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
        
        self.messagesArray = [decoder objectWithData:[request responseData]];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //self.messagesArray = [decoder objectWithData:response];
            [[self tableView] reloadData]; 
        });
    });
    dispatch_release(queue);
//    [request startSynchronous];
//    NSError *error = [request error];
//    if (!error) {
//        NSData *response = [request responseData];
//        JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
//        
//        self.messagesArray = [decoder objectWithData:response];
//    }
//    else {
//        NSLog(@"%@", error);
//    }
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *response = [request responseData];
    JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    
    self.messagesArray = [decoder objectWithData:response];
    [self.tableView reloadData];
    
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    
    NSLog(@"%@", error);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.

    return [self.messagesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MessageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *message = [self.messagesArray objectAtIndex:indexPath.row];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.text = (NSString *)[message objectForKey:@"content"];
    
    NSLog(@"%@", [message objectForKey:@"content"]);
    
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end

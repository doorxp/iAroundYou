/*
     File: IconDownloader.m 
 Abstract: Helper object for managing the downloading of a particular app's icon.
 As a delegate "NSURLConnectionDelegate" is downloads the app icon in the background if it does not
 yet exist and works in conjunction with the RootViewController to manage which apps need their icon.
 
 A simple BOOL tracks whether or not a download is already in progress to avoid redundant requests.
  
  
 */

#import "ImageDownloader.h"
#import "User.h"


#define PROFILE_IMAGE_BASE_URL @"http://iaroundyou.com"

@implementation ImageDownloader

@synthesize user = _user;
@synthesize indexPathInTableView = _indexPathInTableView;
@synthesize activeDownload = _activeDownload;
@synthesize imageConnection = _imageConnection;
@synthesize delegate = _delegate;

#pragma mark


- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
    
    NSString *imageUrl = [PROFILE_IMAGE_BASE_URL stringByAppendingString:self.user.profileImagePath];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              [NSURL URLWithString:imageUrl]] delegate:self];
    self.imageConnection = conn;
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    NSLog(@"%@", error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"complete load image data for user:%d", [self.user.userId intValue]);
    NSData *data = [[NSData alloc] initWithData:self.activeDownload];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *name = (NSString *)[[self.user.profileImagePath componentsSeparatedByString:@"/"] lastObject];
    
    NSString *extension = (NSString *)[[name componentsSeparatedByString:@"."] lastObject];
    NSString *filePath = [[docDir stringByAppendingPathComponent:[self.user.userId stringValue]] stringByAppendingPathExtension:extension];
    
    NSLog(@"try write file to from %@", filePath);
    
    [data writeToFile:filePath atomically:YES];
    
    self.activeDownload = nil;

    
    // Release the connection now that it's finished
    self.imageConnection = nil;
        
    // call our delegate and tell it that our icon is ready for display
    [self.delegate profileImageDidLoad:self.indexPathInTableView];
}

@end


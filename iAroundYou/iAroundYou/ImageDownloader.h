/*
     File: IconDownloader.h 
 Abstract: Helper object for managing the downloading of a particular app's icon.
 As a delegate "NSURLConnectionDelegate" is downloads the app icon in the background if it does not
 yet exist and works in conjunction with the RootViewController to manage which apps need their icon.
 
 A simple BOOL tracks whether or not a download is already in progress to avoid redundant requests.
  
  Version: 1.2 
    
 */

@class User;
@class MessagesTableViewController;

@protocol UserProfileImageDownloader;

@interface ImageDownloader : NSObject


@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, strong) id <UserProfileImageDownloader> delegate;

@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, strong) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol UserProfileImageDownloader 

- (void)profileImageDidLoad:(NSIndexPath *)indexPath;

@end
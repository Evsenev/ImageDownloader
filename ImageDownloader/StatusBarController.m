#import "StatusBarController.h"

@implementation StatusBarController {
    DownloadDelegate *downloadDelegate;
    NSMenu *menu;
    ImageWindow *imageWindow;
    NSStatusItem *statusBarItem;
    NSMenuItem *progressItem;
}

NSString *crystalImageName = @"crystal";
NSString *downloadImageName = @"download";
int progressItemIndex = 0;

- (instancetype)init
{
    self = [super init];
    if (self) {
        statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        [self loadMenu];
    }
    return self;
}

-(void)loadMenu {
    [self setStatusBarImageNamed:crystalImageName];
    if(!menu) {
        menu = [[NSMenu alloc] init];
        
        NSMenuItem *downloadItem = [[NSMenuItem alloc] init];
        [downloadItem setTitle:NSLocalizedString(@"DownloadBtn", nil)];
        [downloadItem setTarget:self];
        [downloadItem setAction:@selector(downloadImage)];
        [menu addItem:downloadItem];
        
        [menu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *quitItem = [[NSMenuItem alloc] init];
        [quitItem setTitle:NSLocalizedString(@"QuitBtn", nil)];
        [quitItem setTarget:self];
        [quitItem setAction:@selector(quit)];
        [menu addItem:quitItem];
    }
    statusBarItem.menu = menu;
}

#pragma mark - Visual Actions

-(void)setStatusBarImageNamed:(NSString *)imageName {
    if(statusBarItem)
        [statusBarItem setImage:[NSImage imageNamed:imageName]];
}

-(void)showProgressItem {
    if(!menu)
        [self loadMenu];
    if(!progressItem)
        progressItem = [[NSMenuItem alloc] init];
    [progressItem setTitle:NSLocalizedString(@"Downloading", nil)];
    [menu insertItem:progressItem atIndex:progressItemIndex];
}

-(void)hideProgressItem {
    if(progressItem && menu)
       [menu removeItem:progressItem];
}

-(void)openWindowWithImage:(NSImage *)image {
    NSSize screenSize = [NSScreen mainScreen].frame.size;
    NSPoint centeredPoint = NSMakePoint(screenSize.width/2 - image.size.width/2, screenSize.height/2 - image.size.height/2);
    NSRect frame = NSMakeRect(centeredPoint.x,centeredPoint.y, 0, 0);
    Byte windowMask = NSClosableWindowMask | NSTitledWindowMask;
    if(!imageWindow)
        imageWindow = [[ImageWindow alloc] initWithContentRect:frame
                                                      styleMask:windowMask
                                                        backing:NSBackingStoreBuffered
                                                          defer:NO];
    [imageWindow setFrame:frame display:NO];
    [imageWindow setReleasedWhenClosed:NO];
    [imageWindow showWithImage:image];
}

#pragma mark - Menu Actions

-(void)downloadImage {
    if(!downloadDelegate)
        downloadDelegate = [[DownloadDelegate alloc] init];
    
    __weak StatusBarController *weakSelf = self;
    __weak NSMenuItem *weakProgressItem = progressItem;
    
    NSURL *url = [NSURL URLWithString:[[NSPasteboard generalPasteboard] stringForType:NSPasteboardTypeString]];
    [downloadDelegate setFinishAction:^(NSImage *image){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf openWindowWithImage:image];
            [weakSelf setStatusBarImageNamed:crystalImageName];
        });
    }];
    
    [downloadDelegate setErrorAction:^(NSError *error) {
        if(error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSAlert alertWithError:error] runModal];
            });
        }
        [weakSelf hideProgressItem];
        [weakSelf setStatusBarImageNamed:crystalImageName];
    }];
    
    [downloadDelegate setDownloadingAction:^(NSNumber *progress) {
        NSString *progressText = [NSString stringWithFormat:@"%@: %d%%",
                                  NSLocalizedString(@"Progress", nil), [progress intValue]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakProgressItem setTitle:progressText];
        });
    }];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:downloadDelegate delegateQueue:nil];
    [[session downloadTaskWithURL:url] resume];
    
    [self showProgressItem];
    [self setStatusBarImageNamed:downloadImageName];
}

-(void)quit {
    [[NSApplication sharedApplication] terminate:self];
}
@end

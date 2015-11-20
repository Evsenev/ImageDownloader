#import <Foundation/Foundation.h>

@interface DownloadDelegate : NSObject <NSURLSessionDownloadDelegate>
@property (copy) void (^finishAction)(NSImage *);
@property (copy) void (^downloadingAction)(NSNumber *);
@property (copy) void (^errorAction)(NSError *);
@end

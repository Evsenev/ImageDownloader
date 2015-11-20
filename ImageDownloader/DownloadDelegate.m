#import "DownloadDelegate.h"
#import "AppDelegate.h"

@implementation DownloadDelegate

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSImage *image = [[NSImage alloc] initWithData:[NSData dataWithContentsOfURL:location]];
    if(_finishAction)
        _finishAction(image);
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSNumber *progress = [NSNumber numberWithDouble:(double)totalBytesWritten/(double)totalBytesExpectedToWrite *  100];
    if(_downloadingAction)
        _downloadingAction(progress);
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if(_errorAction)
        _errorAction(error);
}
@end

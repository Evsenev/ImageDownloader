#import "ImageWindow.h"

@implementation ImageWindow{
    NSImageView *imageView;
}

-(void)showWithImage:(NSImage *)image {
    if(!imageView)
        imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0,0,image.size.width, image.size.height)];
    else
       [imageView setFrame:NSMakeRect(0,0,image.size.width, image.size.height)];
    [imageView setImage:image];
    [self.contentView addSubview:imageView];
    [self setFrame:NSMakeRect(self.frame.origin.x, self.frame.origin.y,
                                 image.size.width, image.size.height) display:YES];
    [self makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}
@end

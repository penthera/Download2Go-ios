//
//  DemoPlayerViewController.m
//  Download2GoHelloWorld-Objc
//

#import "DemoPlayerViewController.h"

@implementation DemoPlayerViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self play];
    
    // Redirect errors from FairPlay licensing here so we can handle reporting errors to the user.
    AVURLAsset* asset = (AVURLAsset*)self.playerView.player.currentItem.asset;
    if( [[asset.resourceLoader.delegate class]conformsToProtocol:@protocol(VirtuosoAVAssetResourceLoaderDelegate)] )
    {
        id<VirtuosoAVAssetResourceLoaderDelegate> loader = (id<VirtuosoAVAssetResourceLoaderDelegate>)asset.resourceLoader.delegate;
        loader.errorHandler = self;  // see method resourceLoaderDelegate below
    }
}

- (void)resourceLoaderDelegate:(id<VirtuosoAVAssetResourceLoaderDelegate>)delegate generatedError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"License Error" message:@"An error was encountered playing this content.  Please try again later." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

@end

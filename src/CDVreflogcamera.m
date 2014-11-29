/********* CDVdbcamera.m Cordova Plugin Implementation *******/

#import "Cordova/CDV.h"
#import "BDCameraViewController.h"

@interface CDVreflogcamera : CDVPlugin <UINavigationControllerDelegate, CameraDelegate>{}

@property (copy) NSString* callbackId;

- (void)openCamera:(CDVInvokedUrlCommand*)command;
@end

@implementation CDVreflogcamera

- (void)openCamera:(CDVInvokedUrlCommand*)command
{
    id title = [command.arguments objectAtIndex:0];
    self.callbackId = command.callbackId;
    BDCameraViewController *cameraContainer = [[BDCameraViewController alloc] initWithDelegate:self];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cameraContainer];
    nav.delegate = self;
    cameraContainer.title = title;
    [nav setNavigationBarHidden:NO];
    [self.viewController presentViewController:nav animated:YES completion:nil];
}
#define _PHOTO_PREFIX @"RFCAMERA_"
- (void) imageCaptured:(UIImage *)image
{
    NSData* data = UIImagePNGRepresentation(image);
    NSString* docsPath = [NSTemporaryDirectory()stringByStandardizingPath];
    NSError* err = nil;
    NSFileManager* fileMgr = [[NSFileManager alloc] init];
    NSString* filePath;

    int i = 1;
    do {
        filePath = [NSString stringWithFormat:@"%@/%@%03d.%@", docsPath, _PHOTO_PREFIX, i++, @"png"];
    } while ([fileMgr fileExistsAtPath:filePath]);

    CDVPluginResult* pluginResult = nil;

    if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
    } else {
        NSMutableDictionary* resultDictionary = [[NSMutableDictionary alloc] init];
        [resultDictionary setValue:[[NSURL fileURLWithPath:filePath] absoluteString] forKey:@"imageURL"];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDictionary];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

- (void)closeCamera:(CDVInvokedUrlCommand*)cmd {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UINavigationControllerDelegate

- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController;
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

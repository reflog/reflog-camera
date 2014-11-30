/********* CDVdbcamera.m Cordova Plugin Implementation *******/

#import "Cordova/CDV.h"
#import "BDCameraViewController.h"
#import "MBProgressHUD.h"

@interface CDVreflogcamera : CDVPlugin <UINavigationControllerDelegate, CameraDelegate>{}

@property (copy) NSString* callbackId;
@property (strong, nonatomic) BDCameraViewController *cameraContainer;
- (void)openCamera:(CDVInvokedUrlCommand*)command;
@end

@implementation CDVreflogcamera

- (void)openCamera:(CDVInvokedUrlCommand*)command
{
    self.cameraContainer = [[BDCameraViewController alloc] initWithDelegate:self];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.cameraContainer];
    nav.delegate = self;
    [nav setNavigationBarHidden:NO];
    [self.viewController presentViewController:nav animated:YES completion:nil];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)takePhoto:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    id title = [command.arguments objectAtIndex:0];
    self.cameraContainer.title = title;
}


#define _PHOTO_PREFIX @"RFCAMERA_"
- (void) imageCaptured:(UIImage *)image
{
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.cameraContainer.view animated:YES];
    hud.labelText = @"Saving...";
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData* data = UIImagePNGRepresentation(image);
        
        NSArray *dirPaths;
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask, YES);
        NSString* docsPath = [dirPaths objectAtIndex:0];
        
        NSError* err = nil;
        NSFileManager* fileMgr = [[NSFileManager alloc] init];
        NSString* filePath;
        NSString* fileName;
        
        int i = 1;
        do {
            fileName = [NSString stringWithFormat:@"%@%03d.%@",_PHOTO_PREFIX, i++, @"png"];
            filePath = [NSString stringWithFormat:@"%@/%@", docsPath, fileName];
        } while ([fileMgr fileExistsAtPath:filePath]);
        
        __block CDVPluginResult* pluginResult = nil;
        
        if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
        } else {
            NSMutableDictionary* resultDictionary = [[NSMutableDictionary alloc] init];
            [resultDictionary setValue:[[NSURL fileURLWithPath:fileName] absoluteString] forKey:@"imageURL"];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDictionary];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.cameraContainer.view animated:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
        });
    });
    
   }

- (void)closeCamera:(CDVInvokedUrlCommand*)command {
    [self.viewController dismissViewControllerAnimated:YES completion:^{
        self.cameraContainer = nil;
        NSLog(@"sending result to %@",command.callbackId);
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

#pragma mark - UINavigationControllerDelegate

- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController;
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

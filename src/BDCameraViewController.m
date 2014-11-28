#import "BDCameraViewController.h"
#import "ExpandButton.h"
#import <AVFoundation/AVFoundation.h>

@implementation BDPhotoCameraView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.camera = [[BDStillImageCamera alloc] initWithPreviewView:self preset:AVCaptureSessionPresetPhoto];
    [self.camera startCameraCapture];
}

- (void)takePhotoWithCompletion:(void (^)(UIImage *))completion
{
    [self.camera takeImageWithCompletion:^(UIImage *capturedImage, NSError *error) {
        completion(capturedImage);
    }];
}

@end

@interface BDCameraViewController ()
@property (strong, nonatomic) BDPhotoCameraView *cameraView;
@property (strong, nonatomic) DDExpandableButton* modeButton;
@property (strong, nonatomic) UISlider* slider;
@property (weak, nonatomic) id<CameraDelegate> delegate;
@end

@implementation BDCameraViewController

- (id)initWithDelegate:(id<CameraDelegate>)delegate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    // View defaults to full size.  If you want to customize the view's size, or its subviews (e.g. webView),
    // you can do so here.

    [super viewWillAppear:animated];
}

- (void)controlChanged:(DDExpandableButton *)sender

{
    self.modeButton.hidden = sender.selectedItem != 1;
    self.slider.hidden = sender.selectedItem != 1;
}


- (void)changeLensPosition:(id)sender
{
    UISlider *control = sender;
    NSError *error = nil;
    
    if ([self.cameraView.camera.videoDevice lockForConfiguration:&error])
    {
        [self.cameraView.camera.videoDevice setFocusModeLockedWithLensPosition:control.value completionHandler:nil];
    }
    else
    {
        NSLog(@"%@", error);
    }
}
- (AVCaptureWhiteBalanceGains)normalizedGains:(AVCaptureWhiteBalanceGains) gains
{
    AVCaptureWhiteBalanceGains g = gains;
    
    g.redGain = MAX(1.0, g.redGain);
    g.greenGain = MAX(1.0, g.greenGain);
    g.blueGain = MAX(1.0, g.blueGain);
    
    g.redGain = MIN(self.cameraView.camera.videoDevice.maxWhiteBalanceGain, g.redGain);
    g.greenGain = MIN(self.cameraView.camera.videoDevice.maxWhiteBalanceGain, g.greenGain);
    g.blueGain = MIN(self.cameraView.camera.videoDevice.maxWhiteBalanceGain, g.blueGain);
    
    return g;
}
- (IBAction)changeTemperature:(id)sender
{
    AVCaptureWhiteBalanceTemperatureAndTintValues temperatureAndTint = {
        .temperature = self.slider.value,
        .tint = 0,
    };
    AVCaptureWhiteBalanceGains gains = [self.cameraView.camera.videoDevice deviceWhiteBalanceGainsForTemperatureAndTintValues:temperatureAndTint];
    
    
    NSError *error = nil;
    
    if ([self.cameraView.camera.videoDevice lockForConfiguration:&error])
    {
        AVCaptureWhiteBalanceGains normalizedGains = [self normalizedGains:gains]; // Conversion can yield out-of-bound values, cap to limits
        [self.cameraView.camera.videoDevice setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains:normalizedGains completionHandler:nil];
    }
    else
    {
        NSLog(@"%@", error);
    }

}


static float EXPOSURE_DURATION_POWER = 5; // Higher numbers will give the slider more sensitivity at shorter durations
static float EXPOSURE_MINIMUM_DURATION = 1.0/1000; // Limit exposure duration to a useful range

- (IBAction)changeExposureDuration:(id)sender
{
    UISlider *control = sender;
    NSError *error = nil;
    
    double p = pow( control.value, EXPOSURE_DURATION_POWER ); // Apply power function to expand slider's low-end range
    double minDurationSeconds = MAX(CMTimeGetSeconds(self.cameraView.camera.videoDevice.activeFormat.minExposureDuration), EXPOSURE_MINIMUM_DURATION);
    double maxDurationSeconds = CMTimeGetSeconds(self.cameraView.camera.videoDevice.activeFormat.maxExposureDuration);
    double newDurationSeconds = p * ( maxDurationSeconds - minDurationSeconds ) + minDurationSeconds; // Scale from 0-1 slider range to actual duration
    
    
    if ([self.cameraView.camera.videoDevice lockForConfiguration:&error])
    {
        [self.cameraView.camera.videoDevice setExposureModeCustomWithDuration:CMTimeMakeWithSeconds(newDurationSeconds, 1000*1000*1000)  ISO:AVCaptureISOCurrent completionHandler:nil];
    }
    else
    {
        NSLog(@"%@", error);
    }
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
        AVCaptureDevice *device = self.cameraView.camera.videoDevice;
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.cameraView.camera.videoDevice.focusMode != AVCaptureFocusModeLocked && self.cameraView.camera.videoDevice.exposureMode != AVCaptureExposureModeCustom)
    {
        CGPoint devicePoint = [self.cameraView.camera.previewLayer captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
        [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
    }
}
- (void)modeChanged:(DDExpandableButton *)sender
{
    switch(self.modeButton.selectedItem){
        case 0 :
            [self changeLensPosition:self.slider];
            break;
        case 1 :
            [self changeExposureDuration:self.slider];
            break;
        case 2 :
            [self changeTemperature:self.slider];
            break;
    }
}

- (void) sliderChanged:(UISlider*)sender{
    [self modeChanged:self.modeButton];
}

- (void) capture:(id) sender{
    [self.cameraView takePhotoWithCompletion:^(UIImage *image) {
        
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

    self.cameraView = [[BDPhotoCameraView alloc] initWithFrame:self.view.bounds];
    [self.cameraView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusAndExposeTap:)]];
    [self.view addSubview:self.cameraView];
    
    NSArray *buttons = [NSArray arrayWithObjects:@"Focus", @"Exposure", @"White Balance", nil];
    DDExpandableButton *modeButton = [[DDExpandableButton alloc] initWithPoint:CGPointMake(20, 55) leftTitle:@"Mode:" buttons:buttons] ;
    [[self view] addSubview:modeButton];
    self.modeButton = modeButton;
    NSArray *buttons2 = [NSArray arrayWithObjects:@"Auto", @"Manual", nil];
    DDExpandableButton *controlButton = [[DDExpandableButton alloc] initWithPoint:CGPointMake(20, 20) leftTitle:@"Control:" buttons:buttons2] ;
    controlButton.toggleMode = TRUE;
    controlButton.selectedItem  = 0;
    [[self view] addSubview:controlButton];
    
    UISlider* slider = [[UISlider alloc]initWithFrame:CGRectMake(20,85,200,40)];
    self.slider = slider;
    [[self view] addSubview:slider];

    
    [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [controlButton addTarget:self action:@selector(controlChanged:) forControlEvents:UIControlEventValueChanged];
    [modeButton addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventValueChanged];
    [self controlChanged:controlButton];
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom] ;
    [btn setImage:[UIImage imageNamed:@"trigger.png"] forState:UIControlStateNormal];
    [btn sizeToFit];
    CGRect btnFrame = btn.frame;
    btnFrame.origin.y = self.view.bounds.size.height - btnFrame.size.height - 10;
    btnFrame.origin.x = (self.view.bounds.size.width - btnFrame.size.width)/2;
    btn.frame = btnFrame;
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(capture:) forControlEvents:UIControlEventTouchUpInside];
 }

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

@end

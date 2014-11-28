
#import "BDStillImageCamera.h"


@interface BDPhotoCameraView : UIView

@property (nonatomic, strong) BDStillImageCamera *camera;

- (void)takePhotoWithCompletion:(void(^)(UIImage *image))completion;

@end

@protocol CameraDelegate <NSObject>

- (void) imageCaptured: (UIImage*)img;

@end

@interface BDCameraViewController : UIViewController
- (id)initWithDelegate:(id<CameraDelegate>)delegate;
@end

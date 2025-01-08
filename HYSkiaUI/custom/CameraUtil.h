#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "CameraData.h"

using namespace HYSkiaUI;

@interface CameraUtil : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;

- (instancetype)init: (void *)context;
- (void)startCamera;
- (void)stopCamera;
- (CameraData*)getCameraData;

@end

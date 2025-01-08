#import "CameraUtil.h"
#include "SkiaUIContext.h"

using namespace HYSkiaUI;

@interface CameraUtil()

@end

@implementation CameraUtil {
    SkiaUIContext* _context;
    CameraData* data;
}

- (instancetype)init: (void *)context; {
    self = [super init];
    if (self) {
        self->_context = (SkiaUIContext*)context;
        self->data = nullptr;
    }
    return self;
}

- (void)startCamera {
    [self checkCameraPermission];
}

- (void)checkCameraPermission {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                [self setupCameraSession];
            } else {
                NSLog(@"Camera access denied");
            }
        }];
    } else if (status == AVAuthorizationStatusAuthorized) {
        [self setupCameraSession];
    } else {
        NSLog(@"Camera access denied");
    }
}

- (void)setupCameraSession {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.captureSession = [[AVCaptureSession alloc] init];
        
        AVCaptureDevice *camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&error];
        if (input) {
            [self.captureSession addInput:input];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
            return;
        }
        
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        [output setSampleBufferDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        output.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
        [self.captureSession addOutput:output];
        [self.captureSession startRunning];
    });
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    uint8_t *yPlane = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t yWidth = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
    size_t yHeight = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
    size_t yPlaneSize = yWidth * yHeight;
    uint8_t *uvPlane = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
    size_t uvWidth = CVPixelBufferGetWidthOfPlane(imageBuffer, 1);
    size_t uvHeight = CVPixelBufferGetHeightOfPlane(imageBuffer, 1);
    size_t uvPlaneSize = uvWidth * uvHeight;
    uint8_t *yCopy = (uint8_t *)malloc(yPlaneSize);
    uint8_t *uvCopy = (uint8_t *)malloc(uvPlaneSize);
    memcpy(yCopy, yPlane, yPlaneSize);
    memcpy(uvCopy, uvPlane, uvPlaneSize);
    
    auto data = new CameraData();
    data->y = yPlane;
    data->yWidth = yWidth;
    data->yHeight = yHeight;
    data->uv = uvPlane;
    data->uvWidth = uvWidth;
    data->uvHeight = uvHeight;
    if (self->_context != nullptr) {
        self->_context->sendToUIThread([self, data]() {
            delete self->data;
            self->data = data;
        });
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

- (void)stopCamera {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.captureSession stopRunning];
        self.captureSession = nil;
        delete self->data;
    });
}

- (CameraData*)getCameraData {
    return self->data;
}

@end

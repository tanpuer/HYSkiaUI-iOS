#import "HYVideoDecoder.h"
#include "SkiaUIContext.h"
#include "memory"
#include "HYAudioPlayer.h"

@interface HYVideoDecoder ()

@property (nonatomic, strong) AVAssetReader *assetReader;
@property (nonatomic, strong) AVAssetReaderTrackOutput *videoTrackOutput;
@property (nonatomic, strong) dispatch_queue_t decodingQueue;

@property (nonatomic, strong) HYAudioPlayer* _audioPlayer;
@property bool _paused;
@property int64_t _pts;

@property (atomic) BOOL _stop;

@end

@implementation HYVideoDecoder {
    SkiaUIContext* _context;
    HYVideoFrameData* currentFrameData;
}

- (instancetype)init: (void *)context {
    self = [super init];
    if (self) {
        self._stop = false;
        self._pts = 0L;
        self->_context = (SkiaUIContext*)context;
        static std::string decodingName = "video-decoding";
        decodingName += "1";
        self.decodingQueue = dispatch_queue_create(decodingName.c_str(), DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc {
    NSLog(@"HYVideoDecoder dealloc");
    self->_context = nullptr;
    delete currentFrameData;
    self._audioPlayer = nil;
}

- (void)setSource: (const char*)path {
    self._paused = false;
    dispatch_async(self.decodingQueue, ^{
        self._audioPlayer = [[HYAudioPlayer alloc]init];
        [self._audioPlayer setSource:path];
        [self._audioPlayer play];
        
        self->currentFrameData = nullptr;
        NSString *resource = [NSString stringWithUTF8String:path];
        NSString *videoPath = [[NSBundle mainBundle] pathForResource:resource ofType:nil];
        if (!videoPath) {
            NSLog(@"Video file not found: %@", resource);
            return;
        }
        NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
        NSError *error = nil;
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        if (!videoTrack) {
            NSLog(@"No video track found in %@", resource);
            return;
        }
        self.assetReader = [AVAssetReader assetReaderWithAsset:asset error:&error];
        if (error) {
            NSLog(@"Failed to create asset reader: %@", error);
            return;
        }
        NSDictionary *outputSettings = @{
            (NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
        };
        self.videoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack
                                                                           outputSettings:outputSettings];
        [self.assetReader addOutput:self.videoTrackOutput];
        [self.assetReader startReading];
        [self decodeOneFrame];
    });
}

- (void)decodeOneFrame {
    if (self._stop) {
        [self.assetReader cancelReading];
        self.assetReader = nil;
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 8.0 * MSEC_PER_SEC), self.decodingQueue, ^{
        [self decodeOneFrame];
    });
    long audioPts = [self._audioPlayer getCurrPosition];
    if (self._pts > audioPts) {
        return;
    }
    CMSampleBufferRef sampleBuffer = [self.videoTrackOutput copyNextSampleBuffer];
    if (!sampleBuffer) {
        if (self.assetReader.status == AVAssetReaderStatusCompleted) {
            NSLog(@"Video playback completed");
        } else if (self.assetReader.status == AVAssetReaderStatusFailed) {
            NSLog(@"Video decoding failed: %@", self.assetReader.error);
        }
        return;
    }
    CMTime time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer) {
        // 锁定 buffer 以便读取
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        size_t width = CVPixelBufferGetWidth(pixelBuffer);
        size_t height = CVPixelBufferGetHeight(pixelBuffer);
        size_t yStride = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
        size_t ySize = yStride * height;
        uint8_t *ySource = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        size_t uvStride = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
        size_t uvHeight = height / 2;
        size_t uvSize = uvStride * uvHeight;
        uint8_t *uvSource = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        CMTimeScale timescale = time.timescale;
        int64_t seconds = time.value / timescale;
        int64_t milliseconds = (time.value % timescale) * 1000 / timescale;
        long pts = seconds * 1000 + milliseconds;
        HYVideoFrameData *frameData = new HYVideoFrameData();
        frameData->yData = (uint8_t *)malloc(ySize);
        frameData->uvData = (uint8_t *)malloc(uvSize);
        memcpy(frameData->yData, ySource, ySize);
        memcpy(frameData->uvData, uvSource, uvSize);
        frameData->width = (int)width;
        frameData->height = (int)height;
        frameData->yStride = (int)yStride;
        frameData->uvStride = (int)uvStride;
        frameData->pts = pts;
        self._pts = pts;
        if (self->_context == nullptr) {
            delete frameData;
        } else {
            self->_context->runOnUIThread<HYVideoFrameData*>([frameData](){
                return frameData;
            }, [self](HYVideoFrameData* data) {
                [self setVideoFrameData:data];
            });
        }
        // 解锁 buffer
//        ALOGD("current video pts:%ld, audio pts:%ld", pts, audioPts);
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    }
    CFRelease(sampleBuffer);
}

- (void)setVideoFrameData: (HYVideoFrameData*)data {
    if (self->currentFrameData != nullptr) {
        delete self->currentFrameData;
    }
    self->currentFrameData = data;
}

- (const HYVideoFrameData*)getFrameData {
    return self->currentFrameData;
}

- (void)pause {
    if (self._paused) {
        return;
    }
    self._paused = true;
    dispatch_async(self.decodingQueue, ^{
        if (self._audioPlayer) {
            [self._audioPlayer pause];
        }
    });
}

- (void)start {
    if (!self._paused) {
        return;
    }
    self._paused = false;
    dispatch_async(self.decodingQueue, ^{
        if (self._audioPlayer) {
            [self._audioPlayer play];
        }
    });
}

- (void)stop {
    self._stop = true;
}

@end

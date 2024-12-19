#import "HYSkiaMetalApp.hpp"
#import <include/gpu/ganesh/GrBackendSurface.h>
#import <include/gpu/ganesh/SkImageGanesh.h>
#import <include/gpu/ganesh/SkSurfaceGanesh.h>
#import <include/gpu/ganesh/mtl/GrMtlBackendContext.h>
#import <include/gpu/ganesh/mtl/GrMtlBackendSurface.h>
#import <include/gpu/ganesh/mtl/GrMtlDirectContext.h>
#import <include/gpu/ganesh/mtl/SkSurfaceMetal.h>
#import <include/gpu/ganesh/GrContextOptions.h>
#import <include/gpu/ganesh/GrRecordingContext.h>
#import <include/gpu/ganesh/GrDirectContext.h>
#import <include/core/SkCanvas.h>
#import <include/core/SkColorSpace.h>
#import "native_log.h"

namespace HYSkiaUI {

HYSkiaMetalApp::HYSkiaMetalApp(int width, int height) {
    _layer = [CAMetalLayer layer];
    _width = width;
    _height = height;
    _layer.frame = CGRectMake(0, 0, width, height);
    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = id<MTLCommandQueue>(CFRetain((GrMTLHandle)[_device newCommandQueue]));
    GrMtlBackendContext backendContext = {};
    backendContext.fDevice.reset((__bridge void *)_device);
    backendContext.fQueue.reset((__bridge void *)_commandQueue);
    GrContextOptions grContextOptions;
    _skContext = GrDirectContexts::MakeMetal(backendContext);
    if (_skContext == nullptr) {
        ALOGD(@"Couldn't create a Skia Metal Context");
        return;
    }
    _layer.framebufferOnly = NO;
    _layer.device = MTLCreateSystemDefaultDevice();
    _layer.opaque = false;
    _layer.contentsScale = [UIScreen mainScreen].scale;
    _layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    _layer.contentsGravity = kCAGravityBottomLeft;
    _layer.drawableSize = CGSizeMake(width, height);
    ALOGD(@"create Skia Metal Context!");
}

HYSkiaMetalApp::~HYSkiaMetalApp() {
    _layer = nil;
}

sk_sp<SkSurface> HYSkiaMetalApp::getSurface() {
    if (_skSurface) {
        return _skSurface;
    }
    _currentDrawable = [_layer nextDrawable];
    if (!_currentDrawable) {
        ALOGD(@"Could not retrieve drawable from CAMetalLayer");
        return nullptr;
    }
    GrMtlTextureInfo fbInfo;
    fbInfo.fTexture.retain((__bridge void*)_currentDrawable.texture);
    auto backendRT = GrBackendRenderTargets::MakeMtl(_layer.drawableSize.width, _layer.drawableSize.height, fbInfo);
    _skSurface = SkSurfaces::WrapBackendRenderTarget(_skContext.get(), backendRT, kTopLeft_GrSurfaceOrigin, kBGRA_8888_SkColorType, nullptr, nullptr);
    if (!_skSurface) {
        ALOGD(@"create SkSurface failed");
    }
    return _skSurface;
}

void HYSkiaMetalApp::draw(SkPicture* picture) {
    if (picture == nullptr) {
        return;
    }
    auto surface = getSurface();
    auto skCanvas = surface->getCanvas();
    skCanvas->clear(SK_ColorWHITE);
    picture->playback(skCanvas);
    picture->unref();
    _skContext->flushAndSubmit();
    
    id<MTLCommandBuffer> commandBuffer([_commandQueue commandBuffer]);
    [commandBuffer presentDrawable:_currentDrawable];
    [commandBuffer commit];
    _skSurface = nullptr;
}

CAMetalLayer* HYSkiaMetalApp::getLayer() {
    return _layer;
}

}

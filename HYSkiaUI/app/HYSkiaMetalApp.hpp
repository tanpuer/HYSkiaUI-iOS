#pragma once

#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#import <include/gpu/ganesh/GrDirectContext.h>
#import <include/core/SkSurface.h>
#import <include/core/SkPicture.h>


class HYSkiaMetalApp {
    
public:
    
    HYSkiaMetalApp(int width, int height);
    
    ~HYSkiaMetalApp();
    
    sk_sp<SkSurface> getSurface();
    
    void draw(SkPicture* picture);
    
    CAMetalLayer* getLayer();
    
private:
    
    CAMetalLayer *_layer = nullptr;
    
    int _width = 0;
    
    int _height = 0;
    
    id<MTLDevice> _device;
    
    id<MTLCommandQueue> _commandQueue = nullptr;
    
    id<CAMetalDrawable> _currentDrawable = nil;
    
    sk_sp<GrDirectContext> _skContext = nullptr;
    
    sk_sp<SkSurface> _skSurface = nullptr;
    
};

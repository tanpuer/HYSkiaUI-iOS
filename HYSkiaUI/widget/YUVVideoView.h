#pragma once

#include "View.h"
#include "string"
#include "core/SkImage.h"
#include "View.h"
#include "effects/SkRuntimeEffect.h"
#include "HYVideoDecoder.h"

namespace HYSkiaUI {

class YUVVideoView : public View {
    
public:
    
    YUVVideoView();
    
    virtual ~YUVVideoView();
    
    void setSource(const char *path);
    
    const char* getSource();
    
    void start();
    
    void pause();
    
    void draw(SkCanvas *canvas) override;
    
    const char *name() override;
    
    void onShow() override;
    
    void onHide() override;
    
    void setRenderFirstFrameCallback(std::function<void()>&& callback);
    
private:
    
    SkRect dstRect;
    
    std::unique_ptr<SkPaint> videoPaint;
    
    std::string src;
    
    sk_sp<SkRuntimeEffect> runtimeEffect = nullptr;
    
    std::function<void()> renderFirstFrameCallback = nullptr;
    
    bool firstFrame = true;
    
    HYVideoDecoder* videoDecoder = nullptr;
    
};

}

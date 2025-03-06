#pragma once

#include "IAnimator.h"
#include "View.h"

namespace HYSkiaUI {

class LinearAnimator : public IAnimator {
    
public:
    
    LinearAnimator(View *view, float startValue, float endValue);
    
    ~LinearAnimator();
    
    void update(SkIRect &rect) override;
    
    void setUpdateListener(std::function<void(View *, float)> &&listener);
    
private:
    
    float startValue, endValue;
    View *targetView;
    std::function<void(View *, float)> updateListener = nullptr;
    
    void updateInner();
    
#pragma mark JavaScriptCore
public:
    
    void protectCallback(JSContextRef ctx, JSObjectRef callback);
    
protected:
    
    JSObjectRef jsCallback = nullptr;
    
    JSContextRef ctx = nullptr;
    
};

}

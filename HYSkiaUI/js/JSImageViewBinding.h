#pragma once

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#include "JSViewBinding.h"

namespace HYSkiaUI {

class JSImageViewBinding: public JSViewBinding {
    
public:
    
    JSImageViewBinding() = default;
    
    virtual ~JSImageViewBinding() = default;
    
    void registerImageView(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext>& context);
    
    static JSValueRef ImageViewGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception);
    
    static bool ImageViewSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception);
    
};

}





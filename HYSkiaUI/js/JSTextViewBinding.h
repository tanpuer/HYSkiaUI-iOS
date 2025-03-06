#pragma once

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#include "JSViewBinding.h"

namespace HYSkiaUI {

class JSTextViewBinding: public JSViewBinding {
    
public:
    
    JSTextViewBinding() = default;
    
    virtual ~JSTextViewBinding() = default;
    
    void registerTextView(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext>& context);
    
    static JSValueRef TextViewGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception);
    
    static bool TextViewSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception);
    
};

}




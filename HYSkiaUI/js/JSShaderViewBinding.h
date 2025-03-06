#pragma once

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#include "JSViewBinding.h"

namespace HYSkiaUI {

class JSShaderViewBinding: public JSViewBinding {
    
public:
    
    JSShaderViewBinding() = default;
    
    virtual ~JSShaderViewBinding() = default;
    
    void registerShaderView(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext>& context);
    
    static JSValueRef ShaderViewGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception);
    
    static bool ShaderViewSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception);
    
};

}







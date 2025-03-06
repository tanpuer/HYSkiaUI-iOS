#pragma once

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#include "JSViewBinding.h"

namespace HYSkiaUI {

class JSSVGBinding: public JSViewBinding {
    
public:
    
    JSSVGBinding() = default;
    
    virtual ~JSSVGBinding() = default;
    
    void registerSVG(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext>& context);
    
    static JSValueRef SVGGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception);
    
    static bool SVGSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception);
    
};

}






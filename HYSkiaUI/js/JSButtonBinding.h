#pragma once

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#include "JSTextViewBinding.h"

namespace HYSkiaUI {

class JSButtonBinding: public JSTextViewBinding {
    
public:
    
    JSButtonBinding() = default;
    
    virtual ~JSButtonBinding() = default;
    
    void registerButton(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext>& context);
    
    static JSValueRef ButtonGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception);
    
    static bool ButtonSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception);
    
};

}





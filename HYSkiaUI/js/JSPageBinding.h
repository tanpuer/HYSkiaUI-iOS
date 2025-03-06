#pragma once

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#include "JSViewGroupBinding.h"

namespace HYSkiaUI {

class JSPageBinding: public JSViewGroupBinding {
    
public:
    
    JSPageBinding() = default;
    
    virtual ~JSPageBinding() = default;
    
    void registerPage(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext>& context);
    
    static JSValueRef PageGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception);
    
    static bool PageSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception);
    
};

}

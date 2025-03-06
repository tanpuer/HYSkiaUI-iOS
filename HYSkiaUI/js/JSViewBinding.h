#pragma once

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#include "View.h"

namespace HYSkiaUI {

class JSViewBinding {
    
public:
    
    JSViewBinding() = default;
    
    virtual ~JSViewBinding() = default;
    
    static std::string JSStringToStdString(JSStringRef jsString);
    
    void registerView(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext>& context);
    
    static JSValueRef ViewGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception);
    
    static bool ViewSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception);
    
protected:
    
    std::shared_ptr<SkiaUIContext> context = nullptr;
    
};

}

#pragma once

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#include "JSViewGroupBinding.h"

namespace HYSkiaUI {

class JSFlexboxLayoutBinding: public JSViewGroupBinding {
    
public:
    
    JSFlexboxLayoutBinding() = default;
    
    virtual ~JSFlexboxLayoutBinding() = default;
    
    void registerFlexboxLayout(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext>& context);
    
    static JSValueRef FlexboxLayoutGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception);
    
    static bool FlexboxLayoutSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception);
    
};

}


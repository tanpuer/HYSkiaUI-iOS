#pragma once

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#include "JSFlexboxLayoutBinding.h"

namespace HYSkiaUI {

class JSScrollViewBinding: public JSFlexboxLayoutBinding {
    
public:
    
    JSScrollViewBinding() = default;
    
    virtual ~JSScrollViewBinding() = default;
    
    void registerScrollView(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext>& context);
    
    static JSValueRef ScrollViewGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception);
    
    static bool ScrollViewSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception);
    
};

}

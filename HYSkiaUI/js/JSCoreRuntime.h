#pragma once

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

namespace HYSkiaUI {

class JSCoreRuntime {
    
public:
    
    JSCoreRuntime();
    
    ~JSCoreRuntime();
    
private:
    
    JSContext* _jsContext = nullptr;
    
};

}

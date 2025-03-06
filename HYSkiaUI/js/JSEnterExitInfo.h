#pragma once

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#include "SkiaUIContext.h"

namespace HYSkiaUI {

class JSEnterExitInfo {

public:
    
    JSEnterExitInfo();
    
    ~JSEnterExitInfo();
    
    virtual void registerView(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext>& context);
    
};

}


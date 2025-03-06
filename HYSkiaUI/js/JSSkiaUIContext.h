#pragma once

#include "SkiaUIContext.h"

namespace HYSkiaUI {
 
class JSSkiaUIContext {
    
public:
    
    static JSSkiaUIContext* getInstance() {
        static JSSkiaUIContext instance;
        return &instance;
    }
    
    std::shared_ptr<SkiaUIContext>& getUIContext() {
        return context;
    }
    
    void setUIContext(std::shared_ptr<SkiaUIContext>& context) {
        this->context = context;
    }
    
private:
    
    std::shared_ptr<SkiaUIContext> context = nullptr;
    
};
    
}

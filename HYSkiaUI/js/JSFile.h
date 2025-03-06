#pragma once
#include "SkiaUIContext.h"

namespace HYSkiaUI {

class JSFile {
    
public:
    
    JSFile(std::shared_ptr<SkiaUIContext>& context, const char* name);
    
    ~JSFile();
    
    const char* read();
    
private:
    
    std::string name;
    
    std::shared_ptr<SkiaUIContext> context = nullptr;
    
};

}

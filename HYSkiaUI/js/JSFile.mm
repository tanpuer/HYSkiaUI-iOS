#include "JSFile.h"

namespace HYSkiaUI {

JSFile::JSFile(std::shared_ptr<SkiaUIContext>& context, const char* name) {
    this->context = context;
    this->name = name;
}

JSFile::~JSFile() {
    
}

const char* JSFile::read() {
    return context->getAssetManager()->readFile(name.c_str());
}

}

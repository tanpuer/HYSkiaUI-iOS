#import "JSEnterExitInfo.h"
#include "Page.h"

namespace HYSkiaUI {

JSClassRef sEnterExitInfoClass = nullptr;

static JSObjectRef enterExitInfoConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
    assert(argc == 2 || argc == 3);
    auto width = JSValueToNumber(ctx, argv[0], exception);
    auto height = JSValueToNumber(ctx, argv[1], exception);
    auto duration = 500;
    if (argc == 3) {
        duration = JSValueToNumber(ctx, argv[2], exception);
    }
    auto info = new Page::EnterExitInfo(width, height, duration);
    return JSObjectMake(ctx, sEnterExitInfoClass, info);
}

JSEnterExitInfo::JSEnterExitInfo() {
    
}

JSEnterExitInfo::~JSEnterExitInfo() {
    
}

void JSEnterExitInfo::registerView(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext> &context) {
    JSStringRef className = JSStringCreateWithUTF8CString("EnterExitInfo");
    static JSClassDefinition InfoClassDef = {
        0, kJSClassAttributeNone,
        "EnterExitInfo", nullptr, nullptr,
        nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
        nullptr, nullptr, nullptr,
        nullptr, nullptr, nullptr
    };
    sEnterExitInfoClass = JSClassCreate(&InfoClassDef);
    JSObjectRef constructor = JSObjectMakeConstructor(ctx, sEnterExitInfoClass, enterExitInfoConstructor);
    JSObjectSetProperty(ctx, SkiaUI, className, constructor, kJSPropertyAttributeNone, nullptr);
    JSStringRelease(className);
}

}

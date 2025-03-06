#include "JSButtonBinding.h"
#include "Button.h"
#include "JSSkiaUIContext.h"
#include "w3c_util.h"

namespace HYSkiaUI {

static JSClassRef sButtonClass = nullptr;

static JSObjectRef ButtonConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
    Button* button = new Button();
    button->setContext(JSSkiaUIContext::getInstance()->getUIContext());
    return JSObjectMake(ctx, sButtonClass, button);
}

static void ButtonFinalize(JSObjectRef object) {
    
}

JSValueRef JSButtonBinding::ButtonGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception) {
    return JSTextViewBinding::TextViewGetProperty(ctx, object, propertyName, exception);
}

bool JSButtonBinding::ButtonSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception) {
    return JSTextViewBinding::TextViewSetProperty(ctx, object, propertyName, value, exception);
}

void JSButtonBinding::registerButton(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext> &context) {
    JSStringRef className = JSStringCreateWithUTF8CString("Button");
    static JSClassDefinition ButtonClassDef = {
        0, kJSClassAttributeNone,
        "Button", nullptr, nullptr,
        nullptr, nullptr, ButtonFinalize, nullptr, ButtonGetProperty, ButtonSetProperty,
        nullptr, nullptr, nullptr,
        nullptr, nullptr, nullptr
    };
    sButtonClass = JSClassCreate(&ButtonClassDef);
    JSObjectRef constructor = JSObjectMakeConstructor(ctx, sButtonClass, ButtonConstructor);
    
    JSStringRef protoName = JSStringCreateWithUTF8CString("prototype");
    JSValueRef buttonProtoValue = JSObjectGetProperty(ctx, constructor, protoName, nullptr);
    JSObjectRef buttonPrototype = JSValueToObject(ctx, buttonProtoValue, nullptr);
    
    // 4. 显式继承View原型
    JSStringRef textViewName = JSStringCreateWithUTF8CString("TextView");
    JSValueRef textViewConstructorVal = JSObjectGetProperty(ctx, SkiaUI, textViewName, nullptr);
    JSObjectRef textViewConstructor = JSValueToObject(ctx, textViewConstructorVal, nullptr);
    JSValueRef textViewProtoVal = JSObjectGetProperty(ctx, textViewConstructor, protoName, nullptr);
    JSObjectRef textViewProto = JSValueToObject(ctx, textViewProtoVal, nullptr);
    JSStringRelease(textViewName);
    
    // 设置 ViewGroup.prototype 的原型为 View.prototype
    JSObjectSetPrototype(ctx, buttonPrototype, textViewProto);
    JSStringRelease(protoName);
    
    JSObjectSetProperty(ctx, SkiaUI, className, constructor, kJSPropertyAttributeNone, nullptr);
    JSStringRelease(className);
}

}





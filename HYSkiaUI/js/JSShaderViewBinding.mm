#include "JSShaderViewBinding.h"
#include "ShaderView.h"
#include "JSSkiaUIContext.h"
#include "w3c_util.h"

namespace HYSkiaUI {

static JSClassRef sShaderViewClass = nullptr;

static JSObjectRef ShaderViewConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
    ShaderView* shaderView = new ShaderView();
    shaderView->setContext(JSSkiaUIContext::getInstance()->getUIContext());
    return JSObjectMake(ctx, sShaderViewClass, shaderView);
}

static void ShaderViewFinalize(JSObjectRef object) {
    
}

JSValueRef JSShaderViewBinding::ShaderViewGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception) {
    auto propName = JSStringToStdString(propertyName);
    if (propName == "setShaderPath") {
        JSValueRef addViewValue = JSObjectGetPrototype(ctx, object);
        JSObjectRef addViewMethod = JSValueToObject(ctx, addViewValue, exception);
        return JSObjectGetProperty(ctx, addViewMethod, propertyName, exception);
    }
    return JSViewBinding::ViewGetProperty(ctx, object, propertyName, exception);
}

bool JSShaderViewBinding::ShaderViewSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception) {
    return JSViewBinding::ViewSetProperty(ctx, object, propertyName, value, exception);
}

static JSValueRef setShaderPath(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 2);
    auto path = JSShaderViewBinding::JSStringToStdString(JSValueToStringCopy(ctx, arguments[0], nullptr));
    std::vector<std::string> imagePaths;
    JSObjectRef arrayObj = JSValueToObject(ctx, arguments[1], exception);
    if (!arrayObj || !JSValueIsObject(ctx, arrayObj)) {
        ALOGE("Second argument must be an array");
        return JSValueMakeUndefined(ctx);
    }
    JSStringRef lengthStr = JSStringCreateWithUTF8CString("length");
    JSValueRef lengthVal = JSObjectGetProperty(ctx, arrayObj, lengthStr, exception);
    JSStringRelease(lengthStr);
    size_t length = (size_t)JSValueToNumber(ctx, lengthVal, exception);
    for (unsigned int i = 0; i < length; i++) {
        JSValueRef element = JSObjectGetPropertyAtIndex(ctx, arrayObj, i, exception);
        if (*exception) {
            ALOGE("Error getting array element at index %u", i);
            break;
        }
        if (JSValueIsString(ctx, element)) {
            JSStringRef stringRef = JSValueToStringCopy(ctx, element, exception);
            if (stringRef) {
                std::string path = JSShaderViewBinding::JSStringToStdString(stringRef);
                imagePaths.push_back(path);
                JSStringRelease(stringRef);
            }
        }
    }
    ShaderView* shaderView = static_cast<ShaderView*>(JSObjectGetPrivate(thisObject));
    shaderView->setShaderPath(path.c_str(), imagePaths);
    return JSValueMakeUndefined(ctx);
}

void JSShaderViewBinding::registerShaderView(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext> &context) {
    JSStringRef className = JSStringCreateWithUTF8CString("ShaderView");
    static JSClassDefinition ShaderViewClassDef = {
        0, kJSClassAttributeNone,
        "ShaderView", nullptr, nullptr,
        nullptr, nullptr, ShaderViewFinalize, nullptr, ShaderViewGetProperty, ShaderViewSetProperty,
        nullptr, nullptr, nullptr,
        nullptr, nullptr, nullptr
    };
    sShaderViewClass = JSClassCreate(&ShaderViewClassDef);
    JSObjectRef constructor = JSObjectMakeConstructor(ctx, sShaderViewClass, ShaderViewConstructor);
    
    JSStringRef protoName = JSStringCreateWithUTF8CString("prototype");
    JSValueRef shaderViewProtoValue = JSObjectGetProperty(ctx, constructor, protoName, nullptr);
    JSObjectRef shaderViewPrototype = JSValueToObject(ctx, shaderViewProtoValue, nullptr);
    
    // 3. 手动添加原型方法
    JSStringRef setShaderPathName = JSStringCreateWithUTF8CString("setShaderPath");
    JSObjectRef setShaderPathFunc = JSObjectMakeFunctionWithCallback(ctx, setShaderPathName, setShaderPath);
    JSObjectSetProperty(ctx, shaderViewPrototype, setShaderPathName, setShaderPathFunc, kJSPropertyAttributeReadOnly, nullptr);
    JSStringRelease(setShaderPathName);
    
    // 4. 显式继承View原型
    JSStringRef viewName = JSStringCreateWithUTF8CString("View");
    JSValueRef viewConstructorVal = JSObjectGetProperty(ctx, SkiaUI, viewName, nullptr);
    JSObjectRef viewConstructor = JSValueToObject(ctx, viewConstructorVal, nullptr);
    JSValueRef viewProtoVal = JSObjectGetProperty(ctx, viewConstructor, protoName, nullptr);
    JSObjectRef viewProto = JSValueToObject(ctx, viewProtoVal, nullptr);
    JSStringRelease(viewName);
    
    // 设置 ShaerView.prototype 的原型为 View.prototype
    JSObjectSetPrototype(ctx, shaderViewPrototype, viewProto);
    JSStringRelease(protoName);
    
    JSObjectSetProperty(ctx, SkiaUI, className, constructor, kJSPropertyAttributeNone, nullptr);
    JSStringRelease(className);
}

}







#include "JSLottieBinding.h"
#include "LottieView.h"
#include "JSSkiaUIContext.h"
#include "w3c_util.h"

namespace HYSkiaUI {

static JSClassRef sLottieClass = nullptr;

static JSObjectRef LottieConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
    LottieView* lottieView = new LottieView();
    lottieView->setContext(JSSkiaUIContext::getInstance()->getUIContext());
    return JSObjectMake(ctx, sLottieClass, lottieView);
}

static void LottieFinalize(JSObjectRef object) {
    
}

JSValueRef JSLottieBinding::LottieGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception) {
    auto propName = JSStringToStdString(propertyName);
    if (propName == "src") {
        LottieView* lottieView = static_cast<LottieView*>(JSObjectGetPrivate(object));
        return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(lottieView->getSource()));
    } else if (propName == "start" || propName == "pause") {
        JSValueRef addViewValue = JSObjectGetPrototype(ctx, object);
        JSObjectRef addViewMethod = JSValueToObject(ctx, addViewValue, exception);
        return JSObjectGetProperty(ctx, addViewMethod, propertyName, exception);
    }
    return JSViewBinding::ViewGetProperty(ctx, object, propertyName, exception);
}

bool JSLottieBinding::LottieSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception) {
    auto propName = JSStringToStdString(propertyName);
    if (propName == "src") {
        LottieView* lottieView = static_cast<LottieView*>(JSObjectGetPrivate(object));
        JSStringRef jsString = JSValueToStringCopy(ctx, value, nullptr);
        lottieView->setSource(JSStringToStdString(jsString).c_str());
        JSStringRelease(jsString);
        return true;
    }
    return JSViewBinding::ViewSetProperty(ctx, object, propertyName, value, exception);
}

static JSValueRef start(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 0);
    LottieView* lottieView = static_cast<LottieView*>(JSObjectGetPrivate(thisObject));
    lottieView->start();
    return JSValueMakeUndefined(ctx);
}

static JSValueRef pause(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 0);
    LottieView* lottieView = static_cast<LottieView*>(JSObjectGetPrivate(thisObject));
    lottieView->pause();
    return JSValueMakeUndefined(ctx);
}

void JSLottieBinding::registerLottie(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext> &context) {
    JSStringRef className = JSStringCreateWithUTF8CString("LottieView");
    static JSClassDefinition LottieClassDef = {
        0, kJSClassAttributeNone,
        "LottieView", nullptr, nullptr,
        nullptr, nullptr, LottieFinalize, nullptr, LottieGetProperty, LottieSetProperty,
        nullptr, nullptr, nullptr,
        nullptr, nullptr, nullptr
    };
    sLottieClass = JSClassCreate(&LottieClassDef);
    JSObjectRef constructor = JSObjectMakeConstructor(ctx, sLottieClass, LottieConstructor);
    
    JSStringRef protoName = JSStringCreateWithUTF8CString("prototype");
    JSValueRef lottieProtoValue = JSObjectGetProperty(ctx, constructor, protoName, nullptr);
    JSObjectRef lottiePrototype = JSValueToObject(ctx, lottieProtoValue, nullptr);
    
    // 3. 手动添加原型方法
    JSStringRef startName = JSStringCreateWithUTF8CString("start");
    JSObjectRef startFunc = JSObjectMakeFunctionWithCallback(ctx, startName, start);
    JSObjectSetProperty(ctx, lottiePrototype, startName, startFunc, kJSPropertyAttributeReadOnly, nullptr);
    JSStringRelease(startName);
    JSStringRef pauseName = JSStringCreateWithUTF8CString("pause");
    JSObjectRef pauseFunc = JSObjectMakeFunctionWithCallback(ctx, pauseName, pause);
    JSObjectSetProperty(ctx, lottiePrototype, pauseName, pauseFunc, kJSPropertyAttributeReadOnly, nullptr);
    JSStringRelease(pauseName);
    
    // 4. 显式继承View原型
    JSStringRef viewName = JSStringCreateWithUTF8CString("View");
    JSValueRef viewConstructorVal = JSObjectGetProperty(ctx, SkiaUI, viewName, nullptr);
    JSObjectRef viewConstructor = JSValueToObject(ctx, viewConstructorVal, nullptr);
    JSValueRef viewProtoVal = JSObjectGetProperty(ctx, viewConstructor, protoName, nullptr);
    JSObjectRef viewProto = JSValueToObject(ctx, viewProtoVal, nullptr);
    JSStringRelease(viewName);
    
    // 设置 ViewGroup.prototype 的原型为 View.prototype
    JSObjectSetPrototype(ctx, lottiePrototype, viewProto);
    JSStringRelease(protoName);
    
    JSObjectSetProperty(ctx, SkiaUI, className, constructor, kJSPropertyAttributeNone, nullptr);
    JSStringRelease(className);
}

}


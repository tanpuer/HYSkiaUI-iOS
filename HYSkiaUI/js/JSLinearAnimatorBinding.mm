#include "JSLinearAnimatorBinding.h"
#include "LinearAnimator.h"
#include "JSSkiaUIContext.h"
#include "w3c_util.h"

namespace HYSkiaUI {

static JSClassRef sLinearAnimatorClass = nullptr;

static JSObjectRef LinearAnimatorConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
    assert(argc == 3);
    auto view = static_cast<View*>(JSObjectGetPrivate(JSValueToObject(ctx, argv[0], exception)));
    auto start = JSValueToNumber(ctx, argv[1], exception);
    auto end = JSValueToNumber(ctx, argv[2], exception);
    LinearAnimator* animator = new LinearAnimator(view, start, end);
    return JSObjectMake(ctx, sLinearAnimatorClass, animator);
}

static void LinearAnimatorFinalize(JSObjectRef object) {
    
}

JSValueRef JSLinearAnimatorBinding::LinearAnimatorGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception) {
    std::string propName = JSViewBinding::JSStringToStdString(propertyName);
    if (propName == "setUpdateListener" || propName == "start") {
        JSValueRef value = JSObjectGetPrototype(ctx, object);
        JSObjectRef method = JSValueToObject(ctx, value, exception);
        return JSObjectGetProperty(ctx, method, propertyName, exception);
    }
    return JSValueMakeUndefined(ctx);
}

bool JSLinearAnimatorBinding::LinearAnimatorSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception) {
    std::string propName = JSViewBinding::JSStringToStdString(propertyName);
    LinearAnimator* animator = static_cast<LinearAnimator*>(JSObjectGetPrivate(object));
    if (propName == "duration") {
        animator->setDuration(JSValueToNumber(ctx, value, exception));
        return true;
    } else if (propName == "loop") {
        animator->setLoopCount(JSValueToNumber(ctx, value, exception));
    }
    return false;
}

static JSValueRef setUpdateListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 1);
    JSObjectRef callback = JSValueToObject(ctx, arguments[0], exception);
    assert(JSObjectIsFunction(ctx, callback));
    LinearAnimator* animator = static_cast<LinearAnimator*>(JSObjectGetPrivate(thisObject));
    JSGlobalContextRef globalCtx = JSContextGetGlobalContext(ctx);
    JSValueProtect(globalCtx, callback);
    animator->protectCallback(ctx, callback);
    animator->setUpdateListener([globalCtx, thisObject, callback](View* view, float value) {
        JSValueRef callbackArgs[] = {
            JSValueMakeNumber(globalCtx, value)
        };
        JSValueRef exception = nullptr;
        JSObjectCallAsFunction(globalCtx, callback, thisObject, 1, callbackArgs, &exception);
    });
    return JSValueMakeUndefined(ctx);
}

static JSValueRef start(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 0);
    LinearAnimator* animator = static_cast<LinearAnimator*>(JSObjectGetPrivate(thisObject));
    animator->start();
    return JSValueMakeUndefined(ctx);
}

void JSLinearAnimatorBinding::registerLinearAnimator(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext> &context) {
    JSStringRef className = JSStringCreateWithUTF8CString("LinearAnimator");
    static JSClassDefinition LinearAnimatorClassDef = {
        0, kJSClassAttributeNone,
        "LinearAnimator", nullptr, nullptr,
        nullptr, nullptr, LinearAnimatorFinalize, nullptr, LinearAnimatorGetProperty, LinearAnimatorSetProperty,
        nullptr, nullptr, nullptr,
        nullptr, nullptr, nullptr
    };
    sLinearAnimatorClass = JSClassCreate(&LinearAnimatorClassDef);
    JSObjectRef constructor = JSObjectMakeConstructor(ctx, sLinearAnimatorClass, LinearAnimatorConstructor);
    JSStringRef protoName = JSStringCreateWithUTF8CString("prototype");
    JSValueRef viewProtoValue = JSObjectGetProperty(ctx, constructor, protoName, nullptr);
    JSObjectRef viewPrototype = JSValueToObject(ctx, viewProtoValue, nullptr);
    // 3. 手动添加原型方法
    JSStringRef startName = JSStringCreateWithUTF8CString("start");
    JSObjectRef startFunc = JSObjectMakeFunctionWithCallback(ctx, startName, start);
    JSObjectSetProperty(ctx, viewPrototype, startName, startFunc, kJSPropertyAttributeReadOnly, nullptr);
    JSStringRelease(startName);
    JSStringRef updateName = JSStringCreateWithUTF8CString("setUpdateListener");
    JSObjectRef updateFunc = JSObjectMakeFunctionWithCallback(ctx, updateName, setUpdateListener);
    JSObjectSetProperty(ctx, viewPrototype, updateName, updateFunc, kJSPropertyAttributeReadOnly, nullptr);
    JSStringRelease(startName);
    
    
    JSObjectSetProperty(ctx, SkiaUI, className, constructor, kJSPropertyAttributeNone, nullptr);
    JSStringRelease(className);
}

}


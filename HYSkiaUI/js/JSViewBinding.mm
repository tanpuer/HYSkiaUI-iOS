#import "JSViewBinding.h"
#include "View.h"
#include "JSSkiaUIContext.h"
#include "w3c_util.h"

namespace HYSkiaUI {

std::string JSViewBinding::JSStringToStdString(JSStringRef jsString) {
    size_t maxBufferSize = JSStringGetMaximumUTF8CStringSize(jsString);
    char* buffer = new char[maxBufferSize];
    JSStringGetUTF8CString(jsString, buffer, maxBufferSize);
    std::string result(buffer);
    delete[] buffer;
    return result;
}

static JSClassRef sViewClass = nullptr;

static JSObjectRef ViewConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
    View* view = new View();
    view->setContext(JSSkiaUIContext::getInstance()->getUIContext());
    return JSObjectMake(ctx, sViewClass, view);
}

static void ViewFinalize(JSObjectRef object) {
    
}

JSValueRef JSViewBinding::ViewGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception) {
    View* view = static_cast<View*>(JSObjectGetPrivate(object));
    std::string propName = JSViewBinding::JSStringToStdString(propertyName);
    if (propName == "name") {
        return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(view->name()));
    } else if (propName == "width") {
        return JSValueMakeNumber(ctx, view->getWidth());
    } else if (propName == "height") {
        return JSValueMakeNumber(ctx, view->getHeight());
    } else if (propName == "backgroundColor") {
        return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(view->getBackgroundColor()));
    } else if (propName == "flex") {
        return JSValueMakeNumber(ctx, view->getFlex());
    } else if (propName == "marginLeft") {
        return JSValueMakeNumber(ctx, view->marginLeft);
    } else if (propName == "marginTop") {
        return JSValueMakeNumber(ctx, view->marginTop);
    } else if (propName == "marginRight") {
        return JSValueMakeNumber(ctx, view->marginRight);
    } else if (propName == "marginBottom") {
        return JSValueMakeNumber(ctx, view->marginBottom);
    } else if (propName == "rotateZ") {
        return JSValueMakeNumber(ctx, view->rotateZ);
    } else if (propName == "setOnClickListener") {
        JSValueRef addViewValue = JSObjectGetPrototype(ctx, object);
        JSObjectRef addViewMethod = JSValueToObject(ctx, addViewValue, exception);
        return JSObjectGetProperty(ctx, addViewMethod, propertyName, exception);
    } else if (propName == "position") {
        return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(YGPositionToW3C(view->getPositionType())));
    }
    ALOGE("Error getProperty %s", propName.c_str())
    return JSValueMakeUndefined(ctx);
}

bool JSViewBinding::ViewSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception) {
    View* view = static_cast<View*>(JSObjectGetPrivate(object));
    auto propName = JSStringToStdString(propertyName);
    if (propName == "width") {
        auto width = JSValueToNumber(ctx, value, exception);
        view->setWidth(static_cast<int>(width));
        return true;
    } else if (propName == "height") {
        auto height = JSValueToNumber(ctx, value, exception);
        view->setHeight(static_cast<int>(height));
        return true;
    } else if (propName == "backgroundColor") {
        JSStringRef jsString = JSValueToStringCopy(ctx, value, nullptr);
        view->setBackgroundColor(JSStringToStdString(jsString));
        return true;
    } else if (propName == "flex") {
        view->setFlex(JSValueToNumber(ctx, value, exception));
        return true;
    } else if (propName == "marginLeft") {
        view->setMarginLeft(JSValueToNumber(ctx, value, exception));
        return true;
    } else if (propName == "marginTop") {
        view->setMarginTop(JSValueToNumber(ctx, value, exception));
        return true;
    } else if (propName == "marginRight") {
        view->setMarginRight(JSValueToNumber(ctx, value, exception));
        return true;
    } else if (propName == "marginBottom") {
        view->setMarginBottom(JSValueToNumber(ctx, value, exception));
        return true;
    } else if (propName == "rotateZ") {
        view->rotateZ = JSValueToNumber(ctx, value, exception);
        return true;
    } else if (propName == "position") {
        JSStringRef jsString = JSValueToStringCopy(ctx, value, nullptr);
        view->setPositionType(W3CToYGPosition(JSStringToStdString(jsString)));
        return true;
    }
    return false;
}

static JSValueRef setOnClickListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 1);
    JSObjectRef callback = JSValueToObject(ctx, arguments[0], exception);
    assert(JSObjectIsFunction(ctx, callback));
    View* view = static_cast<View*>(JSObjectGetPrivate(thisObject));
    
    JSGlobalContextRef globalCtx = JSContextGetGlobalContext(ctx);
    JSValueProtect(globalCtx, callback);
    
    view->protectClickCallback(ctx, callback);
    
    view->setOnClickListener([globalCtx, thisObject, callback](View* view) {
        JSValueRef callbackArgs[] = {
            JSObjectMake(globalCtx, nullptr, view)
        };
        JSValueRef exception = nullptr;
        JSObjectCallAsFunction(globalCtx, callback, thisObject, 1, callbackArgs, &exception);
    });
    return JSValueMakeUndefined(ctx);
}

void JSViewBinding::registerView(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext> &context) {
    JSStringRef className = JSStringCreateWithUTF8CString("View");
    static JSClassDefinition ViewClassDef = {
        0, kJSClassAttributeNone,
        "View", nullptr, nullptr,
        nullptr, nullptr, ViewFinalize, nullptr, ViewGetProperty, ViewSetProperty,
        nullptr, nullptr, nullptr,
        nullptr, nullptr, nullptr
    };
    sViewClass = JSClassCreate(&ViewClassDef);
    JSObjectRef constructor = JSObjectMakeConstructor(ctx, sViewClass, ViewConstructor);
    JSStringRef protoName = JSStringCreateWithUTF8CString("prototype");
    JSValueRef viewProtoValue = JSObjectGetProperty(ctx, constructor, protoName, nullptr);
    JSObjectRef viewPrototype = JSValueToObject(ctx, viewProtoValue, nullptr);
    // 3. 手动添加原型方法
    JSStringRef clickName = JSStringCreateWithUTF8CString("setOnClickListener");
    JSObjectRef clickFunc = JSObjectMakeFunctionWithCallback(ctx, clickName, setOnClickListener);
    JSObjectSetProperty(ctx, viewPrototype, clickName, clickFunc, kJSPropertyAttributeReadOnly, nullptr);
    JSStringRelease(clickName);
    JSObjectSetProperty(ctx, SkiaUI, className, constructor, kJSPropertyAttributeNone, nullptr);
    JSStringRelease(className);
}

}

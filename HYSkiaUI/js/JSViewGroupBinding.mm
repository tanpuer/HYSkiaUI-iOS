#include "JSViewGroupBinding.h"
#include "ViewGroup.h"
#include "JSSkiaUIContext.h"
#include "w3c_util.h"

namespace HYSkiaUI {

static JSClassRef sViewGroupClass = nullptr;

static JSObjectRef ViewGroupConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
    ViewGroup* viewGroup = new ViewGroup();
    viewGroup->setContext(JSSkiaUIContext::getInstance()->getUIContext());
    return JSObjectMake(ctx, sViewGroupClass, viewGroup);
}

static void ViewGroupFinalize(JSObjectRef object) {
    
}

JSValueRef JSViewGroupBinding::ViewGroupGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception) {
    auto propName = JSStringToStdString(propertyName);
    ViewGroup* viewGroup = static_cast<ViewGroup*>(JSObjectGetPrivate(object));
    if (propName == "addView") {
        JSValueRef addViewValue = JSObjectGetPrototype(ctx, object);
        JSObjectRef addViewMethod = JSValueToObject(ctx, addViewValue, exception);
        return JSObjectGetProperty(ctx, addViewMethod, propertyName, exception);
    } else if (propName == "flexDireaction") {
        return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(viewGroup->getFlexDirection()));
    } else if (propName == "flexWrap") {
        return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(viewGroup->getFLexWrap()));
    } else if (propName == "justifyContent") {
        return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(viewGroup->getJustifyContent()));
    } else if (propName == "alignItems") {
        return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(viewGroup->getAlignItems()));;
    }
    return JSViewBinding::ViewGetProperty(ctx, object, propertyName, exception);
}

bool JSViewGroupBinding::ViewGroupSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception) {
    auto propName = JSStringToStdString(propertyName);
    if (propName == "flexDirection") {
        ViewGroup* viewGroup = static_cast<ViewGroup*>(JSObjectGetPrivate(object));
        JSStringRef jsString = JSValueToStringCopy(ctx, value, nullptr);
        viewGroup->setFlexDirection(W3CToYGFlexDirection(JSStringToStdString(jsString)));
        JSStringRelease(jsString);
        return true;
    } else if (propName == "flexWrap") {
        ViewGroup* viewGroup = static_cast<ViewGroup*>(JSObjectGetPrivate(object));
        JSStringRef jsString = JSValueToStringCopy(ctx, value, nullptr);
        viewGroup->setFlexWrap(W3CToYGWrap(JSStringToStdString(jsString)));
        JSStringRelease(jsString);
        return true;
    } else if (propName == "justifyContent") {
        ViewGroup* viewGroup = static_cast<ViewGroup*>(JSObjectGetPrivate(object));
        JSStringRef jsString = JSValueToStringCopy(ctx, value, nullptr);
        viewGroup->setJustifyContent(W3CToYGJustify(JSStringToStdString(jsString)));
        JSStringRelease(jsString);
        return true;
    } else if (propName == "alignItems") {
        ViewGroup* viewGroup = static_cast<ViewGroup*>(JSObjectGetPrivate(object));
        JSStringRef jsString = JSValueToStringCopy(ctx, value, nullptr);
        viewGroup->setAlignItems(W3CToYGAlign(JSStringToStdString(jsString)));
        JSStringRelease(jsString);
        return true;
    }
    return JSViewBinding::ViewSetProperty(ctx, object, propertyName, value, exception);
}

static JSValueRef addView(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 1);
    ViewGroup* viewGroup = static_cast<ViewGroup*>(JSObjectGetPrivate(thisObject));
    View* view = static_cast<View*>(JSObjectGetPrivate(JSValueToObject(ctx, arguments[0], nullptr)));
    viewGroup->addView(view);
    return JSValueMakeUndefined(ctx);
}

void JSViewGroupBinding::registerViewGroup(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext> &context) {
    JSStringRef className = JSStringCreateWithUTF8CString("ViewGroup");
    static JSClassDefinition ViewGroupClassDef = {
        0, kJSClassAttributeNone,
        "ViewGroup", nullptr, nullptr,
        nullptr, nullptr, ViewGroupFinalize, nullptr, ViewGroupGetProperty, ViewGroupSetProperty,
        nullptr, nullptr, nullptr,
        nullptr, nullptr, nullptr
    };
    sViewGroupClass = JSClassCreate(&ViewGroupClassDef);
    JSObjectRef constructor = JSObjectMakeConstructor(ctx, sViewGroupClass, ViewGroupConstructor);
    
    JSStringRef protoName = JSStringCreateWithUTF8CString("prototype");
    JSValueRef viewGroupProtoValue = JSObjectGetProperty(ctx, constructor, protoName, nullptr);
    JSObjectRef viewGroupPrototype = JSValueToObject(ctx, viewGroupProtoValue, nullptr);
    
    // 3. 手动添加原型方法
    JSStringRef addViewName = JSStringCreateWithUTF8CString("addView");
    JSObjectRef addViewFunc = JSObjectMakeFunctionWithCallback(ctx, addViewName, addView);
    JSObjectSetProperty(ctx, viewGroupPrototype, addViewName, addViewFunc, kJSPropertyAttributeReadOnly, nullptr);
    JSStringRelease(addViewName);
    
    // 4. 显式继承View原型
    JSStringRef viewName = JSStringCreateWithUTF8CString("View");
    JSValueRef viewConstructorVal = JSObjectGetProperty(ctx, SkiaUI, viewName, nullptr);
    JSObjectRef viewConstructor = JSValueToObject(ctx, viewConstructorVal, nullptr);
    JSValueRef viewProtoVal = JSObjectGetProperty(ctx, viewConstructor, protoName, nullptr);
    JSObjectRef viewProto = JSValueToObject(ctx, viewProtoVal, nullptr);
    JSStringRelease(viewName);
    
    // 设置 ViewGroup.prototype 的原型为 View.prototype
    JSObjectSetPrototype(ctx, viewGroupPrototype, viewProto);
    JSStringRelease(protoName);
    
    JSObjectSetProperty(ctx, SkiaUI, className, constructor, kJSPropertyAttributeNone, nullptr);
    JSStringRelease(className);
}

}

#include "JSScrollViewBinding.h"
#include "ScrollView.h"
#include "JSSkiaUIContext.h"

namespace HYSkiaUI {

static JSClassRef sScrollViewClass = nullptr;

static JSObjectRef ScrollViewConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
    ScrollView* scrollView = new ScrollView();
    scrollView->setContext(JSSkiaUIContext::getInstance()->getUIContext());
    return JSObjectMake(ctx, sScrollViewClass, scrollView);
}

static void ScrollViewFinalize(JSObjectRef object) {
    
}

JSValueRef JSScrollViewBinding::ScrollViewGetProperty(
                                          JSContextRef ctx,
                                          JSObjectRef object,
                                          JSStringRef propertyName,
                                          JSValueRef* exception
                                          ) {
    auto name = JSStringToStdString(propertyName);
    if (name == "scrollTo" || name == "getDistanceByIndex") {
        JSValueRef pushValue = JSObjectGetPrototype(ctx, object);
        JSObjectRef pushMethod = JSValueToObject(ctx, pushValue, exception);
        return JSObjectGetProperty(ctx, pushMethod, propertyName, exception);
    }
    return JSFlexboxLayoutBinding::FlexboxLayoutGetProperty(ctx, object, propertyName, exception);
}

bool JSScrollViewBinding::ScrollViewSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception){
    return JSFlexboxLayoutBinding::FlexboxLayoutSetProperty(ctx, object, propertyName, value, exception);
}

static JSValueRef scrollTo(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 1);
    auto diff = JSValueToNumber(ctx, arguments[0], exception);
    ScrollView *scrollView = static_cast<ScrollView*>(JSObjectGetPrivate(thisObject));
    scrollView->scrollTo(diff);
    return JSValueMakeUndefined(ctx);
}

static JSValueRef getDistanceByIndex(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 1);
    auto index = JSValueToNumber(ctx, arguments[0], exception);
    ScrollView *scrollView = static_cast<ScrollView*>(JSObjectGetPrivate(thisObject));
    return JSValueMakeNumber(ctx, scrollView->getDistanceByIndex(index));
}

void JSScrollViewBinding::registerScrollView(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext> &context) {
    JSStringRef className = JSStringCreateWithUTF8CString("ScrollView");
    
    // 1. 创建类时继承 FlexboxLayout 的类定义
    static JSClassDefinition PageClassDef = {
        0, kJSClassAttributeNone,
        "ScrollView", nullptr, nullptr,
        nullptr,
        nullptr, ScrollViewFinalize, nullptr, ScrollViewGetProperty, ScrollViewSetProperty,
        nullptr, nullptr, nullptr,
        nullptr, nullptr, nullptr
    };
    sScrollViewClass = JSClassCreate(&PageClassDef);
    JSObjectRef constructor = JSObjectMakeConstructor(ctx, sScrollViewClass, ScrollViewConstructor);
    
    JSStringRef protoName = JSStringCreateWithUTF8CString("prototype");
    JSValueRef scrollProtoValue = JSObjectGetProperty(ctx, constructor, protoName, nullptr);
    JSObjectRef scrollPrototype = JSValueToObject(ctx, scrollProtoValue, nullptr);
    
    JSStringRef scrollToName = JSStringCreateWithUTF8CString("scrollTo");
    JSObjectRef scrollToFunc = JSObjectMakeFunctionWithCallback(ctx, scrollToName, scrollTo);
    JSObjectSetProperty(ctx, scrollPrototype, scrollToName, scrollToFunc, kJSPropertyAttributeReadOnly,nullptr);
    JSStringRelease(scrollToName);
    JSStringRef getDistanceByIndexName = JSStringCreateWithUTF8CString("getDistanceByIndex");
    JSObjectRef getDistanceByIndexFunc = JSObjectMakeFunctionWithCallback(ctx, getDistanceByIndexName, scrollTo);
    JSObjectSetProperty(ctx, scrollPrototype, getDistanceByIndexName, getDistanceByIndexFunc, kJSPropertyAttributeReadOnly,nullptr);
    JSStringRelease(getDistanceByIndexName);
    
    // 2. 获取 Flexbox 构造函数作为父类
    JSStringRef flexboxName = JSStringCreateWithUTF8CString("FlexboxLayout");
    JSValueRef flexboxConstructorVal = JSObjectGetProperty(ctx, SkiaUI, flexboxName, nullptr);
    JSObjectRef flexboxConstructor = JSValueToObject(ctx, flexboxConstructorVal, nullptr);
    JSValueRef flexboxProtoVal = JSObjectGetProperty(ctx, flexboxConstructor, protoName, nullptr);
    JSObjectRef flexboxProto = JSValueToObject(ctx, flexboxProtoVal, nullptr);
    JSObjectSetPrototype(ctx, scrollPrototype, flexboxProto); // 原型链继承
    
    // 6. 注册全局对象
    JSObjectSetProperty(ctx, SkiaUI, className, constructor, kJSPropertyAttributeNone, nullptr);
    // 7. 内存释放
    JSStringRelease(protoName);
    JSStringRelease(flexboxName);
    JSStringRelease(className);
}

}


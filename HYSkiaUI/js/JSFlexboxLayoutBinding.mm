#include "JSFlexboxLayoutBinding.h"
#include "FlexboxLayout.h"
#include "JSSkiaUIContext.h"

namespace HYSkiaUI {

static JSClassRef sFlexboxLayoutClass = nullptr;

static JSObjectRef ScrollViewConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
    FlexboxLayout* flexboxLayout = new FlexboxLayout();
    flexboxLayout->setContext(JSSkiaUIContext::getInstance()->getUIContext());
    return JSObjectMake(ctx, sFlexboxLayoutClass, flexboxLayout);
}

static void FlexboxLyaoutFinalize(JSObjectRef object) {
    
}

JSValueRef JSFlexboxLayoutBinding::FlexboxLayoutGetProperty(
                                          JSContextRef ctx,
                                          JSObjectRef object,
                                          JSStringRef propertyName,
                                          JSValueRef* exception
                                          ) {
    return JSViewGroupBinding::ViewGroupGetProperty(ctx, object, propertyName, exception);
}

bool JSFlexboxLayoutBinding::FlexboxLayoutSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception){
    return JSViewGroupBinding::ViewGroupSetProperty(ctx, object, propertyName, value, exception);
}

void JSFlexboxLayoutBinding::registerFlexboxLayout(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext> &context) {
    JSStringRef className = JSStringCreateWithUTF8CString("FlexboxLayout");
    
    // 1. 创建类时继承 ViewGroup 的类定义
    static JSClassDefinition FlexboxLayoutClassDef = {
        0, kJSClassAttributeNone,
        "FlexboxLayout", nullptr, nullptr,
        nullptr,
        nullptr, FlexboxLyaoutFinalize, nullptr, FlexboxLayoutGetProperty, FlexboxLayoutSetProperty,
        nullptr, nullptr, nullptr,
        nullptr, nullptr, nullptr
    };
    sFlexboxLayoutClass = JSClassCreate(&FlexboxLayoutClassDef);
    
    // 2. 获取 ViewGroup 构造函数作为父类
    JSStringRef viewGroupName = JSStringCreateWithUTF8CString("ViewGroup");
    JSValueRef viewGroupConstructorVal = JSObjectGetProperty(ctx, SkiaUI, viewGroupName, nullptr);
    JSObjectRef viewGroupConstructor = JSValueToObject(ctx, viewGroupConstructorVal, nullptr);
    
    // 3. 创建 Page 构造函数并继承 ViewGroup
    JSObjectRef constructor = JSObjectMakeConstructor(ctx, sFlexboxLayoutClass, ScrollViewConstructor);
    JSObjectSetPrototype(ctx, constructor, viewGroupConstructor); // 关键：构造函数继承
    
    // 4. 设置原型链
    JSStringRef protoName = JSStringCreateWithUTF8CString("prototype");
    JSValueRef flexboxProtoValue = JSObjectGetProperty(ctx, constructor, protoName, nullptr);
    JSObjectRef flexboxPrototype = JSValueToObject(ctx, flexboxProtoValue, nullptr);
    JSValueRef viewGroupProtoVal = JSObjectGetProperty(ctx, viewGroupConstructor, protoName, nullptr);
    JSObjectRef viewGroupProto = JSValueToObject(ctx, viewGroupProtoVal, nullptr);
    JSObjectSetPrototype(ctx, flexboxPrototype, viewGroupProto);
    
    // 6. 注册全局对象
    JSObjectSetProperty(ctx, SkiaUI, className, constructor, kJSPropertyAttributeNone, nullptr);
    // 7. 内存释放
    JSStringRelease(protoName);
    JSStringRelease(viewGroupName);
    JSStringRelease(className);
}

}



#include "JSPageBinding.h"
#include "Page.h"
#include "JSSkiaUIContext.h"

namespace HYSkiaUI {

static JSClassRef sPageClass = nullptr;

static JSObjectRef PageConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
    Page* page = new Page();
    page->setContext(JSSkiaUIContext::getInstance()->getUIContext());
    return JSObjectMake(ctx, sPageClass, page);
}

static void PageFinalize(JSObjectRef object) {
    
}

JSValueRef JSPageBinding::PageGetProperty(
                                          JSContextRef ctx,
                                          JSObjectRef object,
                                          JSStringRef propertyName,
                                          JSValueRef* exception
                                          ) {
    auto name = JSStringToStdString(propertyName);
    ALOGD("JSPageBinding::PageGetProperty %s", name.c_str())
    static std::unordered_map<std::string, int> methodsList {
        {"push", 0},
        {"pop", 1},
        {"onShow", 2},
        {"onHide", 3},
        {"onCreate", 4},
        {"onDestory", 4}
    };
    if (methodsList.find(name) != methodsList.end()) {
        JSValueRef pushValue = JSObjectGetPrototype(ctx, object);
        JSObjectRef pushMethod = JSValueToObject(ctx, pushValue, exception);
        return JSObjectGetProperty(ctx, pushMethod, propertyName, exception);
    }
    return JSViewGroupBinding::ViewGroupGetProperty(ctx, object, propertyName, exception);
}

bool JSPageBinding::PageSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception){
    return JSViewGroupBinding::ViewGroupSetProperty(ctx, object, propertyName, value, exception);
}

static JSValueRef push(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 1);
    Page* page = static_cast<Page*>(JSObjectGetPrivate(thisObject));
    JSObjectRef infoRef = JSValueToObject(ctx, arguments[0], exception);
    auto info = static_cast<Page::EnterExitInfo*>(JSObjectGetPrivate(infoRef));
    page->getContext()->getPageStackManager()->push(page);
    page->enterFromRight(*info);
    return JSValueMakeUndefined(ctx);
}

static JSValueRef pop(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 1);
    Page* page = static_cast<Page*>(JSObjectGetPrivate(thisObject));
    JSObjectRef infoRef = JSValueToObject(ctx, arguments[0], exception);
    auto info = static_cast<Page::EnterExitInfo*>(JSObjectGetPrivate(infoRef));
    page->exitToLeft(*info);
    return JSValueMakeUndefined(ctx);
}

static JSValueRef onShow(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 1);
    Page* page = static_cast<Page*>(JSObjectGetPrivate(thisObject));
    return JSValueMakeUndefined(ctx);
}

static JSValueRef onHide(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 1);
    Page* page = static_cast<Page*>(JSObjectGetPrivate(thisObject));
    return JSValueMakeUndefined(ctx);
}

static JSValueRef onCreate(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 1);
    Page* page = static_cast<Page*>(JSObjectGetPrivate(thisObject));
    return JSValueMakeUndefined(ctx);
}

static JSValueRef onDestroy(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 1);
    Page* page = static_cast<Page*>(JSObjectGetPrivate(thisObject));
    return JSValueMakeUndefined(ctx);
}

void JSPageBinding::registerPage(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext> &context) {
    JSStringRef className = JSStringCreateWithUTF8CString("Page");
    
    // 1. 创建类时继承 ViewGroup 的类定义
    static JSClassDefinition PageClassDef = {
        0, kJSClassAttributeNone,
        "Page", nullptr, nullptr,
        nullptr,
        nullptr, PageFinalize, nullptr, PageGetProperty, PageSetProperty,
        nullptr, nullptr, nullptr,
        nullptr, nullptr, nullptr
    };
    sPageClass = JSClassCreate(&PageClassDef);
    
    // 2. 获取 ViewGroup 构造函数作为父类
    JSStringRef viewGroupName = JSStringCreateWithUTF8CString("ViewGroup");
    JSValueRef viewGroupConstructorVal = JSObjectGetProperty(ctx, SkiaUI, viewGroupName, nullptr);
    JSObjectRef viewGroupConstructor = JSValueToObject(ctx, viewGroupConstructorVal, nullptr);
    
    // 3. 创建 Page 构造函数并继承 ViewGroup
    JSObjectRef constructor = JSObjectMakeConstructor(ctx, sPageClass, PageConstructor);
    JSObjectSetPrototype(ctx, constructor, viewGroupConstructor); // 关键：构造函数继承
    
    // 4. 设置原型链
    JSStringRef protoName = JSStringCreateWithUTF8CString("prototype");
    JSValueRef pageProtoValue = JSObjectGetProperty(ctx, constructor, protoName, nullptr);
    JSObjectRef pagePrototype = JSValueToObject(ctx, pageProtoValue, nullptr);
    JSValueRef viewGroupProtoVal = JSObjectGetProperty(ctx, viewGroupConstructor, protoName, nullptr);
    JSObjectRef viewGroupProto = JSValueToObject(ctx, viewGroupProtoVal, nullptr);
    JSObjectSetPrototype(ctx, pagePrototype, viewGroupProto); // 原型链继承
    // 5. 添加方法到原型（必须在设置原型链之后）
    JSStringRef pushName = JSStringCreateWithUTF8CString("push");
    JSObjectRef pushFunc = JSObjectMakeFunctionWithCallback(ctx, pushName, push);
    JSObjectSetProperty(ctx, pagePrototype, pushName, pushFunc, kJSPropertyAttributeReadOnly,nullptr);
    JSStringRelease(pushName);
    JSStringRef popName = JSStringCreateWithUTF8CString("pop");
    JSObjectRef popFunc = JSObjectMakeFunctionWithCallback(ctx, popName, pop);
    JSObjectSetProperty(ctx, pagePrototype, popName, popFunc, kJSPropertyAttributeReadOnly,nullptr);
    JSStringRelease(popName);
    JSStringRef onShowName = JSStringCreateWithUTF8CString("onShow");
    JSObjectRef onShowFunc = JSObjectMakeFunctionWithCallback(ctx, onShowName, onShow);
    JSObjectSetProperty(ctx, pagePrototype, onShowName, onShowFunc, kJSPropertyAttributeReadOnly,nullptr);
    JSStringRelease(onShowName);
    JSStringRef onHideName = JSStringCreateWithUTF8CString("onHide");
    JSObjectRef onHideFunc = JSObjectMakeFunctionWithCallback(ctx, onHideName, onShow);
    JSObjectSetProperty(ctx, pagePrototype, onHideName, onHideFunc, kJSPropertyAttributeReadOnly,nullptr);
    JSStringRelease(onHideName);
    JSStringRef onCreateName = JSStringCreateWithUTF8CString("onCreate");
    JSObjectRef onCreateFunc = JSObjectMakeFunctionWithCallback(ctx, onCreateName, onShow);
    JSObjectSetProperty(ctx, pagePrototype, onCreateName, onCreateFunc, kJSPropertyAttributeReadOnly,nullptr);
    JSStringRelease(onCreateName);
    JSStringRef onDestroyName = JSStringCreateWithUTF8CString("onDestroy");
    JSObjectRef onDestroyFunc = JSObjectMakeFunctionWithCallback(ctx, onDestroyName, onShow);
    JSObjectSetProperty(ctx, pagePrototype, onDestroyName, onDestroyFunc, kJSPropertyAttributeReadOnly,nullptr);
    JSStringRelease(onDestroyName);
    // 6. 注册全局对象
    JSObjectSetProperty(ctx, SkiaUI, className, constructor, kJSPropertyAttributeNone, nullptr);
    // 7. 内存释放
    JSStringRelease(protoName);
    JSStringRelease(viewGroupName);
    JSStringRelease(className);
}

}

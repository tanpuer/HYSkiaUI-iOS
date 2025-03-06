#include "JSSVGBinding.h"
#include "SVGView.h"
#include "JSSkiaUIContext.h"
#include "w3c_util.h"

namespace HYSkiaUI {

static JSClassRef sSVGViewClass = nullptr;

static JSObjectRef SVGConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
    SVGView* svg = new SVGView();
    svg->setContext(JSSkiaUIContext::getInstance()->getUIContext());
    return JSObjectMake(ctx, sSVGViewClass, svg);
}

static void SVGFinalize(JSObjectRef object) {
    
}

JSValueRef JSSVGBinding::SVGGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception) {
    auto propName = JSStringToStdString(propertyName);
    if (propName == "src") {
        SVGView* svg = static_cast<SVGView*>(JSObjectGetPrivate(object));
        return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(svg->getSource()));
    }
    return JSViewBinding::ViewGetProperty(ctx, object, propertyName, exception);
}

bool JSSVGBinding::SVGSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception) {
    auto propName = JSStringToStdString(propertyName);
    if (propName == "src") {
        SVGView* svg = static_cast<SVGView*>(JSObjectGetPrivate(object));
        JSStringRef jsString = JSValueToStringCopy(ctx, value, nullptr);
        svg->setSource(JSStringToStdString(jsString).c_str());
        JSStringRelease(jsString);
        return true;
    }
    return JSViewBinding::ViewSetProperty(ctx, object, propertyName, value, exception);
}

void JSSVGBinding::registerSVG(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext> &context) {
    JSStringRef className = JSStringCreateWithUTF8CString("SVGView");
    static JSClassDefinition SVGClassDef = {
        0, kJSClassAttributeNone,
        "SVGView", nullptr, nullptr,
        nullptr, nullptr, SVGFinalize, nullptr, SVGGetProperty, SVGSetProperty,
        nullptr, nullptr, nullptr,
        nullptr, nullptr, nullptr
    };
    sSVGViewClass = JSClassCreate(&SVGClassDef);
    JSObjectRef constructor = JSObjectMakeConstructor(ctx, sSVGViewClass, SVGConstructor);
    
    JSStringRef protoName = JSStringCreateWithUTF8CString("prototype");
    JSValueRef svgProtoValue = JSObjectGetProperty(ctx, constructor, protoName, nullptr);
    JSObjectRef svgPrototype = JSValueToObject(ctx, svgProtoValue, nullptr);
    
    // 4. 显式继承View原型
    JSStringRef viewName = JSStringCreateWithUTF8CString("View");
    JSValueRef viewConstructorVal = JSObjectGetProperty(ctx, SkiaUI, viewName, nullptr);
    JSObjectRef viewConstructor = JSValueToObject(ctx, viewConstructorVal, nullptr);
    JSValueRef viewProtoVal = JSObjectGetProperty(ctx, viewConstructor, protoName, nullptr);
    JSObjectRef viewProto = JSValueToObject(ctx, viewProtoVal, nullptr);
    JSStringRelease(viewName);
    
    // 设置 ViewGroup.prototype 的原型为 View.prototype
    JSObjectSetPrototype(ctx, svgPrototype, viewProto);
    JSStringRelease(protoName);
    
    JSObjectSetProperty(ctx, SkiaUI, className, constructor, kJSPropertyAttributeNone, nullptr);
    JSStringRelease(className);
}

}






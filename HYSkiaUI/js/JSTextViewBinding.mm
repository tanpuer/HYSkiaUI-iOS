#include "JSTextViewBinding.h"
#include "TextView.h"
#include "JSSkiaUIContext.h"
#include "w3c_util.h"
#include "color_util.h"

namespace HYSkiaUI {

static JSClassRef sTextViewClass = nullptr;

static JSObjectRef TextViewConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
    TextView* textView = new TextView();
    textView->setContext(JSSkiaUIContext::getInstance()->getUIContext());
    return JSObjectMake(ctx, sTextViewClass, textView);
}

static void TextViewFinalize(JSObjectRef object) {
    
}

JSValueRef JSTextViewBinding::TextViewGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception) {
    auto propName = JSStringToStdString(propertyName);
    if (propName == "textColor") {
        TextView* textView = static_cast<TextView*>(JSObjectGetPrivate(object));
        return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(textView->getTextColor()));
    } else if (propName == "textSize") {
        TextView* textView = static_cast<TextView*>(JSObjectGetPrivate(object));
        return JSValueMakeNumber(ctx, textView->getTextSize());
    } else if (propName == "setTextGradient") {
        JSValueRef value = JSObjectGetPrototype(ctx, object);
        JSObjectRef method = JSValueToObject(ctx, value, exception);
        return JSObjectGetProperty(ctx, method, propertyName, exception);
    } else if (propName == "text") {
        TextView* textView = static_cast<TextView*>(JSObjectGetPrivate(object));
        return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(textView->getText().c_str()));
    }
    return JSViewBinding::ViewGetProperty(ctx, object, propertyName, exception);
}

bool JSTextViewBinding::TextViewSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception) {
    auto propName = JSStringToStdString(propertyName);
    if (propName == "textColor") {
        TextView* textView = static_cast<TextView*>(JSObjectGetPrivate(object));
        JSStringRef jsString = JSValueToStringCopy(ctx, value, nullptr);
        textView->setTextColor(JSStringToStdString(jsString).c_str());
        JSStringRelease(jsString);
        return true;
    } else if (propName == "textSize") {
        TextView* textView = static_cast<TextView*>(JSObjectGetPrivate(object));
        textView->setTextSize(JSValueToNumber(ctx, value, nullptr));
        return true;
    } else if (propName == "text") {
        TextView* textView = static_cast<TextView*>(JSObjectGetPrivate(object));
        JSStringRef jsString = JSValueToStringCopy(ctx, value, nullptr);
        textView->setText(JSStringToStdString(jsString).c_str());
        JSStringRelease(jsString);
        return true;
    }
    return JSViewBinding::ViewSetProperty(ctx, object, propertyName, value, exception);
}

static JSValueRef setTextGradient(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 2);
    TextView* textView = static_cast<TextView*>(JSObjectGetPrivate(thisObject));
    std::vector<SkColor> colors;
    JSObjectRef posArray = JSValueToObject(ctx, arguments[0], exception);
    if (posArray && JSValueIsObject(ctx, posArray)) {
        JSStringRef lengthStr = JSStringCreateWithUTF8CString("length");
        JSValueRef lengthVal = JSObjectGetProperty(ctx, posArray, lengthStr, exception);
        JSStringRelease(lengthStr);
        size_t posLength = (size_t)JSValueToNumber(ctx, lengthVal, exception);
        for (unsigned int i = 0; i < posLength; i++) {
            JSValueRef posVal = JSObjectGetPropertyAtIndex(ctx, posArray, i, exception);
            auto hexColor = JSViewBinding::JSStringToStdString(JSValueToStringCopy(ctx, posVal, exception));
            int r, g, b, a;
            hexToRGBA(hexColor, r, g, b, a);
            colors.push_back(SkColorSetARGB(a, r, g, b));
        }
    }
    std::vector<float> positions;
    JSObjectRef posArray1 = JSValueToObject(ctx, arguments[1], exception);
    if (posArray1 && JSValueIsObject(ctx, posArray1)) {
        JSStringRef lengthStr = JSStringCreateWithUTF8CString("length");
        JSValueRef lengthVal = JSObjectGetProperty(ctx, posArray1, lengthStr, exception);
        JSStringRelease(lengthStr);
        size_t posLength = (size_t)JSValueToNumber(ctx, lengthVal, exception);
        for (unsigned int i = 0; i < posLength; i++) {
            JSValueRef posVal = JSObjectGetPropertyAtIndex(ctx, posArray1, i, exception);
            float position = (float)JSValueToNumber(ctx, posVal, exception);
            positions.push_back(position);
        }
    }
    textView->setTextGradient(colors, positions);
    return JSValueMakeUndefined(ctx);
}

void JSTextViewBinding::registerTextView(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext> &context) {
    JSStringRef className = JSStringCreateWithUTF8CString("TextView");
    static JSClassDefinition TextViewClassDef = {
        0, kJSClassAttributeNone,
        "TextView", nullptr, nullptr,
        nullptr, nullptr, TextViewFinalize, nullptr, TextViewGetProperty, TextViewSetProperty,
        nullptr, nullptr, nullptr,
        nullptr, nullptr, nullptr
    };
    sTextViewClass = JSClassCreate(&TextViewClassDef);
    JSObjectRef constructor = JSObjectMakeConstructor(ctx, sTextViewClass, TextViewConstructor);
    
    JSStringRef protoName = JSStringCreateWithUTF8CString("prototype");
    JSValueRef textViewProtoValue = JSObjectGetProperty(ctx, constructor, protoName, nullptr);
    JSObjectRef textViewPrototype = JSValueToObject(ctx, textViewProtoValue, nullptr);
    
    // 3. 手动添加原型方法
    JSStringRef setTextGradientName = JSStringCreateWithUTF8CString("setTextGradient");
    JSObjectRef setTextGradientFunc = JSObjectMakeFunctionWithCallback(ctx, setTextGradientName, setTextGradient);
    JSObjectSetProperty(ctx, textViewPrototype, setTextGradientName, setTextGradientFunc, kJSPropertyAttributeReadOnly, nullptr);
    JSStringRelease(setTextGradientName);
    
    // 4. 显式继承View原型
    JSStringRef viewName = JSStringCreateWithUTF8CString("View");
    JSValueRef viewConstructorVal = JSObjectGetProperty(ctx, SkiaUI, viewName, nullptr);
    JSObjectRef viewConstructor = JSValueToObject(ctx, viewConstructorVal, nullptr);
    JSValueRef viewProtoVal = JSObjectGetProperty(ctx, viewConstructor, protoName, nullptr);
    JSObjectRef viewProto = JSValueToObject(ctx, viewProtoVal, nullptr);
    JSStringRelease(viewName);
    
    // 设置 ViewGroup.prototype 的原型为 View.prototype
    JSObjectSetPrototype(ctx, textViewPrototype, viewProto);
    JSStringRelease(protoName);
    
    JSObjectSetProperty(ctx, SkiaUI, className, constructor, kJSPropertyAttributeNone, nullptr);
    JSStringRelease(className);
}

}




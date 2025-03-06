#include "JSImageViewBinding.h"
#include "ImageView.h"
#include "JSSkiaUIContext.h"
#include "w3c_util.h"

namespace HYSkiaUI {

static JSClassRef sImageViewClass = nullptr;

static JSObjectRef ImageViewConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
    ImageView* imageView = new ImageView();
    imageView->setContext(JSSkiaUIContext::getInstance()->getUIContext());
    return JSObjectMake(ctx, sImageViewClass, imageView);
}

static void ImageViewFinalize(JSObjectRef object) {
    
}

JSValueRef JSImageViewBinding::ImageViewGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception) {
    auto propName = JSStringToStdString(propertyName);
    if (propName == "src") {
        ImageView* imageView = static_cast<ImageView*>(JSObjectGetPrivate(object));
        return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(imageView->getSource()));
    } else if (propName == "objectFill") {
        ImageView* imageView = static_cast<ImageView*>(JSObjectGetPrivate(object));
        return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(scaleTypeToW3c(imageView->getScaleType())));
    }
    return JSViewBinding::ViewGetProperty(ctx, object, propertyName, exception);
}

bool JSImageViewBinding::ImageViewSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception) {
    auto propName = JSStringToStdString(propertyName);
    if (propName == "src") {
        ImageView* imageView = static_cast<ImageView*>(JSObjectGetPrivate(object));
        JSStringRef jsString = JSValueToStringCopy(ctx, value, nullptr);
        imageView->setSource(JSStringToStdString(jsString).c_str());
        JSStringRelease(jsString);
        return true;
    } else if (propName == "objectFill") {
        ImageView* imageView = static_cast<ImageView*>(JSObjectGetPrivate(object));
        JSStringRef jsString = JSValueToStringCopy(ctx, value, nullptr);
        imageView->setScaleType(W3CToScaleType(JSStringToStdString(jsString).c_str()));
        JSStringRelease(jsString);
        return true;
    } else if (propName == "blur") {
        ImageView* imageView = static_cast<ImageView*>(JSObjectGetPrivate(object));
        imageView->blur(JSValueToNumber(ctx, value, exception));
        return true;
    }
    return JSViewBinding::ViewSetProperty(ctx, object, propertyName, value, exception);
}

static JSValueRef start(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 0);
    ImageView* imageView = static_cast<ImageView*>(JSObjectGetPrivate(thisObject));
    imageView->start();
    return JSValueMakeUndefined(ctx);
}

static JSValueRef pause(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 0);
    ImageView* imageView = static_cast<ImageView*>(JSObjectGetPrivate(thisObject));
    imageView->pause();
    return JSValueMakeUndefined(ctx);
}

void JSImageViewBinding::registerImageView(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext> &context) {
    JSStringRef className = JSStringCreateWithUTF8CString("ImageView");
    static JSClassDefinition ImageViewClassDef = {
        0, kJSClassAttributeNone,
        "ImageView", nullptr, nullptr,
        nullptr, nullptr, ImageViewFinalize, nullptr, ImageViewGetProperty, ImageViewSetProperty,
        nullptr, nullptr, nullptr,
        nullptr, nullptr, nullptr
    };
    sImageViewClass = JSClassCreate(&ImageViewClassDef);
    JSObjectRef constructor = JSObjectMakeConstructor(ctx, sImageViewClass, ImageViewConstructor);
    
    JSStringRef protoName = JSStringCreateWithUTF8CString("prototype");
    JSValueRef imageViewProtoValue = JSObjectGetProperty(ctx, constructor, protoName, nullptr);
    JSObjectRef imageViewPrototype = JSValueToObject(ctx, imageViewProtoValue, nullptr);
    
    // 3. 手动添加原型方法
    JSStringRef startName = JSStringCreateWithUTF8CString("start");
    JSObjectRef startFunc = JSObjectMakeFunctionWithCallback(ctx, startName, start);
    JSObjectSetProperty(ctx, imageViewPrototype, startName, startFunc, kJSPropertyAttributeReadOnly, nullptr);
    JSStringRelease(startName);
    JSStringRef pauseName = JSStringCreateWithUTF8CString("pause");
    JSObjectRef pauseFunc = JSObjectMakeFunctionWithCallback(ctx, pauseName, pause);
    JSObjectSetProperty(ctx, imageViewPrototype, pauseName, pauseFunc, kJSPropertyAttributeReadOnly, nullptr);
    JSStringRelease(pauseName);
    
    // 4. 显式继承View原型
    JSStringRef viewName = JSStringCreateWithUTF8CString("View");
    JSValueRef viewConstructorVal = JSObjectGetProperty(ctx, SkiaUI, viewName, nullptr);
    JSObjectRef viewConstructor = JSValueToObject(ctx, viewConstructorVal, nullptr);
    JSValueRef viewProtoVal = JSObjectGetProperty(ctx, viewConstructor, protoName, nullptr);
    JSObjectRef viewProto = JSValueToObject(ctx, viewProtoVal, nullptr);
    JSStringRelease(viewName);
    
    // 设置 ViewGroup.prototype 的原型为 View.prototype
    JSObjectSetPrototype(ctx, imageViewPrototype, viewProto);
    JSStringRelease(protoName);
    
    JSObjectSetProperty(ctx, SkiaUI, className, constructor, kJSPropertyAttributeNone, nullptr);
    JSStringRelease(className);
}

}





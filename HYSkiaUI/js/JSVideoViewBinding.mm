#include "JSVideoViewBinding.h"
#include "YUVVideoView.h"
#include "JSSkiaUIContext.h"
#include "w3c_util.h"

namespace HYSkiaUI {

static JSClassRef sVideoViewClass = nullptr;

static JSObjectRef VideoViewConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
    YUVVideoView* videoView = new YUVVideoView();
    videoView->setContext(JSSkiaUIContext::getInstance()->getUIContext());
    return JSObjectMake(ctx, sVideoViewClass, videoView);
}

static void VideoViewFinalize(JSObjectRef object) {
    
}

JSValueRef JSVideoViewBinding::VideoViewGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception) {
    auto propName = JSStringToStdString(propertyName);
    if (propName == "src") {
        YUVVideoView* videoView = static_cast<YUVVideoView*>(JSObjectGetPrivate(object));
        return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(videoView->getSource()));
    } else if (propName == "start" || propName == "pause") {
        JSValueRef value = JSObjectGetPrototype(ctx, object);
        JSObjectRef method = JSValueToObject(ctx, value, exception);
        return JSObjectGetProperty(ctx, method, propertyName, exception);
    }
    return JSViewBinding::ViewGetProperty(ctx, object, propertyName, exception);
}

bool JSVideoViewBinding::VideoViewSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception) {
    auto propName = JSStringToStdString(propertyName);
    if (propName == "src") {
        YUVVideoView* videoView = static_cast<YUVVideoView*>(JSObjectGetPrivate(object));
        JSStringRef jsString = JSValueToStringCopy(ctx, value, nullptr);
        videoView->setSource(JSStringToStdString(jsString).c_str());
        JSStringRelease(jsString);
        return true;
    }
    return JSViewBinding::ViewSetProperty(ctx, object, propertyName, value, exception);
}

static JSValueRef start(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 0);
    YUVVideoView* videoView = static_cast<YUVVideoView*>(JSObjectGetPrivate(thisObject));
    videoView->start();
    return JSValueMakeUndefined(ctx);
}

static JSValueRef pause(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 0);
    YUVVideoView* videoView = static_cast<YUVVideoView*>(JSObjectGetPrivate(thisObject));
    videoView->pause();
    return JSValueMakeUndefined(ctx);
}

void JSVideoViewBinding::registerVideoView(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext> &context) {
    JSStringRef className = JSStringCreateWithUTF8CString("VideoView");
    static JSClassDefinition VideoViewClassDef = {
        0, kJSClassAttributeNone,
        "VideoView", nullptr, nullptr,
        nullptr, nullptr, VideoViewFinalize, nullptr, VideoViewGetProperty, VideoViewSetProperty,
        nullptr, nullptr, nullptr,
        nullptr, nullptr, nullptr
    };
    sVideoViewClass = JSClassCreate(&VideoViewClassDef);
    JSObjectRef constructor = JSObjectMakeConstructor(ctx, sVideoViewClass, VideoViewConstructor);
    
    JSStringRef protoName = JSStringCreateWithUTF8CString("prototype");
    JSValueRef videoViewProtoValue = JSObjectGetProperty(ctx, constructor, protoName, nullptr);
    JSObjectRef videoViewPrototype = JSValueToObject(ctx, videoViewProtoValue, nullptr);
    
    // 3. 手动添加原型方法
    JSStringRef startName = JSStringCreateWithUTF8CString("start");
    JSObjectRef startFunc = JSObjectMakeFunctionWithCallback(ctx, startName, start);
    JSObjectSetProperty(ctx, videoViewPrototype, startName, startFunc, kJSPropertyAttributeReadOnly, nullptr);
    JSStringRelease(startName);
    JSStringRef pauseName = JSStringCreateWithUTF8CString("pause");
    JSObjectRef pauseFunc = JSObjectMakeFunctionWithCallback(ctx, pauseName, pause);
    JSObjectSetProperty(ctx, videoViewPrototype, pauseName, pauseFunc, kJSPropertyAttributeReadOnly, nullptr);
    JSStringRelease(pauseName);
    
    // 4. 显式继承View原型
    JSStringRef viewName = JSStringCreateWithUTF8CString("View");
    JSValueRef viewConstructorVal = JSObjectGetProperty(ctx, SkiaUI, viewName, nullptr);
    JSObjectRef viewConstructor = JSValueToObject(ctx, viewConstructorVal, nullptr);
    JSValueRef viewProtoVal = JSObjectGetProperty(ctx, viewConstructor, protoName, nullptr);
    JSObjectRef viewProto = JSValueToObject(ctx, viewProtoVal, nullptr);
    JSStringRelease(viewName);
    
    // 设置 ViewGroup.prototype 的原型为 View.prototype
    JSObjectSetPrototype(ctx, videoViewPrototype, viewProto);
    JSStringRelease(protoName);
    
    JSObjectSetProperty(ctx, SkiaUI, className, constructor, kJSPropertyAttributeNone, nullptr);
    JSStringRelease(className);
}

}



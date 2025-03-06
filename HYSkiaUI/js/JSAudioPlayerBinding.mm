#include "JSAudioPlayerBinding.h"
#include "JSAudioPlayer.h"
#include "JSSkiaUIContext.h"
#include "w3c_util.h"

namespace HYSkiaUI {

static JSClassRef sAudioPlayerClass = nullptr;

static JSObjectRef AudioPlayerConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
    assert(argc == 1);
    JSStringRef jsString = JSValueToStringCopy(ctx, argv[0], nullptr);
    JSAudioPlayer *audioPlayer = new JSAudioPlayer(JSViewBinding::JSStringToStdString(jsString).c_str());
    return JSObjectMake(ctx, sAudioPlayerClass, audioPlayer);
}

static void AudioPlayerFinalize(JSObjectRef object) {
    JSAudioPlayer* player = static_cast<JSAudioPlayer*>(JSObjectGetPrivate(object));
    delete player;
}

JSValueRef JSAudioPlayerBinding::AudioPlayerGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception) {
    std::string propName = JSViewBinding::JSStringToStdString(propertyName);
    if (propName == "start" || propName == "pause" || propName == "release" || propName == "getCurrentPosition") {
        JSValueRef value = JSObjectGetPrototype(ctx, object);
        JSObjectRef method = JSValueToObject(ctx, value, exception);
        return JSObjectGetProperty(ctx, method, propertyName, exception);
    }
    return JSValueMakeUndefined(ctx);
}

bool JSAudioPlayerBinding::AudioPlayerSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception) {
    return false;
}

static JSValueRef start(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 0);
    JSAudioPlayer* player = static_cast<JSAudioPlayer*>(JSObjectGetPrivate(thisObject));
    player->play();
    return JSValueMakeUndefined(ctx);
}

static JSValueRef pause(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 0);
    JSAudioPlayer* player = static_cast<JSAudioPlayer*>(JSObjectGetPrivate(thisObject));
    player->pause();
    return JSValueMakeUndefined(ctx);
}

static JSValueRef release(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 0);
    JSAudioPlayer* player = static_cast<JSAudioPlayer*>(JSObjectGetPrivate(thisObject));
    player->releasePlayer();
    return JSValueMakeUndefined(ctx);
}

static JSValueRef getCurrentPosition(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 0);
    JSAudioPlayer* player = static_cast<JSAudioPlayer*>(JSObjectGetPrivate(thisObject));
    return JSValueMakeNumber(ctx, player->getCurrPosition());
}

void JSAudioPlayerBinding::registerAudioPlayer(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext> &context) {
    JSStringRef className = JSStringCreateWithUTF8CString("AudioPlayer");
    static JSClassDefinition AudioPlayerClassDef = {
        0, kJSClassAttributeNone,
        "AudioPlayer", nullptr, nullptr,
        nullptr, nullptr, AudioPlayerFinalize, nullptr, AudioPlayerGetProperty, AudioPlayerSetProperty,
        nullptr, nullptr, nullptr,
        nullptr, nullptr, nullptr
    };
    sAudioPlayerClass = JSClassCreate(&AudioPlayerClassDef);
    JSObjectRef constructor = JSObjectMakeConstructor(ctx, sAudioPlayerClass, AudioPlayerConstructor);
    JSStringRef protoName = JSStringCreateWithUTF8CString("prototype");
    JSValueRef viewProtoValue = JSObjectGetProperty(ctx, constructor, protoName, nullptr);
    JSObjectRef viewPrototype = JSValueToObject(ctx, viewProtoValue, nullptr);
    // 3. 手动添加原型方法
    JSStringRef startName = JSStringCreateWithUTF8CString("start");
    JSObjectRef startFunc = JSObjectMakeFunctionWithCallback(ctx, startName, start);
    JSObjectSetProperty(ctx, viewPrototype, startName, startFunc, kJSPropertyAttributeReadOnly, nullptr);
    JSStringRelease(startName);
    JSStringRef pauseName = JSStringCreateWithUTF8CString("pause");
    JSObjectRef pauseFunc = JSObjectMakeFunctionWithCallback(ctx, pauseName, pause);
    JSObjectSetProperty(ctx, viewPrototype, pauseName, pauseFunc, kJSPropertyAttributeReadOnly, nullptr);
    JSStringRelease(pauseName);
    JSStringRef releaseName = JSStringCreateWithUTF8CString("release");
    JSObjectRef releaseFunc = JSObjectMakeFunctionWithCallback(ctx, releaseName, pause);
    JSObjectSetProperty(ctx, viewPrototype, releaseName, releaseFunc, kJSPropertyAttributeReadOnly, nullptr);
    JSStringRelease(releaseName);
    JSStringRef getCurrPosName = JSStringCreateWithUTF8CString("getCurrentPosition");
    JSObjectRef getCurrPosFunc = JSObjectMakeFunctionWithCallback(ctx, getCurrPosName, getCurrentPosition);
    JSObjectSetProperty(ctx, viewPrototype, getCurrPosName, getCurrPosFunc, kJSPropertyAttributeReadOnly, nullptr);
    JSStringRelease(getCurrPosName);
    
    JSObjectSetProperty(ctx, SkiaUI, className, constructor, kJSPropertyAttributeNone, nullptr);
    JSStringRelease(className);
}

}



#include "JSFileBinding.h"
#include "JSSkiaUIContext.h"
#include "w3c_util.h"
#include "JSFile.h"

namespace HYSkiaUI {

static JSClassRef sFileClass = nullptr;

static JSObjectRef FileConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
    assert(argc == 1);
    JSStringRef jsString = JSValueToStringCopy(ctx, argv[0], nullptr);
    JSFile* file = new JSFile(JSSkiaUIContext::getInstance()->getUIContext(), JSViewBinding::JSStringToStdString(jsString).c_str());
    return JSObjectMake(ctx, sFileClass, file);
}

static void FileFinalize(JSObjectRef object) {
    JSFile* file = static_cast<JSFile*>(JSObjectGetPrivate(object));
    delete file;
}

JSValueRef JSFileBinding::FileGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception) {
    std::string propName = JSViewBinding::JSStringToStdString(propertyName);
    if (propName == "read") {
        JSValueRef value = JSObjectGetPrototype(ctx, object);
        JSObjectRef method = JSValueToObject(ctx, value, exception);
        return JSObjectGetProperty(ctx, method, propertyName, exception);
    }
    return JSValueMakeUndefined(ctx);
}

bool JSFileBinding::FileSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception) {
    return false;
}

static JSValueRef read(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
    assert(argumentCount == 0);
    JSFile* file = static_cast<JSFile*>(JSObjectGetPrivate(thisObject));
    return JSValueMakeString(ctx, JSStringCreateWithUTF8CString(file->read()));
}

void JSFileBinding::registerFile(JSGlobalContextRef ctx, JSObjectRef SkiaUI, std::shared_ptr<SkiaUIContext> &context) {
    JSStringRef className = JSStringCreateWithUTF8CString("File");
    static JSClassDefinition FileClassDef = {
        0, kJSClassAttributeNone,
        "File", nullptr, nullptr,
        nullptr, nullptr, FileFinalize, nullptr, FileGetProperty, FileSetProperty,
        nullptr, nullptr, nullptr,
        nullptr, nullptr, nullptr
    };
    sFileClass = JSClassCreate(&FileClassDef);
    JSObjectRef constructor = JSObjectMakeConstructor(ctx, sFileClass, FileConstructor);
    JSStringRef protoName = JSStringCreateWithUTF8CString("prototype");
    JSValueRef viewProtoValue = JSObjectGetProperty(ctx, constructor, protoName, nullptr);
    JSObjectRef viewPrototype = JSValueToObject(ctx, viewProtoValue, nullptr);
    // 3. 手动添加原型方法
    JSStringRef readName = JSStringCreateWithUTF8CString("read");
    JSObjectRef readFunc = JSObjectMakeFunctionWithCallback(ctx, readName, read);
    JSObjectSetProperty(ctx, viewPrototype, readName, readFunc, kJSPropertyAttributeReadOnly, nullptr);
    JSStringRelease(readName);
    
    JSObjectSetProperty(ctx, JSContextGetGlobalObject(ctx), className, constructor, kJSPropertyAttributeNone, nullptr);
    JSStringRelease(className);
}

}




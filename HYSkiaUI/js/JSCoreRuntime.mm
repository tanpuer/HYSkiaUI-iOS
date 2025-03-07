#include "JSCoreRuntime.h"
#include "native_log.h"
#include "View.h"
#include "ViewGroup.h"
#include "TextView.h"
#include "Page.h"
#include "FlexboxLayout.h"
#include "ScrollView.h"

namespace HYSkiaUI {

JSCoreRuntime::JSCoreRuntime(std::shared_ptr<SkiaUIContext>& context) {
    this->context = context;
    jsContext = [[JSContext alloc]init];
    jsContext.exceptionHandler = ^(JSContext *ctx, JSValue *exception) {
        NSLog(@"JS Error: %@", exception);
    };
    injectConsole();
    injectPerformance();
    injectFrameCallback();
    injectTimer();
    injectViews();
    injectBackPressedCallback();
}

JSCoreRuntime::~JSCoreRuntime() {
    
}

void JSCoreRuntime::evaluateJavaScript(const char* code) {
    [jsContext evaluateScript:[NSString stringWithUTF8String:code]];
}

void JSCoreRuntime::invokeFrameCallback() {
    auto ctx = jsContext.JSGlobalContextRef;
    for (auto& item: frameCallbackMap) {
        JSObjectCallAsFunction(ctx, JSValueToObject(ctx, item.second.JSValueRef, nullptr), nullptr, 0, nullptr, nullptr);
    }
}

void JSCoreRuntime::injectConsole() {
    jsContext[@"console"] = @{
        @"log": ^(JSValue *args, ...) {
            NSMutableArray *messages = [NSMutableArray array];
            for (JSValue *arg in [JSContext currentArguments]) {
                if ([arg isUndefined] || [arg isNull]) {
                    [messages addObject:@"null"];
                } else if ([arg isBoolean]) {
                    [messages addObject:[arg toBool] ? @"true" : @"false"];
                } else if ([arg isNumber]) {
                    [messages addObject:[arg toString]];
                } else if ([arg isString]) {
                    [messages addObject:[arg toString]];
                } else if ([arg isArray]) {
                    [messages addObject:[NSString stringWithFormat:@"Array(%@)", [arg toString]]];
                } else {
                    [messages addObject:@"[Object]"];
                }
            }
            // 将所有参数用空格连接
            NSString *message = [messages componentsJoinedByString:@" "];
            NSLog(@"JS Log: %@", message);
        },
        
        @"error": ^(JSValue *args, ...) {
            NSMutableArray *messages = [NSMutableArray array];
            for (JSValue *arg in [JSContext currentArguments]) {
                [messages addObject:[arg toString]];
            }
            NSString *message = [messages componentsJoinedByString:@" "];
            NSLog(@"JS Error: %@", message);
        },
        
        @"warn": ^(JSValue *args, ...) {
            NSMutableArray *messages = [NSMutableArray array];
            for (JSValue *arg in [JSContext currentArguments]) {
                [messages addObject:[arg toString]];
            }
            NSString *message = [messages componentsJoinedByString:@" "];
            NSLog(@"JS Warn: %@", message);
        },
        
        @"info": ^(JSValue *args, ...) {
            NSMutableArray *messages = [NSMutableArray array];
            for (JSValue *arg in [JSContext currentArguments]) {
                [messages addObject:[arg toString]];
            }
            NSString *message = [messages componentsJoinedByString:@" "];
            NSLog(@"JS Info: %@", message);
        }
    };
}

void JSCoreRuntime::injectPerformance() {
    jsContext[@"performance"] = @{
        @"now": ^long() {
            return [[NSDate date] timeIntervalSince1970] * 1000.0;
        }
    };
}

void JSCoreRuntime::injectFrameCallback() {
    jsContext[@"requestAnimationFrame"] = ^long(JSValue *callback) {
        auto callbackId = FRAME_INDEX++;
        JSValueProtect(jsContext.JSGlobalContextRef, callback.JSValueRef);
        frameCallbackMap.emplace(callbackId, callback);
        return callbackId;
    };
    jsContext[@"cancelAnimationFrame"] = ^(long index) {
        auto itr = frameCallbackMap.find(index);
        if (itr != frameCallbackMap.end()) {
            JSValueUnprotect(jsContext.JSGlobalContextRef, itr->second.JSValueRef);
            frameCallbackMap.erase(index);
        }
    };
}

void JSCoreRuntime::injectTimer() {
    jsContext[@"setTimeout"] = ^long(JSValue *callback, long timeout) {
        auto callbackId = TIMER_INDEX++;
        timerCallbackMap.emplace(callbackId, callback);
        context->setTimer([callbackId, this]() {
            auto itr = timerCallbackMap.find(callbackId);
            if (itr != timerCallbackMap.end()) {
                [itr->second callWithArguments:nil];
            }
        }, timeout, false);
        return callbackId;
    };
    jsContext[@"clearTimeout"] = ^(long index) {
        if (timerCallbackMap.find(index) != timerCallbackMap.end()) {
            timerCallbackMap.erase(index);
        }
    };
}

void JSCoreRuntime::injectViews() {
    auto ctx = jsContext.JSGlobalContextRef;
    auto SkiaUI = JSObjectMake(ctx, NULL, NULL);
    JSObjectSetProperty(ctx, JSContextGetGlobalObject(ctx), JSStringCreateWithUTF8CString("SkiaUI"), SkiaUI, kJSPropertyAttributeNone, NULL);
    jsContext[@"SkiaUI"][@"innerWidth"] = @(context->getWidth());
    jsContext[@"SkiaUI"][@"innerHeight"] = @(context->getHeight());
    jsEnterExitInfo = std::make_unique<JSEnterExitInfo>();
    jsEnterExitInfo->registerView(ctx, SkiaUI, context);
    
    jsViewBinding = std::make_unique<JSViewBinding>();
    jsViewBinding->registerView(ctx, SkiaUI, context);
    jsViewGroupBinding = std::make_unique<JSViewGroupBinding>();
    jsViewGroupBinding->registerViewGroup(ctx, SkiaUI, context);
    jsPageBinding = std::make_unique<JSPageBinding>();
    jsPageBinding->registerPage(ctx, SkiaUI, context);
    jsFlexboxLayoutBinding = std::make_unique<JSFlexboxLayoutBinding>();
    jsFlexboxLayoutBinding->registerFlexboxLayout(ctx, SkiaUI, context);
    jsScrollViewBinding = std::make_unique<JSScrollViewBinding>();
    jsScrollViewBinding->registerScrollView(ctx, SkiaUI, context);
    jsLottieBinding = std::make_unique<JSLottieBinding>();
    jsLottieBinding->registerLottie(ctx, SkiaUI, context);
    jsVideoViewBinding = std::make_unique<JSVideoViewBinding>();
    jsVideoViewBinding->registerVideoView(ctx, SkiaUI, context);
    jsTextViewBinding = std::make_unique<JSTextViewBinding>();
    jsTextViewBinding->registerTextView(ctx, SkiaUI, context);
    jsButtonBinding = std::make_unique<JSButtonBinding>();
    jsButtonBinding->registerButton(ctx, SkiaUI, context);
    jsImageViewBinding = std::make_unique<JSImageViewBinding>();
    jsImageViewBinding->registerImageView(ctx, SkiaUI, context);
    jsSVGBinding = std::make_unique<JSSVGBinding>();
    jsSVGBinding->registerSVG(ctx, SkiaUI, context);
    jsShaderViewBinding = std::make_unique<JSShaderViewBinding>();
    jsShaderViewBinding->registerShaderView(ctx, SkiaUI, context);
    jsLinearAnimatorBinding = std::make_unique<JSLinearAnimatorBinding>();
    jsLinearAnimatorBinding->registerLinearAnimator(ctx, SkiaUI, context);
    jsAudioPlayerBinding = std::make_unique<JSAudioPlayerBinding>();
    jsAudioPlayerBinding->registerAudioPlayer(ctx, SkiaUI, context);
    jsFileBinding = std::make_unique<JSFileBinding>();
    jsFileBinding->registerFile(ctx, SkiaUI, context);
}

void JSCoreRuntime::injectBackPressedCallback() {
    context->setBackPressedInterceptor([this](){
        auto ctx = jsContext.JSGlobalContextRef;
        for (auto& item: backPressedCallbackMap) {
            JSObjectCallAsFunction(ctx, JSValueToObject(ctx, item.second.JSValueRef, nullptr), nullptr, 0, nullptr, nullptr);
        }
    });
    jsContext[@"SkiaUI"][@"setBackPressedCallback"] = ^long(JSValue *callback) {
        auto callbackId = BACK_PRESSED_INDEX++;
        JSValueProtect(jsContext.JSGlobalContextRef, callback.JSValueRef);
        backPressedCallbackMap.emplace(callbackId, callback);
        return callbackId;
    };
}

}

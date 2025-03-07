#pragma once

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#include "unordered_map"
#include "SkiaUIContext.h"
#include "JSEnterExitInfo.h"
#include "JSViewBinding.h"
#include "JSViewGroupBinding.h"
#include "JSPageBinding.h"
#include "JSFlexboxLayoutBinding.h"
#include "JSScrollViewBinding.h"
#include "JSLottieBinding.h"
#include "JSVideoViewBinding.h"
#include "JSTextViewBinding.h"
#include "JSButtonBinding.h"
#include "JSImageViewBinding.h"
#include "JSSVGBinding.h"
#include "JSShaderViewBinding.h"
#include "JSLinearAnimatorBinding.h"
#include "JSAudioPlayerBinding.h"
#include "JSFileBinding.h"

namespace HYSkiaUI {

class JSCoreRuntime {
    
public:
    
    JSCoreRuntime(std::shared_ptr<SkiaUIContext>& context);
    
    ~JSCoreRuntime();
    
    void evaluateJavaScript(const char* code);
    
    void invokeFrameCallback();
    
private:
    
    void injectConsole();
    
    void injectPerformance();
    
    void injectFrameCallback();
    
    void injectTimer();
    
    void injectViews();
    
    void injectBackPressedCallback();
    
private:
    
    JSContext* jsContext = nullptr;
    
    std::shared_ptr<SkiaUIContext> context = nullptr;
    
    long FRAME_INDEX = 0;
    
    std::unordered_map<long, JSValue*> frameCallbackMap;
    
    long TIMER_INDEX = 0;
    
    std::unordered_map<long, JSValue*> timerCallbackMap;
    
    long BACK_PRESSED_INDEX = 0;
    
    std::unordered_map<long, JSValue*> backPressedCallbackMap;
    
private:
    
    std::unique_ptr<JSEnterExitInfo> jsEnterExitInfo;
    
    std::unique_ptr<JSViewBinding> jsViewBinding;
    std::unique_ptr<JSViewGroupBinding> jsViewGroupBinding;
    std::unique_ptr<JSPageBinding> jsPageBinding;
    std::unique_ptr<JSFlexboxLayoutBinding> jsFlexboxLayoutBinding;
    std::unique_ptr<JSScrollViewBinding> jsScrollViewBinding;
    std::unique_ptr<JSLottieBinding> jsLottieBinding;
    std::unique_ptr<JSVideoViewBinding> jsVideoViewBinding;
    std::unique_ptr<JSTextViewBinding> jsTextViewBinding;
    std::unique_ptr<JSButtonBinding> jsButtonBinding;
    std::unique_ptr<JSImageViewBinding> jsImageViewBinding;
    std::unique_ptr<JSSVGBinding> jsSVGBinding;
    std::unique_ptr<JSShaderViewBinding> jsShaderViewBinding;
    std::unique_ptr<JSLinearAnimatorBinding> jsLinearAnimatorBinding;
    std::unique_ptr<JSAudioPlayerBinding> jsAudioPlayerBinding;
    std::unique_ptr<JSFileBinding> jsFileBinding;
    
};

}

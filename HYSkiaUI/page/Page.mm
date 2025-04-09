#include "Page.h"
#include "core/SkPictureRecorder.h"
#include "core/SkPicture.h"
#include "LinearAnimator.h"
#include "TranslateAnimator.h"
#include "PageStackManager.h"
#include "core/SkColorFilter.h"
//#include "PluginManager.h"

namespace HYSkiaUI {

Page::Page() {
    pageId = PAGE_ID++;
    ALOGD("Page create %d", pageId)
    pagePaint = std::make_unique<SkPaint>();
}


void Page::setContext(std::shared_ptr<SkiaUIContext>& context) {
    View::setContext(context);
    setBackgroundColor(SK_ColorTRANSPARENT);
    if (ctx && jsOnCreateCallback) {
        JSObjectCallAsFunction(ctx, JSValueToObject(ctx, jsOnCreateCallback, nullptr), nullptr, 0, nullptr, nullptr);
    }
}

Page::~Page() {
    ALOGD("page destroy %d", pageId)
    if (ctx && jsOnDestroyCallback) {
        JSObjectCallAsFunction(ctx, JSValueToObject(ctx, jsOnDestroyCallback, nullptr), nullptr, 0, nullptr, nullptr);
        JSValueUnprotect(ctx, jsOnDestroyCallback);
        jsOnDestroyCallback = nullptr;
    }
    if (ctx && jsOnCreateCallback) {
        JSValueUnprotect(ctx, jsOnCreateCallback);
        jsOnCreateCallback = nullptr;
    }
    if (ctx && jsOnShowCallback) {
        JSValueUnprotect(ctx, jsOnShowCallback);
        jsOnShowCallback = nullptr;
    }
    if (ctx && jsOnDestroyCallback) {
        JSValueUnprotect(ctx, jsOnDestroyCallback);
        jsOnDestroyCallback = nullptr;
    }
}

void Page::enterFromRight(const EnterExitInfo &info) {
    ALOGD("enterFromRight %d %d %d", info.from, info.to, info.duration)
    auto animator = new TranslateAnimator(this, info.from, info.to, 0, 0);
    animator->setDuration(info.duration);
    animator->addListener([this]() {
        context->getPageStackManager()->hideLastPage();
    });
    animator->start();
    context->getPageStackManager()->showCurrentPage();
    //    context->getPluginManager()->invokeMethod("toast", "show", "push");
    markDirty();
}

void Page::exitToLeft(const EnterExitInfo &info) {
    ALOGD("exitToLeft %d %d %d", info.from, info.to, info.duration)
    auto animator = new TranslateAnimator(this, info.from, info.to, 0, 0);
    animator->setDuration(info.duration);
    animator->addListener([this]() {
        this->markDestroyed = true;
    });
    animator->start();
    context->getPageStackManager()->showLastPage();
    //    context->getPluginManager()->invokeMethod("toast", "show", "pop");
    markDirty();
}

void Page::enterFromBottom(const Page::EnterExitInfo &info) {
    ALOGD("enterFromBottom %d %d %d", info.from, info.to, info.duration)
    auto animator = new TranslateAnimator(this, 0, 0, info.from, info.to);
    animator->setDuration(info.duration);
    animator->addListener([this]() {
        context->getPageStackManager()->hideLastPage();
    });
    animator->start();
    context->getPageStackManager()->showCurrentPage();
    //    context->getPluginManager()->invokeMethod("toast", "show", "push");
    markDirty();
}

void Page::exitToTop(const Page::EnterExitInfo &info) {
    ALOGD("exitToTop %d %d %d", info.from, info.to, info.duration)
    auto animator = new TranslateAnimator(this, 0, 0, info.from, info.to);
    animator->setDuration(info.duration);
    animator->addListener([this]() {
        this->markDestroyed = true;
    });
    animator->start();
    context->getPageStackManager()->showLastPage();
    //    context->getPluginManager()->invokeMethod("toast", "show", "pop");
    markDirty();
}

void Page::measure() {
    if (!visible) {
        return;
    }
    SkASSERT(children.size() == 1);
    auto root = children[0];
    measureChild(root);
    YGNodeCalculateLayout(node, this->width, this->height, YGDirectionLTR);
}

void Page::layout(int l, int t, int r, int b) {
    if (!visible) {
        return;
    }
    View::layout(l, t, r, b);
    SkASSERT(children.size() == 1);
    auto root = children[0];
    auto left = static_cast<int>(YGNodeLayoutGetLeft(root->getNode()));
    auto top = static_cast<int>(YGNodeLayoutGetTop(root->getNode()));
    auto width = static_cast<int>(YGNodeLayoutGetWidth(root->getNode()));
    auto height = static_cast<int>(YGNodeLayoutGetHeight(root->getNode()));
    root->layout(left + animTranslateX,
                 top + animTranslateY,
                 left + animTranslateX + width,
                 top + animTranslateY + height);
}

void Page::draw(SkCanvas *canvas) {
    if (!visible) {
        return;
    }
    SkPictureRecorder recorder;
    auto skCanvas = recorder.beginRecording(width, height);
    View::draw(skCanvas);
    SkASSERT(children.size() == 1);
    auto root = children[0];
    root->draw(skCanvas);
    auto picture = recorder.finishRecordingAsPicture();
    canvas->save();
    canvas->translate(left, top);
    canvas->drawPicture(picture, nullptr, pagePaint.get());
    canvas->restore();
}

void Page::setVisibility(bool visible) {
    this->visible = visible;
}

bool Page::getVisibility() {
    return visible;
}

void Page::setBlackWhiteMode() {
    auto rowMajor = {
        0.2126f, 0.7152f, 0.0722f, 0.0f, 0.0f,
        0.2126f, 0.7152f, 0.0722f, 0.0f, 0.0f,
        0.2126f, 0.7152f, 0.0722f, 0.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 1.0f, 0.0f
    };
    auto colorFilter = SkColorFilters::Matrix(data(rowMajor));
    pagePaint->setColorFilter(colorFilter);
}

#pragma mark LifeCycle Callback start

void Page::onShow() {
    if (ctx && jsOnShowCallback) {
        JSObjectCallAsFunction(ctx, JSValueToObject(ctx, jsOnShowCallback, nullptr), nullptr, 0, nullptr, nullptr);
    }
    ViewGroup::onShow();
}

void Page::onHide() {
    if (ctx && jsOnHideCallback) {
        JSObjectCallAsFunction(ctx, JSValueToObject(ctx, jsOnHideCallback, nullptr), nullptr, 0, nullptr, nullptr);
    }
    ViewGroup::onHide();
}

bool Page::isDestroyed() {
    return markDestroyed;
}

void Page::pageSizeChange(int width, int height) {
    setWidth(width);
    setHeight(height);
    for (const auto &item: pageChangeCallbackList) {
        item(width, height);
    }
}

void Page::setOnPageSizeChangeListener(std::function<void(int, int)> &&callback) {
    pageChangeCallbackList.emplace_back(std::move(callback));
}

#pragma mark LifeCycle Callback end

#pragma mark JSCallback start

void Page::protectJSOnCreateCallback(JSContextRef ctx, JSObjectRef callback) {
    JSValueProtect(ctx, callback);
    this->ctx = ctx;
    this->jsOnCreateCallback = callback;
}

void Page::protectJSOnDestroyCallback(JSContextRef ctx, JSObjectRef callback) {
    JSValueProtect(ctx, callback);
    this->ctx = ctx;
    this->jsOnDestroyCallback = callback;
}

void Page::protectJSOnShowCallback(JSContextRef ctx, JSObjectRef callback) {
    JSValueProtect(ctx, callback);
    this->ctx = ctx;
    this->jsOnShowCallback = callback;
}

void Page::protectJSOnHideCallback(JSContextRef ctx, JSObjectRef callback) {
    JSValueProtect(ctx, callback);
    this->ctx = ctx;
    this->jsOnHideCallback = callback;
}

#pragma mark JSCallback end

}
